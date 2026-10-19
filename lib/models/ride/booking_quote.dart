import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Validated fare review; only the backend can authorize a booking or payment.
class BookingQuote {
  BookingQuote._(
      this.id,
      this.fingerprint,
      this.pricingRevision,
      this.amountMinor,
      this.bookingSupported,
      this.distanceMeters,
      this.durationSeconds,
      this.surgeMultiplier,
      this.request,
      this.expiresAt,
      this._now,
      this._elapsed,
      this._budget);

  final String id;
  final String fingerprint;
  final String pricingRevision;
  final int amountMinor;
  final bool bookingSupported;
  final double distanceMeters;
  final double durationSeconds;
  final double surgeMultiplier;
  final Map<String, dynamic> request;
  final DateTime expiresAt;
  final DateTime Function() _now;
  final Duration Function() _elapsed;
  Duration _budget;
  Duration? _lastRemaining;
  String get currency => 'usd';

  static final _hash = RegExp(r'^[a-f0-9]{64}$');
  static final _utc =
      RegExp(r'^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d{1,9})?Z$');

  factory BookingQuote.fromJson(Map<String, dynamic> json,
      {DateTime Function()? now,
      Duration Function()? elapsed,
      Duration requestDuration = Duration.zero}) {
    String hash(String name) {
      final value = json[name];
      if (value is! String || !_hash.hasMatch(value)) {
        _invalid();
      }
      return value;
    }

    DateTime timestamp(String name) {
      final value = json[name];
      if (value is! String || !_utc.hasMatch(value)) {
        _invalid();
      }
      final parsed = DateTime.tryParse(value);
      if (parsed == null || !parsed.isUtc) {
        _invalid();
      }
      // Dart normalizes invalid calendar days; reject that normalization.
      if (parsed.toIso8601String().substring(0, 19) != value.substring(0, 19)) {
        _invalid();
      }
      return parsed;
    }

    final id = hash('id');
    final fingerprint = hash('fingerprint');
    final revision = hash('pricingRevision');
    final amount = json['amountMinor'];
    if (json['protocol'] != 1 ||
        json['protocol'] is! int ||
        json['bookingSupported'] is! bool ||
        json['currency'] != 'usd' ||
        amount is! int ||
        amount < 0 ||
        amount > 1000000 ||
        requestDuration.isNegative) {
      _invalid();
    }
    final request = canonicalRequest(json['request']);
    final route = json['route'];
    if (route is! Map ||
        route['provider'] != 'mapbox' ||
        route['profile'] != 'driving' ||
        !_metric(route['distanceMeters'], 500000) ||
        !_metric(route['durationSeconds'], 86400)) {
      _invalid();
    }
    final fare = json['fare'];
    if (fare is! Map ||
        fare['total'] is! num ||
        !(fare['total'] as num).isFinite ||
        ((fare['total'] as num).toDouble() - amount / 100).abs() > 0.0000001) {
      _invalid();
    }
    final surge = fare['surgeMultiplier'] ??
        (json['bookingSupported'] == false ? 1 : null);
    if (surge is! num || !surge.isFinite || surge < 1) {
      _invalid();
    }
    final created = timestamp('createdAt');
    final expires = timestamp('expiresAt');
    final server = timestamp('serverTime');
    if (expires.difference(created) != const Duration(seconds: 120) ||
        server.isBefore(created)) {
      _invalid();
    }
    final stopwatch = Stopwatch()..start();
    final remaining = expires.difference(server) - requestDuration;
    final quote = BookingQuote._(
        id,
        fingerprint,
        revision,
        amount,
        json['bookingSupported'] as bool,
        (route['distanceMeters'] as num).toDouble(),
        (route['durationSeconds'] as num).toDouble(),
        surge.toDouble(),
        request,
        expires,
        now ?? DateTime.now,
        elapsed ?? () => stopwatch.elapsed,
        remaining.isNegative ? Duration.zero : remaining);
    quote.remaining;
    return quote;
  }

  /// Both clocks can shorten validity; wall-clock rollback cannot extend it.
  Duration get remaining {
    final micros = math.max(
        0,
        math.min(
            (_budget - _elapsed()).inMicroseconds,
            math.min(expiresAt.difference(_now().toUtc()).inMicroseconds,
                (_lastRemaining ?? _budget).inMicroseconds)));
    return _lastRemaining = Duration(microseconds: micros);
  }

  void retainEarlierDeadline(BookingQuote incoming) {
    if (id != incoming.id ||
        fingerprint != incoming.fingerprint ||
        pricingRevision != incoming.pricingRevision ||
        amountMinor != incoming.amountMinor ||
        distanceMeters != incoming.distanceMeters ||
        durationSeconds != incoming.durationSeconds ||
        surgeMultiplier != incoming.surgeMultiplier ||
        expiresAt != incoming.expiresAt ||
        !matchesRequest(incoming.request)) {
      _invalid();
    }
    _budget = _elapsed() +
        Duration(
            microseconds: math.min(
                remaining.inMicroseconds, incoming.remaining.inMicroseconds));
    if (bookingSupported && !incoming.bookingSupported) {
      _budget = Duration.zero;
    }
  }

  bool matchesRequest(Map<String, dynamic> value) {
    final other = canonicalRequest(value);
    return request['vehicleType'] == other['vehicleType'] &&
        mapEquals(request['pickup'] as Map, other['pickup'] as Map) &&
        mapEquals(request['destination'] as Map, other['destination'] as Map);
  }

  static Map<String, dynamic> canonicalRequest(dynamic value) {
    if (value is! Map ||
        !setEquals(
            value.keys.toSet(), {'vehicleType', 'pickup', 'destination'}) ||
        value['vehicleType'] is! String ||
        !RegExp(r'^[a-z][a-z0-9_-]{0,39}$').hasMatch(value['vehicleType'])) {
      _invalid();
    }
    Map<String, dynamic> point(dynamic input) {
      if (input is! Map ||
          !setEquals(
              input.keys.toSet(), {'latitude', 'longitude', 'address'})) {
        _invalid();
      }
      final lat = input['latitude'];
      final lon = input['longitude'];
      final address = input['address'];
      if (lat is! num ||
          lon is! num ||
          !lat.isFinite ||
          !lon.isFinite ||
          lat.abs() > 90 ||
          lon.abs() > 180 ||
          address is! String ||
          address.trim().isEmpty ||
          address.length > 256 ||
          RegExp(r'[\x00-\x1f\x7f-\x9f]').hasMatch(address)) {
        _invalid();
      }
      return Map.unmodifiable({
        'latitude': lat == 0 ? 0.0 : lat.toDouble(),
        'longitude': lon == 0 ? 0.0 : lon.toDouble(),
        'address': address.trim(),
      });
    }

    final pickup = point(value['pickup']);
    final destination = point(value['destination']);
    if (pickup['latitude'] == destination['latitude'] &&
        pickup['longitude'] == destination['longitude']) {
      _invalid();
    }
    return Map.unmodifiable({
      'vehicleType': value['vehicleType'],
      'pickup': pickup,
      'destination': destination,
    });
  }

  static bool _metric(dynamic value, int maximum) =>
      value is num && value.isFinite && value > 0 && value <= maximum;
  static Never _invalid() =>
      throw const FormatException('Invalid booking quote');
}
