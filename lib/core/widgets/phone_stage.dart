import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Presents [child] inside a handset on wide screens.
///
/// WishTier is a phone app. Stretched across a 1440px browser it reads as a
/// mobile layout with a very wide empty column, so on desktop the app is laid
/// out against a 390 x 844 logical screen and shown inside a device frame on a
/// quiet stage. Phones and narrow windows get the app untouched — the demo
/// still has to feel native where it matters.
class PhoneStage extends StatelessWidget {
  const PhoneStage({super.key, required this.child});

  final Widget child;

  /// Logical size handed to the app while framed (iPhone 14 class).
  static const Size screen = Size(390, 844);
  static const double _bezel = 12;
  static const double _bodyRadius = 58;
  static const double _screenRadius = 46;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final framed =
            constraints.maxWidth >= 760 && constraints.maxHeight >= 620;
        if (!framed) return child;

        final dark = Theme.of(context).brightness == Brightness.dark;
        final body = Size(
          screen.width + _bezel * 2,
          screen.height + _bezel * 2,
        );
        // Never upscale past 1: a 4K window should not give us a giant phone.
        final scale = math.min(
          1.0,
          math.min(
            (constraints.maxHeight - 56) / body.height,
            (constraints.maxWidth * 0.72) / body.width,
          ),
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            _Stage(dark: dark),
            Center(
              child: SizedBox(
                width: body.width * scale,
                height: body.height * scale,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: _Device(dark: dark, child: child),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Device extends StatelessWidget {
  const _Device({required this.dark, required this.child});

  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final body = Size(
      PhoneStage.screen.width + PhoneStage._bezel * 2,
      PhoneStage.screen.height + PhoneStage._bezel * 2,
    );

    return SizedBox(
      width: body.width,
      height: body.height,
      // The hardware buttons sit on the silhouette, a hair outside the body.
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Container(
              padding: const EdgeInsets.all(PhoneStage._bezel),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(PhoneStage._bodyRadius),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF5A616D), Color(0xFF20242C), Color(0xFF08090D)],
                  stops: [0, 0.38, 1],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: dark ? 0.36 : 0.7),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.75 : 0.4),
                    blurRadius: 90,
                    spreadRadius: -16,
                    offset: const Offset(0, 46),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: dark ? 0.55 : 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(PhoneStage._screenRadius),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    MediaQuery(
                      // The app sizes itself from MediaQuery, which on web
                      // reports the browser window. Handing it the handset's
                      // size is what makes the layout actually reflow to a
                      // phone instead of being a squeezed desktop page.
                      data: MediaQuery.of(context).copyWith(
                        size: PhoneStage.screen,
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                        viewInsets: EdgeInsets.zero,
                        systemGestureInsets: EdgeInsets.zero,
                      ),
                      child: child,
                    ),
                    // Glass: a rim highlight and a soft top-left glare, so the
                    // screen reads as a surface rather than a printed image.
                    const Positioned.fill(
                      child: IgnorePointer(child: _ScreenFinish()),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            top: body.height * 0.22,
            child: _SideButton(dark: dark, length: 54),
          ),
          Positioned(
            left: -2,
            top: body.height * 0.17,
            child: _SideButton(dark: dark, length: 26),
          ),
          Positioned(
            left: -2,
            top: body.height * 0.17 + 32,
            child: _SideButton(dark: dark, length: 44),
          ),
        ],
      ),
    );
  }
}

class _ScreenFinish extends StatelessWidget {
  const _ScreenFinish();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(PhoneStage._screenRadius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.center,
          colors: [
            Colors.white.withValues(alpha: 0.045),
            Colors.white.withValues(alpha: 0),
          ],
        ),
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  const _SideButton({required this.dark, required this.length});

  final bool dark;
  final double length;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: length,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF4C535F) : const Color(0xFF2E333C),
        border: Border.all(color: Colors.black.withValues(alpha: 0.55)),
        borderRadius: const BorderRadius.horizontal(
          right: Radius.circular(2),
          left: Radius.circular(2),
        ),
      ),
    );
  }
}

class _Stage extends StatelessWidget {
  const _Stage({required this.dark});

  final bool dark;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: dark
              ? const [
                  Color(0xFF323C50),
                  Color(0xFF1D2433),
                  Color(0xFF080A0F),
                ]
              : const [Color(0xFFF1EDE4), Color(0xFFE0DACC), Color(0xFFD3CCBC)],
          stops: const [0, 0.55, 1],
        ),
      ),
      child: CustomPaint(
        painter: _DotField(dark: dark),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.05),
              radius: 0.75,
              colors: [
                Colors.white.withValues(alpha: dark ? 0.09 : 0.55),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DotField extends CustomPainter {
  const _DotField({required this.dark});

  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = (dark ? Colors.white : Colors.black)
          .withValues(alpha: dark ? 0.05 : 0.06);
    const pitch = 26.0;
    for (double y = pitch / 2; y < size.height; y += pitch) {
      for (double x = pitch / 2; x < size.width; x += pitch) {
        canvas.drawCircle(Offset(x, y), 1, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DotField oldDelegate) => oldDelegate.dark != dark;
}