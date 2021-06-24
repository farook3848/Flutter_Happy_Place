// @dart=2.9
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'database_pro.dart';
import 'modelclass.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:toast/toast.dart';

class Addnote extends StatefulWidget {
  const Addnote({Key key}) : super(key: key);

  @override
  _AddnoteState createState() => _AddnoteState();
}

class _AddnoteState extends State<Addnote> {
  String title;
  String body;
  String location;
  DateTime date;
  File imagefile;
  final picker = ImagePicker();
  Uint8List imageInBytes;
  String base;

  chosseImage(ImageSource source) async {
    final pickedfile = await picker.getImage(source: source, imageQuality: 25);
    setState(() {
      imagefile = File(pickedfile.path);
      List<int> imageBytes = imagefile.readAsBytesSync();
      base = base64Encode(imageBytes);
      print(imagefile);
    });
  }

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
    setState(() {
      locc.text = first.addressLine;
    });
  }

  addNote(PlaceModel note) {
    DatabaseProvider.db.addNewNote(note);
    print("Note Added");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Note"),
        backgroundColor: Colors.blue,
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
                  hintText: "Title",
                ),
                style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
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
                    hintText: "Description"),
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: locc,
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
                height: 20,
              ),
              SizedBox(
                height: 18,
              ),
              Container(
                  child: imagefile != null
                      ? Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                              image: DecorationImage(
                            image: FileImage(imagefile),
                          )),
                        )
                      : Container(
                          height: 200,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                          ),
                          child: Center(
                              child: Text(
                            "No Image",
                            style: TextStyle(fontSize: 20),
                          )),
                        )),
              SizedBox(
                height: 20,
              ),
              Container(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    ElevatedButton(
                        onPressed: () {
                          chosseImage(ImageSource.camera);
                        },
                        child: Text("Take photo")),
                    ElevatedButton(
                        onPressed: () {
                          chosseImage(ImageSource.gallery);
                        },
                        child: Text("upload from gallery")),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        onPressed: () {
          setState(() {
            title = titlec.text;
            body = bodyc.text;
            location = locc.text;
            imagefile = imagefile;
            date = DateTime.now();
          });
          if ((titlec.text == "") &&
              (bodyc.text == "") &&
              (imagefile == null)) {
            Toast.show("Enter some content", context,
                duration: Toast.LENGTH_LONG, backgroundColor: Colors.grey);
          } else {
            PlaceModel note = PlaceModel(
                title: title,
                body: body,
                location: location,
                images: base,
                creationdate: date);
            addNote(note);
            Navigator.pushNamedAndRemoveUntil(context, "/", (route) => false);
          }
        },
        label: Text("Save"),
        icon: Icon(Icons.save),
      ),
    );
  }
}
