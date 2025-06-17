# JBL Pill Reminder App

JBL Pill Reminder App is a Flutter-based mobile application designed to help users manage their
medication schedules effectively. It provides timely reminders for taking pills, ensuring users stay
on track with their prescriptions.

## Description

This application allows users to add medications, set up complex schedules (e.g., specific times,
days of the week), and receive notifications and alarms for each dose. It aims to be a reliable
companion for individuals managing multiple medications or complex treatment plans. The app utilizes
background services to ensure reminders are delivered even when the app is not actively running.

## Key Features

* **Medication Management:** Add and manage a list of medications, including names and potentially
  other details.
* **Flexible Scheduling:** Set up reminders for different times of the day, specific days of the
  week, or recurring schedules.
* **Notification System:**
    * Receive pre-reminders (e.g., 15 minutes before the scheduled time).
    * Receive exact-time notifications or alarms for taking medication.
    * Actionable notifications allowing users to mark doses as taken or interact with the reminder.
* **Calendar View:** Visualize medication schedules on a calendar.
* **Background Reliability:** Utilizes foreground services and background tasks (`WorkManager`) to
  ensure reminders are timely and accurate.
* **Local Data Storage:** Uses Hive for efficient local storage of reminder and user data.
* **User Authentication:** (Assumed based on seen files) Features for user login and signup.
* **History Tracking:** (Assumed) Keeps a log of taken medications.

## Tech Stack & Key Dependencies

* **Flutter:** For cross-platform (iOS & Android) mobile app development.
* **GetX:** For state management, navigation, and dependency injection.
* **Hive:** For fast and efficient local NoSQL database storage.
* **awesome_notifications:** For creating rich and customizable local notifications.
* **flutter_foreground_task:** For running tasks in a foreground service, crucial for reliable
  reminders.
* **workmanager:** For scheduling and running background tasks periodically.
* **alarm:** For setting device alarms.
* **table_calendar:** For displaying an interactive calendar.
* **dio / http:** For network requests (e.g., for user authentication or data backup if
  implemented).
* **intl:** For date/time formatting and internationalization.
* **permission_handler:** For requesting necessary device permissions.

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

## Background Services

The application relies on two main mechanisms for background operations:

* **FlutterForegroundTask:** A foreground service is used to continuously monitor upcoming reminders
  and update its notification, providing persistent information to the user. This is critical for
  time-sensitive alerts.
* **WorkManager:** Periodic background tasks are scheduled to analyze the reminder database, set
  alarms, and queue notifications, ensuring that even if the app is killed, future reminders are
  still processed.
