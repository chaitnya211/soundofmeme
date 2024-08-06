import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {

  final String? labelText;
  final TextInputType? keyboardType;
  final TextEditingController controller;
  final String hintText;

  const CustomTextFormField({
    super.key,
  this.labelText, this.keyboardType, required this.controller, required this.hintText
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(color: Colors.white),
      controller: controller,
      decoration: InputDecoration(
          fillColor: const Color(0xff212428),
          labelText: labelText,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.white38),
          labelStyle: const TextStyle(color: Colors.white38),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)
          ),
          // isDense: true
      ),
      validator: (value) {
        if(value == null || value.isEmpty) {
          return "$hintText first";
        }
        return null;
      },
      keyboardType: keyboardType ?? TextInputType.name,
    );
  }
}