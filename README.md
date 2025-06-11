# botanicareflu

A smart irrigation project

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Building the App

Before running on Android you need a `local.properties` file with your Flutter
SDK path. Create `android/local.properties` and add the following line:

```
flutter.sdk=/path/to/flutter
```

Run `flutter pub get` to fetch dependencies. Localization files are not
generated automatically, so run `flutter gen-l10n` afterward to create the
contents of `lib/gen_l10n`:

```bash
flutter pub get
flutter gen-l10n
```

Finally run the project with `flutter run` or build with `flutter build apk`.
