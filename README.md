# chd_app_new

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


# Health Hearts at Home (HeartHub) ❤️🏠

**Comprehensive support for caregivers of children with Congenital Heart Disease (CHD).**

## 📖 Overview

[cite_start]**Health Hearts at Home** is a cross-platform mobile application designed to alleviate the overwhelming burden on caregivers of children with Congenital Heart Disease (CHD)[cite: 17]. [cite_start]By providing a centralized tool for medical tracking, educational resources, and hospital connectivity, the app empowers parents to manage their child's health effectively from home[cite: 17, 21].

The project also includes a **Web Admin Panel (HeartHub)** for hospital staff and administrators to manage content, users, and hospital directories.

## ✨ Key Features

### 📱 Mobile Application (Caregivers)
* **Health Tracking & Visualization:**
    * [cite_start]**Growth:** Log and track weight with visual charts[cite: 19].
    * [cite_start]**Feeding:** Record bottle/breastfeeding sessions and amounts[cite: 19].
    * [cite_start]**Vitals:** Monitor sensitive data like Oxygen Saturation (SpO2) levels[cite: 19, 63].
* **AI-Powered Assistance:**
    * [cite_start]Integrated **Gemini AI** to suggest heart-healthy recipes based on available ingredients[cite: 11].
* **Educational Resources:**
    * [cite_start]Library of video tutorials (e.g., medication administration, wound care)[cite: 18].
    * [cite_start]Detailed information on CHD types, treatments, and defects[cite: 26].
* **Caregiver Support:**
    * [cite_start]**Spiritual Needs:** Access to supplications and spiritual guidance[cite: 20, 39].
    * [cite_start]**Community:** Patient stories and support group information[cite: 20].
* **Localization:**
    * [cite_start]Full support for **English and Arabic** with instant LTR/RTL layout switching[cite: 24, 44].
* **Hospital Directory:**
    * [cite_start]Access contact info, emergency numbers, and location maps for hospitals[cite: 17, 38].

### 💻 Web Admin Panel (Administrators)
* **Dashboard Overview:** View statistics on users, hospitals, and published stories.
* **Content Management:** Add and manage educational tutorials (supports video imports), patient stories, and support groups.
* **Hospital Management:** Add new hospitals with location data (Maps integration).
* **User Management:** Manage roles (Admin, Parent, Hospital).

## 🛠️ Tech Stack & Tools

* [cite_start]**Frontend:** Flutter & Dart (Cross-platform for iOS/Android)[cite: 9, 28].
* [cite_start]**State Management:** **Cubit (BLoC Pattern)** – Used for managing complex states like localization (RTL/LTR switching) and real-time data updates[cite: 59].
* [cite_start]**Backend:** Firebase (Firestore, Authentication, Cloud Functions)[cite: 10, 22, 27].
* [cite_start]**AI Integration:** Gemini AI Assistant[cite: 11].
* **Project Management:** **Trello** – Used for agile task tracking and team coordination.
* **Architecture:** Model-View-ViewModel (MVVM) pattern with Clean Architecture principles.

## 🏗️ System Architecture

[cite_start]The application follows a streamlined data flow[cite: 31]:
1.  [cite_start]**User Input:** Caregivers input data (weight, feeding, oxygen) via the Flutter UI[cite: 32].
2.  [cite_start]**State Management:** **Cubit** handles the business logic, ensuring immediate UI updates and validating forms[cite: 59].
3.  [cite_start]**Authentication:** Firebase Auth handles secure user login/signup[cite: 30].
4.  [cite_start]**Data Sync:** Dynamic data is synced immediately to **Cloud Firestore**[cite: 22, 37].
5.  [cite_start]**Content Delivery:** Static data (tutorials, hospital info) is fetched from Firestore and streamed efficiently to the client[cite: 40, 62].

## 🚀 Getting Started

### Prerequisites
* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* [Dart](https://dart.dev/get-dart)
* A Firebase project set up with Firestore and Authentication enabled.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/yourusername/health-hearts-at-home.git](https://github.com/yourusername/health-hearts-at-home.git)
    ```
2.  **Install dependencies:**
    ```bash
    cd health-hearts-at-home
    flutter pub get
    ```
3.  **Firebase Configuration:**
    * Add your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) files to the respective directories.
4.  **Run the app:**
    ```bash
    flutter run
    ```

## [cite_start]👥 The Apex Team [cite: 2]

[cite_start]This project was built by the **Apex Team**[cite: 3]:

* [cite_start]**Osama Riyad:** Project Manager & Software Engineer [cite: 5]
* [cite_start]**Mohammad Al Ramahi:** AI Engineer [cite: 6]
* [cite_start]**Ibrahim Shalakhti:** Backend Engineer (Firebase) [cite: 7]
* [cite_start]**Laith Abu-Abbas:** UI/UX & Software Engineer [cite: 8]

## 📄 License

[Insert License Name, e.g., MIT License]

---
*Developed for the support of CHD children and their families.*
