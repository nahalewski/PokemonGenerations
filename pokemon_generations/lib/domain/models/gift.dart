class Gift {
  final String id;
  final String senderUsername;
  final String senderDisplayName;
  final String recipientUsername;
  final String itemId;
  final int quantity;
  final String message;
  final DateTime timestamp;
  final String status; // 'pending' | 'accepted'

  const Gift({
    required this.id,
    required this.senderUsername,
    required this.senderDisplayName,
    required this.recipientUsername,
    required this.itemId,
    required this.quantity,
    required this.message,
    required this.timestamp,
    required this.status,
  });

  factory Gift.fromJson(Map<String, dynamic> json) => Gift(
        id: json['id'] as String,
        senderUsername: json['senderUsername'] as String,
        senderDisplayName: json['senderDisplayName'] as String? ?? json['senderUsername'] as String,
        recipientUsername: json['recipientUsername'] as String,
        itemId: json['itemId'] as String,
        quantity: (json['quantity'] as num?)?.toInt() ?? 1,
        message: json['message'] as String? ?? '',
        timestamp: DateTime.tryParse(json['timestamp'] as String? ?? '') ?? DateTime.now(),
        status: json['status'] as String? ?? 'pending',
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderUsername': senderUsername,
        'senderDisplayName': senderDisplayName,
        'recipientUsername': recipientUsername,
        'itemId': itemId,
        'quantity': quantity,
        'message': message,
        'timestamp': timestamp.toIso8601String(),
        'status': status,
      };
}
