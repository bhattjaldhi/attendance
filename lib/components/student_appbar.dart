import 'package:attendance/preferences/student-preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentAppbar extends StatefulWidget {
  @override
  _StudentAppbarState createState() => new _StudentAppbarState();
}

class _StudentAppbarState extends State<StudentAppbar> {
  void _selectOptionMenu(Choice choice) {
    switch (choice.index) {
      case 0:
        _viewProfile();
        break;
    }
  }

  void _viewProfile() async {}

  @override
  Widget build(BuildContext context) {
    return new PopupMenuButton<Choice>(
      // overflow menu
      onSelected: _selectOptionMenu,
      itemBuilder: (BuildContext context) {
        return choices.map((Choice choice) {
          return new PopupMenuItem<Choice>(
            value: choice,
            child: new Text(choice.title),
          );
        }).toList();
      },
    );
  }
}

class Choice {
  const Choice({this.index, this.title});

  final String title;
  final int index;
}

const List<Choice> choices = const <Choice>[
  const Choice(index: 0, title: 'View Profile'),
];
