enum ReaderTheme { light, sepia, dark }

class ReadingSettings {
  final double fontSize;
  final double lineHeight;
  final String fontFamily;
  final ReaderTheme readerTheme;
  final double contentWidth; // % max width for comfortable reading
  final bool showWordCount;

  const ReadingSettings({
    this.fontSize = 18.0,
    this.lineHeight = 1.85,
    this.fontFamily = 'Georgia',
    this.readerTheme = ReaderTheme.light,
    this.contentWidth = 0.65,
    this.showWordCount = true,
  });

  // Backward compat: isDarkMode
  bool get isDarkMode => readerTheme == ReaderTheme.dark;

  ReadingSettings copyWith({
    double? fontSize,
    double? lineHeight,
    String? fontFamily,
    ReaderTheme? readerTheme,
    double? contentWidth,
    bool? showWordCount,
  }) =>
      ReadingSettings(
        fontSize: fontSize ?? this.fontSize,
        lineHeight: lineHeight ?? this.lineHeight,
        fontFamily: fontFamily ?? this.fontFamily,
        readerTheme: readerTheme ?? this.readerTheme,
        contentWidth: contentWidth ?? this.contentWidth,
        showWordCount: showWordCount ?? this.showWordCount,
      );

  Map<String, dynamic> toJson() => {
        'fontSize': fontSize,
        'lineHeight': lineHeight,
        'fontFamily': fontFamily,
        'readerTheme': readerTheme.index,
        'contentWidth': contentWidth,
        'showWordCount': showWordCount,
      };

  factory ReadingSettings.fromJson(Map<String, dynamic> json) {
    final themeIndex = (json['readerTheme'] as num?)?.toInt();
    // Backward compat
    ReaderTheme theme;
    if (themeIndex != null) {
      theme = ReaderTheme.values[themeIndex.clamp(0, ReaderTheme.values.length - 1)];
    } else {
      final isDark = json['isDarkMode'] as bool? ?? false;
      theme = isDark ? ReaderTheme.dark : ReaderTheme.light;
    }
    return ReadingSettings(
      fontSize: (json['fontSize'] as num?)?.toDouble() ?? 18.0,
      lineHeight: (json['lineHeight'] as num?)?.toDouble() ?? 1.85,
      fontFamily: json['fontFamily'] as String? ?? 'Georgia',
      readerTheme: theme,
      contentWidth: (json['contentWidth'] as num?)?.toDouble() ?? 0.65,
      showWordCount: json['showWordCount'] as bool? ?? true,
    );
  }
}
