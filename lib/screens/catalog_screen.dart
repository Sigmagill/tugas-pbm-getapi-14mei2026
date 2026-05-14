import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/product_model.dart';
import '../services/api_service.dart';
import '../widgets/product_card.dart';
import 'add_product_screen.dart';
import 'login_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen>
    with SingleTickerProviderStateMixin {
  List<Product> _products = [];
  bool _isLoading = true;

  late AnimationController _fabController;

  @override
  void initState() {
    super.initState();

    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _loadProducts();
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  // ================= LOAD PRODUCTS =================

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);

    try {
      final products = await ApiService.getProducts();

      setState(() {
        _products = products;
        _isLoading = false;
      });

      _fabController.forward();
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            content: Text(
              'Gagal memuat produk: $e',
              style: GoogleFonts.plusJakartaSans(),
            ),
          ),
        );
      }
    }
  }

  // ================= LOGOUT =================

  Future<void> _logout() async {
    await ApiService.deleteToken();

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  // ================= DELETE PRODUCT =================

  Future<void> _deleteProduct(
    Product product,
    int index,
  ) async {
    final removedProduct = product;

    // remove from ui first
    setState(() {
      _products.removeAt(index);
    });

    final result = await ApiService.deleteProduct(product.id!);

    // if api failed
    if (!result['success']) {
      setState(() {
        _products.insert(index, removedProduct);
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          content: Text(
            result['message'] ?? 'Gagal menghapus produk',
            style: GoogleFonts.plusJakartaSans(),
          ),
        ),
      );

      return;
    }

    if (!mounted) return;

    // snackbar undo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),

        content: Row(
          children: [
            const Icon(
              Icons.delete_outline_rounded,
              color: Colors.white,
              size: 20,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                '${product.name} dihapus',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        action: SnackBarAction(
          label: 'UNDO',
          textColor: const Color(0xFF3ECFCF),

          onPressed: () {
            setState(() {
              _products.insert(index, removedProduct);
            });
          },
        ),
      ),
    );
  }

  // ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),

      // ================= BODY =================

      body: Stack(
        children: [
          // ambient glow
          Positioned(
            top: -120,
            left: -80,
            child: _glowBall(
              260,
              const Color(0xFF6C63FF),
            ),
          ),

          Positioned(
            bottom: -100,
            right: -60,
            child: _glowBall(
              220,
              const Color(0xFF3ECFCF),
            ),
          ),

          NestedScrollView(
            headerSliverBuilder: (_, __) => [
              SliverAppBar(
                expandedHeight: 130,
                pinned: true,
                elevation: 0,
                backgroundColor: const Color(0xFF0A0A0F),

                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFF1A1040),
                          Color(0xFF0A0A0F),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),

                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        60,
                        20,
                        0,
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(14),

                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF6C63FF),
                                  Color(0xFF3ECFCF),
                                ],
                              ),

                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF6C63FF)
                                      .withOpacity(.45),
                                  blurRadius: 18,
                                ),
                              ],
                            ),

                            child: const Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),

                          const SizedBox(width: 14),

                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment:
                                CrossAxisAlignment.start,

                            children: [
                              Text(
                                'Product Space',
                                style:
                                    GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                '${_products.length} active products',
                                style:
                                    GoogleFonts.plusJakartaSans(
                                  color: Colors.white38,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                actions: [
                  // submit tugas
                  IconButton(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const AddProductScreen(
                            isSubmit: true,
                          ),
                        ),
                      );
                    },

                    icon: Container(
                      padding: const EdgeInsets.all(8),

                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(12),

                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF6C63FF),
                            Color(0xFF3ECFCF),
                          ],
                        ),
                      ),

                      child: const Icon(
                        Icons.cloud_upload_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),

                  const SizedBox(width: 6),

                  // logout
                  IconButton(
                    onPressed: _logout,

                    icon: const Icon(
                      Icons.logout_rounded,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ],

            // ================= CONTENT =================

            body: RefreshIndicator(
              onRefresh: _loadProducts,
              color: const Color(0xFF6C63FF),

              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : _products.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(
                            top: 8,
                            bottom: 100,
                          ),

                          itemCount: _products.length,

                          itemBuilder: (_, i) {
                            final product = _products[i];

                            return Dismissible(
                              key: Key(
                                product.id.toString(),
                              ),

                              direction:
                                  DismissDirection.endToStart,

                              background: Container(
                                margin:
                                    const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),

                                padding:
                                    const EdgeInsets.symmetric(
                                  horizontal: 24,
                                ),

                                alignment:
                                    Alignment.centerRight,

                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(
                                          18),

                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.red.shade400,
                                      Colors.red.shade700,
                                    ],
                                  ),
                                ),

                                child: const Icon(
                                  Icons.delete_rounded,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              onDismissed: (_) {
                                _deleteProduct(product, i);
                              },

                              child: TweenAnimationBuilder(
                                tween: Tween<double>(
                                  begin: 0,
                                  end: 1,
                                ),

                                duration: Duration(
                                  milliseconds: 300 + (i * 80),
                                ),

                                curve: Curves.easeOutCubic,

                                builder:
                                    (_, double val, child) {
                                  return Opacity(
                                    opacity: val,

                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        20 * (1 - val),
                                      ),

                                      child: child,
                                    ),
                                  );
                                },

                                child: ProductCard(
                                  product: product,
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ),
        ],
      ),

      // ================= FAB =================

      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabController,
          curve: Curves.elasticOut,
        ),

        child: FloatingActionButton.extended(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const AddProductScreen(
                  isSubmit: false,
                ),
              ),
            );

            _loadProducts();
          },

          elevation: 10,

          backgroundColor: const Color(0xFF6C63FF),

          icon: const Icon(
            Icons.add_rounded,
            color: Colors.white,
          ),

          label: Text(
            'Tambah Produk',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  // ================= EMPTY STATE =================

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(
              begin: 0,
              end: 1,
            ),

            duration: const Duration(milliseconds: 700),

            curve: Curves.elasticOut,

            builder: (_, double val, __) {
              return Transform.scale(
                scale: val,

                child: Container(
                  width: 100,
                  height: 100,

                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius:
                        BorderRadius.circular(28),
                  ),

                  child: const Icon(
                    Icons.inventory_2_outlined,
                    size: 48,
                    color: Colors.white24,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 24),

          Text(
            'No Product Yet',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white70,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Tap the add button to create your first product',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white24,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  // ================= GLOW =================

  Widget _glowBall(
    double size,
    Color color,
  ) {
    return Container(
      width: size,
      height: size,

      decoration: BoxDecoration(
        shape: BoxShape.circle,

        gradient: RadialGradient(
          colors: [
            color.withOpacity(.35),
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}