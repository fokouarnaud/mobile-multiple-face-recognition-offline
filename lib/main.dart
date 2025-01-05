import 'dart:developer' as devtools show log;

import 'package:computer/computer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutterface/config/routes.dart';
import 'package:flutterface/services/snackbar/snackbar_service.dart';
import 'package:logging/logging.dart';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    devtools.log(
      '[${record.loggerName}]: ${record.level.name}: ${record.time}: ${record.message}',
    );
  });

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Computer.shared().turnOn(workersCount: 2);
  Routes.configureRoutes();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();

    return MaterialApp(
      title: 'Face Recognition',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      scaffoldMessengerKey: SnackbarService.instance.scaffoldMessengerKey,
      onGenerateRoute: Routes.router.generator,
      initialRoute: Routes.root,
    );
  }
}