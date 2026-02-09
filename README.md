# To-Do List Application

A premium, minimalist task management application built with **Flutter**, designed for speed, reliability, and visual excellence.

## 🚀 Features
- **Smart Lists**: Dynamic categories for *Today*, *Upcoming*, *Overdue*, and *Completed Today*.
- **Advanced Task Logic**:
  - Support for **Daily** and **Weekly** repeating tasks.
  - Priority levels (Low, Medium, High).
  - Custom categories for better organization.
- **Modern UI/UX**:
  - **Material 3** design system with a curated Indigo theme.
  - **Dark Mode** support with seamless theme switching.
  - **Haptic Feedback** on key interactions.
  - Smooth animations and transitions.
- **Offline First**: Blazing fast local storage using **Hive**.
- **Data Portability**: Built-in functionality to export tasks to **CSV**.
- **Reminders**: Integrated local notification service for task deadlines.

## 🛠 Technical Stack
- **Framework**: [Flutter](https://flutter.dev) (3.38.x)
- **State Management**: [Riverpod 3.0](https://riverpod.dev) (Notifier pattern)
- **Local Database**: [Hive](https://pub.dev/packages/hive)
- **Icons**: [Lucide Icons](https://lucideicons.com)
- **Notifications**: `flutter_local_notifications`

## 🏗️ CI/CD Pipeline
The project includes a robust **GitHub Actions** workflow that automatically generates:
- **Android Release APK**
- **iOS IPA (Unsigned)**

Every push to the `main` branch triggers a cloud build, ensuring that a portfolio-ready version of the app is always available in the **Actions** tab.

## 📦 Getting Started

### Prerequisites
- Flutter SDK (latest stable)
- Dart SDK

### Installation
1. **Clone the repo**:
   ```bash
   git clone https://github.com/killingspree001/to_do_list_app.git
   ```
2. **Install dependencies**:
   ```bash
   flutter pub get
   ```
3. **Generate Hive components**:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
4. **Run the app**:
   ```bash
   flutter run
   ```

## 📝 Author
Developed as a showcase of modern Flutter architecture and clean UI design.
