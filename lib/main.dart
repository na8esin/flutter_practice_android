import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final messagingProvider = Provider<MessagingController>((ref) {
  final messaging = FirebaseMessaging.instance;
  return MessagingController(messaging);
});

class MessagingController extends StateNotifier<FirebaseMessaging> {
  final FirebaseMessaging _messaging;
  MessagingController(this._messaging) : super(_messaging);

  Future<String> getToken() {
    return _messaging.getToken();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

// onBackgroundMessage

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  runApp(ProviderScope(
    child: MaterialApp(home: MyApp()),
  ));
}

class MyApp extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final messagingController = useProvider(messagingProvider);
    final token = useState("");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          token.value = await messagingController.getToken();
          showDialog(
              context: context,
              builder: (context) {
                return SimpleDialog(
                  children: [
                    SimpleDialogOption(
                      child: SelectableText('${token.value}'),
                    )
                  ],
                );
              });
        },
      ),
    );
  }
}
