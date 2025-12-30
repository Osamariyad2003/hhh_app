# Health Hearts at Home (HeartHub) ❤️🏠

**Comprehensive support for caregivers of children with Congenital Heart Disease (CHD).**

## 📖 Overview

**Health Hearts at Home** is a cross-platform mobile application designed to alleviate the overwhelming burden on caregivers of children with Congenital Heart Disease (CHD). By providing a centralized tool for medical tracking, educational resources, and hospital connectivity, the app empowers parents to manage their child's health effectively from home.

The project also includes a **Web Admin Panel (HeartHub)** for hospital staff and administrators to manage content, users, and hospital directories.

## ✨ Key Features

### 📱 Mobile Application (Caregivers)
* **Health Tracking & Visualization:**
    * **Growth:** Log and track weight with visual charts.
    * **Feeding:** Record bottle/breastfeeding sessions and amounts.
    * **Vitals:** Monitor sensitive data like Oxygen Saturation (SpO2) levels].
* **AI-Powered Assistance:**
    * Integrated **Gemini AI** to suggest heart-healthy recipes based on available ingredients.
* **Educational Resources:**
    * Library of video tutorials (e.g., medication administration, wound care).
    * Detailed information on CHD types, treatments, and defects.
* **Caregiver Support:**
    * **Spiritual Needs:** Access to supplications and spiritual guidance.
    * **Community:** Patient stories and support group information.
* **Localization:**
    * Full support for **English and Arabic** with instant LTR/RTL layout switching.
* **Hospital Directory:**
    * Access contact info, emergency numbers, and location maps for hospitals.

### 💻 Web Admin Panel (Administrators)
* **Dashboard Overview:** View statistics on users, hospitals, and published stories.
* **Content Management:** Add and manage educational tutorials (supports video imports), patient stories, and support groups.
* **Hospital Management:** Add new hospitals with location data (Maps integration).
* **User Management:** Manage roles (Admin, Parent, Hospital).

## 🛠️ Tech Stack & Tools

* **Frontend:** Flutter & Dart (Cross-platform for iOS/Android).
* **State Management:** **Cubit (BLoC Pattern)** – Used for managing complex states like localization (RTL/LTR switching) and real-time data updates.
* **Backend:** Firebase (Firestore, Authentication, Cloud Functions).
* **AI Integration:** Gemini AI Assistant.
* **Project Management:** **Trello** – Used for agile task tracking and team coordination.
* **Architecture:** Model-View-ViewModel (MVVM) pattern with Clean Architecture principles.

## 🏗️ System Architecture

The application follows a streamlined data flow:
1.  **User Input:** Caregivers input data (weight, feeding, oxygen) via the Flutter UI.
2.  **State Management:** **Cubit** handles the business logic, ensuring immediate UI updates and validating forms.
3.  **Authentication:** Firebase Auth handles secure user login/signup.
4.  **Data Sync:** Dynamic data is synced immediately to **Cloud Firestore**.
5.  **Content Delivery:** Static data (tutorials, hospital info) is fetched from Firestore and streamed efficiently to the client.

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

## 👥 The Apex Team 

This project was built by the **Apex Team**:

* **Osama Riyad:** Project Manager & Software Engineer 
* **Mohammad Al Ramahi:** AI Engineer 
* **Ibrahim Shalakhti:** Backend Engineer (Firebase) 
* **Laith Abu-Abbas:** UI/UX & Software Engineer 


*Developed for the support of CHD children and their families.*
