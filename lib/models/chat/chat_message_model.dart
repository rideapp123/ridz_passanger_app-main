class RideMessage {
  final String rideId;
  final String message;
  final String sender;
  final String timestamp;

  RideMessage({
    required this.rideId,
    required this.message,
    required this.sender,
    required this.timestamp,
  });

  factory RideMessage.fromJson(Map<String, dynamic> json) {
    final rawTimestamp = json['timestamp'];
    final timestamp = rawTimestamp is String
        ? rawTimestamp
        : DateTime.fromMillisecondsSinceEpoch(
            rawTimestamp is num ? rawTimestamp.toInt() : DateTime.now().millisecondsSinceEpoch,
          ).toIso8601String();
    return RideMessage(
      rideId: (json['rideId'] ?? '').toString(),
      message: (json['message'] ?? json['text'] ?? '') as String,
      sender: (json['sender'] ?? json['by'] ?? 'system').toString(),
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rideId': rideId,
      'message': message,
      'sender': sender,
      'timestamp': timestamp,
    };
  }
}
