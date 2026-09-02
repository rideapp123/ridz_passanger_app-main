enum NotificationTypeEnum {
  reservationConfirmation,
  reservationRejected,
  reservationCancelled,

  newRequest,
  invitationAccepted,
  invitationRejected,

  subscriptionAccepted,
  subscriptionRejected,
  subscriptionExpired,
  subscriptionRequested,

  unknown,
}

NotificationTypeEnum getNotificationTypeEnumFromString(String value) {
  return switch (value) {
    'reservation_confirmation' => NotificationTypeEnum.reservationConfirmation,
    'reservation_rejected' => NotificationTypeEnum.reservationRejected,
    'reservation_cancelled' => NotificationTypeEnum.reservationCancelled,
    'new_request' => NotificationTypeEnum.newRequest,
    'invitation_accepted' => NotificationTypeEnum.invitationAccepted,
    'invitation_rejected' => NotificationTypeEnum.invitationRejected,
    'subscription_accepted' => NotificationTypeEnum.subscriptionAccepted,
    'subscription_rejected' => NotificationTypeEnum.subscriptionRejected,
    'subscription_expired' => NotificationTypeEnum.subscriptionExpired,
    'subscription_requested' => NotificationTypeEnum.subscriptionRequested,
    _ => NotificationTypeEnum.unknown,
  };
}
