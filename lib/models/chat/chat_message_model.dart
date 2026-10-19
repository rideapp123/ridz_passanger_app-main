class RideMessage {
  final String? id;
  final String? clientMessageId;
  final String? orderKey;
  final String rideId;
  final String message;
  final String sender;
  final String timestamp;

  RideMessage({
    this.id,
    this.clientMessageId,
    this.orderKey,
    required this.rideId,
    required this.message,
    required this.sender,
    required this.timestamp,
  });

  factory RideMessage.fromJson(Map<String, dynamic> json) {
    final text = json['message'] ?? json['text'];
    final role = json['sender'] ?? json['by'];
    final ride = json['rideId'];
    final rawTimestamp = json['timestamp'];
    if (text is! String ||
        ride is! String ||
        ride.isEmpty ||
        !const {'passenger', 'driver', 'system'}.contains(role)) {
      throw const FormatException('Invalid chat message');
    }
    final timestamp = rawTimestamp is String
        ? rawTimestamp
        : DateTime.fromMillisecondsSinceEpoch(
            rawTimestamp is num && rawTimestamp.isFinite
                ? rawTimestamp.toInt()
                : 0,
            isUtc: true,
          ).toIso8601String();
    if (DateTime.tryParse(timestamp) == null) {
      throw const FormatException('Invalid chat timestamp');
    }
    return RideMessage(
      id: json['id'] as String?,
      clientMessageId: json['clientMessageId'] as String?,
      orderKey: json['orderKey'] as String?,
      rideId: ride,
      message: text,
      sender: role as String,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (clientMessageId != null) 'clientMessageId': clientMessageId,
        if (orderKey != null) 'orderKey': orderKey,
        'rideId': rideId,
        'message': message,
        'sender': sender,
        'timestamp': timestamp,
      };

  static List<RideMessage> mergeHistory(Iterable<RideMessage> history,
      Iterable<RideMessage> live, String rideId) {
    final messages = <Object, RideMessage>{};
    for (final message in [...history, ...live]) {
      if (message.rideId != rideId) continue;
      final Object key =
          message.id ?? (message.sender, message.timestamp, message.message);
      messages[key] = message;
    }
    final result = messages.values.toList();
    result.sort((a, b) {
      if (a.orderKey != null && b.orderKey != null) {
        return a.orderKey!.compareTo(b.orderKey!);
      }
      final time = (DateTime.tryParse(a.timestamp)?.millisecondsSinceEpoch ?? 0)
          .compareTo(
              DateTime.tryParse(b.timestamp)?.millisecondsSinceEpoch ?? 0);
      return time != 0 ? time : (a.id ?? '').compareTo(b.id ?? '');
    });
    return result;
  }
}
