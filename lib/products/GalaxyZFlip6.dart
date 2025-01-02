import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';  // Import intl untuk format angka
import 'package:cloud_firestore/cloud_firestore.dart';  // Import Firebase Firestore
import 'package:firebase_auth/firebase_auth.dart';  // Import Firebase Auth
import 'package:carousel_slider/carousel_slider.dart';
import '../pages/ReceiptPage.dart';
import '../pages/ShippingPage.dart'; // Import halaman pengecekan ongkir

class GalaxyZFlip6Page extends StatefulWidget {
  const GalaxyZFlip6Page({super.key});

  @override
  State<GalaxyZFlip6Page> createState() => _GalaxyZFlip6PageState();
}

class _GalaxyZFlip6PageState extends State<GalaxyZFlip6Page> {
  String publishableKey = "pk_test_51QbRL0LeDQo9end5Yy4aBxEQmOuF6honGvt9HxwTIBst3kj9CTTBZUhmYHcGOVgsBMtyjtMBNQX1qQB4SzNxS9T200WzxrgkCu";
  String secretKey = "sk_test_51QbRL0LeDQo9end5AbxmGOrz5Aezacy9pw1wVR77iZUsdueTkDM49L3xnUSsqf0pViK41OhFN9nLnJtQrffJQnrc00vFFRORJQ";

  double amount = 13000000;  // Harga per produk
  int quantity = 1;  // Jumlah produk yang ingin dibeli
  Map<String, dynamic>? IntentPaymentData;
  String customerName = ""; // Inisialisasi variabel customerName

  @override
  void initState() {
    super.initState();
    // Ambil nama pengguna yang sedang login
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      customerName = user.displayName ?? user.email ?? "Nama Pengguna";
    }
  }

  // Fungsi untuk menampilkan pembayaran menggunakan Stripe
  showPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet().then((val) {
        setState(() {
          IntentPaymentData = null;
        });
        // Simpan transaksi ke Firebase setelah pembayaran berhasil
        savePurchaseToFirebase();

        // Navigasi ke halaman resi setelah pembayaran berhasil
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPage(amount: amount * quantity, name: '', phone: '', city: '', postalCode: '',),
          ),
        );
      }).onError((errorMsg, sTrace) {
        if (kDebugMode) {
          print(errorMsg.toString() + sTrace.toString());
        }
      });
    } on StripeException catch (error) {
      if (kDebugMode) {
        print(error);
      }

      showDialog(
        context: context,
        builder: (c) => const AlertDialog(
          content: Text("Pembayaran dibatalkan."),
        ),
      );
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  // Fungsi untuk menyimpan data pembelian ke Firestore
  savePurchaseToFirebase() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('purchases').add({
        'product': 'Samsung Galaxy Z Flip 6',  // Nama produk yang dibeli
        'quantity': quantity,   // Jumlah produk yang dibeli
        'total_price': amount * quantity,  // Total harga produk
        'customer_name': customerName,  // Nama pelanggan
        'timestamp': FieldValue.serverTimestamp(),  // Timestamp pembelian
      });

      if (kDebugMode) {
        print("Transaksi berhasil disimpan ke Firestore");
      }
    } catch (e) {
      if (kDebugMode) {
        print("Gagal menyimpan transaksi: $e");
      }
    }
  }

  makeIntentForPayment(amountToBeCharge, currency) async {
    try {
      Map<String, dynamic>? paymentInfo = {
        "amount": (int.parse(amountToBeCharge) * 100).toString(),
        "currency": currency,
        "payment_method_types[]": "card",
      };

      var responseFromStripeAPI = await http.post(
        Uri.parse("https://api.stripe.com/v1/payment_intents"),
        body: paymentInfo,
        headers: {
          "Authorization": "Bearer $secretKey",
          "Content-Type": "application/x-www-form-urlencoded",
        },
      );

      print("response from API = ${responseFromStripeAPI.body}");

      return jsonDecode(responseFromStripeAPI.body);
    } catch (errorMsg) {
      if (kDebugMode) {
        print(errorMsg);
      }
      print(errorMsg.toString());
    }
  }

  paymentSheetInitialization(amountToBeCharge, currency) async {
    try {
      IntentPaymentData = await makeIntentForPayment(amountToBeCharge, currency);

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          allowsDelayedPaymentMethods: true,
          paymentIntentClientSecret: IntentPaymentData!["client_secret"],
          style: ThemeMode.dark,
          merchantDisplayName: "Company Name",
        ),
      ).then((val) {
        print(val);
      });

      showPaymentSheet();
    } catch (errorMsg, s) {
      if (kDebugMode) {
        print(s);
      }
      print(errorMsg.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Format angka dengan pemisah ribuan dan dua angka nol
    String formattedAmount = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 2).format(amount * quantity);

    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Samsung Galaxy Z Flip 6',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.local_shipping),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ShippingPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(12),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    enlargeCenterPage: true,
                  ),
                  items: [
                    'https://asset-2.tstatic.net/tribunnews/foto/bank/images/samsung-galaxy-z-flip-6-768.jpg',
                    'https://images.samsung.com/id/smartphones/galaxy-z-flip6/buy/product_color_white_MO_v2.png',
                    'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTa_Da1UUZPz5YQEEW4-4FS7F96DFsgowEmfiyKSFPWwdzMK-RP5zpPtr5TsUu70J7Zo8M&usqp=CAU',
                  ].map((url) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: MediaQuery.of(context).size.width,
                        );
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Desain Lipat Elegan dengan Performa Tangguh',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Galaxy Z Flip 6 hadir dengan layar lipat fleksibel 6,7 inci, chip Snapdragon 8 Gen 2, dan desain kompak, ideal untuk mobilitas tinggi.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Harga: $formattedAmount',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        setState(() {
                          if (quantity > 1) quantity--;
                        });
                      },
                    ),
                    Text(
                      '$quantity',
                      style: const TextStyle(fontSize: 24),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() {
                          quantity++;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      paymentSheetInitialization(
                        (amount * quantity).round().toString(),
                        "IDR",
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Text(
                      'Beli Sekarang',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
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
