class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String timestamp; // Displayable timestamp
  final DateTime createdAt;
  final bool isUnread;
  final String type; // e.g. 'break', 'call', 'end_workday', 'missed_task', 'general'
  bool isSelected;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.createdAt,
    this.isUnread = true,
    this.type = 'general',
    this.isSelected = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      timestamp: json['timestamp'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isUnread: json['isUnread'] as bool? ?? true,
      type: json['type'] as String? ?? 'general',
      isSelected: json['isSelected'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp,
      'createdAt': createdAt.toIso8601String(),
      'isUnread': isUnread,
      'type': type,
      'isSelected': isSelected,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    String? timestamp,
    DateTime? createdAt,
    bool? isUnread,
    String? type,
    bool? isSelected,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      createdAt: createdAt ?? this.createdAt,
      isUnread: isUnread ?? this.isUnread,
      type: type ?? this.type,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}
