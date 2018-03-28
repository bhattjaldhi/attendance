import 'package:flutter/material.dart';

class CommonFunctions {
  static showProgressDialog(_scaffoldContext) {
    showDialog(
      context: _scaffoldContext,
      child: new Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.all(20.0),
            height: 90.0,
            child: new Card(
              child: new ListTile(
                leading: new CircularProgressIndicator(),
                title: new Text("Please Wait"),
              ),
            ),
          ),
        ],
      ),
    );
  }


  static dismissDialog(_scaffoldContext) {
    Navigator.of(_scaffoldContext).pop();
  }
}