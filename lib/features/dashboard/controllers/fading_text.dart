// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FadingTextAnimation extends StatefulWidget {
  final List<String> texts; // Text to Animate
  final Duration duration; // Duration for each animation
  final Curve curve; // Curve for the animation

  const FadingTextAnimation(
      {super.key,
        required this.texts,
        this.duration = const Duration(seconds: 1),
        this.curve = Curves.easeInOut});

  @override
  _FadingTextAnimationState createState() => _FadingTextAnimationState();
}

class _FadingTextAnimationState extends State<FadingTextAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    // Opacity Animation
    _opacityAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.25), // Fade in during the first 25%
      ),
    );

    // Slide Animation
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.60),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.5), // Slide up during 25% - 50%
      ),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Delay before starting the fade-out and slide-down
        Future.delayed(const Duration(milliseconds: 700), () {
          if (_controller != null) {
            _controller.reverse();
          }
        });
      } else if (status == AnimationStatus.dismissed) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % widget.texts.length;
        });
        _controller.forward(); // Start the next cycle
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
    return Center(
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Text(
            widget.texts[_currentIndex],
            style: TextStyle(
              fontSize: 14.sp,
              color: Color(0xFF7D818C),
            ),
          ),
        ),
      ),
    );
  }
}
