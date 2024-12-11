class NotificationItem {
  String message;
  DateTime date;
  NotificationStatus status;

  NotificationItem(this.message, this.date, this.status);
}
enum NotificationStatus { newItem, yesterday, older, read }
