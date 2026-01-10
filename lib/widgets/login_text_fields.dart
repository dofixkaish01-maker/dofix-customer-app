import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LoginTextField extends StatelessWidget {
  final String? hintText;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final bool? obscureText;
  final bool? readOnly;
  final bool? enabled;
  final bool? autofocus;
  final Function(String)? onChanged;
  final Function(String)? onSubmitted;
  final Function()? onTap;
  final Function()? onEditingComplete;
  final Function()? onFieldSubmitted;
  final Function()? onSaved;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final int? max;
  final int? min;
  final double? width;
  final double? height;
  final String? Function(String?)? validator;
  final FocusNode focusNode;
  final List<TextInputFormatter>? inputFormatters;

  const LoginTextField({
    this.hintText,
    this.keyboardType,
    this.controller,
    this.obscureText,
    this.readOnly,
    this.enabled,
    this.autofocus,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.onEditingComplete,
    this.onFieldSubmitted,
    this.onSaved,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines,
    this.minLines,
    this.maxLength,
    this.max,
    this.min,
    this.width,
    this.height,
    this.validator,
    required this.focusNode,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: ShapeDecoration(
            color: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)
            ),
            shadows: [
              BoxShadow(
                color: Color(0x26000000),
                blurRadius: 20,
                offset: Offset(0, 0),
                spreadRadius: 0,
              )
            ],
          ),
          child: TextFormField(

            inputFormatters: inputFormatters,
            validator: validator,
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText ?? false,
            readOnly: readOnly ?? false,
            enabled: enabled ?? true,
            autofocus: autofocus ?? false,
            onChanged: onChanged,
            onTap: onTap,
            onEditingComplete: onEditingComplete,
            maxLines: maxLines,
            minLines: minLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              counterText: "",
              hintText: hintText,
              hintStyle: TextStyle(
                color: Color(0xFFBDBDBD),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
                  borderRadius: BorderRadius.circular(5),
                  ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white),
                borderRadius: BorderRadius.circular(5),
              ),
              errorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.red),
                borderRadius: BorderRadius.circular(5),
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,

              errorStyle: TextStyle(
                color: Colors.red, // Set error text color to red
                backgroundColor: Colors.transparent, // Ensure background is transparent
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 5), // Space for error message
      ],
    );
  }
}
