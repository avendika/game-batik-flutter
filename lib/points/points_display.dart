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
    return flutter.Stack(
      alignment: flutter.Alignment.center,
      children: [
        flutter.Image.asset(
          'assets/images/tombol.png',
          width: 105, // Adjust width as needed
          height: 40,  // Adjust height as needed
          fit: flutter.BoxFit.cover,
        ),
        flutter.Padding(
          padding: const flutter.EdgeInsets.symmetric(horizontal: 12),
          child: flutter.Row(
            mainAxisSize: flutter.MainAxisSize.min,
            children: [
              flutter.Image.asset(
                'assets/images/points/pointdisplay.png',
                width: 24,
                height: 24,
              ),
              const flutter.SizedBox(width: 8),
              flutter.Text(
                '$collected/$total',
                style: const flutter.TextStyle(
                  fontSize: 18,
                  fontWeight: flutter.FontWeight.bold,
                  color: flutter.Colors.white, // Changed to white for better contrast with the background image
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}