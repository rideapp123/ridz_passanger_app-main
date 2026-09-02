class BalanceResponse {
  final bool success;
  final Balance balance;

  BalanceResponse({
    required this.success,
    required this.balance,
  });

  factory BalanceResponse.fromJson(Map<String, dynamic> json) {
    return BalanceResponse(
      success: json['success'] as bool,
      balance: Balance.fromJson(json['balance'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'balance': balance.toJson(),
    };
  }
}

class Balance {
  final String id;
  final String userId;
  final String userType;
  final num balance;
  final num holdBalance;
  final DateTime lastUpdated;
  final int v;

  Balance({
    required this.id,
    required this.userId,
    required this.userType,
    required this.balance,
    required this.holdBalance,
    required this.lastUpdated,
    required this.v,
  });

  factory Balance.unknown() {
    return Balance(
      id: '',
      userId: '',
      userType: '',
      balance: 0,
      holdBalance: 0,
      lastUpdated: DateTime.now(),
      v: 0,
    );
  }

  factory Balance.fromJson(Map<String, dynamic> json) {
    return Balance(
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userType: (json['userType'] ?? '').toString(),
      balance: (json['balance'] as num?) ?? 0,
      holdBalance: (json['holdBalance'] as num?) ?? 0,
      lastUpdated: DateTime.tryParse((json['lastUpdated'] ?? '').toString()) ??
          DateTime.now(),
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'userType': userType,
      'balance': balance,
      'holdBalance': holdBalance,
      'lastUpdated': lastUpdated.toIso8601String(),
      '__v': v,
    };
  }
}
