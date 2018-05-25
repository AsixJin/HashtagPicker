import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

final key = new GlobalKey<ScaffoldState>();
final key2 = new GlobalKey<ScaffoldState>();

List<String> hashtags = new List<String>();

void addHashtag(TextEditingController controller) {
  String toastMsg = "";
  String tag = controller.text.toLowerCase();
  controller.text = "";

  if(tag.contains("#")){
    tag = tag.replaceAll("#", "");
  }

  if(hashtags.contains(tag)){
    toastMsg = "Hashtag already exists...";
  }else if(tag.isEmpty){
    toastMsg = "Please enter a hashtag...";
  }else{
    toastMsg = "#" + tag + " added!";
    hashtags.add(tag);
  }

  key.currentState.showSnackBar(new SnackBar(content: new Text(toastMsg),));

}

void deleteHashtag(String tag) {
  hashtags.remove(tag);
  key2.currentState.showSnackBar(new SnackBar(content: new Text("#" + tag + " removed!"),));
}

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
  double buttonPadding = 6.0;
  Text hashtagText = new Text("");
  TextEditingController controller = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: key,
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
              buildButton("Add", buttonPadding, true, () => addHashtag(controller)
              ),
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

  void generateHashtags() {
    setState(() {
      String toastMsg = "";
      String generatedHashtags = "";
      if (hashtags.length > 0) {
        for (int i = 0; i < 3; i++) {
          generatedHashtags +=
              "#" + hashtags[next(0, hashtags.length - 1)] + " ";
        }
        Clipboard.setData(new ClipboardData(text: generatedHashtags));
        hashtagText = new Text(generatedHashtags);
        toastMsg = "Hashtags have been generated and copied to clipboard";
      } else {
        toastMsg = "No hashtags to generate!!!";
      }

      key.currentState.showSnackBar(new SnackBar(content: new Text(toastMsg),));
    });
  }

  void _pushSaved() {
    Navigator.of(context).push(new MaterialPageRoute(builder: (context) => new HashList()));
  }
}

class _HashListState extends State<HashList> {
  @override
  Widget build(BuildContext context) {
    List<ListTile> tiles = hashtags.map(
          (tag) {
        return new ListTile(
          title: new Text(
            "#"+tag,
          ),
          onTap: () {
            setState(() => deleteHashtag(tag));
          },
        );
      },
    ).toList();

    if(tiles.isEmpty){
      tiles.add(new ListTile(title: new Text("No hashtags have been saved..."),));
    }

    final divided = ListTile.divideTiles(
      context: context,
      tiles: tiles,
      color: Colors.black,
    ).toList();

    return new Scaffold(
      key: key2,
        appBar: new AppBar(
          title: new Text("Saved Hashtags"),
        ),
        body: new Column(children: <Widget>[new Text("Tap to delete a hashtag", style: new TextStyle(fontSize: 20.0),), new Expanded(child: new ListView(children: divided)),]));
  }
}
