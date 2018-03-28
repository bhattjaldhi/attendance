import 'dart:async';
import 'dart:convert';

import 'package:attendance/config.dart';
import 'package:attendance/preferences/student-preferences.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class AttendanceRecord extends StatefulWidget {
  @override
  _CoursesListState createState() => new _CoursesListState();
}

class _CoursesListState extends State<AttendanceRecord> {
  List data;
  int current_page = 1;
  int lastpage;
  var isLoading = false, isLoadMore = false;

  DateTime selectedDateTime;
  String selectedDate = "", selectedCourse = "";
  bool noDataFound = false;

  // Get student attendance data from server
  getData({bool isDateSelected: false, bool isCourseSelected: false}) async {
    if (isDateSelected || isCourseSelected) {
      setState(() {
        data = null;
      });
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var studentId = prefs.getInt(StudentPreferences.KEY_STUDENT_ID);

    var response = await http.post(
        Uri.encodeFull(
            Config.getAttendanceRecordUrl + "?page=" + current_page.toString()),
        headers: {
          "Accept": "application/json"
        },
        body: {
          'student_id': studentId.toString(),
          'course_id': selectedCourse,
          'date': selectedDate
        });

    var responseData = JSON.decode(response.body);

    print(response.body);

    setState(() {
      isLoading = false;

      if (data == null) {
        data = responseData['data'];

        if (data.length == 0) {
          noDataFound = true;
          return;
        }
        noDataFound = false;
        lastpage = responseData['last_page'];
      } else {
        isLoadMore = false;
        for (var i = 0; i < responseData['data'].length; i++) {
          data.add(responseData['data'][i]);
        }
      }
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

    setState(() {
      data = null;
    });
  }

  _onNotification(value) {
    if (value is OverscrollNotification) {
      if (value.overscroll > 0 && current_page < lastpage) {
        setState(() {
          current_page++;
          isLoadMore = true;
        });
        getData();
      }
    }
  }

  // show date picker
  // when user select date, load data accordingly
  _showDatePicker() async {
    Future<DateTime> future = showDatePicker(
      context: context,
      firstDate: new DateTime(2018),
      initialDate:
          selectedDateTime != null ? selectedDateTime : new DateTime.now(),
      lastDate: new DateTime.now(),
    );

    future.then((dateTime) {
      setState(() {
        selectedDate = dateTime.toIso8601String();
        selectedDateTime = dateTime;
        isLoading = true;
      });
      this.getData(isDateSelected: true);
    }).catchError((e) {
      print(e.message);
    });
  }

  @override
  Widget build(BuildContext context) {
    var _progressIndicator = new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: new Center(
        child: new CircularProgressIndicator(),
      ),
    );

    var _listRegisteredViewBuilder = new NotificationListener(
      onNotification: (value) {
        _onNotification(value);
      },
      child: new ListView.builder(
        scrollDirection: Axis.vertical,
        itemCount:
            data == null ? 0 : (isLoadMore ? data.length + 1 : data.length),
        itemBuilder: (BuildContext context, int index) {
          return new Container(
            padding: new EdgeInsets.symmetric(horizontal: 5.0),
            child: isLoadMore && index == data.length
                ? _progressIndicator
                : new Card(
                    child: new Rows(
                      courseName: data[index]['session']['courses']
                          ['course_name'],
                      sessionCode: data[index]['session']['session_code'],
                      latitude: data[index]['latitude'].toString(),
                      longitude: data[index]['longitude'].toString(),
                    ),
                  ),
          );
        },
      ),
    );

    var _noDataFoundView = new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      child: new Center(
        child: new Image.asset("images/img_no_data.png"),
      ),
    );

    var _topButtons = new Container(
      child: new Column(
        children: <Widget>[
          new SizedBox(height: 24.0),
          new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new FlatButton(
                    onPressed: () {
                      _showDatePicker();
                    },
                    child: new Icon(
                      Icons.calendar_today,
                      color: Colors.blueAccent,
                    )),
              ]),
          new Expanded(
            child: noDataFound ? _noDataFoundView : _listRegisteredViewBuilder,
          )
        ],
      ),
    );

    return isLoading ? _progressIndicator : _topButtons;
  }
}

// Signle row design
class Rows extends StatefulWidget {
  Rows({this.courseName, this.sessionCode, this.latitude, this.longitude});

  String courseName, sessionCode, latitude, longitude;

  @override
  _RowsState createState() => new _RowsState();
}

class _RowsState extends State<Rows> {
  // launch map with attendance latitude and longitude
  _launchMap() async {
    var url = "http://maps.google.com/maps?q=${widget.latitude},${widget
        .longitude}(" +
        "You were here" +
        ")&iwloc=A&hl=es";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
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
                    child: new Text(widget.sessionCode,
                        style: new TextStyle(color: Colors.grey)),
                  )
                ],
              ),
              trailing: new FlatButton(
                onPressed: () {
                  _launchMap();
                },
                child: new Text(
                  "View Location",
                  style: new TextStyle(color: Colors.blueAccent),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
