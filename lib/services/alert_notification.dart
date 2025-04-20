import 'package:flutter/material.dart' as flutter;

class AlertNotification extends flutter.StatefulWidget {
  final String message;

  const AlertNotification({
    super.key,
    required this.message,
  });

  @override
  flutter.State<AlertNotification> createState() => _AlertNotificationState();
}

class _AlertNotificationState extends flutter.State<AlertNotification> with flutter.SingleTickerProviderStateMixin {
  late flutter.AnimationController _controller;
  late flutter.Animation<double> _opacityAnimation;
  bool _visible = true;

  @override
  void initState() {
    super.initState();
    _controller = flutter.AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    );
    
    _opacityAnimation = flutter.Tween<double>(begin: 1.0, end: 0.0).animate(
      flutter.CurvedAnimation(
        parent: _controller,
        curve: const flutter.Interval(0.7, 1.0),
      ),
    );
    
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _visible = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  flutter.Widget build(flutter.BuildContext context) {
    if (!_visible) return const flutter.SizedBox.shrink();
    
    return flutter.AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return flutter.Opacity(
          opacity: _opacityAnimation.value,
          child: child,
        );
      },
      child: flutter.Container(
        padding: const flutter.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        margin: const flutter.EdgeInsets.all(16),
        decoration: flutter.BoxDecoration(
          color: const flutter.Color(0xFFFFF9C4),
          borderRadius: flutter.BorderRadius.circular(8),
          boxShadow: [
            flutter.BoxShadow(
              color: flutter.Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const flutter.Offset(0, 3),
            ),
          ],
          border: flutter.Border.all(
            color: const flutter.Color.fromARGB(255, 0, 0, 0),
            width: 2,
          ),
        ),
        child: flutter.Row(
          mainAxisSize: flutter.MainAxisSize.min,
          children: [
            // const flutter.Icon(
            //   flutter.Icons.warning_amber_rounded,
            //   color: flutter.Color(0xFFF57F17),
            //   size: 28,
            // ),
            const flutter.SizedBox(width: 12),
            flutter.Flexible(
              child: flutter.Text(
                widget.message,
                style: const flutter.TextStyle(
                  fontSize: 16,
                  fontWeight: flutter.FontWeight.w500,
                  color: flutter.Colors.black87,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}