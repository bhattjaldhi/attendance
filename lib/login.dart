import 'dart:convert';

import 'package:attendance/config.dart';
import 'package:attendance/preferences/professor-preferences.dart';
import 'package:attendance/professor/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:attendance/components/appbar.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passwordController = new TextEditingController();

  var isProcessing = false;
  var message="";
  var messageType = 0;

//    Make Http request to server for login professor
//    if result code is 200 then success and
//    replace navigator to professor dashboard
//    result code is 400 then failed login attempt
  tryLogin() async {



    if(_emailController.text.trim().isEmpty &&
        _passwordController.text.trim().isEmpty){
      return;
    }

    setState(() {
      isProcessing = true;
    });

    var response = await http.post(Uri.encodeFull(Config.professorLoginUrl),
        headers: {
          "Accept": "application/json"
        },
        body: {
          "email": _emailController.text.trim(),
          "password": _passwordController.text.trim()
        });

    setState(() {
      isProcessing = false;
    });

    print(response.body);

    var data = JSON.decode(response.body);

    if (data['resultCode'] == 200) {
      setState(() {
        this.messageType = 1;
        this.message = data['message'];
      });

      new ProfessorPreferences().storeDataAtLogin(data);

      Navigator.of(context).pushReplacement(new MaterialPageRoute(
          builder: (BuildContext context) => new ProfessorDashboard()));
    } else {
      setState(() {
        this.messageType = 0;
        this.message = data['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    timeDilation = 2.0; // 1.0 means normal animation speed.


    final logo = new Hero(
      tag: 'professor-logo',
      child: new CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: new Image.asset('images/professor.jpg'),
      ),
    );

    final email = new TextFormField(
      autocorrect: true,
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      autofocus: false,
      decoration: new InputDecoration(
        hintText: 'Email',
        contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(32.0)),
      ),
    );



    final password = new TextFormField(
      controller: _passwordController,
      autofocus: false,
      obscureText: true,
      decoration: new InputDecoration(
        hintText: 'Password',
        contentPadding: new EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: new OutlineInputBorder(
            borderRadius: new BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = new Padding(
      padding: new EdgeInsets.symmetric(vertical: 16.0),
      child: new Material(
        borderRadius: new BorderRadius.circular(30.0),
        shadowColor: Colors.lightBlueAccent.shade100,
        elevation: 5.0,
        child: new MaterialButton(
          minWidth: 200.0,
          height: 42.0,
          onPressed: () {
            this.tryLogin();
          },
          color: Colors.lightBlueAccent,
          child: new Text('Log In', style: new TextStyle(color: Colors.white)),
        ),
      ),
    );

    final forgotLabel = new FlatButton(
      child: new Text(
        'Forgot password ?',
        style: new TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return new Scaffold(
      appBar: new MyAppBar().createAppbar("Professor login"),
      backgroundColor: Colors.white,
      body: new Center(
        child: new ListView(
          shrinkWrap: true,
          padding: new EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            new SizedBox(height: 48.0),
            email,
            new SizedBox(height: 8.0),
            password,
            new SizedBox(height: 24.0),
            new Center(
              child: isProcessing == true
                  ? new CircularProgressIndicator()
                  : new Text(this.message,
                      style: this.messageType == 0
                          ? new TextStyle(color: Colors.red)
                          : new TextStyle(color: Colors.green)),
            ),
            new SizedBox(height: 24.0),
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}
