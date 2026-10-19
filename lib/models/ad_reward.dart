class AdRewardOffer {
  AdRewardOffer(this.minor, this.units);
  final int minor;
  final Set<String> units;
  factory AdRewardOffer.parse(Map<String, dynamic> data) {
    if (data['enabled'] != true || data['serverVerificationRequired'] != true) {
      throw const FormatException('Rewards are unavailable');
    }
    return AdRewardOffer(rewardMinor(data['rewardAmount'], data['currency']),
        rewardUnits(data['allowedAdUnits']));
  }
}

class AdRewardSession {
  AdRewardSession._(
      this.id,
      this.owner,
      this.status,
      this.minor,
      this.units,
      this.notBefore,
      this.watchDeadline,
      this.confirmationDeadline,
      this.requestId,
      this.rideId);
  final String id, owner, status;
  final String? requestId;
  final String rideId;
  final int minor;
  final Set<String> units;
  final DateTime notBefore, watchDeadline, confirmationDeadline;
  String get money => 'USD ${(minor / 100).toStringAsFixed(2)}';
  bool get confirmed => status == 'completed';

  factory AdRewardSession.parse(dynamic raw, String owner,
      {String? expectedId}) {
    if (raw is! Map) throw const FormatException('Invalid reward session');
    final id = raw['id'] ?? raw['_id'];
    if (!rewardId(id) ||
        (expectedId != null && id != expectedId) ||
        (raw['id'] != null && raw['_id'] != null && raw['id'] != raw['_id']) ||
        raw['passengerId'] != owner ||
        !rewardId(owner) ||
        !const {'started', 'completed', 'cancelled'}.contains(raw['status'])) {
      throw const FormatException('Reward identity was not confirmed');
    }
    final minor = rewardMinor(raw['rewardAmount'], raw['currency']);
    final rules = raw['rules'];
    if (rules is! Map ||
        rules['version'] is! int ||
        rules['version'] != 1 ||
        rules['rewardMinor'] is! int ||
        rules['rewardMinor'] != minor ||
        rules['currency'] != 'usd' ||
        rules['providerAmount'] is! String ||
        !RegExp(r'^[0-9]{1,9}(\.[0-9]{1,6})?$')
            .hasMatch(rules['providerAmount']) ||
        (num.tryParse(rules['providerAmount']) ?? 0) <= 0 ||
        rules['providerItem'] is! String ||
        (rules['providerItem'] as String).trim().isEmpty) {
      throw const FormatException('Reward policy needs review');
    }
    final units = rewardUnits(rules['allowedUnits']);
    final start = rewardDate(raw['startedAt']);
    final notBefore = rewardDate(rules['notBefore']);
    final watch = rewardDate(rules['watchDeadline']);
    final confirm = rewardDate(rules['confirmationDeadline']);
    if (notBefore.isBefore(start) ||
        !notBefore.isBefore(watch) ||
        watch.difference(start) > const Duration(hours: 1) ||
        confirm.isBefore(watch) ||
        confirm.difference(watch) > const Duration(hours: 24)) {
      throw const FormatException('Invalid reward deadlines');
    }
    if (raw['status'] == 'completed') {
      final metadata = raw['adMetadata'];
      final completed = rewardDate(raw['completedAt']);
      if (!rewardId(raw['walletTransactionId']) ||
          metadata is! Map ||
          metadata['serverVerified'] != 'true' ||
          metadata['adNetwork'] != 'admob' ||
          !rewardId(metadata['transaction_id']) ||
          !units.contains(metadata['ad_unit']) ||
          metadata['reward_item'] != rules['providerItem'] ||
          metadata['reward_amount'] is! String ||
          num.tryParse(metadata['reward_amount']) !=
              num.parse(rules['providerAmount']) ||
          metadata['timestamp'] is! String ||
          int.tryParse(metadata['timestamp']) == null ||
          completed.isBefore(notBefore) ||
          !completed.isBefore(confirm)) {
        throw const FormatException('Reward credit was not verified');
      }
      final event = DateTime.fromMillisecondsSinceEpoch(
          int.parse(metadata['timestamp']),
          isUtc: true);
      if (event.isBefore(notBefore) || !event.isBefore(watch)) {
        throw const FormatException('Reward evidence is outside the session');
      }
    }
    if (raw['rideId'] is! String ||
        (raw['startRequestId'] != null && !rewardId(raw['startRequestId']))) {
      throw const FormatException('Invalid reward request');
    }
    return AdRewardSession._(id, owner, raw['status'], minor, units, notBefore,
        watch, confirm, raw['startRequestId'], raw['rideId']);
  }
}

class AdRewardCredit {
  AdRewardCredit(AdRewardSession session)
      : sessionId = session.id,
        owner = session.owner,
        minor = session.minor {
    if (!session.confirmed) {
      throw const FormatException('Reward is not confirmed');
    }
  }
  final String sessionId, owner;
  final int minor;
  String get money => 'USD ${(minor / 100).toStringAsFixed(2)}';
}

int rewardMinor(dynamic value, dynamic currency) {
  if (currency != 'usd' ||
      value is! num ||
      !value.isFinite ||
      value < .01 ||
      value > 100) {
    throw const FormatException('Invalid reward money');
  }
  final minor = (value * 100).round();
  if ((value * 100 - minor).abs() > 0.0000001) {
    throw const FormatException('Invalid reward cents');
  }
  return minor;
}

bool rewardId(dynamic value) =>
    value is String && RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(value);
DateTime rewardDate(dynamic value) {
  if (value is! String || !value.endsWith('Z')) {
    throw const FormatException('Invalid reward time');
  }
  final result = DateTime.tryParse(value);
  if (result == null) throw const FormatException('Invalid reward time');
  return result.toUtc();
}

Set<String> rewardUnits(dynamic value) {
  if (value is! List ||
      value.isEmpty ||
      value.length > 20 ||
      value.any((v) =>
          v is! String || !RegExp(r'^[A-Za-z0-9/_-]{1,128}$').hasMatch(v))) {
    throw const FormatException('Invalid approved ad units');
  }
  return Set.unmodifiable(value.cast<String>());
}

bool approvedRewardUnit(Set<String> units, String sdkUnit) {
  final match =
      RegExp(r'^ca-app-pub-[0-9]{16}/([0-9]{10})$').firstMatch(sdkUnit);
  return match != null &&
      (units.contains(sdkUnit) || units.contains(match.group(1)));
}
