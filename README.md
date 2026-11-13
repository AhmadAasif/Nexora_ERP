# NEXORA ERP

A professional, responsive ERP dashboard frontend built with Flutter and Material 3.

## Project scope

This repository contains the **frontend only**. It uses local sample data to demonstrate the interface and basic interactions.

- No backend or server
- No database
- No API calls
- No authentication service
- No paid packages or external UI dependencies

## Included modules

- Overview dashboard with revenue, orders, expenses and profit cards
- Revenue and expenses chart drawn with Flutter CustomPainter
- Quick actions and create-invoice dialog
- Sales invoice list with local search
- Purchase order overview
- Inventory cards and low-stock alerts
- Customer overview cards
- Reports and analytics screen
- Workspace settings screen
- Responsive desktop sidebar and mobile bottom navigation

## Requirements

- Flutter SDK (Dart 3.4 or newer)
- Android Studio or VS Code with the Flutter extension
- Windows desktop development tools for the Windows desktop target

## Run the project

1. Clone this repository.
2. Open a terminal in the project folder.
3. Generate the platform folders for the devices you want to run:

   `flutter create . --platforms=windows,android,ios,web`

4. Fetch Flutter dependencies:

   `flutter pub get`

5. Run the app:

   `flutter run -d windows`

   Or use `flutter run -d chrome` for the web target.

You can also open the folder in VS Code and press **F5** after selecting a Flutter device.

## Test

Run the included widget smoke test with:

`flutter test`

## Sample data

All dashboard numbers, products, customers and transactions are demonstration data stored in `lib/data/sample_data.dart`. Creating an invoice adds it to the current app session only. Data resets when the app restarts.

## Project structure

```
lib/
  data/
    sample_data.dart
  models/
    erp_models.dart
  theme/
    app_theme.dart
  widgets/
    revenue_chart.dart
  main.dart
test/
  widget_test.dart
pubspec.yaml
README.md
```

## Next development stage

The UI can later be connected to a backend, database and authentication system. Those integrations are intentionally not included in this frontend build.
