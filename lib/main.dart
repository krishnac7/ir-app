import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'screens/pnr_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/seats_screen.dart';
import 'screens/fare_screen.dart';

void main() => runApp(const IRApp());

class IRApp extends StatelessWidget {
  const IRApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Indian Railways Enquiry',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF337ab7)),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF337ab7),
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/':        (_) => const HomeScreen(),
        '/pnr':     (_) => const PnrScreen(),
        '/schedule':(_) => const ScheduleScreen(),
        '/seats':   (_) => const SeatsScreen(),
        '/fare':    (_) => const FareScreen(),
      },
    );
  }
}
