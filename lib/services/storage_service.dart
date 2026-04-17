import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/book.dart';
import '../models/reading_settings.dart';
import '../models/category_model.dart';

/// StorageService: tất cả I/O được debounce để tránh ghi liên tục khi typing.
class StorageService {
  static const String _booksKey    = 'books_v2';
  static const String _settingsKey = 'settings_v2';
  static const String _libraryKey  = 'library_v2';

  SharedPreferences? _prefs;
  Timer? _saveLibraryTimer;
  Timer? _saveBooksTimer;

  Future<SharedPreferences> get _p async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ── Books ──────────────────────────────────────────────────────────────────
  Future<List<Book>> loadBooks() async {
    final p = await _p;
    final raw = p.getString(_booksKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => Book.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Debounced: ghi sau 500ms kể từ lần gọi cuối.
  void saveBooksDebounced(List<Book> books) {
    _saveBooksTimer?.cancel();
    _saveBooksTimer = Timer(const Duration(milliseconds: 500), () {
      _saveBooksNow(books);
    });
  }

  Future<void> saveBooksNow(List<Book> books) => _saveBooksNow(books);

  Future<void> _saveBooksNow(List<Book> books) async {
    final p = await _p;
    await p.setString(_booksKey, jsonEncode(books.map((b) => b.toJson()).toList()));
  }

  // ── Settings ───────────────────────────────────────────────────────────────
  Future<ReadingSettings> loadSettings() async {
    final p = await _p;
    final raw = p.getString(_settingsKey);
    if (raw == null) return const ReadingSettings();
    try {
      return ReadingSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const ReadingSettings();
    }
  }

  Future<void> saveSettings(ReadingSettings settings) async {
    final p = await _p;
    await p.setString(_settingsKey, jsonEncode(settings.toJson()));
  }

  // ── Library (categories) ───────────────────────────────────────────────────
  Future<List<BookCategory>> loadLibrary() async {
    final p = await _p;
    final raw = p.getString(_libraryKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => BookCategory.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Debounced: ghi sau 800ms (content có thể thay đổi liên tục khi gõ).
  void saveLibraryDebounced(List<BookCategory> cats) {
    _saveLibraryTimer?.cancel();
    _saveLibraryTimer = Timer(const Duration(milliseconds: 800), () {
      _saveLibraryNow(cats);
    });
  }

  Future<void> saveLibraryNow(List<BookCategory> cats) => _saveLibraryNow(cats);

  Future<void> _saveLibraryNow(List<BookCategory> cats) async {
    final p = await _p;
    await p.setString(_libraryKey, jsonEncode(cats.map((c) => c.toJson()).toList()));
  }

  void dispose() {
    _saveLibraryTimer?.cancel();
    _saveBooksTimer?.cancel();
  }
}
