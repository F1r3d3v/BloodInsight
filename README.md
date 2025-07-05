# 🩸 BloodInsight - Bloodwork Monitoring App

![BloodInsight Banner](https://github.com/user-attachments/assets/e7fc0e4c-9354-45bc-aaa4-1e8228847484)

## 🌟 Overview

BloodInsight is an intuitive and powerful application designed to help users track, analyze, and gain valuable insights from their bloodwork data. With a sleek interface and advanced analytics, BloodInsight enables individuals to monitor their health trends over time and receive personalized recommendations tailored to their needs.

## 🔑 Key Features

- **🔐 Secure Login** – Use Google, Facebook, Apple, or email to sign in effortlessly.
- **📊 Dashboard** – Get an instant overview of recent bloodwork results, key health metrics, and important insights.
- **📂 Results History** – Browse and filter past bloodwork records by date and test type for easy access.
- **📑 Detailed Reports** – Analyze individual bloodwork results with clear comparisons, trends, and interactive visual graphs.
- **💡 Personalized Insights** – Receive customized health insights and lifestyle recommendations based on your bloodwork data.
- **⏰ Reminders** – Set up automatic notifications for upcoming blood tests to stay on track.
- **📥 Data Import & Export** – Easily upload bloodwork data and download reports in PDF format for convenient sharing and record-keeping.

## 📈 Advanced Analytics & Insights

- **📉 Health Trends** – Track long-term trends in key health indicators and monitor improvements or concerns.
- **⚠️ Predictive Insights** – Get proactive alerts based on emerging data patterns on potential health risks.
- **🏥 Condition-Specific Insights** – Access specialized insights for diabetes, anemia, and thyroid disorders.

## 🚀 Getting Started

1. **Download & Install** – Get BloodInsight on your preferred device.
2. **Sign In** – Use your preferred authentication method for secure access.
3. **Import Your Data** – Upload your bloodwork records to start analyzing.
4. **Explore & Monitor** – View detailed insights, set reminders, and take control of your health.

## 🏗️ Running Locally

To run BloodInsight on your local machine for testing or development, follow these steps:

### 📋 Prerequisites

Before you begin to install and test BloodInsight on your local machine, make sure you have met the following requirements:

- 🔧 You have installed the latest version of Flutter SDK. [Install Flutter](https://docs.flutter.dev/get-started/install)
- 🤖 You have installed Android Studio and optionally set up an emulator. [Download Android Studio](https://developer.android.com/studio)

### 🔑 Environment Variables

Create a \`.env\` file in the root directory of the project with the following content:

```
GOOGLE_MAPS_API=<your_google_maps_api_key>
GEMINI_API=<your_gemini_api_key>
```

> [!IMPORTANT]
> Replace `<your_google_maps_api_key>` and `<your_gemini_api_key>` with your actual API keys obtained from Google Maps and Gemini services. Keep your `.env` file secure and do not commit it to version control.

### 🚀 Run

1. 📦 Restore the packages:
   ```
   flutter pub get
   ```
2. 🏃 Run the application:
   ```
   flutter run --dart-define-from-file=.env
   ```
