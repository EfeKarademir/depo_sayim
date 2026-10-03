# Depo Sayım — Warehouse Inventory Counting App

A cross-platform Flutter application for managing warehouse inventory counts. Built for teams that need fast, structured stock counting with role-based workflows: employees run live counting sessions, while managers oversee tasks, staff accounts, and reporting from a dedicated dashboard.

## ✨ Features

- **User login with role-based access** — two roles (`employee` and `manager`) with a "remember me" session option; managers unlock additional admin screens.
- **Manager dashboard** — an overview of counting activity where managers create counting blocks/tasks and monitor progress.
- **Live counting screen** — a fast, focused counting interface for recording counted products during a session.
- **Task details with target tracking** — each counting task tracks expected (target) vs. counted quantities, with per-record difference and status.
- **Manager account & messaging screens** — managers manage staff accounts and send/read personnel messages.
- **Report export** — one-tap export of counting reports to an Excel (`.xlsx`) file, shared via the native share sheet.
- **Offline mode** — data is persisted locally (SharedPreferences/JSON) so tasks, reports, and messages survive app restarts and work without connectivity, with an offline-first sync layer for automatic synchronization when a connection is available.

## 🛠️ Tech Stack

- **Flutter / Dart** (Dart SDK `^3.12.0`)
- **Layered architecture** — clear separation between `core` (theme & shared widgets), `data` (models & repositories), `presentation` (screens & widgets), and `services` (auth, export, storage, sync)
- **Key packages**
  - [`google_fonts`](https://pub.dev/packages/google_fonts) — typography
  - [`excel`](https://pub.dev/packages/excel) — report export
  - [`share_plus`](https://pub.dev/packages/share_plus) — native share sheet
  - [`shared_preferences`](https://pub.dev/packages/shared_preferences) — local key-value storage
  - [`path_provider`](https://pub.dev/packages/path_provider) — filesystem paths

## 📁 Project Structure

```
lib/
├── main.dart                          # App entry point & auth gate
├── core/
│   ├── theme/                         # App colors, theme, text styles
│   └── widgets/                       # Shared UI widgets (cards, badges, background)
├── data/
│   ├── models/                        # Data models (user, product, task, report, message)
│   └── repositories/                  # Data access & business logic layer
├── presentation/
│   ├── screens/                       # App screens (login, dashboard, counting,
│   │                                  #   task detail, manager accounts & messages)
│   └── widgets/                       # Screen-specific dialogs and widgets
└── services/                          # Auth, Excel export, local storage,
                                       #   offline sync
```

## 🚀 Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (stable channel)
- A connected device or emulator, or a desktop/desktop target

### Setup

1. Clone the repository:

   ```bash
   git clone <repository-url>
   cd depo_sayim
   ```

2. Install dependencies:

   ```bash
   flutter pub get
   ```

3. Run the app:

   ```bash
   flutter run
   ```

   To target a specific device:

   ```bash
   flutter devices        # list available devices
   flutter run -d <device-id>
   ```

## 📱 Supported Platforms

| Platform | Status |
| -------- | ------ |
| Android  | ✅ Supported |
| iOS      | ✅ Supported |
| macOS    | ✅ Supported |
| Windows  | ✅ Supported |
| Linux    | ✅ Supported |
| Web      | ✅ Supported |

## ⚠️ Disclaimer

This software is provided "as is", without warranty of any kind, express
or implied. The author assumes no responsibility or liability for any
damages, data loss, or business interruptions arising from the use of
this software. Use it at your own risk. This project is provided for
educational and demonstration purposes only.
