import 'package:attendance/preferences/professor-preferences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfessorAppbar extends StatefulWidget {
  @override
  _ProfessorAppbarState createState() => new _ProfessorAppbarState();
}

class _ProfessorAppbarState extends State<ProfessorAppbar> {
  void _selectOptionMenu(Choice choice) {
    switch (choice.title) {
      case "Logout":
        _logout();
        break;
    }
  }

  void _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove(ProfessorPreferences.KEY_PROFESSOR_ID);
    prefs.remove(ProfessorPreferences.KEY_PROFESSOR_EMAIL);
    prefs.remove(ProfessorPreferences.KEY_PROFESSOR_NAME);
    prefs.remove(ProfessorPreferences.KEY_PROFESSOR_DEPTID);
    prefs.remove(ProfessorPreferences.KEY_PROFESSOR_ORGANIZATION_ID);

    Navigator.of(context).pop(true);
  }

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
  const Choice({this.title});

  final String title;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Logout'),
];
