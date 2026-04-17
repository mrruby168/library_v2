class SubCategory {
  final String id;
  final String title;
  final String content;
  final bool isSelected;
  final DateTime updatedAt;

  SubCategory({
    required this.id,
    required this.title,
    this.content = '',
    this.isSelected = false,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  SubCategory copyWith({
    String? id,
    String? title,
    String? content,
    bool? isSelected,
    DateTime? updatedAt,
  }) =>
      SubCategory(
        id: id ?? this.id,
        title: title ?? this.title,
        content: content ?? this.content,
        isSelected: isSelected ?? this.isSelected,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory SubCategory.fromJson(Map<String, dynamic> json) => SubCategory(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? '',
        content: json['content'] as String? ?? '',
        isSelected: json['isSelected'] as bool? ?? false,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : DateTime.now(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'isSelected': isSelected,
        'updatedAt': updatedAt.toIso8601String(),
      };

  int get wordCount {
    if (content.isEmpty) return 0;
    return content.trim().split(RegExp(r'\s+')).length;
  }
}

class BookCategory {
  final String id;
  final String title;
  final List<SubCategory> subCategories;
  final bool isExpanded;
  final DateTime createdAt;

  BookCategory({
    required this.id,
    required this.title,
    required this.subCategories,
    this.isExpanded = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BookCategory copyWith({
    String? id,
    String? title,
    List<SubCategory>? subCategories,
    bool? isExpanded,
  }) =>
      BookCategory(
        id: id ?? this.id,
        title: title ?? this.title,
        subCategories: subCategories ?? this.subCategories,
        isExpanded: isExpanded ?? this.isExpanded,
        createdAt: createdAt,
      );

  factory BookCategory.fromJson(Map<String, dynamic> json) {
    final list = json['subCategories'] as List? ?? [];
    return BookCategory(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      subCategories: list.map((i) => SubCategory.fromJson(i as Map<String, dynamic>)).toList(),
      isExpanded: json['isExpanded'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'subCategories': subCategories.map((s) => s.toJson()).toList(),
        'isExpanded': isExpanded,
        'createdAt': createdAt.toIso8601String(),
      };

  int get totalWordCount =>
      subCategories.fold(0, (sum, s) => sum + s.wordCount);
}
