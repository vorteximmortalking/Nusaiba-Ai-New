import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.5,
            colors: [Color(0xFF1A2A6C), Color(0xFF0A0E27)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Animate(
                  effects: [FadeEffect(duration: 1500.ms)],
                  child: const FloatingAvatar(),
                ),
                const SizedBox(height: 30),
                Animate(
                  effects: [FadeEffect(delay: 800.ms, duration: 1000.ms)],
                  child: Text(
                    'Nusaiba AI',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [const Shadow(color: Color(0xFF4FC3F7), blurRadius: 20)],
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                Animate(
                  effects: [
                    FadeEffect(delay: 1500.ms),
                    ScaleEffect(delay: 1500.ms, duration: 500.ms),
                  ],
                  child: FloatingActionButton.large(
                    onPressed: () {},
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(colors: [Color(0xFF4FC3F7), Color(0xFF9C6ADE)]),
                        boxShadow: [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.6), blurRadius: 25, spreadRadius: 8)],
                      ),
                      child: const Icon(Icons.mic, color: Colors.white, size: 40),
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

class FloatingAvatar extends StatefulWidget {
  const FloatingAvatar({super.key});

  @override
  State<FloatingAvatar> createState() => _FloatingAvatarState();
}

class _FloatingAvatarState extends State<FloatingAvatar> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _animation = Tween<double>(begin: -15, end: 15).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Container(
            width: 280,
            height: 400,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              boxShadow: [BoxShadow(color: const Color(0xFF4FC3F7).withOpacity(0.4), blurRadius: 50, spreadRadius: 10)],
              image: const DecorationImage(
                image: AssetImage('assets/images/nusaiba_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}
