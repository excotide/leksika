import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:leksika/app.dart';
import 'package:leksika/core/di/injection_container.dart' as di;
import 'package:leksika/core/di/injection_container.dart';
import 'package:leksika/core/services/fcm_notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
  await di.init();
  await sl<FcmNotificationService>().initialize();
  runApp(const LeksikaApp());
}
