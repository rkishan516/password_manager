import 'dart:async';

import 'package:fancy_bottom_navigation/fancy_bottom_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Password Manager',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Password Manager'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int currentPage = 0;

  _getPage(int page) async* {
    if (page == 0) {
      yield PairData(
        keys: '',
        password: '',
      );
    } else if (page == 1) {
      final storage = FlutterSecureStorage();
      Map<String, String> data = await storage.readAll();
      yield PairPage(creds: data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _getPage(currentPage),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return snapshot.data;
          } else {
            return Container();
          }
        },
      ),
      bottomNavigationBar: FancyBottomNavigation(
        tabs: [
          TabData(iconData: Icons.home, title: "Home"),
          TabData(iconData: Icons.search, title: "Store"),
        ],
        onTabChangedListener: (position) async {
          if (currentPage == 0) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                TextEditingController textEditingController =
                    TextEditingController();
                return Dialog(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: PinCodeTextField(
                      length: 4,
                      obsecureText: true,
                      animationType: AnimationType.fade,
                      textInputType: TextInputType.number,
                      pinTheme: PinTheme(
                        shape: PinCodeFieldShape.circle,
                        borderRadius: BorderRadius.circular(5),
                        fieldHeight: 50,
                        fieldWidth: 40,
                        activeFillColor: Colors.white,
                      ),
                      errorAnimationController:
                          StreamController<ErrorAnimationType>(),
                      animationDuration: Duration(milliseconds: 300),
                      backgroundColor: Colors.blue.shade50,
                      onChanged: (value) {
                        if (value == '0000') {
                          Navigator.of(context).pop();
                          setState(() {
                            currentPage = position;
                          });
                        }
                      },
                      controller: textEditingController,
                      beforeTextPaste: (text) {
                        return true;
                      },
                    ),
                  ),
                );
              },
            );
          } else {
            setState(() {
              currentPage = position;
            });
          }
        },
      ),
    );
  }
}

class PairPage extends StatefulWidget {
  final Map<String, String> creds;
  PairPage({this.creds});
  @override
  _PairPageState createState() => _PairPageState(creds: creds);
}

class _PairPageState extends State<PairPage> {
  final Map<String, String> creds;
  _PairPageState({this.creds});

  @override
  Widget build(BuildContext context) {
    List<String> keys = creds.keys.toList();
    return Container(
      child: (creds.length > 0)
          ? ListView.builder(
              itemCount: creds.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Domain : ' + keys[index]),
                  subtitle: Text('Password : ' + creds[keys[index]]),
                  trailing: CircleAvatar(
                    child: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          final storage = FlutterSecureStorage();
                          await storage.delete(key: keys[index]);
                          setState(() {});
                          creds.remove(keys[index]);
                        }),
                  ),
                );
              },
            )
          : Center(
              child: Text('Nothing Saved'),
            ),
    );
  }
}

class PairData extends StatefulWidget {
  final String keys;
  final String password;
  PairData({this.keys, this.password});
  @override
  _PairDataState createState() => _PairDataState();
}

class _PairDataState extends State<PairData> {
  @override
  Widget build(BuildContext context) {
    TextEditingController keyTextEditingController =
        TextEditingController.fromValue(TextEditingValue(text: widget.keys));
    TextEditingController passwordTextEditingController =
        TextEditingController.fromValue(
            TextEditingValue(text: widget.password));
    return Column(
      children: <Widget>[
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Domain',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: keyTextEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  hintText: 'e.g. Gmail',
                  filled: true,
                ),
              )
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Password',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: passwordTextEditingController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  fillColor: Color(0xfff3f3f4),
                  hintText: 'e.g. Kishan@5',
                  filled: true,
                ),
              )
            ],
          ),
        ),
        FlatButton(
            color: Colors.blue,
            onPressed: () async {
              final storage = FlutterSecureStorage();
              await storage.write(
                  key: keyTextEditingController.text,
                  value: passwordTextEditingController.text);
              setState(() {
                keyTextEditingController.text = '';
                passwordTextEditingController.text = '';
              });
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ))
      ],
    );
  }
}
