import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firestore
import '../services/fonnte_service.dart';
import 'login.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String password;
  final String phoneNumber;
  final String city;
  final String postalCode;

  OTPVerificationScreen({
    required this.name,
    required this.email,
    required this.password,
    required this.phoneNumber,
    required this.city,
    required this.postalCode,
  });

  @override
  _OTPVerificationScreenState createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final List<TextEditingController> otpControllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isLoading = false;  // Variabel untuk mengontrol loading spinner

  Future<void> verifyOTP() async {
    final otp = otpControllers.map((controller) => controller.text).join();

    if (otp.length == 6) {
      setState(() {
        _isLoading = true; // Mulai loading ketika OTP dimasukkan
      });

      final phoneNumber = widget.phoneNumber;
      if (FonnteService.verifyOTP(phoneNumber, otp)) {
        try {
          // Buat akun di Firebase Authentication
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

          // Menyimpan data pengguna ke Firestore setelah berhasil registrasi
          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
            'name': widget.name,
            'email': widget.email,
            'phone': widget.phoneNumber,
            'city': widget.city,
            'postalCode' : widget.postalCode,
            'uid': userCredential.user!.uid,
            'createdAt': FieldValue.serverTimestamp(),  // Menambahkan timestamp
          });

          // Menampilkan notifikasi bahwa registrasi berhasil
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registrasi berhasil!")),
          );

          // Navigasi ke layar Login setelah sukses
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
          );
        } catch (e) {
          setState(() {
            _isLoading = false; // Matikan loading setelah selesai
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to create account: ${e.toString()}")),
          );
        }
      } else {
        setState(() {
          _isLoading = false; // Matikan loading setelah selesai
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Invalid OTP. Please try again.")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid 6-digit OTP.")),
      );
    }
  }

  @override
  void dispose() {
    // Pastikan untuk membebaskan FocusNode saat halaman dihapus
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
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
                  "Verifikasi OTP",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 40),

                Text(
                  "Masukkan OTP yang telah dikirimkan ke nomor ${widget.phoneNumber}",
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center
                ),
                const SizedBox(height: 40),

                // Input OTP dalam kotak-kotak
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      child: TextField(
                        controller: otpControllers[index],
                        focusNode: focusNodes[index],
                        autofocus: index == 0, // Fokus otomatis pada kotak pertama
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          counterText: '',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty) {
                            // Jika user mengisi angka dan bukan angka kosong
                            if (index < 5) {
                              FocusScope.of(context).requestFocus(focusNodes[index + 1]);
                            }
                          } else {
                            // Jika user menghapus angka, fokus akan pindah ke kiri
                            if (index > 0) {
                              FocusScope.of(context).requestFocus(focusNodes[index - 1]);
                            }
                          }

                          // Cek apakah semua input OTP sudah terisi
                          if (otpControllers.every((controller) => controller.text.isNotEmpty)) {
                            verifyOTP();  // Jika sudah selesai, langsung verifikasi OTP
                          }
                        },
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),

                // Menampilkan spinner loading jika sedang memproses OTP
                if (_isLoading)
                  Center(child: CircularProgressIndicator()),

                // Tombol Verifikasi OTP
                if (!_isLoading)
                  ElevatedButton(
                    onPressed: verifyOTP,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      "Verifikasi OTP",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                const SizedBox(height: 24),

                // Tautan Kembali ke Halaman Login
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Sudah punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
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
