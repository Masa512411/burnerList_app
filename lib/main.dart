import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:burner_list/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: BurnerListApp()));
}

class BurnerListApp extends StatelessWidget {
  const BurnerListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Burner List',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFF5722), // Burner orange
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.outfitTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      ),
      home: const HomeScreen(),
    );
  }
}
