import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Variabel untuk mengatur visibilitas password
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;

  Future<void> updatePassword() async {
    final email = emailController.text.trim();
    final currentPassword = currentPasswordController.text.trim();
    final newPassword = newPasswordController.text.trim();

    if (email.isEmpty || currentPassword.isEmpty || newPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please fill all fields.")),
      );
      return;
    }

    try {
      // Login dengan email dan password lama untuk memverifikasi kredensial
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: currentPassword,
      );

      // Jika login berhasil, kita bisa mengupdate password
      await userCredential.user!.updatePassword(newPassword);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Berhasil Mengubah Kata Sandi!.")),
      );

      // Kembali ke halaman login setelah berhasil mengubah password
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal Mengubah Kata Sandi: ${e.toString()}")),
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
                  "Ubah Kata Sandi",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

                // Menambahkan gambar di bawah teks "Change Password"
                Center(
                  child: Image.asset(
                    'assets/images/change_password_image.png', // Ganti dengan path gambar Anda
                    width: 200,  // Ukuran gambar
                    height: 200, // Ukuran gambar
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 40),

                // Input Email
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),

                // Input Current Password
                TextField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: "Password Lama",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureCurrentPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureCurrentPassword,
                ),
                const SizedBox(height: 16),

                // Input New Password
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: "Password Baru",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscureNewPassword,
                ),
                const SizedBox(height: 24),

                // Tombol Update Password
                ElevatedButton(
                  onPressed: updatePassword,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: const Text(
                    "Ganti Kata Sandi",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
