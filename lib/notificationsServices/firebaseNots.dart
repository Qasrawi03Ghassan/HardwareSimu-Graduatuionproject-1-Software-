// firebase_nots.dart
import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hardwaresimu_software_graduation_project/chatComponents.dart';
import 'package:hardwaresimu_software_graduation_project/chatServices/chatService.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/feedPage.dart';
import 'package:hardwaresimu_software_graduation_project/mobilePages/notifsPage.dart';
import 'package:hardwaresimu_software_graduation_project/main.dart'; // for navigatorKey
import 'package:hardwaresimu_software_graduation_project/notificationsServices/notifsProvider.dart';
import 'package:hardwaresimu_software_graduation_project/users.dart' as myUser;
import 'package:provider/provider.dart';

String? activeChatUserId;

StreamSubscription<RemoteMessage>? messageSub;
StreamSubscription<RemoteMessage>? messageSubBack;

class FirebaseNots {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotification(myUser.User? user) async {
    if (user == null || user.userID == 0) return;
    await _firebaseMessaging.requestPermission();
    final fcmToken = await _firebaseMessaging.getToken();
    print('fcmToken: $fcmToken');

    // Foreground message
    /*FirebaseMessaging.onMessage.listen((message) {
      handleMessage(message, user);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      handleMessage(message, user);
    });

    // App launched from terminated state
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      handleMessage(initialMessage, user);
    }*/

    await initPushNotifs(user);
  }

  void handleMessage(RemoteMessage? message, myUser.User? user) {
    if (message == null) return;

    final context = navKey.currentContext;
    if (context == null || user == null || user.userID == 0) {
      print("Context is null or user invalid");
      return;
    }

    if (!kIsWeb) {
      if (feedPageKey.currentState != null &&
          feedPageKey.currentState!.mounted) {
        // If FeedPage is active (app in foreground or visible)
        // Just update notification without navigating
        feedPageKey.currentState!.showNotification(message);
      } else {
        // Not on FeedPage (app background/terminated)
        // Navigate to FeedPage with Notifications tab selected
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => FeedPage(user: user, selectedIndex: 3),
            settings: RouteSettings(arguments: message),
          ),
        );
      }
    } else {
      print(' ✅ Got a notification on web!');
    }
  }

  Future<void> initPushNotifs(myUser.User? user) async {
    if (user == null || user.userID == 0) return;
    final fcm = FirebaseMessaging.instance;

    // Handle app opened from terminated state
    final initialMessage = await fcm.getInitialMessage();
    if (initialMessage != null) {
      final context = navKey.currentContext;
      if (context == null) return;
      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );

      notificationsProvider.addNotification(initialMessage);
      feedPageKey.currentState?.goToNotificationsScreen();
    }

    if (messageSub != null) {
      print("🚫 Already listening to FCM messages");
      return;
    }

    // App opened from background (notification tap)
    messageSubBack = FirebaseMessaging.onMessageOpenedApp.listen((message) {
      final context = navKey.currentContext;
      if (context == null) return;

      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );
      //feedPageKey.currentState!.showNotificationOnApp(message);
      notificationsProvider.addNotification(message);
      feedPageKey.currentState?.goToNotificationsScreen();
      //handleMessage(message, user);
    });

    // Foreground messages — just update notification in place (no navigation)
    messageSub = FirebaseMessaging.onMessage.listen((message) {
      if (message == null || message.notification == null) return;

      final context = navKey.currentContext;
      if (context == null) return;

      final notificationsProvider = Provider.of<NotificationsProvider>(
        context,
        listen: false,
      );

      if (message.notification!.title!.contains('🔔')) {
        feedPageKey.currentState!.showChatNotif(
          title: message.notification!.title!,
          body: message.notification!.body!,
        );
        // feedPageKey.currentState!.showNotificationOnApp(message);
        // // // If you want, you can still add the chat notification to the provider
        // notificationsProvider.addNotification(message);
      }

      if (!message.notification!.title!.contains('chat')) {
        // Instead of calling feedPageKey.currentState!.showNotificationOnApp(message),
        // add to notifications provider
        feedPageKey.currentState!.showNotificationOnApp(message);
        notificationsProvider.addNotification(message);
      } else {
        final senderId = message.data['fromUser'];
        final isOnChat = feedPageKey.currentState?.isOnChatScreen ?? false;
        activeChatUserId = FirebaseAuth.instance.currentUser!.uid;

        if (!isOnChat && activeChatUserId != senderId) {
          feedPageKey.currentState!.showChatNotif(
            title: message.notification!.title!,
            body: message.notification!.body!,
          );
          feedPageKey.currentState!.showNotificationOnApp(message);
          // // // If you want, you can still add the chat notification to the provider
          notificationsProvider.addNotification(message);
        }
      }
      //feedPageKey.currentState!.showNotificationOnApp(message);
      // If you want, you can still add the chat notification to the provider
      //notificationsProvider.addNotification(message);
      //feedPageKey.currentState!.showNotificationOnApp(message);
      // // If you want, you can still add the chat notification to the provider
      //notificationsProvider.addNotification(message);
    });
  }
}
