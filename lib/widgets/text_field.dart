import 'package:flutter/material.dart';
import 'package:flutter_tracker/colors.dart';

class CustomTextField extends StatefulWidget {
  final bool autovalidate;
  final String initialValue;
  final String hintText;
  final Color color;
  final IconData icon;
  final Color iconColor;
  final Widget suffixIcon;
  final int maxLines;
  final bool autofocus;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final TextEditingController controller;
  final FormFieldValidator<String> validator;
  final FormFieldSetter<String> onSaved;
  final FormFieldSetter<String> onChanged;

  CustomTextField({
    this.autovalidate = false,
    this.initialValue,
    this.hintText,
    this.color: Colors.black,
    this.icon,
    this.iconColor,
    this.suffixIcon,
    this.maxLines: 1,
    this.autofocus: false,
    this.keyboardType,
    this.textCapitalization: TextCapitalization.words,
    this.controller,
    this.validator,
    this.onSaved,
    this.onChanged,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return TextFormField(
      controller: widget.controller,
      autovalidate: widget.autovalidate,
      initialValue: widget.initialValue,
      maxLines: widget.maxLines,
      autofocus: widget.autofocus,
      textCapitalization: widget.textCapitalization,
      validator: widget.validator,
      onChanged: widget.onChanged,
      onSaved: widget.onSaved,
      style: TextStyle(
        color: widget.color,
      ),
      decoration: InputDecoration(
        hintText: widget.hintText,
        contentPadding: const EdgeInsets.only(
          left: 0.0,
          right: 20.0,
          top: 15.0,
        ),
        prefixIcon: Icon(
          widget.icon,
          color: (widget.iconColor == null)
              ? AppTheme.inactive()
              : widget.iconColor,
        ),
        suffixIcon: widget.suffixIcon,
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey[500],
            width: 2.0,
          ),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppTheme.inactive()),
        ),
      ),
    );
  }
}
