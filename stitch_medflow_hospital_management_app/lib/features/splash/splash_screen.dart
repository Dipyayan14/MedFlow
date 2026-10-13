import 'dart:ui';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final Widget next;

  const SplashScreen({
    super.key,
    required this.next,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            transitionDuration: const Duration(milliseconds: 500),
            pageBuilder: (context, animation, secondaryAnimation) => widget.next,
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;

            // 0.00 to 0.30: Logo entry (fade in 0->1, scale 0.8->1.0, easeOutCubic)
            final double logoIntro = const Interval(
              0.00,
              0.30,
              curve: Curves.easeOutCubic,
            ).transform(t);
            final double logoOpacity = logoIntro;
            final double logoScale = 0.8 + (0.2 * logoIntro);

            // 0.22 to 0.45: Text entry (fade in 0->1, slide up 14px -> 0px)
            final double textIntro = const Interval(
              0.22,
              0.45,
              curve: Curves.easeOutCubic,
            ).transform(t);
            final double textOpacity = textIntro;
            final double textSlideY = (1.0 - textIntro) * 14.0;

            // 0.68 to 1.00: Dissolve ("vanish into thin air", easeInCubic)
            final double dissolve = const Interval(
              0.68,
              1.00,
              curve: Curves.easeInCubic,
            ).transform(t);

            // Dissolve opacity: 1.0 -> 0.0
            final double dissolveOpacity = (1.0 - dissolve).clamp(0.0, 1.0);
            // Dissolve scale: +12% (1.0 -> 1.12)
            final double dissolveScale = 1.0 + (dissolve * 0.12);
            // Dissolve blur: sigma up to 12
            final double sigma = dissolve * 12.0;

            // Entire group is transformed and dissolved together
            Widget content = Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo (140x140)
                Opacity(
                  opacity: logoOpacity.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: logoScale,
                    child: Image.asset(
                      'assets/icon/app_icon.png',
                      width: 140,
                      height: 140,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Text group
                Opacity(
                  opacity: textOpacity.clamp(0.0, 1.0),
                  child: Transform.translate(
                    offset: Offset(0, textSlideY),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'MedFlow',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                            color: Color(0xFF006574),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'HOSPITAL MANAGEMENT',
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 3,
                            color: const Color(0xFF006574).withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );

            // Apply dissolve effects to whole logo and text group
            if (sigma > 0.05) {
              content = ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: content,
              );
            }

            if (dissolveScale != 1.0) {
              content = Transform.scale(
                scale: dissolveScale,
                child: content,
              );
            }

            if (dissolveOpacity < 1.0) {
              content = Opacity(
                opacity: dissolveOpacity,
                child: content,
              );
            }

            return content;
          },
        ),
      ),
    );
  }
}
