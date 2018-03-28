import 'dart:async';
import 'dart:convert';

import 'package:attendance/common-functions.dart';
import 'package:attendance/config.dart';
import 'package:attendance/login.dart';
import 'package:attendance/preferences/professor-preferences.dart';
import 'package:attendance/preferences/student-preferences.dart';
import 'package:attendance/professor/dashboard.dart';
import 'package:attendance/student/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:attendance/components/appbar.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var data;
  var androidID;
  var _scaffoldContext, context;
  static const platform = const MethodChannel('attendance.student');

  TextStyle btnLable = new TextStyle(
      color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.w900);

  /*
   *
   *
   *
   *  Open professor login page
   *
   *
   *
   *
   */
  openProfessorLoginpage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_ID) != null) {
      Navigator.of(context).push(
          new MaterialPageRoute(builder: (_) => new ProfessorDashboard()));
    } else {
      Navigator
          .of(context)
          .push(new MaterialPageRoute(builder: (_) => new LoginPage()));
    }
  }

  /*
   *
   *
   *
   *
   * open dialog to select gmail accounts
   *
   * Get selected gmail account by student
   *
   *
   *
   *
   */
  Future<String> _getStudentSelectedAccount() async {
    String result = "";

    try {
      result = await platform.invokeMethod('getStudentSelectedAccount');
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }

    return result;
  }

  /*
   *
   * 
   * 
   *  Get android id from custom plugin
   *  
   *  
   * 
   */
  Future<String> _getAndroidID() async {
    String result = "";

    try {
      result = await platform.invokeMethod('getAndroidID');
    } on PlatformException catch (e) {
      print("Failed to get battery level: '${e.message}'.");
    }

    return result;
  }

  /*
   *
   * 
   * 
   * 
   * 
   * 
   * 
   * Check if student status is active or deactive
   *
   * if student status is active then Route to student dashboard
   *
   * otherwise display message in snackbar
   *
   * 
   * 
   * 
   * 
   * 
   * 
   */
  checkStudentStatus(id) async {
    CommonFunctions.showProgressDialog(_scaffoldContext);

    var response = await http.post(Uri.encodeFull(Config.checkStudentStatusUrl),
        headers: {"Accept": "application/json"},
        body: {'student_id': id.toString()});

    CommonFunctions.dismissDialog(_scaffoldContext);
    await new Future.delayed(const Duration(milliseconds: 500));

    data = JSON.decode(response.body);

    if (data['resultCode'] != 200) {
      Scaffold
          .of(_scaffoldContext)
          .showSnackBar(new SnackBar(content: new Text(data['message'])));
    }

    Navigator
        .of(context)
        .pushReplacement(new MaterialPageRoute(builder: (_) => new StudentDashboard()));
  }

  /*
   * 
   * 
   * 
   * 
   * 
   * 
   * check if student id is already saved or not
   * 
   * if student id is already stored, then check student status
   * 
   * otherwise open dialog to choose account
   * 
   * Student will select account and then make http request along with android ID
   * 
   * 
   * 
   * 
   *
   * 
   */
  openStudentLoginPage() async {
    Future<int> future_student = StudentPreferences.getStudentId();

    future_student.then((value) {
      if (value != null) {
        checkStudentStatus(value);
        return;
      }

      Future<String> selectedAccount = _getStudentSelectedAccount();
      Future<String> androidID = _getAndroidID();

      androidID.then((value) {
        this.androidID = value;
      }).catchError((error) => (error) {});

      selectedAccount
          .then((value) => _storeStudentData(value))
          .catchError((error) => (error) {});
    });
  }

  /*
   *
   * 
   * 
   * 
   * 
   * 
   * Get android ID and selected account by student
   * 
   * Make HTTP request to store in database at first time
   * 
   * 
   * 
   * 
   */
  void _storeStudentData(selectedAccount) async {
    if (selectedAccount != null && androidID != null) {
      CommonFunctions.showProgressDialog(_scaffoldContext);

      var response = await http.post(Uri.encodeFull(Config.storeStudentDataUrl),
          headers: {"Accept": "application/json"},
          body: {'student_email': selectedAccount, 'android_id': androidID});

      CommonFunctions.dismissDialog(_scaffoldContext);
      await new Future.delayed(const Duration(milliseconds: 500));

      this.setState(() {
        data = JSON.decode(response.body);
      });

      handleStudentData();
    }
  }

  /*
   *
   * 
   * 
   * 
   * 
   * 
   * 
   * Check if student data is correct
   *
   * If it is correct, save in shared preferences
   *
   * Otherwise, display message from server
   *
   *
   *
   *
   *
   *
   */
  void handleStudentData() {
    if (data['resultCode'] != 200) {
      Scaffold
          .of(_scaffoldContext)
          .showSnackBar(new SnackBar(content: new Text(data['message'])));
      return;
    }

    if (data['data']['status'] != 1) {
      Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
          content: new Text(
              "Your account has been deactivated by organization admin")));
      return;
    }

    new StudentPreferences().storeDataAtLogin(data);
    Navigator
        .of(context)
        .pushReplacement(new MaterialPageRoute(builder: (_) => new StudentDashboard()));
  }

  /*
   *
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   * 
   */

  @override
  Widget build(BuildContext context) {
    this.context = context;

    final professorLogo = new Hero(
      tag: 'professor-logo',
      child: new CircleAvatar(
        child: new Container(
            width: 150.0,
            height: 150.0,
            decoration: new BoxDecoration(
              color: const Color(0xff7c94b6),
              image: new DecorationImage(
                image: new AssetImage("images/professor.jpg"),
              ),
              borderRadius: new BorderRadius.all(new Radius.circular(80.0)),
            )),
      ),
    );

    final studentLogo = new Hero(
      tag: 'student-logo',
      child: new CircleAvatar(
        child: new Container(
          width: 150.0,
          height: 150.0,
          decoration: new BoxDecoration(
            color: const Color(0xff7c94b6),
            image: new DecorationImage(
              image: new AssetImage("images/student.jpg"),
            ),
            borderRadius: new BorderRadius.all(new Radius.circular(80.0)),
          ),
        ),
      ),
    );

    return new Scaffold(
      appBar: new MyAppBar().createAppbar("Attendee"),
      body: new Builder(
        builder: (BuildContext context) {
          _scaffoldContext = context;

          return new Container(
            decoration: new BoxDecoration(
              gradient: new LinearGradient(
                begin: Alignment.topCenter,
                end: new Alignment(1.0, 5.0),
                // 10% of the width, so there are ten blinds.
                colors: [Colors.white, Colors.blueAccent], // whitish to gray
              ),
            ),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                new Column(
                  children: <Widget>[
                    new Container(
                      width: 150.0,
                      height: 150.0,
                      child: professorLogo,
                      margin: const EdgeInsets.all(16.0),
                    ),
                  ],
                ),
                new Container(
                  child: new RaisedButton(
                    padding: new EdgeInsets.all(16.0),
                    color: Colors.blueAccent,
                    elevation: 20.0,
                    onPressed: () {
                      openProfessorLoginpage();
                    },
                    child: new Text("I am Professor", style: btnLable),
                    shape: new RoundedRectangleBorder(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(60.0))),
                  ),
                  margin: new EdgeInsets.only(
                      bottom: 16.0, left: 16.0, right: 16.0),
                ),
                new Column(
                  children: <Widget>[
                    new Container(
                      width: 150.0,
                      height: 150.0,
                      child: studentLogo,
                      margin: const EdgeInsets.all(16.0),
                    ),
                  ],
                ),
                new Container(
                  child: new RaisedButton(
                    padding: new EdgeInsets.all(16.0),
                    color: Colors.blueAccent,
                    elevation: 20.0,
                    onPressed: () {
                      openStudentLoginPage();
                    },
                    child: new Text("I am Student", style: btnLable),
                    shape: new RoundedRectangleBorder(
                        borderRadius:
                            new BorderRadius.all(new Radius.circular(60.0))),
                  ),
                  margin: new EdgeInsets.only(
                      bottom: 16.0, left: 16.0, right: 16.0),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
