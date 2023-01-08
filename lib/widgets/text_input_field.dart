import 'package:flutter/material.dart';

class TextFieldInput extends StatelessWidget {
  final TextEditingController
      textEditingController; //used for controlling the data entered
  final String hintText;
  final bool isPass; //for setting obscuretext to true/false
  final TextInputType textInputType; //type of text enetered into the text field

  //a constructor for our generalized TextField
  const TextFieldInput(
      {super.key,
      required this.textEditingController,
      required this.hintText,
      this.isPass = false,
      required this.textInputType});

  @override
  Widget build(BuildContext context) {
    final inputBorder = OutlineInputBorder();
    // borderSide: Divider.createBorderSide(context)

    return TextField(
      controller: textEditingController,
      decoration: InputDecoration(
          hintText: hintText,
          border: inputBorder,
          enabledBorder: inputBorder,
          focusedBorder: inputBorder,
          filled: true,
          contentPadding: const EdgeInsets.all(15.0)),
      keyboardType: textInputType,
      obscureText: isPass,
    );
  }
}
