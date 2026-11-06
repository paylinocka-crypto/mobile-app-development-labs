import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  const AppButton({required this.text, required this.onPressed, super.key});

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(text),
        ),
      ),
    );
  }
}
