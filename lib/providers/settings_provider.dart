import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reading_settings.dart';
import '../services/storage_service.dart';

final _storage = StorageService();

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, ReadingSettings>(
  (ref) => SettingsNotifier(_storage),
);

class SettingsNotifier extends StateNotifier<ReadingSettings> {
  final StorageService _storage;

  SettingsNotifier(this._storage) : super(const ReadingSettings()) {
    _load();
  }

  Future<void> _load() async {
    state = await _storage.loadSettings();
  }

  Future<void> setFontSize(double v) async {
    state = state.copyWith(fontSize: v.clamp(12.0, 36.0));
    await _storage.saveSettings(state);
  }

  Future<void> setLineHeight(double v) async {
    state = state.copyWith(lineHeight: v.clamp(1.2, 2.5));
    await _storage.saveSettings(state);
  }

  Future<void> setFontFamily(String f) async {
    state = state.copyWith(fontFamily: f);
    await _storage.saveSettings(state);
  }

  Future<void> setReaderTheme(ReaderTheme t) async {
    state = state.copyWith(readerTheme: t);
    await _storage.saveSettings(state);
  }

  Future<void> setContentWidth(double w) async {
    state = state.copyWith(contentWidth: w.clamp(0.4, 0.9));
    await _storage.saveSettings(state);
  }

  Future<void> toggleDarkMode() async {
    final next = state.readerTheme == ReaderTheme.dark
        ? ReaderTheme.light
        : ReaderTheme.dark;
    state = state.copyWith(readerTheme: next);
    await _storage.saveSettings(state);
  }
}
