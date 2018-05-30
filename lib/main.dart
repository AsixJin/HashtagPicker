import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

final generatorKey = new GlobalKey<ScaffoldState>();

final listKey = new GlobalKey<ScaffoldState>();

//region  Hashtag Methods
List<String> hashtags = new List<String>();

void addHashtag(TextEditingController controller) {
  String toastMsg = "";
  String tag = controller.text.toLowerCase();
  controller.text = "";

  if (tag.contains("#")) {
    tag = tag.replaceAll("#", "");
  }

  if(tag.contains(" ")){
    tag = tag.replaceAll(" ", "");
  }

  if (hashtags.contains(tag)) {
    toastMsg = "Hashtag already exists...";
  } else if (tag.isEmpty) {
    toastMsg = "Please enter a hashtag...";
  } else {
    toastMsg = "#" + tag + " added!";
    hashtags.add(tag);
  }

  generatorKey.currentState.showSnackBar(new SnackBar(
    content: new Text(toastMsg),
  ));
}

void deleteHashtag(String tag) {
  hashtags.remove(tag);
  listKey.currentState.showSnackBar(new SnackBar(
    content: new Text("#" + tag + " removed!"),
  ));
}
//endregion

//region Random Methods
final _random = new Random();

int next(int min, int max) => min + _random.nextInt(max - min);
//endregion

//region Hash Generator
class HashGenerator extends StatefulWidget {
  @override
  _HashGeneratorState createState() => new _HashGeneratorState();
}

class _HashGeneratorState extends State<HashGenerator> {
  double buttonPadding = 6.0;
  Text hashtagText = new Text("");
  TextEditingController controller = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: generatorKey,
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
              buildButton(
                  "Add", buttonPadding, true, () => addHashtag(controller)),
              buildButton("List", buttonPadding, true, _pushSaved)
            ]),
            alignment: Alignment.centerRight,
          ),
          new Align(
            child: new Row(
              children: <Widget>[
                new Flexible(
                    child: new TextField(
                  controller: controller2,
                )),
                buildButton("Generate", 0.0, false, () {
                  generateHashtags(controller2.text);
                }),
              ],
            ),
          ),
          new Padding(
            padding: new EdgeInsets.all(12.0),
            child: hashtagText,
          )
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

  void generateHashtags(String numOfHash) {
    setState(() {
      int num = int.parse(numOfHash);
      String toastMsg = "";
      String generatedHashtags = "";
      if (hashtags.length > 0) {
        for (int i = 0; i < num; i++) {
          generatedHashtags +=
              "#" + hashtags[next(0, hashtags.length - 1)] + " ";
        }
        Clipboard.setData(new ClipboardData(text: generatedHashtags));
        hashtagText = new Text(generatedHashtags);
        toastMsg = "Hashtags have been generated and copied to clipboard";
      } else {
        toastMsg = "No hashtags to generate!!!";
      }

      generatorKey.currentState.showSnackBar(new SnackBar(
        content: new Text(toastMsg),
      ));
    });
  }

  void _pushSaved() {
    Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (context) => new HashList()));
  }
}
//endregion

//region Hash List
class HashList extends StatefulWidget {
  @override
  _HashListState createState() => new _HashListState();
}

class _HashListState extends State<HashList> {
  @override
  Widget build(BuildContext context) {
    List<ListTile> tiles = hashtags.map(
      (tag) {
        return new ListTile(
          title: new Text(
            "#" + tag,
          ),
          onTap: () {
            setState(() => deleteHashtag(tag));
          },
        );
      },
    ).toList();

    if (tiles.isEmpty) {
      tiles.add(new ListTile(
        title: new Text("No hashtags have been saved..."),
      ));
    }

    final divided = ListTile
        .divideTiles(
          context: context,
          tiles: tiles,
          color: Colors.black,
        )
        .toList();

    return new Scaffold(
        key: listKey,
        appBar: new AppBar(
          title: new Text("Saved Hashtags"),
        ),
        body: new Column(children: <Widget>[
          new Text(
            "Tap to delete a hashtag",
            style: new TextStyle(fontSize: 20.0),
          ),
          new Expanded(child: new ListView(children: divided)),
        ]));
  }
}
//endregion

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
