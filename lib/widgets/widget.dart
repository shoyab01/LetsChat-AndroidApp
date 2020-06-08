import 'package:flutter/material.dart';

Widget appBarMain(BuildContext context)
{
  return AppBar(
    title: Image.asset(
      "assets/images/logo.png",
      height: 50,
    ),
  );
}

InputDecoration textFieldInputDecoration(String hintText)
{
  return (InputDecoration(
    hintText: hintText,
    hintStyle: TextStyle(
      color: Colors.black45,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2.0),
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 1.0),
    ),
  )
  );
}

TextStyle simpleTextStyle()
{
  return TextStyle(
    color: Colors.black,
    fontSize: 16,
  );
}

TextStyle mediumTextStyle()
{
  return TextStyle(
    color: Colors.white,
    fontSize: 17,
  );
}