import 'dart:async';
import 'dart:io';
import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'dart:math';

//Globalkeys that allow me to use the snackbar (aka toast)
final generatorKey = new GlobalKey<ScaffoldState>();
final listKey = new GlobalKey<ScaffoldState>();

//region  Hashtag Methods
List<String> hashtags = new List<String>(); //the list of hashtags

//A method used to add hashtags to the list and returns a bool
//letting the user know if it was added successfully
bool addHashtag(TextEditingController controller) {
  String toastMsg = ""; //Toast message string
  String tag = controller.text.toLowerCase(); //tag to be added which is gotten from the given controller
  controller.text = ""; //clear the given controller's text
  bool isSuccess = false; //bool determining if adding hashtag was successful

  //remove the '#' from string...User doesn't need to add that
  if (tag.contains("#")) {
    tag = tag.replaceAll("#", "");
  }

  //remove the spaces
  if(tag.contains(" ")){
    tag = tag.replaceAll(" ", "");
  }

  //Check to see if the hashtag is already in the list to avoid duplicates
  if (hashtags.contains(tag)) {
    toastMsg = "Hashtag already exists..."; //if so let the user know
  } else if (tag.isEmpty) { //Now check if the given hashtag is empty
    toastMsg = "Please enter a hashtag..."; //if so let the user know
  } else {
    //otherwise let the user know the hashtag has added
    toastMsg = "#" + tag + " added!";
    hashtags.add(tag); //add the hashtag
    isSuccess = true; //set the success bool to true
  }

  //Display the toast/snackbar
  generatorKey.currentState.showSnackBar(new SnackBar(
    content: new Text(toastMsg),
  ));

  //return whether the operation was successfully
  return isSuccess;
}

//A method used to remove a hashtag from the list
void deleteHashtag(String tag) {
  //remove the hashtag
  hashtags.remove(tag);
  //let the user know it was removed via toast/snackbar
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
final _random = new Random(); //variable to help get random numbers

//random number method
int next(int min, int max) => min + _random.nextInt(max - min);
//endregion

//region Hash Generator
class HashGenerator extends StatefulWidget {
  final ListStorage storage; //the class that handles saving and loading

  HashGenerator({Key key, @required this.storage}) : super(key: key);

  @override
  _HashGeneratorState createState() => new _HashGeneratorState();
}

class _HashGeneratorState extends State<HashGenerator> {
  double buttonPadding = 6.0; //padding around all the buttons
  Text hashtagText = new Text(""); //the textview of the generated hashtags
  TextEditingController controller = new TextEditingController(); //Text controller for the hashtag text field
  TextEditingController controller2 = new TextEditingController(); //Text controller for the number of hashtag text field

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

  //A helper method that builds a button the way I need them
  Widget buildButton(String buttonText, double padding, bool expand, onPressed()) {
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

  //A method to generate a hashtag string for the user
  void generateHashtags(String numOfHash) {
    setState(() {
      String toastMsg = ""; //The toast message to be displayed
      String generatedHashtags = ""; //The generated hashtag string
      //Get the number from user input
      int num = int.parse(numOfHash, onError: (string)=>1);
      //Check to see if the number is in between 1 and 100
      if(num > 100){
        num = 100;
      }else if(num < 1){
        num = 1;
      }
      //Check to see if we have hashtags to generate
      if (hashtags.length > 0) {
        //if so than we generate the number of hashtags asked for
        for (int i = 0; i < num; i++) {
          generatedHashtags +=
              "#" + hashtags[next(0, hashtags.length)] + " ";
        }
        //then set it to the user's clipboard
        Clipboard.setData(new ClipboardData(text: generatedHashtags));
        //and display the generated hashtags to the user
        hashtagText = new Text(generatedHashtags);
        //Then let the user know whats happened via toast
        toastMsg = "Hashtags have been generated and copied to clipboard";
      } else {
        //if not than tell the use via toast
        toastMsg = "No hashtags to generate!!!";
      }

      //Display the toast which will have the results of the generation
      generatorKey.currentState.showSnackBar(new SnackBar(
        content: new Text(toastMsg),
      ));
    });
  }

  //A method to navigate to the hashtag list
  void _pushSaved() {
    //This navigates to the hashtag list so the user can view and delete them
    Navigator
        .of(context)
        .push(new MaterialPageRoute(builder: (context) => new HashList(storage: new ListStorage())));
  }
}
//endregion

//region Hash List
class HashList extends StatefulWidget {
  final ListStorage storage; //the class that handles saving and loading

  HashList({Key key, @required this.storage}) : super(key: key);

  @override
  _HashListState createState() => new _HashListState();
}

class _HashListState extends State<HashList> {
  @override
  Widget build(BuildContext context) {
    //Generate a listTile for every hashtag in the list
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

    //if there aren't any hashtags create a special listTile to let the user know
    if (tiles.isEmpty) {
      tiles.add(new ListTile(
        title: new Text("No hashtags have been saved..."),
      ));
    }

    //prepare listTiles to be displayed
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
