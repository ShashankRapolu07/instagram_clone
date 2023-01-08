import 'package:flutter/material.dart';

class LikeAnimation extends StatefulWidget {
  final Widget child;
  final bool isAnimating;
  final Duration duration;
  final VoidCallback? onEnd;

  LikeAnimation({
    required this.child,
    this.isAnimating = false,
    this.duration = const Duration(milliseconds: 900),
    required this.onEnd,
  });

  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  Animation<double>? _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);
    _scale = Tween<double>(begin: 1, end: 1.3).animate(_controller!);
  }

  @override
  void didUpdateWidget(covariant LikeAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isAnimating == true) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    await _controller!.forward();
    await Future.delayed(const Duration(milliseconds: 20));
    await _controller!.reverse();
    //await Future.delayed(const Duration(milliseconds: 200));

    if (widget.onEnd != null) {
      widget.onEnd!();
    } else {}
  }

  @override
  void dispose() {
    super.dispose();
    _controller!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale!,
      child: widget.child,
    );
  }
}
