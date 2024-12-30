import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../model/model_kota.dart';
import 'detail_page.dart';  // Pastikan halaman detail ada dan disesuaikan

class ShippingPage extends StatefulWidget {
  const ShippingPage({Key? key}) : super(key: key);

  @override
  State<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends State<ShippingPage> {
  var strKey = "ef51b58f400ec2ef2cb839759450bdb3";
  var strKotaAsal;
  var strKotaTujuan;
  var strBerat;
  var strEkspedisi;

  final Map<String, String> courierLogos = {
    "JNE": "assets/images/jne_logo.png",
    "TIKI": "assets/images/tiki_logo.png",
    "POS": "assets/images/pos_logo.png",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Cek Ongkos Kirim",
          style: TextStyle(
            fontFamily: 'Inter', // Menetapkan font Inter untuk judul
            fontWeight: FontWeight.bold, // Menggunakan font-bold
            color: Colors.white, // Mengubah warna teks menjadi putih
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.black, // Menyesuaikan dengan tema UI sebelumnya
        iconTheme: const IconThemeData(
          color: Colors.white, // Mengubah warna ikon menjadi putih
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Menambahkan logo di atas judul
                Image.asset(
                  'assets/images/courier.png', // Ganti dengan logo yang sesuai
                  height: 300, // Menyesuaikan ukuran logo
                  width: 3000, // Menyesuaikan ukuran logo
                ),
                const SizedBox(height: 0),

                // Heading kiri dengan styling
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Isi Detail Pengiriman",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Kota Asal Dropdown
                DropdownSearch<ModelKota>(
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Kota Asal",
                      hintText: "Pilih Kota Asal",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  ),
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                  ),
                  onChanged: (value) {
                    strKotaAsal = value?.cityId;
                  },
                  itemAsString: (item) => "${item.type} ${item.cityName}",
                  asyncItems: (text) async {
                    var response = await http.get(Uri.parse("https://api.rajaongkir.com/starter/city?key=$strKey"));
                    List allKota = (jsonDecode(response.body) as Map<String, dynamic>)['rajaongkir']['results'];
                    var dataKota = ModelKota.fromJsonList(allKota);
                    return dataKota;
                  },
                ),
                const SizedBox(height: 20),

                // Kota Tujuan Dropdown
                DropdownSearch<ModelKota>(
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Kota Tujuan",
                      hintText: "Pilih Kota Tujuan",
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  ),
                  popupProps: const PopupProps.menu(
                    showSearchBox: true,
                  ),
                  onChanged: (value) {
                    strKotaTujuan = value?.cityId;
                  },
                  itemAsString: (item) => "${item.type} ${item.cityName}",
                  asyncItems: (text) async {
                    var response = await http.get(Uri.parse("https://api.rajaongkir.com/starter/city?key=$strKey"));
                    List allKota = (jsonDecode(response.body) as Map<String, dynamic>)['rajaongkir']['results'];
                    var dataKota = ModelKota.fromJsonList(allKota);
                    return dataKota;
                  },
                ),
                const SizedBox(height: 20),

                // Berat Paket TextField
                TextField(
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: "Berat Paket (gram)",
                    hintText: "Input Berat Paket",
                    prefixIcon: Icon(Icons.scale),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  ),
                  onChanged: (text) {
                    strBerat = text;
                  },
                ),
                const SizedBox(height: 20),

                // Kurir Dropdown with Logos
                DropdownSearch<String>(
                  items: courierLogos.keys.toList(),
                  dropdownDecoratorProps: const DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: "Kurir",
                      hintText: "Pilih Kurir",
                      prefixIcon: Icon(Icons.local_shipping),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    itemBuilder: (context, item, isSelected) {
                      return ListTile(
                        leading: Image.asset(
                          courierLogos[item]!,
                          width: 30,
                          height: 30,
                        ),
                        title: Text(item),
                      );
                    },
                  ),
                  onChanged: (text) {
                    strEkspedisi = text?.toLowerCase();
                  },
                ),
                const SizedBox(height: 30),

                // Cek Ongkir Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    elevation: 10,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () {
                    if (strKotaAsal == null ||
                        strKotaTujuan == null ||
                        strBerat == null ||
                        strEkspedisi == null) {
                      const snackBar = SnackBar(
                        content: Text("Ups, form tidak boleh kosong!"),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      // Navigasi ke halaman DetailPage setelah pengecekan ongkir
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPage(
                            kota_asal: strKotaAsal,
                            kota_tujuan: strKotaTujuan,
                            berat: strBerat,
                            kurir: strEkspedisi,
                          ),
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Cek Ongkir",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
