import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_settings.dart';
import '../providers/library_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

// ── Highlight controller ──────────────────────────────────────────────────────
class HighlightController extends TextEditingController {
  final List<TextRange> _highlights = [];

  List<TextRange> get highlights => List.unmodifiable(_highlights);

  void addHighlight(TextRange range) {
    if (!range.isValid || range.isCollapsed) return;
    if (range.start < 0 || range.end > text.length) return;
    _highlights.add(range);
    notifyListeners();
  }

  void clearHighlights() {
    _highlights.clear();
    notifyListeners();
  }

  void _validateHighlights() {
    _highlights.removeWhere(
      (r) => r.end > text.length || r.start < 0 || r.start >= r.end,
    );
  }

  @override
  set text(String newText) {
    super.text = newText;
    _validateHighlights();
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final full = text;
    if (full.isEmpty) return TextSpan(text: '', style: style);

    final valid = _highlights
        .where((r) =>
            r.isValid &&
            !r.isCollapsed &&
            r.start >= 0 &&
            r.end <= full.length)
        .toList()
      ..sort((a, b) => a.start.compareTo(b.start));

    if (valid.isEmpty) return TextSpan(text: full, style: style);

    final spans = <TextSpan>[];
    int cur = 0;
    for (final r in valid) {
      if (r.start < cur) continue;
      if (r.start > cur) {
        spans.add(TextSpan(text: full.substring(cur, r.start), style: style));
      }
      final end = min(r.end, full.length);
      spans.add(TextSpan(
        text: full.substring(r.start, end),
        style: style?.copyWith(
          backgroundColor: AppColors.gold.withOpacity(0.45),
          color: Colors.black,
        ),
      ));
      cur = end;
    }
    if (cur < full.length) {
      spans.add(TextSpan(text: full.substring(cur), style: style));
    }
    return TextSpan(style: style, children: spans);
  }
}

// ── Reader screen ─────────────────────────────────────────────────────────────
class ReaderScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String subId;
  final String title;

  const ReaderScreen({
    super.key,
    required this.categoryId,
    required this.subId,
    required this.title,
  });

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderState();
}

class _ReaderState extends ConsumerState<ReaderScreen> {
  bool _isEditMode = false;
  bool _isBookmarked = false;
  bool _showSettings = false;
  double _readingProgress = 0;
  TextAlign _textAlign = TextAlign.left;

  late final HighlightController _ctrl;
  late final FocusNode _focusNode;
  late final ScrollController _scroll;

  @override
  void initState() {
    super.initState();
    _ctrl = HighlightController();
    _focusNode = FocusNode();
    _scroll = ScrollController()..addListener(_updateProgress);
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadContent());
  }

  @override
  void dispose() {
    _scroll
      ..removeListener(_updateProgress)
      ..dispose();
    _focusNode.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _loadContent() {
    final cats = ref.read(libraryProvider);
    try {
      final cat = cats.firstWhere((c) => c.id == widget.categoryId);
      final sub = cat.subCategories.firstWhere((s) => s.id == widget.subId);
      if (mounted) setState(() => _ctrl.text = sub.content);
    } catch (_) {
      if (mounted) _ctrl.text = '';
    }
  }

  void _updateProgress() {
    if (!_scroll.hasClients) return;
    final max = _scroll.position.maxScrollExtent;
    if (max <= 0) return;
    final prog = (_scroll.offset / max).clamp(0.0, 1.0);
    if ((prog - _readingProgress).abs() > 0.005) {
      setState(() => _readingProgress = prog);
    }
  }

  void _toggleEdit() {
    setState(() => _isEditMode = !_isEditMode);
    if (_isEditMode) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _focusNode.requestFocus();
      });
    } else {
      _focusNode.unfocus();
      _saveContent();
    }
  }

  void _saveContent() {
    ref.read(libraryProvider.notifier).updateSubCategoryContent(
          widget.categoryId,
          widget.subId,
          _ctrl.text,
        );
  }

  void _highlight() {
    final sel = _ctrl.selection;
    if (!sel.isValid || sel.isCollapsed) {
      _snack('Hãy bôi đen văn bản trước!');
      return;
    }
    _ctrl.addHighlight(TextRange(start: sel.start, end: sel.end));
    _ctrl.selection = TextSelection.collapsed(offset: sel.end);
    _snack('Đã đánh dấu!');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(msg, style: AppTextStyles.caption.copyWith(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        width: 280,
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.surface,
      ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final colors = _themeColors(settings.readerTheme);

    return Scaffold(
      backgroundColor: colors.bg,
      body: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.escape) {
              if (_isEditMode) _toggleEdit();
              else Navigator.pop(context);
            }
          }
        },
        child: Column(
          children: [
            _buildTopBar(colors),
            if (_showSettings) _buildSettingsBar(settings),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: _buildContent(settings, colors)),
                ],
              ),
            ),
            _buildStatusBar(colors),
          ],
        ),
      ),
    );
  }

  _ThemeColors _themeColors(ReaderTheme t) {
    switch (t) {
      case ReaderTheme.dark:
        return _ThemeColors(
          bg: AppColors.readerDark,
          text: const Color(0xFFD4CFCA),
          surface: const Color(0xFF1E2230),
          border: AppColors.border,
        );
      case ReaderTheme.sepia:
        return _ThemeColors(
          bg: AppColors.readerSepia,
          text: const Color(0xFF3B2F1E),
          surface: const Color(0xFFD9C9A8),
          border: const Color(0xFFC4B08A),
        );
      case ReaderTheme.light:
      default:
        return _ThemeColors(
          bg: AppColors.readerPaper,
          text: AppColors.textOnLight,
          surface: const Color(0xFFEAE5D8),
          border: const Color(0xFFD0C9B8),
        );
    }
  }

  Widget _buildTopBar(_ThemeColors c) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          // Back button
          _toolBtn(
            Icons.arrow_back_rounded,
            'Quay lại (Esc)',
            () {
              if (_isEditMode) _saveContent();
              Navigator.pop(context);
            },
            color: c.text,
          ),
          const SizedBox(width: 8),
          // Title
          Expanded(
            child: Text(
              widget.title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: c.text,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Actions
          _toolBtn(
            _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
            _isBookmarked ? 'Bỏ đánh dấu' : 'Đánh dấu',
            () => setState(() => _isBookmarked = !_isBookmarked),
            color: _isBookmarked ? AppColors.gold : c.text,
          ),
          _toolBtn(
            _isEditMode ? Icons.check_circle_rounded : Icons.edit_outlined,
            _isEditMode ? 'Lưu (Esc)' : 'Chỉnh sửa',
            _toggleEdit,
            color: _isEditMode ? AppColors.gold : c.text,
          ),
          _toolBtn(
            Icons.tune_rounded,
            'Cài đặt hiển thị',
            () => setState(() => _showSettings = !_showSettings),
            color: _showSettings ? AppColors.gold : c.text,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsBar(ReadingSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);
    final c = _themeColors(settings.readerTheme);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 52,
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          // Font size
          _settingLabel('Cỡ chữ', c.text),
          _iconBtn(Icons.remove_rounded, () {
            notifier.setFontSize(settings.fontSize - 1);
          }, c.text),
          Text(
            settings.fontSize.toInt().toString(),
            style: TextStyle(
                fontFamily: 'Inter', fontSize: 13, color: c.text, fontWeight: FontWeight.w600),
          ),
          _iconBtn(Icons.add_rounded, () {
            notifier.setFontSize(settings.fontSize + 1);
          }, c.text),

          _vDivider(c),

          // Line height
          _settingLabel('Dòng', c.text),
          _iconBtn(Icons.remove_rounded, () {
            notifier.setLineHeight(settings.lineHeight - 0.1);
          }, c.text),
          Text(
            settings.lineHeight.toStringAsFixed(1),
            style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: c.text),
          ),
          _iconBtn(Icons.add_rounded, () {
            notifier.setLineHeight(settings.lineHeight + 0.1);
          }, c.text),

          _vDivider(c),

          // Theme
          _settingLabel('Giao diện', c.text),
          ...ReaderTheme.values.map((t) => _themeChip(t, settings.readerTheme, notifier, c)),

          _vDivider(c),

          // Alignment
          _settingLabel('Căn lề', c.text),
          _iconBtn(
            _textAlign == TextAlign.justify
                ? Icons.format_align_justify_rounded
                : Icons.format_align_left_rounded,
            () => setState(() => _textAlign =
                _textAlign == TextAlign.left ? TextAlign.justify : TextAlign.left),
            c.text,
          ),

          _vDivider(c),

          // Highlight
          _settingLabel('Highlight', c.text),
          _iconBtn(Icons.brush_rounded, _highlight, AppColors.gold),

          const Spacer(),

          // Word count
          Text(
            '${_wordCount()} từ',
            style: AppTextStyles.caption.copyWith(color: c.text.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _settingLabel(String t, Color c) => Padding(
        padding: const EdgeInsets.only(right: 4, left: 8),
        child: Text(t,
            style: AppTextStyles.caption.copyWith(color: c.withOpacity(0.6))),
      );

  Widget _vDivider(_ThemeColors c) => Container(
        width: 1,
        height: 24,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        color: c.border,
      );

  Widget _themeChip(
      ReaderTheme t, ReaderTheme current, SettingsNotifier notifier, _ThemeColors c) {
    final labels = {
      ReaderTheme.light: ('☀️', 'Sáng'),
      ReaderTheme.sepia: ('📜', 'Sepia'),
      ReaderTheme.dark: ('🌙', 'Tối'),
    };
    final label = labels[t]!;
    final isActive = t == current;

    return GestureDetector(
      onTap: () => notifier.setReaderTheme(t),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(left: 4),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.gold.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isActive ? AppColors.gold : c.border,
          ),
        ),
        child: Text(
          '${label.$1} ${label.$2}',
          style: AppTextStyles.caption.copyWith(
            color: isActive ? AppColors.gold : c.text.withOpacity(0.7),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(ReadingSettings settings, _ThemeColors c) {
    // Centered content column (like a real book page)
    return SingleChildScrollView(
      controller: _scroll,
      padding: EdgeInsets.symmetric(
        horizontal:
            (MediaQuery.of(context).size.width * (1 - settings.contentWidth) / 2)
                .clamp(40.0, 300.0),
        vertical: 40,
      ),
      child: GestureDetector(
        onTap: () {
          if (!_isEditMode) _focusNode.unfocus();
        },
        child: TextField(
          controller: _ctrl,
          focusNode: _focusNode,
          maxLines: null,
          readOnly: !_isEditMode,
          enableInteractiveSelection: true,
          style: TextStyle(
            fontFamily: settings.fontFamily,
            fontSize: settings.fontSize,
            height: settings.lineHeight,
            color: c.text,
          ),
          textAlign: _textAlign,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: _isEditMode ? 'Nhập nội dung ở đây...' : null,
            hintStyle: TextStyle(
              color: c.text.withOpacity(0.4),
              fontStyle: FontStyle.italic,
              fontFamily: settings.fontFamily,
              fontSize: settings.fontSize,
            ),
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (v) {
            _ctrl.validateHighlights();
            ref.read(libraryProvider.notifier).updateSubCategoryContent(
                  widget.categoryId,
                  widget.subId,
                  v,
                );
          },
        ),
      ),
    );
  }

  void Function() get validateHighlights => _ctrl.validateHighlights;

  Widget _buildStatusBar(_ThemeColors c) {
    final totalChars = _ctrl.text.length;
    final pages = ((totalChars / 1800).ceil()).clamp(1, 9999);
    final currentPage = ((_readingProgress * pages) + 1).floor().clamp(1, pages);

    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.border)),
      ),
      child: Row(
        children: [
          Text(
            'Trang $currentPage / $pages',
            style: AppTextStyles.caption.copyWith(color: c.text.withOpacity(0.6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: LinearProgressIndicator(
              value: _readingProgress,
              backgroundColor: c.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
              minHeight: 3,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${(_readingProgress * 100).toInt()}%',
            style: AppTextStyles.caption.copyWith(color: c.text.withOpacity(0.6)),
          ),
          if (_isEditMode) ...[
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'CHẾ ĐỘ CHỈNH SỬA',
                style: AppTextStyles.caption.copyWith(color: AppColors.gold),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  int _wordCount() {
    final t = _ctrl.text.trim();
    if (t.isEmpty) return 0;
    return t.split(RegExp(r'\s+')).length;
  }

  Widget _toolBtn(IconData icon, String tooltip, VoidCallback onTap,
      {Color? color}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Icon(icon, size: 18, color: color ?? AppColors.textSecondary),
        ),
      ),
    );
  }

  Widget _iconBtn(IconData icon, VoidCallback onTap, Color color) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}

extension on HighlightController {
  void validateHighlights() {
    highlights; // already validated in getter
    // explicit call triggers _validateHighlights via set text trick:
    // For safety, just call the parent class method via setter.
    final t = text;
    // ignore: invalid_use_of_protected_member
    super.value = super.value.copyWith(text: t);
  }
}

// ── Theme colors helper ───────────────────────────────────────────────────────
class _ThemeColors {
  final Color bg;
  final Color text;
  final Color surface;
  final Color border;
  const _ThemeColors(
      {required this.bg,
      required this.text,
      required this.surface,
      required this.border});
}
