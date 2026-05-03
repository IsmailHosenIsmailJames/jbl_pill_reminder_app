# JBL Pill Reminder App

JBL Pill Reminder App is a Flutter-based mobile application designed to help users manage their
medication schedules effectively. It provides timely reminders for taking pills, ensuring users stay
on track with their prescriptions.

## Description

This application allows users to add medications, set up schedules, and receive notifications for each dose. Notifications are managed via Firebase Cloud Messaging (FCM) to ensure reliability and battery efficiency.

## Key Features

* **Medication Management:** Add and manage a list of medications, including names and dosages.
* **Flexible Scheduling:** Set up reminders for different times of the day and recurring schedules.
* **Notification System:**
    * Receive timely notifications managed via FCM.
    * Actionable notifications allowing users to mark doses as taken.
* **Calendar View:** Visualize medication schedules on an interactive calendar.
* **History Tracking:** Keeps a log of taken medications.
* **Cloud Sync:** Synchronize reminders and history with the server.

## Tech Stack & Key Dependencies

* **Flutter:** For cross-platform (iOS & Android) mobile app development.
* **Flutter Bloc:** For robust and predictable state management.
* **Sqflite:** For efficient local relational database storage.
* **Firebase Cloud Messaging (FCM):** For reliable, server-triggered notifications.
* **GoRouter:** For declarative and flexible navigation.
* **Table Calendar:** For displaying an interactive medication calendar.
* **Dio:** For network requests and API interactions.
* **Get It:** For dependency injection.

## Setup and Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd jbl_pill_reminder_app
   ```
2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```
3. **Run the application:**
   ```bash
   flutter run
   ```
   Ensure you have a connected device or a running emulator/simulator.

## Notification System

The application utilizes Firebase Cloud Messaging (FCM) for all reminders. This approach ensures that:
- Notifications are delivered even if the app is in the background or terminated.
- Battery consumption is minimized by avoiding persistent local background services.
- Reminders stay in sync across different devices if applicable.

JBL Pill Reminder is your personal medication assistant, designed to help you manage your health with confidence and ease. Never worry about forgetting a dose again with our reliable and user-friendly app.