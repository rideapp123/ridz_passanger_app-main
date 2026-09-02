class TransactionResponse {
  final bool success;
  final List<Transaction> transactions;
  final int total;
  final int page;
  final int pages;

  TransactionResponse({
    required this.success,
    required this.transactions,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory TransactionResponse.fromJson(Map<String, dynamic> json) {
    return TransactionResponse(
      success: json['success'],
      transactions: (json['transactions'] as List)
          .map((e) => Transaction.fromJson(e))
          .toList(),
      total: json['total'],
      page: json['page'],
      pages: json['pages'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'transactions': transactions.map((e) => e.toJson()).toList(),
      'total': total,
      'page': page,
      'pages': pages,
    };
  }
}

class Transaction {
  final Metadata metadata;
  final String id;
  final String userId;
  final String userType;
  final String type;
  final num amount;
  final num balance;
  final String category;
  final String description;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  Transaction({
    required this.metadata,
    required this.id,
    required this.userId,
    required this.userType,
    required this.type,
    required this.amount,
    required this.balance,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      metadata: Metadata.fromJson(
          (json['metadata'] as Map<String, dynamic>?) ?? <String, dynamic>{}),
      id: (json['_id'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      userType: (json['userType'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      amount: (json['amount'] as num?) ?? 0,
      balance: (json['balance'] as num?) ?? 0,
      category: (json['category'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      status: (json['status'] ?? '').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ?? DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ?? DateTime.now(),
      v: (json['__v'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metadata': metadata.toJson(),
      '_id': id,
      'userId': userId,
      'userType': userType,
      'type': type,
      'amount': amount,
      'balance': balance,
      'category': category,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
    };
  }
}

class Metadata {
  final String paymentId;

  Metadata({required this.paymentId});

  factory Metadata.fromJson(Map<String, dynamic> json) {
    return Metadata(
      paymentId: (json['paymentId'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'paymentId': paymentId,
    };
  }
}
