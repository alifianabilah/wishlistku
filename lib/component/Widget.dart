// ignore_for_file: file_names, must_be_immutable, prefer_const_constructors

import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  String? label;
  TextEditingController? controller;
  FocusNode? focusNode;
  IconData? icon;
  int? maxLines;
  void Function(String?)? onSubmitted;
  String? Function(dynamic)? validator;
  TextInputType? textInputType;
  TextInputAction? textInputAction;
  bool? autovalidate = false;

  CustomTextField(
      {Key? key,
      this.label,
      this.controller,
      this.focusNode,
      this.icon,
      this.maxLines,
      this.autovalidate,
      this.onSubmitted,
      this.textInputType,
      this.textInputAction,
      this.validator})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 10.0),
      decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10.0)),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        textInputAction: textInputAction ?? TextInputAction.continueAction,
        autovalidateMode: AutovalidateMode.always,
        onFieldSubmitted: onSubmitted,
        validator: validator,
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(5, 5.0, 5.0, 0),
            labelText: label,
            prefixIcon: icon == null ? null : Icon(icon),
            border: InputBorder.none),
        maxLines: maxLines,
        keyboardType: textInputType ?? TextInputType.text,
      ),
    );
  }
}
