import 'package:flutter/material.dart';

class CustomTextFieldd extends StatelessWidget {
  final String text;
  final TextEditingController controller;
  final Widget? prefixIcon;
  final int? maxlines;
  final bool? ab;
  final Widget? prefix;
  final Widget? suffix;

  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  const CustomTextFieldd(
      {Key? key,
      required this.text,
      this.maxlines,
      required this.controller,
      this.suffixIcon,
      this.keyboardType,
      this.prefixIcon,
      required this.ab,
      this.prefix,
      this.suffix})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      obscureText: ab!,
      textAlign: TextAlign.left,
      keyboardType: keyboardType,
      autofillHints: const [
        AutofillHints.username,
        AutofillHints.password,
        AutofillHints.email,
        AutofillHints.telephoneNumber
      ],
      decoration: InputDecoration(
        contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        // fillColor:  Color(AppColors.fillColor),
        filled: true,

        prefixIcon: prefixIcon,
        prefix: Padding(
          padding: EdgeInsets.only(right: 5),
          child: prefix,
        ),
        suffix: suffix,

        // maxLines: maxlines,

        hintText: text,
        hintStyle: const TextStyle(
            color: Color.fromARGB(
              255,
              156,
              146,
              146,
            ),
            fontSize: 14),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.transparent, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red, width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
