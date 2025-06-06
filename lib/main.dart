import 'package:dashboard_perpus/login_page.dart';
import 'package:dashboard_perpus/register_page.dart';
import 'package:dashboard_perpus/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'home_page.dart';

Future<void> main() async { // Make sure main is async
  WidgetsFlutterBinding.ensureInitialized(); // Ensures Flutter bindings are ready
  await initializeDateFormatting('id_ID');   // Initialize for Indonesian locale
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginPage(),
        '/register': (context) => RegisterPage(),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return HomePage(
            namaUser: args['namaUser'],
            accountId: args['accountId'],
          );
        },
        // Add other routes like '/profile', '/booking' if you navigate to them directly using named routes
      },
    );
  }
}