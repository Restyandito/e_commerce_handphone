import 'package:http/http.dart' as http;
import 'dart:math';

class FonnteService {
  static const String apiKey = 'stoMk8AasL8zZfNaGoAe';
  static const String baseUrl = 'https://api.fonnte.com/send';
  static Map<String, String> otpStorage = {}; // Simpan OTP sementara

  static Future<void> sendOTP(String phoneNumber) async {
    final otp = generateOTP();
    otpStorage[phoneNumber] = otp; // Simpan OTP untuk verifikasi

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': apiKey,
        },
        body: {
          'target': phoneNumber,
          'message': 'Jangan lama-lama, kode OTP ini cuma aktif sesaat. Yuk, buruan dimasukin! 😉 Nih Kodemu: $otp',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to send OTP');
      }
    } catch (e) {
      rethrow;
    }
  }

  static bool verifyOTP(String phoneNumber, String otp) {
    final storedOTP = otpStorage[phoneNumber];
    if (storedOTP == null) return false;

    final isValid = storedOTP == otp;
    if (isValid) {
      otpStorage.remove(phoneNumber); // Hapus OTP setelah verifikasi sukses
    }
    return isValid;
  }

  static String generateOTP() {
    return Random().nextInt(999999).toString().padLeft(6, '0');
  }
}
