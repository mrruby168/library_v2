import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/library_provider.dart';
import '../models/category_model.dart';
import '../widgets/shared_widgets.dart';
import 'reader_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _selectedCatId;
  String? _selectedSubId;
  bool _isEditMode = false;
  final Map<String, TextEditingController> _catControllers = {};
  final Map<String, TextEditingController> _subControllers = {};

  @override
  void dispose() {
    for (final c in _catControllers.values) c.dispose();
    for (final c in _subControllers.values) c.dispose();
    super.dispose();
  }

  void _openSub(BookCategory cat, SubCategory sub) {
    setState(() {
      _selectedCatId = cat.id;
      _selectedSubId = sub.id;
    });
    ref.read(libraryProvider.notifier).selectSubCategory(cat.id, sub.id);
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => ReaderScreen(
          categoryId: cat.id,
          subId: sub.id,
          title: sub.title,
        ),
        transitionDuration: const Duration(milliseconds: 180),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    ).then((_) {
      setState(() {
        _selectedSubId = null;
        _selectedCatId = null;
      });
    });
  }

  TextEditingController _catCtrl(String id, String title) {
    return _catControllers.putIfAbsent(id, () => TextEditingController(text: title));
  }

  TextEditingController _subCtrl(String id, String title) {
    return _subControllers.putIfAbsent(id, () => TextEditingController(text: title));
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(libraryProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Row(
        children: [
          // ── Icon Rail ───────────────────────────────────────────────────────
          _buildIconRail(),

          // ── Separator ───────────────────────────────────────────────────────
          Container(width: 1, color: AppColors.border),

          // ── Tree panel ──────────────────────────────────────────────────────
          SizedBox(
            width: 280,
            child: _buildTreePanel(categories),
          ),

          // ── Separator ───────────────────────────────────────────────────────
          Container(width: 1, color: AppColors.border),

          // ── Welcome / Empty state ────────────────────────────────────────────
          Expanded(child: _buildWelcome()),
        ],
      ),
    );
  }

  Widget _buildIconRail() {
    return Container(
      width: 56,
      color: AppColors.sidebarBg,
      child: Column(
        children: [
          const SizedBox(height: 16),
          // App logo
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.menu_book_rounded,
                color: AppColors.gold, size: 20),
          ),
          const SizedBox(height: 24),
          const AppDivider(),
          const SizedBox(height: 16),
          SidebarButton(
            icon: Icons.library_books_outlined,
            tooltip: 'Thư viện',
            isActive: true,
            onTap: () {},
          ),
          const Spacer(),
          SidebarButton(
            icon: _isEditMode ? Icons.check_rounded : Icons.edit_outlined,
            tooltip: _isEditMode ? 'Hoàn tất chỉnh sửa' : 'Chỉnh sửa',
            isActive: _isEditMode,
            activeColor: AppColors.accent,
            onTap: () => setState(() => _isEditMode = !_isEditMode),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTreePanel(List<BookCategory> categories) {
    return Container(
      color: AppColors.sidebarBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPanelHeader(),
          const AppDivider(),
          Expanded(
            child: categories.isEmpty
                ? _buildEmptyTree()
                : _buildTree(categories),
          ),
          if (_isEditMode) _buildAddCategoryBtn(),
        ],
      ),
    );
  }

  Widget _buildPanelHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
      child: Row(
        children: [
          const Text('THƯ VIỆN', style: AppTextStyles.sectionHeader),
          const Spacer(),
          if (_isEditMode)
            SmallIconButton(
              icon: Icons.add_rounded,
              tooltip: 'Thêm danh mục',
              color: AppColors.accent,
              onTap: () => ref.read(libraryProvider.notifier).addCategory(),
            ),
        ],
      ),
    );
  }

  Widget _buildTree(List<BookCategory> categories) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      itemCount: categories.length,
      itemBuilder: (context, i) =>
          _buildCategoryNode(categories[i]),
    );
  }

  Widget _buildCategoryNode(BookCategory cat) {
    final notifier = ref.read(libraryProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category header
        HoverTile(
          onTap: () => notifier.toggleExpand(cat.id),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          child: Row(
            children: [
              AnimatedRotation(
                turns: cat.isExpanded ? 0.25 : 0,
                duration: const Duration(milliseconds: 150),
                child: const Icon(Icons.chevron_right_rounded,
                    size: 16, color: AppColors.textMuted),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _isEditMode
                    ? _inlineRenameField(
                        _catCtrl(cat.id, cat.title),
                        AppTextStyles.categoryTitle,
                        (v) => notifier.renameCategory(cat.id, v),
                      )
                    : Text(
                        cat.title,
                        style: AppTextStyles.categoryTitle,
                        overflow: TextOverflow.ellipsis,
                      ),
              ),
              if (_isEditMode) ...[
                SmallIconButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Thêm chương',
                  onTap: () => notifier.addSubCategory(cat.id),
                ),
                SmallIconButton(
                  icon: Icons.delete_outline_rounded,
                  tooltip: 'Xoá danh mục',
                  color: AppColors.danger,
                  onTap: () => _confirmDeleteCat(cat),
                ),
              ] else
                Text(
                  '${cat.subCategories.length}',
                  style: AppTextStyles.caption,
                ),
            ],
          ),
        ),

        // Sub-categories
        if (cat.isExpanded)
          ...cat.subCategories.map((sub) => _buildSubNode(cat, sub)),

        const SizedBox(height: 4),
      ],
    );
  }

  Widget _buildSubNode(BookCategory cat, SubCategory sub) {
    final notifier = ref.read(libraryProvider.notifier);
    final isSelected = _selectedSubId == sub.id && _selectedCatId == cat.id;

    return Padding(
      padding: const EdgeInsets.only(left: 20),
      child: HoverTile(
        isSelected: isSelected,
        onTap: _isEditMode ? null : () => _openSub(cat, sub),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          children: [
            Icon(
              Icons.article_outlined,
              size: 14,
              color: isSelected ? AppColors.gold : AppColors.textMuted,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _isEditMode
                  ? _inlineRenameField(
                      _subCtrl(sub.id, sub.title),
                      AppTextStyles.subTitle,
                      (v) => notifier.renameSubCategory(cat.id, sub.id, v),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub.title,
                          style: AppTextStyles.subTitle.copyWith(
                            color: isSelected
                                ? AppColors.gold
                                : AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (sub.wordCount > 0)
                          Text(
                            '${sub.wordCount} từ',
                            style: AppTextStyles.caption,
                          ),
                      ],
                    ),
            ),
            if (_isEditMode)
              SmallIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Xoá chương',
                color: AppColors.danger,
                size: 14,
                onTap: () => _confirmDeleteSub(cat, sub),
              ),
          ],
        ),
      ),
    );
  }

  Widget _inlineRenameField(
    TextEditingController ctrl,
    TextStyle style,
    ValueChanged<String> onChanged,
  ) {
    return TextField(
      controller: ctrl,
      style: style,
      onChanged: onChanged,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.gold),
        ),
        filled: true,
        fillColor: AppColors.cardBg,
      ),
    );
  }

  Widget _buildAddCategoryBtn() {
    return Column(
      children: [
        const AppDivider(),
        HoverTile(
          padding: const EdgeInsets.all(12),
          onTap: () => ref.read(libraryProvider.notifier).addCategory(),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_rounded, size: 16, color: AppColors.accent),
              const SizedBox(width: 6),
              Text('Thêm danh mục',
                  style: AppTextStyles.button
                      .copyWith(color: AppColors.accent)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyTree() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.folder_open_outlined,
                size: 48, color: AppColors.textMuted),
            const SizedBox(height: 12),
            Text(
              'Chưa có nội dung',
              style: AppTextStyles.subTitle
                  .copyWith(color: AppColors.textMuted),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Tạo danh mục đầu tiên'),
              onPressed: () {
                setState(() => _isEditMode = true);
                ref.read(libraryProvider.notifier).addCategory();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcome() {
    return Container(
      color: AppColors.mainBg,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.menu_book_rounded,
                  size: 40, color: AppColors.gold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Ebook Reader',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Chọn một chương từ thanh bên để bắt đầu đọc',
              style: AppTextStyles.subTitle,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _shortcutChip('Click vào chương', 'để mở'),
                const SizedBox(width: 16),
                _shortcutChip('Nút ✏️', 'để chỉnh sửa'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _shortcutChip(String key, String desc) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(key,
              style: AppTextStyles.button
                  .copyWith(color: AppColors.gold)),
          const SizedBox(height: 2),
          Text(desc, style: AppTextStyles.caption),
        ],
      ),
    );
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────────
  Future<void> _confirmDeleteCat(BookCategory cat) async {
    final ok = await _confirm(
      'Xoá danh mục "${cat.title}"?',
      'Tất cả chương bên trong cũng sẽ bị xoá.',
    );
    if (ok && mounted) {
      ref.read(libraryProvider.notifier).removeCategory(cat.id);
    }
  }

  Future<void> _confirmDeleteSub(BookCategory cat, SubCategory sub) async {
    final ok = await _confirm('Xoá chương "${sub.title}"?', null);
    if (ok && mounted) {
      ref.read(libraryProvider.notifier).removeSubCategory(cat.id, sub.id);
    }
  }

  Future<bool> _confirm(String title, String? subtitle) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.cardBg,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            title: Text(title,
                style: AppTextStyles.categoryTitle),
            content: subtitle != null
                ? Text(subtitle, style: AppTextStyles.subTitle)
                : null,
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Huỷ'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Xoá',
                    style: TextStyle(color: AppColors.danger)),
              ),
            ],
          ),
        ) ??
        false;
  }
}
