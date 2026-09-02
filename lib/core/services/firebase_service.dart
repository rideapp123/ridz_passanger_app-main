import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:ridzs_passenger_app/main.dart';

import '../../firebase_options.dart';

class FirebaseService {
  factory FirebaseService() {
    return _singleton;
  }

  FirebaseService._internal();
  static final FirebaseService _singleton = FirebaseService._internal();

  Future<void> initializeFirebase() async {
    if (Firebase.apps.isNotEmpty) {
      return;
    }
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await firebaseNotificationService.initializeFirebaseMessaging();
  }

  Future<String?> getToken() async {
    return firebaseNotificationService.firebaseMessaging.getToken();
  }
}
