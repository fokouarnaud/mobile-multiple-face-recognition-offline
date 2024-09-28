import 'dart:developer' as devtools show log;
import 'package:computer/computer.dart';
import 'package:flutter/material.dart';
import 'package:flutterface/ui/home_page.dart';
import 'package:logging/logging.dart';

/// Configures logging for the application.
///
/// Sets the root logger level to capture all log messages (INFO, DEBUG, etc.)
/// and redirects them to the developer tools for display.
void main() async {
  // Set up logging
  Logger.root.level = Level.ALL; // Capture all log levels
  Logger.root.onRecord.listen((record) {
    devtools.log(
      '[${record.loggerName}]: ${record.level.name}: ${record.time}: ${record.message}',
    );
  });
  await Computer.shared().turnOn(workersCount: 2);
  runApp(const MyApp());
}

/// The main application widget.
///
/// This widget defines the root of the application's widget tree.
/// It uses the MaterialApp widget to configure the application's title, theme,
/// and home screen.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'FlutterFace Demo'),
    );
  }
}
