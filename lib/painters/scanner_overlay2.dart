import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  final double borderRadius;
  final Color overlayColor;
  final Color borderColor;
  final double borderWidth;
  final Color shadowColor;
  final double shadowOpacity;
  final double shadowOffset;
  final double shadowBlurRadius;

  ScannerOverlayPainter({
    this.borderRadius = 20,
    this.overlayColor = const Color(0x80000000), // Semi-transparent black
    this.borderColor = Colors.white,
    this.borderWidth = 2,
    this.shadowColor = Colors.black,
    this.shadowOpacity = 0.3,
    this.shadowOffset = 4,
    this.shadowBlurRadius = 8,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint overlayPaint = Paint()..color = overlayColor; // Semi-transparent overlay color

    final Paint borderPaint =
        Paint()
          ..color = borderColor.withOpacity(0.7)
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth;

    final Paint shadowPaint =
        Paint()
          ..color = shadowColor.withOpacity(shadowOpacity)
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, shadowBlurRadius);

    // Draw the semi-transparent black overlay (background)
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), overlayPaint);

    // Apply shadow effect (draw shadow first for layering)
    final Rect shadowRect = Rect.fromLTWH(
      size.width * 0.1, // Left position of box
      size.height * 0.2, // Top position of box
      size.width * 0.8, // Width of box
      size.height * 0.6, // Height of box
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(shadowRect, Radius.circular(borderRadius)),
      shadowPaint,
    );

    // Draw the border of the center box with rounded corners
    final Rect boxRect = Rect.fromLTWH(
      size.width * 0.1, // Left position of box
      size.height * 0.2, // Top position of box
      size.width * 0.8, // Width of box
      size.height * 0.6, // Height of box
    );
    canvas.drawRRect(RRect.fromRectAndRadius(boxRect, Radius.circular(borderRadius)), borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false; // No need to repaint
  }
}
