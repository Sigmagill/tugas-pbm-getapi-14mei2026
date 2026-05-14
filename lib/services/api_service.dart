import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/product_model.dart';

class ApiService {
  static const String baseUrl = 'https://task.itprojects.web.id';
  static const _storage = FlutterSecureStorage();

  // ─── Simpan & Ambil Token ───────────────────────────────────────
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }

  // ─── Header dengan Bearer Token ────────────────────────────────
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ─── 1. LOGIN ───────────────────────────────────────────────────
  static Future<Map<String, dynamic>> login(String nim) async {
    final url = Uri.parse('$baseUrl/api/auth/login');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'username': nim, 'password': nim}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['data']['token'];
      await saveToken(token);
      return {'success': true, 'message': 'Login berhasil'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Login gagal'};
    }
  }

  // ─── 2. GET PRODUK ──────────────────────────────────────────────
  static Future<List<Product>> getProducts() async {
  final url = Uri.parse('$baseUrl/api/products');
  final headers = await _authHeaders();
  final response = await http.get(url, headers: headers);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final List list = data['data']['products']; // ← fix di sini
    return list.map((item) => Product.fromJson(item)).toList();
  } else {
    throw Exception('Gagal mengambil produk: ${response.body}');
  }
}

  // ─── 3. SIMPAN DRAFT PRODUK ─────────────────────────────────────
  static Future<Map<String, dynamic>> saveProduct(Product product) async {
    final url = Uri.parse('$baseUrl/api/products');
    final headers = await _authHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(product.toJson()),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': 'Produk berhasil disimpan'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal menyimpan'};
    }
  }

  // ─── 4. DELETE PRODUK ───────────────────────────────────────────
  static Future<Map<String, dynamic>> deleteProduct(int id) async {
    final url = Uri.parse('$baseUrl/api/products/$id');
    final headers = await _authHeaders();
    final response = await http.delete(url, headers: headers);

    if (response.statusCode == 200) {
      return {'success': true};
    } else {
      return {'success': false, 'message': 'Gagal menghapus'};
    }
  }

  // ─── 5. SUBMIT TUGAS ────────────────────────────────────────────
  static Future<Map<String, dynamic>> submitTugas({
    required String name,
    required int price,
    required String description,
    required String githubUrl,
  }) async {
    final url = Uri.parse('$baseUrl/api/products/submit');
    final headers = await _authHeaders();
    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode({
        'name': name,
        'price': price,
        'description': description,
        'github_url': githubUrl,
      }),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {'success': true, 'message': 'Tugas berhasil dikumpulkan!'};
    } else {
      return {'success': false, 'message': data['message'] ?? 'Gagal submit'};
    }
  }
}