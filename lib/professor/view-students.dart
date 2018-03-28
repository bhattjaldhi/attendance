import 'dart:async';
import 'dart:convert';

import 'package:attendance/components/professor-appbar.dart';
import 'package:attendance/components/professor-drawer.dart';
import 'package:attendance/config.dart';
import 'package:attendance/preferences/professor-preferences.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ViewStudents extends StatefulWidget {
  @override
  _ViewStudentsState createState() => new _ViewStudentsState();
}

class _ViewStudentsState extends State<ViewStudents> {
  List data;
  var isLoading = false;

  getData() async {
    var response = await http.post(
        Uri.encodeFull(Config.professorViewStudentsUrl),
        headers: {"Accept": "application/json"},
        body: {'organization_id': "1", 'department_id': "1"});

    print("Success");

    this.setState(() {
      data = JSON.decode(response.body)['data'];
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

  // simulate a http request
  Future<Null> _onRefresh() async{
    Completer<Null> completer = new Completer<Null>();

    setState(() {
      data == null;
    });

    SharedPreferences prefs = await SharedPreferences.getInstance();
    var organization_id = prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_ORGANIZATION_ID);
    var department_id = prefs.getInt(ProfessorPreferences.KEY_PROFESSOR_DEPTID);

    var response = await http.post(
        Uri.encodeFull(Config.professorViewStudentsUrl),
        headers: {"Accept": "application/json"},
        body: {'organization_id': organization_id.toString(), 'department_id': department_id.toString()});

    print(response.body);

    this.setState(() {
      data = JSON.decode(response.body)['data'];
      completer.complete();
    });

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    var _progressIndicator = new Center(
      child: new CircularProgressIndicator(),
    );

    var _drawer = new Drawer(
      child: new ProfessorDrawer(currentState: context),
    );

    var _appBar = new AppBar(
      title: new Text("View students"),
      actions: <Widget>[
        new ProfessorAppbar(),
      ],
    );

    var _listViewBuilder = new ListView.builder(
      itemCount: data == null ? 0 : data.length,
      itemBuilder: (BuildContext context, int index) {
        return new Container(
          padding: new EdgeInsets.symmetric(horizontal: 5.0),
          child: new Card(
            child: new InkWell(
              onTap: () {
                print(data[index]['name']);
              },
              child: new StudentRow(
                name: data[index]['name'],
                enrollment: data[index]['enrollment'],
                image: data[index]['image'],
              ),
            ),
          ),
        );
      },
    );

    var refreshListner =
        new RefreshIndicator(child: _listViewBuilder, onRefresh: _onRefresh);

    return new Scaffold(
      appBar: _appBar,
      drawer: _drawer,
      body: isLoading ? _progressIndicator : refreshListner,
    );
  }
}

class StudentRow extends StatelessWidget {
  StudentRow({this.name, this.enrollment, this.image});

  final String name, enrollment, image;

  @override
  Widget build(BuildContext context) {
    return new Container(
      padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: new Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          new Container(
            margin: const EdgeInsets.only(right: 18.0),
            child: new CircleAvatar(
              child: new Container(
                decoration: new BoxDecoration(
                  color: const Color(0xff7c94b6),
                  image: new DecorationImage(
                    image: new CachedNetworkImageProvider(
                        Config.baseUrl + "/storage/student_images/" + image),
                  ),
                  borderRadius: new BorderRadius.all(new Radius.circular(80.0)),
                ),
              ),
            ),
          ),
          new Expanded(
              child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Text(this.name, style: Theme.of(context).textTheme.subhead),
              new Container(
                margin: const EdgeInsets.only(top: 6.0),
                child: new Text(this.enrollment),
              )
            ],
          ))
        ],
      ),
    );
  }
}
