import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'bmbdesigns/commandline.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      initialRoute: "/cmd",
      debugShowCheckedModeBanner: false,
      routes: {
        "/cmd": (context) => CommandLine(),
      },
    ),
  );
}
