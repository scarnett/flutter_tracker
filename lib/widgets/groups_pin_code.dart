import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tracker/colors.dart';
import 'package:flutter_tracker/utils/group_utils.dart';

typedef OnDone = void Function(String text);
typedef PinBoxDecoration = BoxDecoration Function(Color borderColor);

class GroupsPinCodeTextField extends StatefulWidget {
  final int maxLength;
  final TextEditingController controller;
  final bool hideCharacter;
  final bool highlight;
  final Color highlightColor;
  final Color defaultBorderColor;
  final String maskCharacter;
  final String spacerCharacter;
  final int spacerIndex;
  final TextStyle pinTextStyle;
  final double pinBoxHeight;
  final double pinBoxWidth;
  final OnDone onDone;
  final bool hasError;
  final Color errorBorderColor;
  final Color hasTextBorderColor;
  final Function(String) onTextChanged;

  const GroupsPinCodeTextField({
    Key key,
    this.maxLength: GROUP_INVITE_CODE_LENGTH,
    this.controller,
    this.hideCharacter: false,
    this.highlight: true,
    this.highlightColor: AppTheme.primaryAccent,
    this.maskCharacter: ' ',
    this.spacerCharacter: GROUP_INVITE_CODE_SPACER_CHAR,
    this.spacerIndex: GROUP_INVITE_CODE_INDEX,
    this.pinBoxWidth: 40.0,
    this.pinBoxHeight: 50.0,
    this.pinTextStyle,
    this.onDone,
    this.defaultBorderColor: AppTheme.hint,
    this.hasTextBorderColor: AppTheme.primary,
    this.hasError: false,
    this.errorBorderColor: Colors.red,
    this.onTextChanged,
  }) : super(key: key);

  @override
  State createState() => GroupsPinCodeTextFieldState();
}

class GroupsPinCodeTextFieldState extends State<GroupsPinCodeTextField> {
  FocusNode focusNode = FocusNode();
  String text = '';
  int currentIndex = 0;
  List<String> strList = [];
  bool hasFocus = false;
  double pinWidth;

  @override
  void didUpdateWidget(
    GroupsPinCodeTextField oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maxLength < widget.maxLength) {
      setState(() {
        currentIndex = text.length;
      });

      widget.controller?.text = text;
      widget.controller?.selection =
          TextSelection.collapsed(offset: text.length);
    } else if ((oldWidget.maxLength > widget.maxLength) &&
        (widget.maxLength > 0) &&
        (text.length > 0) &&
        (text.length > widget.maxLength)) {
      setState(() {
        text = text.substring(0, widget.maxLength);
        currentIndex = text.length;
      });

      widget.controller?.text = text;
      widget.controller?.selection =
          TextSelection.collapsed(offset: text.length);
    }
  }

  _calculateStrList() async {
    if (strList.length > widget.maxLength) {
      strList.length = widget.maxLength;
    }

    while (strList.length < widget.maxLength) {
      strList..add('');
    }
  }

  _calculatePinWidth() async {
    double screenWidth = MediaQuery.of(context).size.width;
    double tempPinWidth = widget.pinBoxWidth;
    int maxLength = widget.maxLength;
    while ((tempPinWidth * maxLength) > screenWidth) {
      tempPinWidth -= 4;
    }

    tempPinWidth -= 10;

    setState(() {
      pinWidth = tempPinWidth;
    });
  }

  @override
  void initState() {
    super.initState();

    _initTextController();
    _calculateStrList();

    widget.controller?.addListener(() {
      setState(() {
        _initTextController();
      });

      widget.onTextChanged(widget.controller.text);
    });

    focusNode.addListener(() {
      setState(() {
        hasFocus = focusNode.hasFocus;
      });
    });
  }

  void _initTextController() {
    if (widget.controller == null) {
      return;
    }

    strList.clear();

    text = widget.controller.text;
    for (int i = 0; i < text.length; i++) {
      strList..add(widget.hideCharacter ? widget.maskCharacter : text[i]);
    }
  }

  @override
  void dispose() {
    focusNode?.dispose();
    widget.controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _touchPinBoxRow(),
          _fakeTextInput(),
        ],
      ),
    );
  }

  Widget _touchPinBoxRow() {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (hasFocus) {
          FocusScope.of(context).requestFocus(FocusNode());
          Future.delayed(Duration(milliseconds: 100), () {
            FocusScope.of(context).requestFocus(focusNode);
          });
        } else {
          FocusScope.of(context).requestFocus(focusNode);
        }
      },
      child: _pinBoxRow(context),
    );
  }

  Widget _fakeTextInput() {
    OutlineInputBorder transparentBorder = OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.transparent,
        width: 0.0,
      ),
    );

    return Container(
      width: 0.1,
      height: 8.0, // RenderBoxDecorator subtextGap constant is 8.0
      child: TextField(
        focusNode: focusNode,
        controller: widget.controller,
        style: const TextStyle(
          height: 0.1,
          color: Colors.transparent,
        ),
        inputFormatters: <TextInputFormatter>[
          UpperCaseTextFormatter(),
        ],
        decoration: InputDecoration(
          focusedErrorBorder: transparentBorder,
          errorBorder: transparentBorder,
          disabledBorder: transparentBorder,
          enabledBorder: transparentBorder,
          focusedBorder: transparentBorder,
          counterText: null,
          counterStyle: null,
          helperStyle: TextStyle(
            height: 0.0,
            color: Colors.transparent,
          ),
          labelStyle: const TextStyle(height: 0.1),
          fillColor: Colors.transparent,
          border: InputBorder.none,
        ),
        cursorColor: Colors.transparent,
        maxLength: widget.maxLength,
        onChanged: _onTextChanged,
      ),
    );
  }

  void _onTextChanged(text) {
    if (widget.onTextChanged != null) {
      widget.onTextChanged(text);
    }

    setState(() {
      this.text = text;
      if (text.length < currentIndex) {
        strList[text.length] = '';
      } else {
        strList[text.length - 1] =
            widget.hideCharacter ? widget.maskCharacter : text[text.length - 1];
      }

      currentIndex = text.length;
    });

    if (text.length == widget.maxLength) {
      FocusScope.of(context).requestFocus(FocusNode());
      widget.onDone(text);
    }
  }

  Widget _pinBoxRow(
    BuildContext context,
  ) {
    _calculateStrList();
    _calculatePinWidth();

    List<Widget> pinCodes = [];

    for (int i = 0; i < widget.maxLength; i++) {
      pinCodes..add(_buildPinCode(i, context));

      if ((widget.spacerIndex > 0) &&
          (widget.maxLength > (i + 1)) &&
          (widget.spacerCharacter != null) &&
          (((i + 1) % widget.spacerIndex) == 0)) {
        pinCodes..add(_buildSpacer());
      }
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      verticalDirection: VerticalDirection.down,
      children: pinCodes,
    );
  }

  Widget _buildPinCode(
    int i,
    BuildContext context,
  ) {
    Color borderColor;

    if (widget.hasError) {
      borderColor = widget.errorBorderColor;
    } else if (widget.highlight &&
        hasFocus &&
        ((i == text.length) ||
            ((i == (text.length - 1)) && (text.length == widget.maxLength)))) {
      borderColor = widget.highlightColor;
    } else if (i < text.length) {
      borderColor = widget.hasTextBorderColor;
    } else {
      borderColor = widget.defaultBorderColor;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: Container(
        key: ValueKey<String>('container$i'),
        child: Center(child: _animatedTextBox(strList[i], i)),
        decoration: BoxDecoration(
          border: Border.all(
            color: borderColor,
            width: 4.0,
          ),
          borderRadius: BorderRadius.all(
            const Radius.circular(5.0),
          ),
        ),
        width: pinWidth,
        height: widget.pinBoxHeight,
      ),
    );
  }

  Widget _buildSpacer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Container(
        child: Center(
          child: Text(
            widget.spacerCharacter,
            style: const TextStyle(
              color: AppTheme.hint,
              fontSize: 30.0,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
        width: 15.0,
        height: widget.pinBoxHeight,
      ),
    );
  }

  Widget _animatedTextBox(
    String text,
    int i,
  ) {
    return AnimatedSwitcher(
      duration: Duration(milliseconds: 300),
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          ScaleTransition(
        child: child,
        scale: animation,
      ),
      child: Text(
        text,
        key: ValueKey<String>('$text$i'),
        style: widget.pinTextStyle ??
            TextStyle(
              fontSize: 20.0,
              fontStyle: FontStyle.normal,
            ),
      ),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return TextEditingValue(
      text: newValue.text?.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
