import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'register.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inshare',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Mengatur font default menggunakan Lexend Deca
        textTheme: GoogleFonts.lexendDecaTextTheme(),
        // primarySwatch: Colors.blue, // Warna tema utama
      ),
      home: const RegisterScreen(),
    );
  }
}
