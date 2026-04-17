class Book {
  final String id;
  final String title;
  final String author;
  final String filePath;
  final String fileType;
  final int lastPosition;
  final DateTime addedAt;
  final DateTime? lastOpenedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.filePath,
    required this.fileType,
    this.lastPosition = 0,
    DateTime? addedAt,
    this.lastOpenedAt,
  }) : addedAt = addedAt ?? DateTime.now();

  Book copyWith({
    int? lastPosition,
    DateTime? lastOpenedAt,
  }) =>
      Book(
        id: id,
        title: title,
        author: author,
        filePath: filePath,
        fileType: fileType,
        lastPosition: lastPosition ?? this.lastPosition,
        addedAt: addedAt,
        lastOpenedAt: lastOpenedAt ?? this.lastOpenedAt,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'author': author,
        'filePath': filePath,
        'fileType': fileType,
        'lastPosition': lastPosition,
        'addedAt': addedAt.toIso8601String(),
        'lastOpenedAt': lastOpenedAt?.toIso8601String(),
      };

  factory Book.fromJson(Map<String, dynamic> json) => Book(
        id: json['id'] as String,
        title: json['title'] as String,
        author: json['author'] as String,
        filePath: json['filePath'] as String,
        fileType: json['fileType'] as String,
        lastPosition: (json['lastPosition'] as num?)?.toInt() ?? 0,
        addedAt: json['addedAt'] != null
            ? DateTime.parse(json['addedAt'] as String)
            : DateTime.now(),
        lastOpenedAt: json['lastOpenedAt'] != null
            ? DateTime.parse(json['lastOpenedAt'] as String)
            : null,
      );
}
