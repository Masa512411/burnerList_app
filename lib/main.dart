import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:burner_list/providers/settings_provider.dart';
import 'package:burner_list/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: BurnerListApp()));
}

class BurnerListApp extends ConsumerWidget {
  const BurnerListApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    final lightTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF5722),
        brightness: Brightness.light,
      ),
      textTheme: GoogleFonts.outfitTextTheme(),
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
    );

    final darkTheme = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFF5722),
        brightness: Brightness.dark,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
    );

    return MaterialApp(
      title: 'Burner List',
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
      home: const HomeScreen(),
    );
  }
}
