# 📖 Ebook Reader — PC Windows

Ứng dụng đọc và ghi chép nội dung sách, tối ưu cho màn hình PC Windows. Xây dựng bằng Flutter.

---

## ✨ Tính năng

| Tính năng | Mô tả |
|---|---|
| **Thư viện danh mục** | Tổ chức nội dung theo danh mục → chương |
| **Trình đọc PC** | Layout căn giữa, chiều rộng tối ưu, không mỏi mắt |
| **3 giao diện đọc** | Sáng / Sepia / Tối |
| **Chỉnh sửa inline** | Gõ thẳng vào chương, tự động lưu |
| **Highlight** | Bôi đen → highlight vàng |
| **Cài đặt chữ** | Cỡ chữ, khoảng dòng, căn lề |
| **Lưu trữ hiệu quả** | Debounced save — không ghi liên tục |
| **Window Manager** | Kích thước cửa sổ mặc định 1280×800, có min size |

---

## 🖥️ Yêu cầu hệ thống

- Windows 10 / 11 (64-bit)
- Flutter SDK ≥ 3.3.0
- Dart SDK ≥ 3.3.0

---

## 🚀 Build & Chạy

```bash
# Cài dependencies
flutter pub get

# Chạy debug
flutter run -d windows

# Build release (exe)
flutter build windows --release
```

File exe đầu ra: `build\windows\x64\runner\Release\ebook_reader.exe`

---

## 📁 Cấu trúc dự án

```
lib/
├── main.dart                  # Entry point, window setup
├── models/
│   ├── book.dart              # Model sách EPUB/TXT
│   ├── category_model.dart    # Model danh mục & chương
│   └── reading_settings.dart  # Cài đặt đọc sách
├── providers/
│   ├── book_provider.dart     # Quản lý danh sách sách
│   ├── library_provider.dart  # Quản lý danh mục/chương
│   └── settings_provider.dart # Quản lý cài đặt
├── screens/
│   ├── home_screen.dart       # Màn hình chính (sidebar + tree)
│   ├── reader_screen.dart     # Màn hình đọc/chỉnh sửa
│   └── library_screen.dart    # Danh sách sách EPUB/TXT
├── services/
│   ├── book_service.dart      # Đọc file EPUB/TXT
│   └── storage_service.dart   # Lưu/đọc dữ liệu (debounced)
├── theme/
│   └── app_theme.dart         # Màu sắc, font, theme
└── widgets/
    └── shared_widgets.dart    # Widget dùng chung
```

---

## 💾 Lưu trữ

Dữ liệu được lưu bằng `shared_preferences` (Windows registry / AppData):

- `library_v2` — toàn bộ danh mục & chương
- `settings_v2` — cài đặt đọc sách
- `books_v2` — danh sách sách EPUB/TXT

**Debounced save:** nội dung chỉ được ghi sau 800ms kể từ lần gõ cuối, tránh I/O liên tục.

---

## 🎨 UI/UX

- Font **Inter** cho giao diện, **Georgia** cho nội dung đọc
- Layout 3 cột: Icon rail (56px) + Tree panel (280px) + Content
- Tất cả hover states, animation 100–180ms
- Keyboard shortcut: `Esc` để thoát / lưu

---

## 📦 Dependencies

```yaml
flutter_riverpod: ^2.5.1   # State management
shared_preferences: ^2.2.3  # Local storage
file_picker: ^8.0.3         # Chọn file
epubx: 4.0.0                # Đọc EPUB
html: ^0.15.4               # Parse HTML từ EPUB
window_manager: ^0.3.8      # Quản lý cửa sổ Windows
google_fonts: ^6.2.1        # Fonts
```

---

## 🔧 Phát triển tiếp

- [ ] Thêm hỗ trợ PDF (via `pdfx`)
- [ ] Export nội dung ra `.docx` / `.txt`
- [ ] Tìm kiếm toàn văn
- [ ] Dark mode cho toàn app
- [ ] Drag & drop file vào app
