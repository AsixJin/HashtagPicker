import 'package:flutter/material.dart';
import 'dart:math';

final _random = new Random();

int next(int min, int max) => min + _random.nextInt(max - min);

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

// Stateful Widget

class HashGenerator extends StatefulWidget {
  @override
  _HashGeneratorState createState() => new _HashGeneratorState();
}

class HashList extends StatefulWidget {
  @override
  _HashListState createState() => new _HashListState();
}

// States

class _HashGeneratorState extends State<HashGenerator> {
  List<String> hashtags = new List<String>();
  double buttonPadding = 6.0;
  Text hashtagText = new Text("");
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Hashtag Generator"),
      ),
      body: new Column(
        children: <Widget>[
          new TextField(
            controller: controller,
          ),
          new Align(
            child: new Row(children: <Widget>[
              buildButton("Add", buttonPadding, true, addHashtag),
              buildButton("List", buttonPadding, true, _pushSaved)
            ]),
            alignment: Alignment.centerRight,
          ),
          buildButton("Generate", 0.0, false, generateHashtags),
          hashtagText
        ],
      ),
    );
  }

  Widget buildButton(
      String buttonText, double padding, bool expand, onPressed()) {
    if (expand) {
      return new Expanded(
          child: new Padding(
              padding: new EdgeInsets.all(padding),
              child: new RaisedButton(
                  onPressed: onPressed, child: new Text(buttonText))));
    } else {
      return new Padding(
          padding: new EdgeInsets.all(padding),
          child: new RaisedButton(
              onPressed: onPressed, child: new Text(buttonText)));
    }
  }

  void addHashtag() {
    hashtags.add(controller.text);
    controller.text = "";
  }

  void deleteHashtag(String tag) {
    hashtags.remove(tag);
  }

  void generateHashtags() {
    setState(() {
      String generatedHashtags = "";
      if (hashtags.length > 0) {
        for (int i = 0; i < 3; i++) {
          generatedHashtags +=
              "#" + hashtags[next(0, hashtags.length - 1)] + " ";
        }
      } else {
        generatedHashtags = "No hashtags to generate!!!";
      }
      hashtagText = new Text(generatedHashtags);
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) {
      var tiles = hashtags.map(
        (tag) {
          return new ListTile(
            title: new Text(
              tag,
            ),
            onTap: () {
              deleteHashtag(tag);
              _pushSaved();
            },
          );
        },
      );

      if(tiles.isEmpty){
        
      }

      final divided = ListTile
          .divideTiles(
            context: context,
            tiles: tiles,
          )
          .toList();

      return new Scaffold(
          appBar: new AppBar(
            title: new Text("Saved Hashtags"),
          ),
          body: new ListView(children: divided));
    }));
  }
}

class _HashListState extends State<HashList> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Placeholder(),
    );
  }
}
