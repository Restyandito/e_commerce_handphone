import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class DetailPage extends StatefulWidget {
  final String? kota_asal;
  final String? kota_tujuan;
  final String? berat;
  final String? kurir;

  const DetailPage({super.key, this.kota_asal, this.kota_tujuan, this.berat, this.kurir});

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List listData = [];
  var strKey = "ef51b58f400ec2ef2cb839759450bdb3";

  final Map<String, String> courierLogos = {
    "jne": "assets/images/jne_logo.png",
    "tiki": "assets/images/tiki_logo.png",
    "pos": "assets/images/pos_logo.png",
  };

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future getData() async {
    try {
      final response = await http.post(
        Uri.parse("https://api.rajaongkir.com/starter/cost"),
        body: {
          "key": strKey,
          "origin": widget.kota_asal,
          "destination": widget.kota_tujuan,
          "weight": widget.berat,
          "courier": widget.kurir
        },
      );

      var data = jsonDecode(response.body);
      setState(() {
        listData = data['rajaongkir']['results'][0]['costs'];
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              courierLogos[widget.kurir?.toLowerCase()] ?? 'assets/default_logo.png',
              width: 30,
              height: 30,
            ),
            const SizedBox(width: 10),
            Text(
              "Detail Ongkos Kirim ${widget.kurir?.toUpperCase()}",
              style: const TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: listData.isEmpty
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : ListView.builder(
        itemCount: listData.length,
        itemBuilder: (_, index) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    courierLogos[widget.kurir?.toLowerCase()] ?? 'assets/default_logo.png',
                    width: 50,
                    height: 50,
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${listData[index]['service']}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Inter',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "${listData[index]['description']}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontFamily: 'Inter',
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Rp ${listData[index]['cost'][0]['value']}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "${listData[index]['cost'][0]['etd']} Hari",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
