import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:attendance/components/professor-appbar.dart';
import 'package:attendance/components/professor-drawer.dart';
import 'package:attendance/config.dart';
import 'package:location/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/preferences/professor-preferences.dart';
import 'package:flutter/material.dart';

var _scaffoldContext;

class ProfessorDashboard extends StatefulWidget {
  @override
  _ProfessorDashboardState createState() => new _ProfessorDashboardState();
}

List recentSessionData;

class _ProfessorDashboardState extends State<ProfessorDashboard> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  List coursesData;
  bool noDataFound = false;
  var isLoading = false;

  Map<String, double> _currentLocation;
  StreamSubscription<Map<String, double>> _locationSubscription;
  Location _location = new Location();

  /*
   * Get recent 5 session record of professor that has been created
   * By Logged in professor
   */
  void getRecentSessionData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var professorId = prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_ID);

    var response = await http.post(Uri.encodeFull(Config.getRecentSessionUrl),
        headers: {"Accept": "application/json"},
        body: {'professor_id': professorId.toString()});

    var responseData = JSON.decode(response.body);

    setState(() {
      recentSessionData = responseData;
      isLoading = false;

      if (recentSessionData != null && recentSessionData.length == 0) {
        noDataFound = true;
        return;
      }
      noDataFound = false;
    });
  }

  /*
   * Get all courses in which professor is assigned
   * and display in Dialog when professor create a new session
   */
  void getCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var professorId = prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_ID);

    var response = await http.post(
        Uri.encodeFull(Config.getAllCoursesOfProfessorUrl),
        headers: {"Accept": "application/json"},
        body: {'professor_id': professorId.toString()});

    var responseData = JSON.decode(response.body);

    setState(() {
      coursesData = responseData;
    });
  }

  /*
   * Create new session for selected course_id
   * get location of professor and pass in params
   */
  void generateSession(courseId) async {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text('Generating Session...')));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var professorId = prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_ID);

    var response =
        await http.post(Uri.encodeFull(Config.createNewSessionUrl), headers: {
      "Accept": "application/json"
    }, body: {
      'professor_id': professorId.toString(),
      'course_id': courseId,
      'latitude': _currentLocation['latitude'].toString(),
      'longitude': _currentLocation['longitude'].toString()
    });

    var responseData = JSON.decode(response.body);
    if (responseData['resultCode'] == 200) {
      this.setState(() {
        isLoading = true;
      });
      getRecentSessionData();
      return;
    }

    _scaffoldKey.currentState.showSnackBar(
        new SnackBar(content: new Text('Something went wrong !')));
  }

  void showCoursesDialog(_courseList) async {
    showDialog(
      context: _scaffoldKey.currentContext,
      child: new Dialog(
        child: new Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new Padding(
              padding: const EdgeInsets.all(20.0),
              child: new Text(
                "Select course",
                style:
                    new TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
            ),
            new Container(height: 200.0, child: _courseList),
          ],
        ),
      ),
    ).then<void>((value) {
      // The value passed to Navigator.pop() or null.
      if (value != null) {
        generateSession(value.toString());
      }
    });
  }

  @override
  void initState() {
    super.initState();
    this.setState(() {
      isLoading = true;
    });
    this.getCourses();
    this.getRecentSessionData();

    initPlatformState();
    _locationSubscription =
        _location.onLocationChanged.listen((Map<String, double> result) {
      setState(() {
        _currentLocation = result;
      });
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _locationSubscription.cancel();
  }

// Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    Map<String, double> location;
    // Platform messages may fail, so we use a try/catch PlatformException.

    try {
      location = await _location.getLocation;
    } on PlatformException {
      location = null;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _currentLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    var _drawer = new Drawer(
      child: new ProfessorDrawer(currentState: context),
    );

    var _appBar = new AppBar(
      title: new Text("Dashboard"),
      actions: <Widget>[
        new ProfessorAppbar(),
      ],
    );

    var _progressIndicator = new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );

    var _noDataFoundView = new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: new Center(
        child: new Image.asset("images/img_no_data.png"),
      ),
    );

    var _courseList = new ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: coursesData == null ? 0 : coursesData.length,
      itemBuilder: (BuildContext context, int index) {
        return new CourseItem(
          text: coursesData[index]['course_name'],
          onPressed: () {
            Navigator.pop(context, coursesData[index]['id']);
          },
        );
      },
    );

    var _listRegisteredViewBuilder = new ListView.builder(
      scrollDirection: Axis.vertical,
      itemCount: recentSessionData == null ? 0 : recentSessionData.length,
      itemBuilder: (BuildContext context, int index) {
        return new Container(
          padding: new EdgeInsets.symmetric(horizontal: 5.0),
          child: new Card(
            child: new Rows(
              index: index,
              sessionId: recentSessionData[index]['id'],
              courseName: recentSessionData[index]['courses']['course_name'],
              sessionCode: recentSessionData[index]['session_code'],
              status: recentSessionData[index]['status'],
            ),
          ),
        );
      },
    );

    var _btnGenerateSession = new Container(
      child: new RaisedButton(
        padding: new EdgeInsets.all(16.0),
        color: Colors.white,
        elevation: 6.0,
        onPressed: () {
          showCoursesDialog(_courseList);
        },
        child: new Text("Create new session"),
        shape: new RoundedRectangleBorder(
            borderRadius: new BorderRadius.all(new Radius.circular(60.0))),
      ),
      margin: new EdgeInsets.only(bottom: 16.0, left: 16.0, right: 16.0),
    );

    return new Scaffold(
      key: _scaffoldKey,
      appBar: _appBar,
      drawer: _drawer,
      body: new Builder(builder: (BuildContext context) {
        _scaffoldContext = context;
        return new Container(
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              new SizedBox(height: 24.0),
              _btnGenerateSession,
              new Container(
                margin: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 8.0),
                child: new Text(
                  "Recent sessions",
                  style: new TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                ),
              ),
              new Expanded(
                child: isLoading
                    ? _progressIndicator
                    : noDataFound
                        ? _noDataFoundView
                        : _listRegisteredViewBuilder,
              )
            ],
          ),
        );
      }),
    );
  }
}

class Rows extends StatefulWidget {
  Rows({this.index, this.sessionId, this.status, this.sessionCode, this.courseName});

  var index, sessionId, status, sessionCode, courseName;

  @override
  _RowsState createState() => new _RowsState();
}

class _RowsState extends State<Rows> {
  // chnage session status to active/deactive
  void changeSessionStatus() async {
    setState(() {
      if (widget.status == 1) {
        recentSessionData[widget.index]['status'] = 0;
        widget.status = 0;
        return;
      }
      recentSessionData[widget.index]['status'] = 1;
      widget.status = 1;
    });

    var response = await http.post(
        Uri.encodeFull(Config.changeSessionStatusUrl),
        headers: {"Accept": "application/json"},
        body: {'session_id': widget.sessionId.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            child: new ListTile(
              title: new Text(widget.courseName,
                  style: Theme.of(context).textTheme.subhead),
              subtitle: new Text(widget.sessionCode,
                  style: new TextStyle(color: Colors.grey)),
              trailing: new FlatButton(
                onPressed: () {
                  changeSessionStatus();
                },
                child: new Text(
                  widget.status == 1 ? "Stop" : "Start",
                  style: new TextStyle(
                      color: widget.status == 1
                          ? Colors.redAccent
                          : Colors.blueAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseItem extends StatelessWidget {
  const CourseItem({Key key, this.text, this.onPressed}) : super(key: key);

  final String text;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return new SimpleDialogOption(
      onPressed: onPressed,
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.all(10.0),
            child: new Text(text),
          ),
        ],
      ),
    );
  }
}
