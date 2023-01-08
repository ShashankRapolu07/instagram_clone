import 'package:flutter/material.dart';

class ProfileButton extends StatefulWidget {
  final Color barColor;
  final Color textColor;
  final Color borderColor;
  final String label;
  final double width;
  final double height;
  final VoidCallback? onPressed;
  const ProfileButton(
      {super.key,
      required this.label,
      required this.barColor,
      required this.textColor,
      required this.borderColor,
      required this.width,
      required this.height,
      required this.onPressed});

  @override
  State<ProfileButton> createState() => _ProfileButtonState();
}

class _ProfileButtonState extends State<ProfileButton> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(5.0)),
          color: widget.barColor,
          border: Border.all(color: widget.borderColor)),
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: TextButton(
        onPressed: () {
          if (widget.onPressed != null) {
            return widget.onPressed!();
          }
        },
        child: Text(
          widget.label,
          style: TextStyle(
              fontSize: 17.0,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: widget.textColor),
        ),
      ),
    );
  }
}
