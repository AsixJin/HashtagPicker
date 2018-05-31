import 'dart:async';
import 'dart:io';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

final generatorKey = new GlobalKey<ScaffoldState>();

final listKey = new GlobalKey<ScaffoldState>();

//region  Hashtag Methods
List<String> hashtags = new List<String>();

bool addHashtag(TextEditingController controller) {
  String toastMsg = "";
  String tag = controller.text.toLowerCase();
  controller.text = "";
  bool isSuccess = false;

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
    isSuccess = true;
  }

  generatorKey.currentState.showSnackBar(new SnackBar(
    content: new Text(toastMsg),
  ));
  return isSuccess;
}

void deleteHashtag(String tag) {
  hashtags.remove(tag);
  listKey.currentState.showSnackBar(new SnackBar(
    content: new Text("#" + tag + " removed!"),
  ));
}
//endregion

//region Saving/Loading
class ListStorage {
  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return new File('$path/hashtags.txt');
  }

  Future<File> writeList(List<String> list) async {
    final file = await _localFile;

    String feed = json.encode(list);

    // Write the file
    return file.writeAsString(feed);
  }

  Future<List> readList() async {
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();
      List<String> list = json.decode(contents);

      return list;
    } catch (e) {
      // If we encounter an error, return 0
      return new List();
    }
  }
}
//endregion

//region Random Methods
final _random = new Random();

int next(int min, int max) => min + _random.nextInt(max - min);
//endregion

//region Hash Generator
class HashGenerator extends StatefulWidget {
  final ListStorage storage;

  HashGenerator({Key key, @required this.storage}) : super(key: key);

  @override
  _HashGeneratorState createState() => new _HashGeneratorState();
}

class _HashGeneratorState extends State<HashGenerator> {
  double buttonPadding = 6.0;
  Text hashtagText = new Text("");
  TextEditingController controller = new TextEditingController();
  TextEditingController controller2 = new TextEditingController();

  @override
  void initState() {
    super.initState();
    widget.storage.readList().then((List value) {
        hashtags = value;
    });
  }

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
                  "Add", buttonPadding, true, (){if(addHashtag(controller)){
                return widget.storage.writeList(hashtags);
              }}),
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
        .push(new MaterialPageRoute(builder: (context) => new HashList(storage: new ListStorage())));
  }
}
//endregion

//region Hash List
class HashList extends StatefulWidget {
  final ListStorage storage;

  HashList({Key key, @required this.storage}) : super(key: key);

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
            setState((){deleteHashtag(tag);});
            return widget.storage.writeList(hashtags);
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
      home: new HashGenerator(storage: new ListStorage()),
    );
  }
}
