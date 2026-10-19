import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../models/ride/booking_quote.dart';
import '../../../services/booking_quote_service.dart';

class BookingQuoteSheet extends StatefulWidget {
  const BookingQuoteSheet(
      {super.key,
      required this.service,
      required this.request,
      required this.paymentLabel});
  final BookingQuoteService service;
  final Map<String, dynamic> request;
  final String paymentLabel;
  @override
  State<BookingQuoteSheet> createState() => _BookingQuoteSheetState();
}

class _BookingQuoteSheetState extends State<BookingQuoteSheet> {
  BookingQuote? _quote;
  String? _error;
  bool _busy = false;
  late String _key;
  Timer? _timer;
  int _generation = 0;

  String _newKey() {
    final random = Random.secure();
    return base64Url.encode(List.generate(24, (_) => random.nextInt(256)));
  }

  @override
  void initState() {
    super.initState();
    _key = _newKey();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _quote != null) setState(() {});
    });
  }

  Future<void> _load({bool refresh = false}) async {
    if (_busy) return;
    final generation = ++_generation;
    setState(() {
      _busy = true;
      _error = null;
      if (refresh) {
        _key = _newKey();
        _quote = null;
      }
    });
    try {
      final quote = await widget.service.issue(widget.request, _key);
      if (!mounted || generation != _generation) return;
      setState(() {
        _quote = quote;
      });
    } catch (_) {
      if (mounted && generation == _generation) {
        setState(() => _error = 'Fare unavailable. No ride has been booked.');
      }
    } finally {
      if (mounted && generation == _generation) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _generation++;
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = _quote;
    final remaining = quote?.remaining ?? Duration.zero;
    final owned = quote != null && widget.service.owns(quote);
    final valid = quote != null &&
        owned &&
        quote.bookingSupported &&
        remaining > Duration.zero;
    final theme = Theme.of(context);
    return SafeArea(
        child: SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
          24, 16, 24, 24 + MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(children: [
              Expanded(
                  child:
                      Text('Review fare', style: theme.textTheme.titleLarge)),
              IconButton(
                  tooltip: 'Close',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close)),
            ]),
            const SizedBox(height: 12),
            Text(widget.request['pickup']['address'],
                style: theme.textTheme.bodyMedium),
            const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Icon(Icons.south, size: 18))),
            Text(widget.request['destination']['address'],
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 20),
            if (_busy)
              const SizedBox(
                  height: 64, child: Center(child: CircularProgressIndicator()))
            else if (_error != null)
              Text(_error!, style: TextStyle(color: theme.colorScheme.error))
            else if (quote != null) ...[
              Text('USD ${(quote.amountMinor / 100).toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Text(
                  '${(quote.distanceMeters / 1000).toStringAsFixed(1)} km  /  ${(quote.durationSeconds / 60).ceil()} min'),
              if (quote.surgeMultiplier > 1)
                Text(
                    'Demand multiplier ${quote.surgeMultiplier.toStringAsFixed(2)}x'),
              const SizedBox(height: 8),
              Text(widget.paymentLabel),
              const SizedBox(height: 12),
              Text(!owned
                  ? 'Session ended. Sign in again.'
                  : !quote.bookingSupported
                      ? 'Quoted booking is unavailable.'
                      : remaining <= Duration.zero
                          ? 'Fare expired. Review a new fare.'
                          : 'Fare valid for ${remaining.inSeconds ~/ 60}:${(remaining.inSeconds % 60).toString().padLeft(2, '0')}'),
            ],
            const SizedBox(height: 20),
            FilledButton(
                onPressed: _busy
                    ? null
                    : valid
                        ? () {
                            if (widget.service.owns(quote) &&
                                quote.remaining > Duration.zero) {
                              Navigator.of(context).pop(quote);
                            } else {
                              setState(() {});
                            }
                          }
                        : () => _load(refresh: quote != null),
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                        _busy
                            ? 'Getting fare'
                            : valid
                                ? 'Confirm ride'
                                : _error != null
                                    ? 'Retry'
                                    : 'Refresh fare',
                        textAlign: TextAlign.center))),
          ]),
    ));
  }
}
