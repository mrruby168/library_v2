import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/shared_widgets.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      body: Column(
        children: [
          // Header bar
          Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: const BoxDecoration(
              color: AppColors.sidebarBg,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Text('THƯ VIỆN FILE', style: AppTextStyles.sectionHeader),
                const Spacer(),
                Tooltip(
                  message: 'Thêm sách (EPUB / TXT)',
                  child: TextButton.icon(
                    icon: const Icon(Icons.add_rounded, size: 16),
                    label: const Text('Thêm sách'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.gold,
                      textStyle: AppTextStyles.button,
                    ),
                    onPressed: () => ref.read(booksProvider.notifier).addBook(),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Expanded(
            child: books.isEmpty
                ? _buildEmpty(ref)
                : _buildList(context, ref, books),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.library_books_outlined,
              size: 56, color: AppColors.textMuted),
          const SizedBox(height: 16),
          const Text('Chưa có sách nào', style: AppTextStyles.subTitle),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.upload_file_rounded, size: 16),
            label: const Text('Thêm sách EPUB / TXT'),
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            onPressed: () => ref.read(booksProvider.notifier).addBook(),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, books) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: books.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) {
        final book = books[i];
        return HoverTile(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  book.fileType == 'epub'
                      ? Icons.menu_book_rounded
                      : Icons.description_outlined,
                  color: AppColors.gold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.title, style: AppTextStyles.categoryTitle),
                    const SizedBox(height: 2),
                    Text(book.author, style: AppTextStyles.subTitle),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppColors.border),
                ),
                child: Text(
                  book.fileType.toUpperCase(),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(width: 8),
              SmallIconButton(
                icon: Icons.delete_outline_rounded,
                tooltip: 'Xoá khỏi thư viện',
                color: AppColors.danger,
                onTap: () =>
                    ref.read(booksProvider.notifier).removeBook(book.id),
              ),
            ],
          ),
        );
      },
    );
  }
}
