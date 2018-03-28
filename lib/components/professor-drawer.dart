import 'package:attendance/preferences/professor-preferences.dart';
import 'package:attendance/professor/dashboard.dart';
import 'package:attendance/professor/view-sessions.dart';
import 'package:attendance/professor/view-students.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfessorDrawer extends StatefulWidget {
  BuildContext currentState;

  ProfessorDrawer({this.currentState});

  @override
  _ProfessorDrawerState createState() => new _ProfessorDrawerState();
}

class _ProfessorDrawerState extends State<ProfessorDrawer> {
  var name = "", email = "";

  String currentProfilePic =
      "https://scontent-bom1-1.cdninstagram.com/vp/63a30cc70bdb9162cd44ee8d1659d087/5B290D9A/t51.2885-19/s150x150/28428337_2175166739416117_1436518324010745856_n.jpg";

  _getProfessorData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      this.name = prefs.getString(ProfessorPreferences.KEY_PROFESSOR_NAME);
      this.email = prefs.getString(ProfessorPreferences.KEY_PROFESSOR_EMAIL);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _getProfessorData();
  }

  void handleOntap(index) {
    switch (index) {
      case 0:
        if (widget.currentState.widget.toString() == "ProfessorDashboard") {
          Navigator.of(widget.currentState).pop(true);
        } else {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new ProfessorDashboard()));
        }
        break;
      case 1:
        if (widget.currentState.widget.toString() == "ViewStudents") {
          Navigator.of(widget.currentState).pop(true);
        } else {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new ViewStudents()));
        }
        break;
      case 2:
        if (widget.currentState.widget.toString() == "ViewSessions") {
          Navigator.of(widget.currentState).pop(true);
        } else {
          Navigator.of(context).pushReplacement(new MaterialPageRoute(
              builder: (BuildContext context) => new ViewSessions()));
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new ListView(
      children: <Widget>[
        new UserAccountsDrawerHeader(
          accountName: new Text(this.name),
          accountEmail: new Text(this.email),
          currentAccountPicture: new GestureDetector(
            child: new CircleAvatar(
              backgroundImage: new CachedNetworkImageProvider(currentProfilePic),
            ),
          ),
          decoration: new BoxDecoration(
            image: new DecorationImage(
              fit: BoxFit.fill,
              image: new AssetImage("images/navbackground.jpg"),
            ),
          ),
        ),
        new ListTile(
          leading: new Icon(Icons.home),
          title: new Text("Dashboard"),
          onTap: () {
            handleOntap(0);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.person),
          title: new Text("View students"),
          onTap: () {
            handleOntap(1);
          },
        ),
        new ListTile(
          leading: new Icon(Icons.ac_unit),
          title: new Text("All Sessions"),
          onTap: () {
            handleOntap(2);
          },
        ),
      ],
    );
  }
}
