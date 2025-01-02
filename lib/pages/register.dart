import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/fonnte_service.dart';
import 'otp_verification.dart';
import 'package:flutter/services.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController(); // Menambahkan controller untuk Nama
  final TextEditingController cityController = TextEditingController(); // Menambahkan controller untuk Kota
  final TextEditingController postalCodeController = TextEditingController(); // Menambahkan controller untuk Kode Pos
  bool _obscurePassword = true;

  Future<void> sendOTP() async {
    final email = emailController.text.trim();
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final phoneNumber = phoneController.text.trim();
    final city = cityController.text.trim();
    final postalCode = postalCodeController.text.trim();

    if (email.isEmpty || password.isEmpty || phoneNumber.isEmpty || name.isEmpty || city.isEmpty || postalCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("All fields are required.")),
      );
      return;
    }

    try {
      // Kirim OTP melalui Fonnte
      await FonnteService.sendOTP(phoneNumber);

      // Navigasi ke layar OTP Verification setelah OTP berhasil dikirim
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => OTPVerificationScreen(
            name: name,
            email: email,
            password: password,
            phoneNumber: phoneNumber,
            city: city,
            postalCode: postalCode, // Mengirim data alamat ke halaman OTP Verification
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send OTP: ${e.toString()}")),
      );
    }
  }

  // Method untuk mendaftar dan menyimpan data pengguna ke Firestore
  Future<void> registerUser(String email, String password, String phoneNumber, String name, String province, String city, String postalCode) async {
    try {
      // Registrasi pengguna dengan Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Menyimpan data pengguna ke koleksi 'users' Firestore setelah berhasil registrasi
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'name': name,  // Menyimpan nama pengguna
        'email': email,
        'phone': phoneNumber,
        'uid': userCredential.user!.uid,
        'city': city, // Menyimpan kota
        'postalCode': postalCode, // Menyimpan kode pos
        'createdAt': FieldValue.serverTimestamp(),  // Menambahkan timestamp
      });

      // Konfirmasi registrasi berhasil
      print("User registered successfully");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("User registered and data saved to Firestore")),
      );
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registration failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daftar",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                // Input Nama Pengguna
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: "Masukkan nama Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Input Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Masukkan email Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Input Phone Number
                TextField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: "Nomor Telepon",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),

                // Input Kota dan Kode Pos sejajar dengan padding bawah
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),  // Menambahkan padding bawah
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: "Masukkan Kota",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),  // Jarak antar kolom
                      Expanded(
                        child: TextField(
                          controller: postalCodeController,
                          decoration: InputDecoration(
                            labelText: "Masukkan Kode Pos",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(5),  // Membatasi input sampai 5 karakter
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Input Password
                TextField(
                  controller: passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: "Masukkan kata sandi Anda",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Tombol Daftar
                ElevatedButton(
                  onPressed: sendOTP,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Daftar",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                const SizedBox(height: 24),

                // Tautan Masuk
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context); // Kembali ke halaman login
                      },
                      child: const Text(
                        "Masuk",
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
