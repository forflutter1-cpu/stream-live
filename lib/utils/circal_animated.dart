import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:iptv/app_material/app_colors.dart';

class AnimatedCircle extends StatefulWidget {
  const AnimatedCircle({super.key});

  @override
  _AnimatedCircleState createState() => _AnimatedCircleState();
}

class _AnimatedCircleState extends State<AnimatedCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _animation3 = Tween<double>(begin: 0.1, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animation2 = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _animation1 = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        ScaleTransition(
          scale: _animation1,
          child: _buildCircle(AppColors.primryColor.withValues(alpha: 0.2), 200, 200),
        ),
        ScaleTransition(
          scale: _animation2,
          child: _buildCircle(AppColors.primryColor.withValues(alpha: 0.4), 150, 150),
        ),
        ScaleTransition(
          scale: _animation3,
          child: _buildCircle(AppColors.primryColor.withValues(alpha: 0.6), 100, 100),
        ),
      ],
    );
  }

  Widget _buildCircle(Color color, double height, double width) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
