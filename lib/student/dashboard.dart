import 'package:attendance/components/student_appbar.dart';
import 'package:attendance/student/attendance-record.dart';
import 'package:attendance/student/courses-list.dart';
import 'package:attendance/student/attend-class.dart';
import 'package:flutter/material.dart';

class StudentDashboard extends StatefulWidget {
  @override
  _StudentDashboardState createState() => new _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard>
    with SingleTickerProviderStateMixin {
  TabController _tabController;
  var _scaffoldContext;
  var _currrentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = new TabController(vsync: this, length: 3);
    _tabController.addListener(() {
      setState(() {
        _currrentIndex = _tabController.index;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var _appBar = new AppBar(
      title: new Text("Student"),
      actions: <Widget>[
        new StudentAppbar(),
      ],
    );

    return new Scaffold(
        appBar: _appBar,
        bottomNavigationBar: new BottomNavigationBar(
          items: [
            new BottomNavigationBarItem(
                icon: const Icon(Icons.check_box), title: new Text("Attend")),
            new BottomNavigationBarItem(
                icon: const Icon(Icons.collections_bookmark),
                title: new Text("Courses")),
            new BottomNavigationBarItem(
                icon: const Icon(Icons.list), title: new Text("Record")),
          ],
          onTap: (int position) {
            _tabController.animateTo(position);
          },
          type: BottomNavigationBarType.fixed,
          currentIndex: _currrentIndex,
        ),
        body: new Builder(builder: (BuildContext context) {
          _scaffoldContext = context;
          return new TabBarView(
            controller: _tabController,
            children: <Widget>[
              new AttendClass(
                scaffoldContext: _scaffoldContext,
              ),
              new CoursesList(),
              new AttendanceRecord(),
            ],
          );
        }));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
