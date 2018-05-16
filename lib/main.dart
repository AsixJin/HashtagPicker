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
  double buttonPadding = 6.0;
  Text hashtagText = new Text("");
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(body: new Column(children: <Widget>[
      new AppBar(),
      new TextField(controller: controller,),
      new Align(child: new Row(children: <Widget>[buildButton("Add", buttonPadding, true, addHashtag), buildButton("List", buttonPadding, true, null)]), alignment: Alignment.centerRight,),
      buildButton("Generate", 0.0, false, generateHashtags),
      hashtagText
    ],
    ),
    );
  }

  Widget buildButton(String buttonText, double padding, bool expand, onPressed()){
    if(expand){
      return new Expanded(child: new Padding(padding: new EdgeInsets.all(padding), child: new RaisedButton(onPressed: onPressed, child: new Text(buttonText))));
    }else{
      return new Padding(padding: new EdgeInsets.all(padding), child: new RaisedButton(onPressed: onPressed, child: new Text(buttonText)));
    }
  }

  void addHashtag(){
    hashtags.add(controller.text);
  }

  void generateHashtags(){
    setState((){
      String generatedHashtags = "";
      if(hashtags.length > 0){
        for (int i = 0; i < 3; i++) {
          generatedHashtags += hashtags[0];
        }
      }else{
        generatedHashtags = "No hashtags to generate!!!";
      }
      hashtagText = new Text(generatedHashtags);
    });
  }

}


