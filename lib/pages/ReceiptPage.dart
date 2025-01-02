import 'package:flutter/material.dart';
import 'package:intl/intl.dart';  // Import intl untuk format angka
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth

class ReceiptPage extends StatelessWidget {
  final double amount;

  const ReceiptPage({Key? key, required this.amount, required String name, required String phone, required String city, required String postalCode}) : super(key: key);

  // Fungsi untuk mengambil data pengguna dari Firestore berdasarkan uid
  Future<Map<String, String>> _getUserData(User user) async {
    Map<String, String> userData = {
      'name': "Nama tidak tersedia",
      'phone': "Nomor telepon tidak tersedia",
      'city': "Kota tidak ditemukan",
      'postalCode': "Kode Pos tidak ditemukan",
    };

    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        userData['name'] = doc['name'] ?? "Nama tidak ditemukan";
        userData['phone'] = doc['phone'] ?? "Nomor telepon tidak ditemukan";
        userData['city'] = doc['city'] ?? "Kota tidak ditemukan";
        userData['postalCode'] = doc['postalCode'] ?? "Kode Pos tidak ditemukan";
      }
    } catch (e) {
      userData['name'] = "Gagal memuat data pengguna.";
    }
    return userData;
  }

  @override
  Widget build(BuildContext context) {
    // Format angka dengan pemisah ribuan dan dua angka nol
    String formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(amount);

    // Ambil timestamp pembelian
    String formattedTimestamp = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

    // Ambil user saat ini dari Firebase Auth
    User? user = FirebaseAuth.instance.currentUser;

    // Gunakan FutureBuilder untuk menunggu pengambilan data pengguna
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resi Pembayaran'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center( // Gunakan Center untuk menempatkan semua widget di tengah layar
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.black.withOpacity(0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Mengatur semua elemen dalam Column agar terpusat
              crossAxisAlignment: CrossAxisAlignment.center, // Untuk menyesuaikan konten secara horizontal
              children: [
                // Judul dan icon resi
                Icon(
                  Icons.receipt_long,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 10),
                Text(
                  'Resi Pembayaran',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    fontFamily: 'Inter',  // Menambahkan font Inter
                  ),
                  textAlign: TextAlign.center,  // Memastikan teks judul berada di tengah
                ),
                const SizedBox(height: 10),

                // Timestamp Pembelian
                Text(
                  formattedTimestamp,
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,  // Menempatkan timestamp di tengah
                ),
                const Divider(
                  color: Colors.black,
                  height: 20,
                  thickness: 1,
                ),

                // Menampilkan data pengguna menggunakan FutureBuilder
                FutureBuilder<Map<String, String>>(
                  future: _getUserData(user!), // Ambil data pengguna dari Firestore
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Text(
                        "Memuat data pengguna...",
                        textAlign: TextAlign.center,  // Memastikan teks di tengah
                      );
                    } else if (snapshot.hasError) {
                      return Text(
                        "Terjadi kesalahan saat memuat data pengguna.",
                        textAlign: TextAlign.center,
                      );
                    } else if (snapshot.hasData) {
                      var userData = snapshot.data!;
                      return Column(
                        children: [
                          SizedBox(height: 5),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Nama Pembeli: ${userData['name']}',
                              style: TextStyle(fontSize: 16, fontFamily: 'Inter', ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Nomor Telepon: ${userData['phone']}',
                              style: TextStyle(fontSize: 16, fontFamily: 'Inter', ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Kota: ${userData['city']}',
                              style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'Kode Pos: ${userData['postalCode']}',
                              style: TextStyle(fontSize: 16, fontFamily: 'Inter'),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Text(
                        'Data pengguna tidak ditemukan',
                        textAlign: TextAlign.center,
                      );
                    }
                  },
                ),

                const SizedBox(height: 5),
                Divider(
                  color: Colors.black.withOpacity(0.5),
                  height: 20,
                  thickness: 1,
                ),

                // Menambahkan SizedBox untuk mengatur jarak
                SizedBox(height: 10),

                // Detail harga
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,  // Menjaga posisi harga tetap terpusat
                  children: [
                    Text(
                      'Total Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formattedAmount,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Inter'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Divider(
                  color: Colors.black.withOpacity(0.5),
                  height: 20,
                  thickness: 1,
                ),

                // Tombol Kembali
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(200, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Inter'),
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
