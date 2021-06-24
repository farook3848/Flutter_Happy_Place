// @dart=2.9
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'database_pro.dart';
import 'modelclass.dart';
import 'package:learning_flutter/modelclass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';

class ShowNote extends StatefulWidget {
  @override
  _ShowNoteState createState() => _ShowNoteState();
}

class _ShowNoteState extends State<ShowNote> {
  String title;
  String body;
  DateTime date;
  String location;
  Uint8List bases;
  String local;

  TextEditingController titlec = TextEditingController();
  TextEditingController bodyc = TextEditingController();
  TextEditingController locc = TextEditingController();

  getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low);
    getAddress(Coordinates(position.latitude, position.longitude));
  }

  getAddress(Coordinates cords) async {
    var address = await Geocoder.local.findAddressesFromCoordinates(cords);
    var first = address.first;

    locc.text = first.addressLine;
  }

  @override
  void initState() {
    setState(() {
      Future.delayed(Duration.zero, () {
        setState(() {
          final PlaceModel note =
              ModalRoute.of(context).settings.arguments as PlaceModel;
          titlec = TextEditingController(text: note.title);
          bodyc = TextEditingController(text: note.body);
          locc = TextEditingController(text: note.location);
          bases = Base64Decoder().convert(note.images);
        });
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final PlaceModel note =
        ModalRoute.of(context).settings.arguments as PlaceModel;

    return Scaffold(
      appBar: AppBar(
        title: Text("Your Place"),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
              onPressed: () {
                DatabaseProvider.db.deleteNote(note.id);
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              },
              icon: Icon(Icons.delete)),
          IconButton(
              onPressed: () {
                setState(() {
                  title = titlec.text;
                  body = bodyc.text;
                  location = locc.text;
                  date = DateTime.now();
                });

                DatabaseProvider.db.updateNote(
                    note.id, title, body, location, note.images, date);
                Navigator.pushNamedAndRemoveUntil(
                    context, "/", (route) => false);
              },
              icon: Icon(Icons.edit)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              TextField(
                controller: titlec,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 200,
                width: 200,
                child: note.images == null
                    ? new Text("no image")
                    : Image.memory(
                        bases,
                        fit: BoxFit.cover,
                      ),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                  controller: bodyc,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue, width: 1.0),
                    ),
                  )),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: locc,
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blue, width: 1.0),
                  ),
                  hintText: "Location",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: Text("Get Current Location")),
              SizedBox(
                height: 10,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
