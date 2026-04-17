import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/category_model.dart';
import '../services/storage_service.dart';

final isEditModeProvider = StateProvider<bool>((ref) => false);
final selectedSubProvider = StateProvider<String?>((ref) => null);

final _libStorage = StorageService();

final libraryProvider =
    StateNotifierProvider<LibraryNotifier, List<BookCategory>>(
  (ref) => LibraryNotifier(_libStorage),
);

class LibraryNotifier extends StateNotifier<List<BookCategory>> {
  final StorageService _storage;

  LibraryNotifier(this._storage) : super([]) {
    _load();
  }

  Future<void> _load() async {
    final loaded = await _storage.loadLibrary();
    if (loaded.isEmpty) {
      state = [
        BookCategory(
          id: '1',
          title: 'Sách Ví Dụ',
          isExpanded: true,
          subCategories: [
            SubCategory(
              id: '1a',
              title: 'Chương 1: Mở đầu',
              content:
                  'Chào mừng bạn đến với ứng dụng đọc sách!\n\nĐây là một ứng dụng đọc sách được tối ưu hóa cho PC Windows. Bạn có thể tạo các danh mục và chương để quản lý nội dung của mình.\n\nHãy bắt đầu bằng cách nhấn vào một chương để đọc hoặc chỉnh sửa nội dung.',
            ),
            SubCategory(
              id: '1b',
              title: 'Chương 2: Hướng dẫn',
              content:
                  'Để thêm nội dung mới:\n\n1. Nhấn nút Edit ở góc trên bên phải để vào chế độ chỉnh sửa\n2. Thêm danh mục mới hoặc chương mới\n3. Click vào chương để mở và chỉnh sửa nội dung\n\nNội dung sẽ được tự động lưu khi bạn gõ.',
            ),
          ],
        ),
      ];
      _storage.saveLibraryNow(state);
    } else {
      state = loaded;
    }
  }

  void _save() => _storage.saveLibraryDebounced(state);
  Future<void> _saveNow() => _storage.saveLibraryNow(state);

  void updateSubCategoryContent(String catId, String subId, String content) {
    state = state.map((cat) {
      if (cat.id != catId) return cat;
      return cat.copyWith(
        subCategories: cat.subCategories.map((sub) {
          if (sub.id != subId) return sub;
          return sub.copyWith(content: content, updatedAt: DateTime.now());
        }).toList(),
      );
    }).toList();
    _save(); // debounced
  }

  void toggleExpand(String catId) {
    state = state.map((cat) {
      if (cat.id != catId) return cat;
      return cat.copyWith(isExpanded: !cat.isExpanded);
    }).toList();
    _save();
  }

  void renameCategory(String id, String name) {
    state = state.map((cat) {
      if (cat.id != id) return cat;
      return cat.copyWith(title: name);
    }).toList();
    _save();
  }

  void addCategory() {
    final cat = BookCategory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Danh mục mới',
      subCategories: [],
      isExpanded: true,
    );
    state = [...state, cat];
    _saveNow();
  }

  void addSubCategory(String catId) {
    state = state.map((cat) {
      if (cat.id != catId) return cat;
      final sub = SubCategory(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Chương mới',
      );
      return cat.copyWith(subCategories: [...cat.subCategories, sub]);
    }).toList();
    _saveNow();
  }

  void renameSubCategory(String catId, String subId, String name) {
    state = state.map((cat) {
      if (cat.id != catId) return cat;
      return cat.copyWith(
        subCategories: cat.subCategories.map((sub) {
          if (sub.id != subId) return sub;
          return sub.copyWith(title: name);
        }).toList(),
      );
    }).toList();
    _save();
  }

  void removeSubCategory(String catId, String subId) {
    state = state.map((cat) {
      if (cat.id != catId) return cat;
      return cat.copyWith(
        subCategories: cat.subCategories.where((s) => s.id != subId).toList(),
      );
    }).toList();
    _saveNow();
  }

  void removeCategory(String catId) {
    state = state.where((c) => c.id != catId).toList();
    _saveNow();
  }

  void selectSubCategory(String? catId, String? subId) {
    state = state.map((cat) {
      return cat.copyWith(
        subCategories: cat.subCategories.map((sub) {
          return sub.copyWith(isSelected: sub.id == subId && cat.id == catId);
        }).toList(),
      );
    }).toList();
  }

  void reorderCategories(int oldIndex, int newIndex) {
    final list = [...state];
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    state = list;
    _saveNow();
  }
}
