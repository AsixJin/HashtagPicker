import 'package:flutter/material.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Hashtag Picker',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.red,
      ),
      home: new HashGenerator(),
    );
  }
}

class HashGenerator extends StatefulWidget {

  @override
  _HashGeneratorState createState() => new _HashGeneratorState();
}

class _HashGeneratorState extends State<HashGenerator> {
  List<String> hashtags = new List<String>();
  static String hashtagString = "";
  Text hashtagText = new Text(hashtagString);
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {

    return new Scaffold(body: new Column(children: <Widget>[
      new AppBar(),
      new TextField(),
      new Align(child: new Row(children: <Widget>[ new Expanded(child: new RaisedButton(onPressed: null, child: new Text("Button 1"), )), new Expanded(child: new RaisedButton(onPressed: null, child: new Text("Button 2"),))]), alignment: Alignment.centerRight,),
      new RaisedButton(onPressed:(){
        hashtags.add(controller.text);
        hashtagString = hashtags.toString();
      }, child: new Text("Button 3"),),
      hashtagText
    ],
    ),
    );
  }
}


