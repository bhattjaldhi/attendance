import 'dart:convert';

import 'package:attendance/config.dart';
import 'package:attendance/preferences/student-preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CoursesList extends StatefulWidget {
  @override
  _CoursesListState createState() => new _CoursesListState();
}

class _CoursesListState extends State<CoursesList> {
  var data;
  var isLoading = false;

  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var departmentId = prefs.getInt(StudentPreferences.KEY_STUDENT_DEPTID);
    var studentId = prefs.getInt(StudentPreferences.KEY_STUDENT_ID);

    var response = await http.post(Uri.encodeFull(Config.getCoursesUrl),
        headers: {
          "Accept": "application/json"
        },
        body: {
          'department_id': departmentId.toString(),
          'student_id': studentId.toString()
        });

    setState(() {
      data = JSON.decode(response.body);
      isLoading = false;
    });
  }

  @override
  void initState() {
    this.setState(() {
      isLoading = true;
    });
    this.getData();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();

    data = null;
  }

  @override
  Widget build(BuildContext context) {
    var _progressIndicator = new Center(
      child: new CircularProgressIndicator(),
    );

    var _listRegisteredViewBuilder = new ListView.builder(
      itemCount: data == null
          ? 0
          : data['registered_courses'].length +
              data['unregistered_courses'].length,
      itemBuilder: (BuildContext context, int index) {
        return new Container(
          padding: new EdgeInsets.symmetric(horizontal: 5.0),
          child: new Card(
            child: index < data['registered_courses'].length
                ? new Courses(
                    courseName: data['registered_courses'][index]
                        ['course_name'],
                    professorName: data['registered_courses'][index]
                        ['professor']['name'],
                    courseId: data['registered_courses'][index]['id'],
                    type: true,
                  )
                : new Courses(
                    courseName: data['unregistered_courses']
                            [index - data['registered_courses'].length]
                        ['course_name'],
                    professorName: data['unregistered_courses']
                            [index - data['registered_courses'].length]
                        ['professor']['name'],
                    courseId: data['unregistered_courses']
                        [index - data['registered_courses'].length]['id'],
                    type: false,
                  ),
          ),
        );
      },
    );

    return isLoading ? _progressIndicator : _listRegisteredViewBuilder;
  }
}

class Courses extends StatefulWidget {
  Courses({this.courseId, this.courseName, this.professorName, this.type});

  bool type;
  int courseId;
  String courseName, professorName;

  @override
  _CoursesState createState() => new _CoursesState();
}

class _CoursesState extends State<Courses> {
  registerCourse(id) async {

    setState(() {
      widget.type = true;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var studentId = prefs.getInt(StudentPreferences.KEY_STUDENT_ID);

    var response = await http.post(Uri.encodeFull(Config.registerCoursesUrl),
        headers: {"Accept": "application/json"},
        body: {'student_id': studentId.toString(), 'course_id': id.toString()});
  }

  unregisterCourse(id) async {

    setState(() {
      widget.type = false;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var studentId = prefs.getInt(StudentPreferences.KEY_STUDENT_ID);

    var response = await http.post(Uri.encodeFull(Config.unregisterCoursesUrl),
        headers: {"Accept": "application/json"},
        body: {'student_id': studentId.toString(), 'course_id': id.toString()});
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Expanded(
            child: new ListTile(
              title: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  new Text(widget.courseName,
                      style: Theme.of(context).textTheme.subhead),
                  new Container(
                    margin: const EdgeInsets.only(top: 6.0),
                    child: new Text(widget.professorName,
                        style: new TextStyle(color: Colors.grey)),
                  )
                ],
              ),
              trailing: new FlatButton(
                onPressed: () {
                  widget.type == true
                      ? unregisterCourse(widget.courseId)
                      : registerCourse(widget.courseId);
                },
                child: new Text(
                  widget.type == true ? "Remove" : "Register",
                  style: new TextStyle(
                      color: widget.type == true
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
