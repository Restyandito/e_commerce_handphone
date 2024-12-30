import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'pages/login.dart';
import 'pages/register.dart';
import 'pages/home.dart';

void main() async {
  // Pastikan Firebase diinisialisasi terlebih dahulu sebelum menjalankan aplikasi
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();  // Inisialisasi Firebase
  Stripe.publishableKey = "pk_test_51QbRL0LeDQo9end5Yy4aBxEQmOuF6honGvt9HxwTIBst3kj9CTTBZUhmYHcGOVgsBMtyjtMBNQX1qQB4SzNxS9T200WzxrgkCu";  // Ganti dengan kunci Stripe Anda
  await Stripe.instance.applySettings(); // Apply Stripe settings

  runApp(const MyApp());
}

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
      // Menambahkan Named Routes
      initialRoute: '/login',  // Set rute awal ke halaman login
      routes: {
        '/': (context) => LoginScreen(), // Halaman utama setelah login
        '/login': (context) => LoginScreen(), // Halaman login
        '/register': (context) => RegisterScreen(), // Menambahkan route untuk halaman register
        '/home': (context) => HomeScreen(), // Menambahkan route untuk halaman home
      },
    );
  }
}
