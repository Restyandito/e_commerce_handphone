import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Impor FirebaseAuth untuk menghapus akun
import 'package:carousel_slider/carousel_slider.dart'; // Import CarouselSlider
import 'package:animated_text_kit/animated_text_kit.dart'; // Import Animated Text Kit
import '../products/GalaxyZFlip6.dart';
import '../products/Iphone16Pro.dart'; // Impor halaman Iphone16Pro
import '../products/SamsungGalaxyS24Ultra.dart'; // Impor halaman Samsung Galaxy S24 Ultra
import '../products/Iphone15.dart'; // Impor halaman Iphone 15
import '../products/XiaomiMi13Pro.dart'; // Impor halaman Xiaomi Mi 13 Pro
import '../products/GooglePixel8Pro.dart'; // Impor halaman Google Pixel 8 Pro
import 'login.dart';

class HomeScreen extends StatelessWidget {
  final List<Map<String, String>> products = [
    {
      'name': 'Samsung Flip 6',
      'image': 'https://www.static-src.com/wcsstore/Indraprastha/images/catalog/full/catalog-image/103/MTA-176735911/samsung_samsung_galaxy_z_flip_6_-sm-f741b-_12-256gb_-_silver_full01_ehl13703.jpg',
      'price': 'Rp 13.000.000',
    },
    {
      'name': 'Iphone 16 Pro',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQGrBlNiOTf6g9sCtmEIbr1WoImyKdUsj2dCw&s',
      'price': 'Rp 22.000.000',
    },
    {
      'name': 'Samsung S24 Ultra',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQNZnLRuCvYgmvh-T8pSVGF8BWebGwBr-IxUw&s',  // Ganti dengan gambar produk lainnya
      'price': 'Rp 18.499.000',
    },
    {
      'name': 'IPhone 15',
      'image': 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSheEdY89F4aW9qOfzrTNXftNB5hVrg3bqYDw&s',
      'price': 'Rp 13.000.000',
    },
    {
      'name': 'Xiaomi Mi 13 Pro',
      'image': 'https://mobilguru.by/image/cache/catalog/i/op/nb/8bf8f1624518a632700339809d8be98f-500x400.png',
      'price': 'Rp 12.000.000',
    },
    {
      'name': 'Google Pixel 8 Pro',
      'image': 'https://lh3.googleusercontent.com/KaLIFYVg9298b8jv33H3pagRaAz4lCQxrQz-goMEsiTuCmUf2Ood9ktkzgjpotkMuRcAMimOV2RfN7vBZVmnInf5wcwUNsRZpw',
      'price': 'Rp 15.000.000',
    },
  ];

  // Daftar gambar untuk carousel
  final List<String> carouselImages = [
    'https://img.freepik.com/premium-photo/mobile-phones-store-generative-ai_220873-21824.jpg',
    'https://i.gadgets360cdn.com/large/iphone_in_store_purchase_image_apple_1627478772369.jpg',
    'https://s3b.cashify.in/gpro/uploads/2022/02/19015346/Signs-You-Need-a-New-Phone-8.jpg',
    'https://static1.makeuseofimages.com/wordpress/wp-content/uploads/2022/04/Samsung-Z-Flip-Case-Pexels.jpg',
  ];

  // Fungsi untuk menghapus akun
  Future<void> _deleteAccount(BuildContext context) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Hapus akun
        await user.delete();

        // Tampilkan notifikasi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Akun berhasil dihapus."),
            backgroundColor: Colors.green,
          ),
        );

        // Navigasi kembali ke halaman login setelah menghapus akun
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } catch (e) {
      // Tampilkan error jika terjadi kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat menghapus akun."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fungsi untuk log out
  Future<void> _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // Tampilkan notifikasi log out berhasil
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Berhasil log out."),
          backgroundColor: Colors.green,
        ),
      );

      // Navigasi kembali ke halaman login setelah log out
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      // Tampilkan error jika terjadi kesalahan saat log out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Terjadi kesalahan saat log out."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(
            'Selamat Datang!',
            style: TextStyle(
              fontFamily: 'Inter', // Gunakan font yang ditambahkan
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        actions: [
          PopupMenuButton<int>(
            onSelected: (int result) {
              if (result == 0) {
                // Log Out - Panggil fungsi untuk log out
                _logOut(context);
              } else if (result == 1) {
                // Hapus Akun - Panggil fungsi untuk menghapus akun
                _deleteAccount(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem<int>(
                value: 0,
                child: Text("Log Out"),
              ),
              PopupMenuItem<int>(
                value: 1,
                child: Text("Delete Account"),
              ),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Carousel untuk gambar dengan border lengkung
            CarouselSlider(
              options: CarouselOptions(
                height: 160,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: carouselImages.map((url) {
                return Builder(
                  builder: (BuildContext context) {
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(7), // Menambahkan border lengkung
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: MediaQuery.of(context).size.width,
                      ),
                    );
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // Efek mengetik pada teks "Pilih produk apa hari ini?"
            TypewriterAnimatedTextKit(
              text: ['Pilih produk apa hari ini?'],
              textStyle: TextStyle(
                fontFamily: 'Inter', // Gunakan font yang ditambahkan
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center, // Rata tengah
              speed: Duration(milliseconds: 100), // Kecepatan mengetik
            ),
            const SizedBox(height: 20),
            // Grid untuk produk
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dua kolom
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 0.75, // Sesuaikan rasio aspek untuk card
                ),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      // Navigasi ke halaman produk berdasarkan indeks
                      if (index == 0) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GalaxyZFlip6Page()),
                        );
                      } else if (index == 1) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Iphone16ProPage()),
                        );
                      } else if (index == 2) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => SamsungGalaxyS24UltraPage()),
                        );
                      } else if (index == 3) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Iphone15Page()),
                        );
                      } else if (index == 4) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => XiaomiMi13ProPage()),
                        );
                      } else if (index == 5) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GooglePixel8ProPage()),
                        );
                      }
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                            child: Image.network(
                              products[index]['image']!,
                              fit: BoxFit.cover,
                              height: 150,
                              width: double.infinity,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  products[index]['name']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  products[index]['price']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
