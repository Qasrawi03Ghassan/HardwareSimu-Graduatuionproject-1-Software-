import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationsProvider extends ChangeNotifier {
  final List<RemoteMessage> _notifications = [];

  List<RemoteMessage> get notifications => List.unmodifiable(_notifications);

  void addNotification(RemoteMessage message) {
    _notifications.insert(0, message);
    notifyListeners();
  }

  void removeNotification(RemoteMessage message) {
    _notifications.remove(message);
    notifyListeners();
  }

  void clear() {
    _notifications.clear();
    notifyListeners();
  }
}
