import 'package:flutter/material.dart' as flutter;

class PointsDisplay extends flutter.StatelessWidget {
  final int collected;
  final int total;

  const PointsDisplay({
    super.key,
    required this.collected,
    required this.total,
  });

  @override
  flutter.Widget build(flutter.BuildContext context) {
    return flutter.Container(
      padding: const flutter.EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: flutter.BoxDecoration(
        color: const flutter.Color(0xFFD6C6A8),
        borderRadius: flutter.BorderRadius.circular(20),
        boxShadow: [
          flutter.BoxShadow(
            color: flutter.Colors.black.withOpacity(0.3),
            blurRadius: 5,
            offset: const flutter.Offset(0, 3),
          ),
        ],
      ),
      child: flutter.Row(
        mainAxisSize: flutter.MainAxisSize.min,
        children: [
          flutter.Image.asset('assets/images/points/point1.png', // Path ke file gambar Anda
            width: 24,
            height: 24,
          ),
          const flutter.SizedBox(width: 8),
          flutter.Text(
            '$collected/$total',
            style: const flutter.TextStyle(
              fontSize: 18,
              fontWeight: flutter.FontWeight.bold,
              color: flutter.Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}