import 'package:flutter/material.dart';

class ApplicationToolbar extends StatelessWidget with PreferredSizeWidget {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Image.asset("assets/images/logo.png",height: 50,),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

InputDecoration textFieldInputDecoration(String hintText) {
  return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(color: Colors.white54),
      focusedBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      enabledBorder:
          UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)));
}

TextStyle simpleTextStyle() {
  return TextStyle(
    color: Colors.white,
    fontSize: 16,
  );
}

TextStyle mediumTextStyle() {
  return TextStyle(color: Colors.white, fontSize: 16);
}
