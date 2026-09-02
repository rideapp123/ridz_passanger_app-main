import 'package:flutter/material.dart';

abstract class WidgetKeys {
  static const historySubsList = Key('history_subscriptions_list');

  static Key reservationListItem(int id) {
    return Key('reservation_list_item_$id');
  }
}
