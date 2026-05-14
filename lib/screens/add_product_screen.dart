import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final bool isSubmit; // true = submit tugas, false = draft produk
  const AddProductScreen({super.key, required this.isSubmit});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _githubController = TextEditingController();
  bool _isLoading = false;

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    Map<String, dynamic> result;

    if (widget.isSubmit) {
      result = await ApiService.submitTugas(
        name: _nameController.text.trim(),
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        description: _descController.text.trim(),
        githubUrl: _githubController.text.trim(),
      );
    } else {
      final product = Product(
        name: _nameController.text.trim(),
        price: int.tryParse(_priceController.text.trim()) ?? 0,
        description: _descController.text.trim(),
      );
      result = await ApiService.saveProduct(product);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Berhasil'),
          backgroundColor: result['success']
              ? const Color(0xFF43E97B)
              : Colors.red.shade700,
        ),
      );
      if (result['success']) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSubmit = widget.isSubmit;
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          isSubmit ? 'Submit Tugas' : 'Tambah Produk',
          style: GoogleFonts.plusJakartaSans(
              color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isSubmit)
                Container(
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3ECFCF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: const Color(0xFF3ECFCF).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: Color(0xFF3ECFCF), size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Submit hanya dapat dilakukan sekali. Pastikan data sudah benar!',
                          style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF3ECFCF), fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildField(
                label: 'Nama Produk',
                hint: 'Contoh: Macbook Pro M5 2026',
                controller: _nameController,
                icon: Icons.inventory_2_outlined,
                validator: (v) => v!.isEmpty ? 'Nama produk wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Harga (Rp)',
                hint: 'Contoh: 32450000',
                controller: _priceController,
                icon: Icons.attach_money_rounded,
                inputType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => v!.isEmpty ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              _buildField(
                label: 'Deskripsi',
                hint: 'Deskripsi singkat produk...',
                controller: _descController,
                icon: Icons.description_outlined,
                maxLines: 3,
                validator: (v) => v!.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              if (isSubmit) ...[
                const SizedBox(height: 16),
                _buildField(
                  label: 'Link GitHub Repository',
                  hint: 'https://github.com/username/repo',
                  controller: _githubController,
                  icon: Icons.link_rounded,
                  validator: (v) {
                    if (v!.isEmpty) return 'GitHub URL wajib diisi';
                    if (!v.startsWith('https://github.com/')) {
                      return 'URL harus diawali https://github.com/';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSubmit
                        ? const Color(0xFF3ECFCF)
                        : const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Text(
                          isSubmit ? '🚀 Submit Tugas' : 'Simpan Draft Produk',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType? inputType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: GoogleFonts.plusJakartaSans(
                color: Colors.white70, fontSize: 13,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: inputType,
          inputFormatters: inputFormatters,
          style: GoogleFonts.plusJakartaSans(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
                color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white38, size: 20),
            filled: true,
            fillColor: const Color(0xFF1A1A2E),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Color(0xFF2A2A3E), width: 1)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: Color(0xFF6C63FF), width: 1.5)),
            errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1)),
            focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: Colors.redAccent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _descController.dispose();
    _githubController.dispose();
    super.dispose();
  }
}