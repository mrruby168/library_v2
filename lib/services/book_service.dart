import 'dart:io';
import 'package:epubx/epubx.dart';
import 'package:html/parser.dart' as html_parser;

class BookService {
  String extractFileName(String path) {
    final fileName = path.split(Platform.pathSeparator).last;
    final dot = fileName.lastIndexOf('.');
    return dot != -1 ? fileName.substring(0, dot) : fileName;
  }

  Future<Map<String, String>> readEpubMeta(String path) async {
    final bytes = await File(path).readAsBytes();
    final book = await EpubReader.readBook(bytes);
    return {
      'title': book.Title ?? extractFileName(path),
      'author': book.Author ?? 'Unknown Author',
    };
  }

  Future<String> getBookContent(String path, String fileType) async {
    if (fileType == 'epub') {
      return _readEpub(path);
    } else if (fileType == 'txt') {
      return File(path).readAsString();
    }
    return 'Định dạng file không được hỗ trợ.';
  }

  Future<String> _readEpub(String path) async {
    final bytes = await File(path).readAsBytes();
    final book = await EpubReader.readBook(bytes);
    final buffer = StringBuffer();

    if (book.Content?.Html != null) {
      for (final entry in book.Content!.Html!.entries) {
        final doc = html_parser.parse(entry.value.Content);
        final text = doc.body?.text ?? '';
        if (text.trim().isNotEmpty) {
          buffer.writeln(text.trim());
          buffer.writeln('\n');
        }
      }
    }
    return buffer.toString();
  }
}
