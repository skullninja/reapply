# ☀️ Reapply

**Your daily reminder to protect your skin.**

[![App Store](https://img.shields.io/badge/App%20Store-Download-blue?logo=apple&style=flat)](https://apps.apple.com/be/app/reapply-sunscreen-timekeeper/id1451428485)
![Platform](https://img.shields.io/badge/platform-iOS%2016+-lightgrey)
![Swift](https://img.shields.io/badge/swift-5.7+-orange)
![CocoaPods](https://img.shields.io/badge/dependencies-CocoaPods-red)
![Version](https://img.shields.io/badge/version-1.8-blueviolet)
![Status](https://img.shields.io/badge/status-active-brightgreen)
![License](https://img.shields.io/badge/license-CC%20BY--NC%204.0-lightgrey)
![WeatherKit](https://img.shields.io/badge/WeatherKit-Required-blue)

---

## 📱 What is Reapply?

Did you know that sunscreen is a much-needed but rarely used **everyday essential**?  
Or that **90% of skin aging** is caused by daily sun exposure?  
And yes, **all skin tones need sunscreen** and can develop skin cancer.

Whether you're new to SPF or a daily devotee who forgets to reapply, Reapply is designed to help you build sun-safe habits that last.

---

## ✨ Features

- **Morning reminders** to apply sunscreen before you start your day
- **Smart reapplication reminders** throughout the day
- **UV Index awareness** using your current location
- **Sunscreen reviews** and **eco-friendly product recommendations**
- **Educational tips** on skin care, sun damage prevention, and reef-safe sunscreen usage

---

## 🔧 Project Info

- **Language:** Swift
- **Platform:** iOS 16+
- **Package Manager:** CocoaPods
- **Current Version:** 1.8
- **App Store:** [Reapply on iOS](https://apps.apple.com/be/app/reapply-sunscreen-timekeeper/id1451428485)

---

## 🛠 Setup Instructions

1. **Clone the repo:**
   ```bash
   git clone https://github.com/your-username/reapply.git
   cd reapply
   ```

2. **Install dependencies via CocoaPods:**
   ```bash
   pod install
   ```

3. **Open the workspace:**
   ```bash
   open Reapply.xcworkspace
   ```

4. **Configure API keys:**

   The app uses a property list file to store configurable keys such as third-party URLs and tokens.

   - Locate a file named `APIKeys.plist` in the project Configuration directory.
   - Fill in the appropriate values for your build environment (or leave blank to run with limited functionality).

---

### ☁️ WeatherKit Integration (Required)

This project requires **WeatherKit** to function correctly.

- WeatherKit is used to access UV data essential to the app’s features.
- You must configure WeatherKit access through your own Apple Developer account to build and run the app properly.
- To enable WeatherKit:
  - Register your app’s Bundle Identifier with WeatherKit through the [Apple Developer Portal](https://developer.apple.com/account/).
  - Ensure your Apple Developer account has an active WeatherKit subscription (free tier available).
  - Enable the WeatherKit capability in your Xcode project Signing & Capabilities settings.

Without properly configured WeatherKit access, the app will build but may not function correctly at runtime.

---

### ⚙️ Code Signing and Cloud Services

Reapply uses features like iCloud and push notifications in the production App Store version.  
For this public repository:

- **iCloud services have been disabled** in the project settings to simplify local setup.
- You can build and run the app without needing an Apple Developer account or provisioning profile.
- If you wish to re-enable iCloud functionality, you must:
  - Add your own iCloud container in Apple Developer settings.
  - Update the entitlements file (`SPFReminder.entitlements`) accordingly.
  - Enable iCloud services under Signing & Capabilities.

This allows the public version to remain fully buildable without special configuration.

---

## 📄 License

This project is licensed under the **Creative Commons Attribution-NonCommercial 4.0 International License (CC BY-NC 4.0)**.

You are free to use, share, and adapt the code for personal and educational purposes, but **commercial use is strictly prohibited**.

[Read the full license here.](https://creativecommons.org/licenses/by-nc/4.0/)

---

## 🤝 Contributions

This project is being actively iterated on internally.  
Stay tuned for contribution guidelines in a future release!

---

## ☀️ Stay safe, stay glowing!

If this app has helped you build a better SPF habit or you have feedback, we'd love to hear from you!