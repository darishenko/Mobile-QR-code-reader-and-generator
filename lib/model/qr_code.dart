class QRCodeField {
  static final List<String> values = [
    id,
    prioritise,
    content,
    createdTime,
  ];

  static const String id = '_id';
  static const String prioritise = 'prioritise';
  static const String content = 'content';
  static const String createdTime = 'createdTime';
}

class QRCode {
  final int? id;
  late bool prioritise;
  final String content;
  late DateTime createdTime;

  changePrioritise() {
    prioritise = !prioritise;
  }

  QRCode({
    required this.id,
    required this.prioritise,
    required this.content,
    required this.createdTime,
  });

  Map<String, Object?> toJson() => {
        QRCodeField.id: id,
        QRCodeField.content: content,
        QRCodeField.prioritise: prioritise ? 0 : 1,
        QRCodeField.createdTime: createdTime.toIso8601String(),
      };

  QRCode copy({
    int? id,
    bool? prioritise,
    String? content,
    DateTime? createdTime,
  }) =>
      QRCode(
        id: id ?? this.id,
        content: content ?? this.content,
        prioritise: prioritise ?? this.prioritise,
        createdTime: createdTime ?? this.createdTime,
      );

  static QRCode fromJson(Map<String, Object?> json) => QRCode(
        id: json[QRCodeField.id] as int?,
        content: json[QRCodeField.content] as String,
        prioritise: json[QRCodeField.prioritise] == 0,
        createdTime: DateTime.parse(json[QRCodeField.createdTime] as String),
      );
}
