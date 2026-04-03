<div align="center">
  <img src="assets/images/app_logo.png" alt="CityNex Logo" width="120" />
  <h1>CityNex</h1>
  <p><strong>A Premium Smart Neighborhood Reporting Application</strong></p>
  <p>Bridging the gap between citizens, technicians, and local administration to create safer, cleaner, and highly optimized communities.</p>

  [![Flutter](https://img.shields.io/badge/Flutter-3.9.2-blue.svg?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-Fast-blue.svg?logo=dart)](https://dart.dev)
  [![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey.svg)]()
</div>

<br />

## 📖 Overview

**CityNex** is a comprehensive, multi-role mobile application built completely from the ground up with Flutter. It empowers everyday residents to instantly report local infrastructure issues (like broken streetlights, road damages, or waste management problems) directly to the city administration. 

Designed with a sleek, modern UI and a premium user experience, CityNex intelligently routes tickets through an Administration Dashboard directly to the field Technicians equipped to solve them.

---

## ✨ Key Features

*   **👥 Role-Based Access:** Dedicated interfaces and routing for **Citizens**, **Admins**, and **Technicians**.
*   **📸 Media Rich Reporting:** Users can seamlessly attach live photos of issues right from their device camera or gallery.
*   **📍 Geo-Location Tagging:** Automatically grab exact GPS coordinates of the issue so field technicians know precisely where to go.
*   **⚡ Real-Time Local Search & Filtering:** Instantly filter tickets and assignments locally in memory, guaranteeing a zero-latency UX.
*   **🔥 Modern UI/UX:** Built on a strict custom Design System with highly polished gradients, skeleton loading screens, and micro-animations.
*   **🔔 Intelligent Deep Linking:** Direct Instagram, Phone, and Email shortcuts natively baked in.

## 🛠️ Tech Stack & Architecture

*   **Framework:** [Flutter](https://flutter.dev/) / Dart
*   **State Management:** BLoC / Cubit (`flutter_bloc`) 
*   **Networking:** `dio` & `retrofit` (Strongly-typed, generated API clients)
*   **Local Storage:** `shared_preferences` & `flutter_secure_storage` for caching and secure tokens
*   **Location Services:** `geolocator` & `geocoding` 
*   **Routing:** Dynamic, role-based native Flutter named routes
*   **UI Helpers:** `skeletonizer` for premium loading states, `cached_network_image` for optimized thumbnails

## 🎨 Design System

CityNex uses a heavily customized Theme driven by centralized tokens to guarantee strict visual consistency across the entire app:
*   **AppColors:** Primary (`#0D3B66`), Accent (`#FAFAFA`), Pending (`#F39C12`) 
*   **AppTextStyles:** Custom typography paired with the beautiful *Inter* Google Font family.
*   **AppDimensions:** Standardized paddings, border radii, and scalable layout limits.

## ⚙️ Getting Started

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Version 3.9.2 or higher)
- Target devices running Android 11+ or iOS 14.0+

### Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/CityNex.git
   cd CityNex
   ```

2. **Fetch all dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Retrofit API clients & Freezed Models** (If modifying network layers):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Run the app:**
   ```bash
   flutter run
   ```

## 🔐 Error Handling & Validation
CityNex features a highly robust, custom generic `ErrorHandler` that directly interfaces with Laravel-style backend validations. It intercepts raw HTTP exceptions, safely traverses multidimensional error arrays, and outputs clean, instantly readable Action Snackbars straight to the user.

## 👨‍💻 Developer
Developed with ❤️ by **Zeyad Mahmoud**  
[Contact via Instagram](https://ig.me/m/zeyad_turki.lll) | zeyadmahmoud159@gmail.com

---
*© 2026 CityNex. All rights reserved.*
