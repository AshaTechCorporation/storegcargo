import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputTextFormField extends StatefulWidget {
  InputTextFormField({
    super.key,
    this.width,
    this.height,
    this.controller,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.obscureText,
    this.suffixIcon,
    this.onFieldSubmitted,
    this.keyboardType,
    this.format,
    this.validator,
    this.fillcolor,
    this.bordercolor,
    this.focusNode,
    this.suffix,
    this.hintTextcolor,
  });

  double? width;
  double? height;
  TextEditingController? controller;
  String? hintText;
  Widget? label;
  Widget? prefixIcon;
  bool? obscureText;
  Widget? suffixIcon;
  void Function(String)? onFieldSubmitted;
  TextInputType? keyboardType;
  List<TextInputFormatter>? format;
  String? Function(String?)? validator;
  Color? fillcolor;
  Color? bordercolor;
  Widget? suffix;
  FocusNode? focusNode;
  Color? hintTextcolor;

  @override
  State<InputTextFormField> createState() => _InputTextFormFieldState();
}

class _InputTextFormFieldState extends State<InputTextFormField> {
  TextEditingController phone = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width ?? 250,
      height: widget.height ?? 60,
      child: TextFormField(
        controller: widget.controller,
        // onTap: () async {},
        focusNode: widget.focusNode,
        style: TextStyle(fontSize: 22),
        obscureText: widget.obscureText ?? false,
        onFieldSubmitted: widget.onFieldSubmitted,
        keyboardType: widget.keyboardType,
        inputFormatters: widget.format,
        validator: widget.validator,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
          label: widget.label,
          hintText: widget.hintText,
          hintStyle: TextStyle(fontSize: 22, color: widget.hintTextcolor),
          prefixIcon: widget.prefixIcon,
          suffix: widget.suffix,
          filled: true,
          fillColor: widget.fillcolor,
          suffixIcon: widget.suffixIcon,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: widget.bordercolor ?? Colors.black),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: widget.bordercolor ?? Colors.black),
          ),
        ),
      ),
    );
  }
}

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), ''); // ลบตัวที่ไม่ใช่ตัวเลข
    String formatted = '';

    for (int i = 0; i < text.length; i++) {
      if (i == 3) {
        formatted += '-';
      } else if (i == 6) {
        formatted += '-';
      }
      formatted += text[i];
    }

    if (formatted.length > 13) formatted = formatted.substring(0, 13);

    return TextEditingValue(text: formatted, selection: TextSelection.collapsed(offset: formatted.length));
  }
}
