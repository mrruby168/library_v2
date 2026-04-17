import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../models/book.dart';
import '../services/storage_service.dart';
import '../services/book_service.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());
final _bookStorage = StorageService();

final booksProvider = StateNotifierProvider<BooksNotifier, List<Book>>(
  (ref) => BooksNotifier(_bookStorage, ref.read(bookServiceProvider)),
);

class BooksNotifier extends StateNotifier<List<Book>> {
  final StorageService _storage;
  final BookService _svc;

  BooksNotifier(this._storage, this._svc) : super([]) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.loadBooks();
  }

  Future<void> addBook() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'txt'],
      allowMultiple: true,
    );
    if (result == null) return;

    final newBooks = <Book>[];
    for (final f in result.files) {
      final path = f.path;
      if (path == null) continue;
      final ext = f.extension ?? '';
      String title = _svc.extractFileName(path);
      String author = 'Unknown Author';

      if (ext == 'epub') {
        try {
          final meta = await _svc.readEpubMeta(path);
          title = meta['title'] ?? title;
          author = meta['author'] ?? author;
        } catch (_) {}
      }

      // Tránh trùng lặp
      if (state.any((b) => b.filePath == path)) continue;

      newBooks.add(Book(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        author: author,
        filePath: path,
        fileType: ext,
      ));
    }

    if (newBooks.isNotEmpty) {
      state = [...state, ...newBooks];
      await _storage.saveBooksNow(state);
    }
  }

  Future<void> updateReadingPosition(String bookId, int position) async {
    state = state.map((b) {
      if (b.id != bookId) return b;
      return b.copyWith(
        lastPosition: position,
        lastOpenedAt: DateTime.now(),
      );
    }).toList();
    _storage.saveBooksDebounced(state);
  }

  Future<void> removeBook(String bookId) async {
    state = state.where((b) => b.id != bookId).toList();
    await _storage.saveBooksNow(state);
  }
}
