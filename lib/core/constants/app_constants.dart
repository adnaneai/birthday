class AppConstants {
  static const String appName = 'Birthday Reminder';
  static const String hiveBoxName = 'birthdays';
  static const String notificationChannelId = 'birthday_channel';
  static const String notificationChannelName = 'Birthday Reminders';
  static const String notificationChannelDescription = 'Notifications for birthdays';

  // Routes
  static const String homeRoute = '/';
  static const String addBirthdayRoute = '/add-birthday';
  static const String editBirthdayRoute = '/edit-birthday';
  static const String listBirthdayRoute = '/list-birthdays';
  static const String loginRoute = '/login';
  static const String settingsRoute = '/settings';

  // Keys
  static const String themeKey = 'isDarkMode';
  static const String notificationsKey = 'notificationsEnabled';
}