import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance/preferences/student-preferences.dart';
import 'package:location/location.dart';
import 'package:flutter/services.dart';
import 'package:barcodescanner/barcodescanner.dart';
import 'package:attendance/config.dart';
import 'package:attendance/common-functions.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:http/http.dart' as http;

class AttendClass extends StatefulWidget {
  var scaffoldContext;
  AttendClass({this.scaffoldContext});

  @override
  _AttendClassState createState() => new _AttendClassState();
}

class _AttendClassState extends State<AttendClass> {
  var email = "";
  var enrollment = "";
  var id = 0;

  var data;

  Map<String, double> _currentLocation;
  StreamSubscription<Map<String, double>> _locationSubscription;
  Location _location = new Location();

  TextEditingController _textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    getStudentData();

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

  _btnAttendClick() async {
    if (_textController.text.isEmpty || _textController.text.length < 6) {
      showSnackBar("Please enter correct session code");
      return;
    }

    print(_currentLocation['latitude'].toString() +
        " " +
        _currentLocation['longitude'].toString());

    CommonFunctions.showProgressDialog(widget.scaffoldContext);

    var response =
        await http.post(Uri.encodeFull(Config.attendClassUrl), headers: {
      "Accept": "application/json"
    }, body: {
      'student_id': this.id.toString(),
      'session_code': _textController.text.trim(),
      'latitude': _currentLocation['latitude'].toString(),
      'longitude': _currentLocation['longitude'].toString()
    });

    CommonFunctions.dismissDialog(widget.scaffoldContext);

    print(response.body);

    setState(() {
      data = JSON.decode(response.body);
    });

    showSnackBar(data['message']);
  }

  getStudentData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    email = prefs.getString(StudentPreferences.KEY_STUDENT_NAME);
    enrollment = prefs.getString(StudentPreferences.KEY_STUDENT_ENROLLMENT);
    id = prefs.getInt(StudentPreferences.KEY_STUDENT_ID);

    setState(() {
      this.email = email;
      this.enrollment = enrollment;
      this.id = id;
    });
  }

  _scanBarcode() async {
    Future<String> future = _startScan();
    future.then((barcode) {
      print(barcode);
    });
  }

  Future<String> _startScan() async {
    Map<String, dynamic> barcodeData;
    try {
      //barcodeData is a JSON (Map<String,dynamic>) like this:
      //{barcode: '12345', barcodeFormat: 'ean-13'}
      barcodeData = await Barcodescanner.scanBarcode;
      print(barcodeData['barcode']);
    } on PlatformException {
      barcodeData = {'barcode': 'Could not scan barcode'};
    }

    if (!mounted) return null;
    return barcodeData['barcode'];
  }

  showSnackBar(text) {
    Scaffold.of(widget.scaffoldContext).showSnackBar(
          new SnackBar(
            content: new Text(text),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    var _btnAttend = new RaisedButton(
      padding: new EdgeInsets.all(16.0),
      onPressed: () {
        _btnAttendClick();
      },
      elevation: 10.0,
      child: new Text(
        "Attend",
        style: new TextStyle(color: Colors.white),
      ),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.all(
          new Radius.circular(60.0),
        ),
      ),
      color: Colors.redAccent,
    );

    var _btnScan = new RaisedButton(
      padding: new EdgeInsets.all(16.0),
      onPressed: () {
        _scanBarcode();
      },
      elevation: 10.0,
      child: new Text(
        "Scan",
        style: new TextStyle(color: Colors.white),
      ),
      shape: new RoundedRectangleBorder(
        borderRadius: new BorderRadius.all(
          new Radius.circular(60.0),
        ),
      ),
      color: Colors.redAccent,
    );

    return new Center(
      child: new Container(
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        child: new Card(
          child: new ListView(
            shrinkWrap: true,
            padding: new EdgeInsets.only(left: 24.0, right: 24.0),
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
                decoration: new BoxDecoration(
                  boxShadow: <BoxShadow>[
                    new BoxShadow(
                      color: Colors.grey,
                      offset: new Offset(0.0, 6.0),
                      blurRadius: 20.0,
                    ),
                  ],
                  color: Colors.blueAccent,
                  borderRadius: new BorderRadius.all(
                    new Radius.circular(10.0),
                  ),
                ),
                child: new Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    new Container(
                      height: 60.0,
                      width:60.0,
                      margin: const EdgeInsets.fromLTRB(8.0,10.0,14.0,10.0),
                      child: new CircleAvatar(
                        child: new Container(
                          decoration: new BoxDecoration(
                            color: const Color(0xff7c94b6),
                            image: new DecorationImage(
                              image: new CachedNetworkImageProvider(
                                  Config.baseUrl +
                                      "/storage/student_images/"+enrollment+".jpg"),
                            ),
                            borderRadius:
                                new BorderRadius.all(new Radius.circular(80.0)),
                          ),
                        ),
                      ),
                    ),
                    new Expanded(
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            margin: const EdgeInsets.fromLTRB(
                                16.0, 16.0, 16.0, 8.0),
                            child: new Text(email,
                                style: new TextStyle(color: Colors.white)),
                          ),
                          new Container(
                            margin: const EdgeInsets.fromLTRB(
                                16.0, 8.0, 16.0, 16.0),
                            child: new Text(enrollment,
                                style: new TextStyle(color: Colors.white)),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              new SizedBox(height: 48.0),
              new TextFormField(
                keyboardType: TextInputType.number,
                controller: _textController,
                decoration:
                    new InputDecoration(labelText: "Enter Session Code"),
              ),
              new SizedBox(height: 8.0),
              new SizedBox(height: 24.0),
              _btnAttend,
              new SizedBox(height: 24.0),
              new Center(
                child: new Text(
                  "OR",
                  style: new TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              new SizedBox(height: 24.0),
              _btnScan,
              new SizedBox(height: 24.0),
            ],
          ),
        ),
      ),
    );
  }
}
