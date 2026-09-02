enum LocalNotificationPayloadType {
  reviewPage('review_page'),
  appFeedbackPage('app_feedback_page');

  const LocalNotificationPayloadType(this.message);
  final String message;
}
