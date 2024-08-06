import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onPressed;

  const CustomButton({
    super.key,
    required this.btnText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0x4080D0C7),
              Color(0xb3007BFF),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.5),
              blurRadius: 1.0,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: Text(
            btnText,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
