# ScaffAssistant

A Flutter app for scaffolding professionals with essential tools and AI assistance.

---

## Core Features

| Feature | Description |
|---------|-------------|
| **AR Measure** | Measure real-world distances using AR (ARCore/ARKit) |
| **Level Tool** | Digital spirit level using accelerometer |
| **Count Tool** | Camera-based counting with image cropping |
| **Weight Calculator** | Calculate scaffolding material weights |
| **Weather Alerts** | Real-time weather notifications for safety |
| **AI Chat** | Chat with AI for scaffolding questions |
| **Quiz** | Test scaffolding knowledge (Part 1, Part 2, Advanced) |

---

## Tech Stack

- **Flutter** + **Dart**
- **GetX** - State Management
- **ARCore** (Android) / **ARKit** (iOS)
- **Firebase** - Auth & FCM

---

## Quick Start

```bash
# Install dependencies
flutter pub get

# Run app
flutter run
```

---

## 📁 Structure

```
lib/
├── core/           # Constants, Utils, Services
├── feature/        # All features (Auth, Chat, Quiz, Tools)
├── routing/        # Routes
└── main.dart

android/kotlin/     # ARCore implementation
ios/Runner/         # ARKit implementation
```

---

## 📦 Key Packages

```yaml
get: ^4.6.6              # State management
camera: ^0.10.5+9        # Camera
image: ^4.1.7            # Image processing
sensors_plus: ^4.0.2     # Accelerometer
firebase_messaging       # Push notifications
```

---

## 👥 Developer
 
[Bayajit Islam](https://github.com/BayajitIslam) & [Siamul Islam Soaib](https://github.com/mdsiamulislam)


---
