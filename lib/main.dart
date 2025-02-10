import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lecturas_usiap_movil/database/firebase_options.dart';
import 'package:lecturas_usiap_movil/src/inicio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DefaultFirebaseOptions.currentPlatform;
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Inicio(),
    );
  }
}
