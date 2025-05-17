import 'package:flutter/material.dart';

class CustomTextInput extends StatelessWidget {
  final String? hintText;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final TextInputType keyboardType;
  final bool obscureText;

  const CustomTextInput({
    super.key,
    this.hintText,
    this.initialValue,
    this.onChanged,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(30, 0, 0, 0),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: TextFormField(
        initialValue: initialValue,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: colorScheme.onSurface),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
