import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/api_service.dart';
import 'catalog_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  final _nimController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  // Controllers
  late AnimationController _floatController;
  late AnimationController _cardController;
  late AnimationController _buttonController;

  // Animations
  late Animation<double> _cardScale;
  late Animation<double> _cardOpacity;
  late Animation<Offset> _cardSlide;

  late Animation<double> _buttonGlow;

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _cardScale = Tween<double>(
      begin: .85,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutExpo,
      ),
    );

    _cardOpacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOut,
      ),
    );

    _cardSlide = Tween<Offset>(
      begin: const Offset(0, .15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutCubic,
      ),
    );

    _buttonGlow = Tween<double>(
      begin: 10,
      end: 24,
    ).animate(_buttonController);

    Future.delayed(const Duration(milliseconds: 250), () {
      _cardController.forward();
    });
  }

  @override
  void dispose() {
    _floatController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await ApiService.login(
      _nimController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (result['success']) {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 900),
          pageBuilder: (_, animation, __) => FadeTransition(
            opacity: animation,
            child: const CatalogScreen(),
          ),
        ),
      );
    } else {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          content: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(.15),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(.3),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        result['message'],
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050816),
      body: Stack(
        children: [
          // ===== Animated Background =====
          AnimatedBuilder(
            animation: _floatController,
            builder: (context, child) {
              return Stack(
                children: [
                  _animatedOrb(
                    top: -120 + (_floatController.value * 60),
                    left: -60,
                    size: 280,
                    color: const Color(0xFF6E5BFF),
                  ),
                  _animatedOrb(
                    top: 120,
                    right: -80 + (_floatController.value * 40),
                    size: 220,
                    color: const Color(0xFF00D1FF),
                  ),
                  _animatedOrb(
                    bottom: -100,
                    left: 20 + (_floatController.value * 30),
                    size: 240,
                    color: const Color(0xFFFF4ECD),
                  ),
                  _animatedOrb(
                    bottom: 80,
                    right: -40,
                    size: 180,
                    color: const Color(0xFF7BFFB2),
                  ),
                ],
              );
            },
          ),

          // Noise overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.white.withOpacity(.02),
                  Colors.transparent,
                  Colors.black.withOpacity(.15),
                ],
              ),
            ),
          ),

          // ===== Main Content =====
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: SlideTransition(
                  position: _cardSlide,
                  child: FadeTransition(
                    opacity: _cardOpacity,
                    child: ScaleTransition(
                      scale: _cardScale,
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 420),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(34),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 18,
                              sigmaY: 18,
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(34),
                                border: Border.all(
                                  color: Colors.white.withOpacity(.08),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Colors.white.withOpacity(.08),
                                    Colors.white.withOpacity(.03),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(.35),
                                    blurRadius: 40,
                                    spreadRadius: 2,
                                    offset: const Offset(0, 20),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // ===== Top Icon =====
                                  Container(
                                    width: 88,
                                    height: 88,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF6E5BFF),
                                          Color(0xFF00D1FF),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFF6E5BFF)
                                              .withOpacity(.5),
                                          blurRadius: 30,
                                          spreadRadius: 1,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 40,
                                      color: Colors.white,
                                    ),
                                  ),

                                  const SizedBox(height: 28),

                                  ShaderMask(
                                    shaderCallback: (bounds) {
                                      return const LinearGradient(
                                        colors: [
                                          Colors.white,
                                          Color(0xFFB6C2FF),
                                        ],
                                      ).createShader(bounds);
                                    },
                                    child: Text(
                                      'Welcome Back',
                                      style: GoogleFonts.poppins(
                                        fontSize: 32,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        letterSpacing: -.8,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    'Sign in to continue your journey',
                                    textAlign: TextAlign.center,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      color: Colors.white.withOpacity(.5),
                                      height: 1.5,
                                    ),
                                  ),

                                  const SizedBox(height: 34),

                                  // ===== Form =====
                                  Form(
                                    key: _formKey,
                                    child: Column(
                                      children: [
                                        _modernField(
                                          controller: _nimController,
                                          hint: 'Student ID / Username',
                                          icon:
                                              Icons.person_outline_rounded,
                                          keyboardType:
                                              TextInputType.number,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Username wajib diisi';
                                            }
                                            return null;
                                          },
                                        ),

                                        const SizedBox(height: 20),

                                        _modernField(
                                          controller:
                                              _passwordController,
                                          hint: 'Password',
                                          obscure: _obscurePassword,
                                          icon: Icons.lock_outline_rounded,
                                          validator: (v) {
                                            if (v == null || v.isEmpty) {
                                              return 'Password wajib diisi';
                                            }
                                            return null;
                                          },
                                          suffix: IconButton(
                                            splashRadius: 20,
                                            onPressed: () {
                                              setState(() {
                                                _obscurePassword =
                                                    !_obscurePassword;
                                              });
                                            },
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons
                                                      .visibility_off_rounded
                                                  : Icons.visibility_rounded,
                                              color: Colors.white38,
                                            ),
                                          ),
                                        ),

                                        const SizedBox(height: 34),

                                        // ===== Login Button =====
                                        AnimatedBuilder(
                                          animation: _buttonController,
                                          builder: (context, child) {
                                            return Container(
                                              width: double.infinity,
                                              height: 58,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        18),
                                                gradient:
                                                    const LinearGradient(
                                                  colors: [
                                                    Color(0xFF6E5BFF),
                                                    Color(0xFF00D1FF),
                                                  ],
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color:
                                                        const Color(0xFF6E5BFF)
                                                            .withOpacity(.5),
                                                    blurRadius:
                                                        _buttonGlow.value,
                                                    spreadRadius: 1,
                                                  ),
                                                ],
                                              ),
                                              child: Material(
                                                color: Colors.transparent,
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          18),
                                                  onTap: _isLoading
                                                      ? null
                                                      : _handleLogin,
                                                  child: Center(
                                                    child: _isLoading
                                                        ? const SizedBox(
                                                            width: 24,
                                                            height: 24,
                                                            child:
                                                                CircularProgressIndicator(
                                                              strokeWidth:
                                                                  2.6,
                                                              color: Colors
                                                                  .white,
                                                            ),
                                                          )
                                                        : Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              const Icon(
                                                                Icons
                                                                    .arrow_forward_rounded,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                              const SizedBox(
                                                                  width: 10),
                                                              Text(
                                                                'Continue',
                                                                style:
                                                                    GoogleFonts
                                                                        .poppins(
                                                                  color: Colors
                                                                      .white,
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ),

                                  const SizedBox(height: 24),

                                  Text(
                                    'FORTEEE',
                                    style: GoogleFonts.poppins(
                                      color:
                                          Colors.white.withOpacity(.25),
                                      fontSize: 11,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(.06),
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(.04),
            Colors.white.withOpacity(.02),
          ],
        ),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: validator,
        style: GoogleFonts.poppins(
          color: Colors.white,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 18,
          ),
          hintText: hint,
          hintStyle: GoogleFonts.poppins(
            color: Colors.white38,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.white54,
            size: 22,
          ),
          suffixIcon: suffix,
          errorStyle: GoogleFonts.poppins(),
        ),
      ),
    );
  }

  Widget _animatedOrb({
    double? top,
    double? left,
    double? right,
    double? bottom,
    required double size,
    required Color color,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(.55),
              color.withOpacity(.08),
              Colors.transparent,
            ],
          ),
        ),
      ),
    );
  }
}