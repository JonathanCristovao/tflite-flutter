import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roseai/widget/camera_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
      [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    return MaterialApp(
      title: 'Rose AI',
      theme: ThemeData.light(),
      home: CameraViewPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
