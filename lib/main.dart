// @dart=2.9
import 'dart:typed_data';
import 'modelclass.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'database_pro.dart';
import 'adddnote.dart';
import 'display_notes.dart';
import 'dart:convert';
import 'package:circular_profile_avatar/circular_profile_avatar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return Sizer(builder: (context, orientation, deviceType) {
      return MaterialApp(
        initialRoute: "/",
        routes: {
          "/": (context) => HomePage(),
          "/second": (context) => ShowNote(),
        },
        debugShowCheckedModeBanner: false,
        title: "Learning",
      );
    });
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  getNotes() async {
    final notes = await DatabaseProvider.db.getNotes();
    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Happy Places")),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: FutureBuilder<dynamic>(
          future: getNotes(),
          builder: (context, placedata) {
            switch (placedata.connectionState) {
              case ConnectionState.waiting:
                {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              case ConnectionState.done:
                {
                  if (placedata.data == Null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.place,
                            size: 60,
                            color: Colors.grey,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            "No place",
                            style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(
                          top: 8, left: 4, right: 4, bottom: 8),
                      child: ListView.builder(
                          itemCount: placedata.data?.length,
                          itemBuilder: (context, index) {
                            String title = placedata.data[index]['title'];
                            String body = placedata.data[index]['body'];
                            String location = placedata.data[index]['location'];
                            String creationdate =
                                placedata.data[index]['creation_date'];
                            String base = placedata.data[index]['images'];
                            int id = placedata.data[index]['id'];
                            Uint8List bases = Base64Decoder().convert(base);

                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              shadowColor: Colors.blue,
                              elevation: 5,
                              child: ListTile(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    "/second",
                                    arguments: PlaceModel(
                                        title: title,
                                        body: body,
                                        location: location,
                                        images: base,
                                        creationdate:
                                            DateTime.parse(creationdate),
                                        id: id),
                                  );
                                },
                                leading: CircularProfileAvatar(
                                  '',
                                  child: Image.memory(bases),
                                  borderColor: Colors.blue,
                                  backgroundColor: Colors.black,
                                  borderWidth: 1,
                                  elevation: 2,
                                  radius: 27,
                                ),
                                title: Text(title),
                                subtitle: Text(body),
                                trailing: Text(creationdate),
                              ),
                            );
                          }),
                    );
                  }
                }
            }
          }),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        splashColor: Colors.pink,
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => Addnote()));
        },
        label: Text(
          "Add Place",
          style: TextStyle(fontSize: 15),
        ),
        icon: Icon(Icons.add),
      ),
    );
  }
}
