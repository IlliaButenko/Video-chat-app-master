import 'dart:io';
import 'package:OCWA/data/services.dart';
import 'package:OCWA/data/storage_service.dart';
import 'package:OCWA/pages/loading.dart';
import 'package:OCWA/provider/image_upload_provider.dart';
import 'package:OCWA/provider/user_provider.dart';
import 'package:OCWA/ui/colors.dart';
import 'package:OCWA/ui/ui_helper.dart';
import 'package:OCWA/utils/route_generator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:workmanager/workmanager.dart';
import 'Controllers/notificationController.dart';
import 'data/service_locator.dart';
import 'pages/configs/configs.dart' as config;

Services services = new StorageServiceSharedPreferences();
Widget _defaultHome = Loading();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await FlutterDownloader.initialize();
  setupServiceLocator();
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ImageUploadProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'OCWA',
          theme: ThemeData(
            primaryColor: UIHelper.SPOTIFY_COLOR,
            accentColor: UIHelper.THEME_PRIMARY,
            scaffoldBackgroundColor: scaffoldBgColor,
            fontFamily: 'Souliyo',
          ),
          home: _defaultHome,
          onGenerateRoute: RouteGenerator.generateRoute,
          initialRoute: '/loading'),
    );
  }
}
