# 📱 Diagora - Application mobile

## 📦 Pré-requis

- [Flutter](https://flutter.dev/docs/get-started/install)
- [Dart](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) et/ou [Xcode](https://developer.apple.com/xcode/)
- [Firebase](#installation-et-configuration-de-firebase)

### Installation et configuration de Firebase

Pour configurer initialement ou changer de projet Firebase, il faut suivre les étapes suivantes :

- [Installez le CLI Firebase](https://firebase.google.com/docs/cli#setup_update_cli)
- Connectez-vous à Firebase avec votre compte Google

```bash
firebase login
```

- Installez le CLI FlutterFire globalement

```bash
dart pub global activate flutterfire_cli
```

- Configurez le projet Firebase, en choisissant le projet à utiliser et les plateformes à configurer

```bash
flutterfire configure
```

### 🛠 Développement

```bash
flutter run
```

### 📱 Publication

```bash
flutter build apk
```

```bash
flutter build ios
```
