import 'package:flutter/material.dart';

class MyAppBar {

  createAppbar(title) {
    return new AppBar(title: new Text(title, style: new TextStyle(color: Colors.white)));
  }

}
