// Import required packages
import 'dart:math'; // For mathematical calculations (pi, cos, sin)

import 'package:flutter/material.dart'; // Core Flutter framework

// Main entry point of the application
void main() {
  runApp(const MaterialApp(
    home: CircularClock(), // Set the CircularClock as the home screen
    debugShowCheckedModeBanner: false, // Remove debug banner from the app
  ));
}

// StatefulWidget for the circular clock
// This is the main widget that represents the clock interface
class CircularClock extends StatefulWidget {
  const CircularClock({super.key});

  @override
  State<CircularClock> createState() => _CircularClockState();
}

// State class for CircularClock
// Manages the dynamic state and animation of the clock
class _CircularClockState extends State<CircularClock>
    with TickerProviderStateMixin {
  // Mixin provides vsync for animations
  late final AnimationController _controller; // Controls the animation timing

  @override
  void initState() {
    super.initState();
    // Initialize animation controller
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 16), // ~60fps for smooth animation
    )..repeat(); // Continuously repeat the animation
  }

  @override
  void dispose() {
    _controller
        .dispose(); // Clean up animation controller when widget is disposed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Set black background for the app
      body: Center(
        child: Container(
          width: 300,
          height: 300,
          decoration: BoxDecoration(
            shape: BoxShape.circle, // Create circular container
            color: Colors.black,
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.1),
                // Subtle white glow effect
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          // AnimatedBuilder rebuilds on each animation tick
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(300, 300),
                painter: ClockPainter(
                    DateTime.now()), // Paint clock with current time
              );
            },
          ),
        ),
      ),
    );
  }
}

// CustomPainter class that handles all the drawing logic for the clock
class ClockPainter extends CustomPainter {
  final DateTime dateTime; // Current time to display

  ClockPainter(this.dateTime);

  @override
  void paint(Canvas canvas, Size size) {
    final center =
        Offset(size.width / 2, size.height / 2); // Calculate center point
    final radius = size.width / 2; // Calculate radius of the clock

    // Draw the three main components of the clock
    _drawRotatingSeconds(canvas, center, radius, dateTime.second);
    _drawFixedIndicator(canvas, center, radius);
    _drawCenterTime(canvas, center, dateTime);
  }

  /// Draws the rotating seconds markers and numbers around the clock face
  void _drawRotatingSeconds(
      Canvas canvas, Offset center, double radius, int currentSecond) {
    final numberPaint = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    // Calculate smooth rotation including microseconds for fluid motion
    final microseconds = dateTime.microsecond / 1000000;
    final milliseconds = dateTime.millisecond / 1000;
    final smoothSeconds = currentSecond + milliseconds + microseconds;
    final baseRotation =
        smoothSeconds * 6 * pi / 180; // Convert to radians (6° per second)

    // Draw 60 tick marks for seconds
    for (int i = 0; i < 60; i++) {
      final angle = baseRotation +
          ((i * 6 - 90) * pi / 180); // Calculate angle for each tick
      final shouldDrawNumber = i % 5 == 0; // Draw number every 5 ticks

      // Configure tick mark style
      final tickPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth =
            shouldDrawNumber ? 2 : 1; // Thicker lines for numbered ticks

      // Calculate tick mark positions
      final outerPoint = Offset(center.dx + (radius - 20) * cos(angle),
          center.dy + (radius - 20) * sin(angle));
      final innerPoint = Offset(center.dx + (radius - 25) * cos(angle),
          center.dy + (radius - 25) * sin(angle));
      canvas.drawLine(innerPoint, outerPoint, tickPaint);

      // Draw numbers at every 5th position
      if (shouldDrawNumber) {
        final number = (60 - i) % 60; // Calculate number to display
        final numberStr =
            number.toString().padLeft(2, '0'); // Format with leading zero
        numberPaint.text = TextSpan(
          text: numberStr,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        );

        numberPaint.layout();

        // Position the number
        final numberPoint = Offset(
            center.dx + (radius - 45) * cos(angle) - numberPaint.width / 2,
            center.dy + (radius - 45) * sin(angle) - numberPaint.height / 2);

        numberPaint.paint(canvas, numberPoint);
      }
    }
  }

  /// Draws the fixed triangle indicator at the top of the clock
  void _drawFixedIndicator(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final path = Path();

    // Define triangle points
    final bottomPoint = Offset(center.dx, center.dy - radius + 25);
    final leftPoint = Offset(center.dx - 8, center.dy - radius + 10);
    final rightPoint = Offset(center.dx + 8, center.dy - radius + 10);

    // Create triangle path
    path.moveTo(bottomPoint.dx, bottomPoint.dy);
    path.lineTo(leftPoint.dx, leftPoint.dy);
    path.lineTo(rightPoint.dx, rightPoint.dy);
    path.close();

    // Add glow effect to the indicator
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawPath(path, glowPaint); // Draw glow
    canvas.drawPath(path, paint); // Draw solid triangle
  }

  /// Draws the digital time display in the center of the clock
  void _drawCenterTime(Canvas canvas, Offset center, DateTime time) {
    // Format time components with leading zeros
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final second = time.second.toString().padLeft(2, '0');

    // Define text style for the time display
    const textStyle = TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.w300,
    );

    // Create painters for all time components
    final List<TextPainter> painters = [];
    final List<String> components = [hour, ':', minute, ':', second];

    // Initialize text painters for each component
    for (final component in components) {
      painters.add(TextPainter(
        text: TextSpan(
          text: component,
          style: textStyle,
        ),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      )..layout());
    }

    // Calculate total width of all components
    final totalWidth =
        painters.fold<double>(0, (sum, painter) => sum + painter.width);

    // Calculate starting position for center alignment
    var currentX = center.dx - totalWidth / 2;
    final centerY = center.dy - painters[0].height / 2;

    // Draw all time components
    for (final painter in painters) {
      painter.paint(canvas, Offset(currentX, centerY));
      currentX += painter.width;
    }
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) {
    // Repaint only if the time has changed
    return oldDelegate.dateTime != dateTime;
  }
}
