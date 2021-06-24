// @dart=2.9
class PlaceModel {
  int id;
  String title;
  String body;
  String location;
  String images;
  DateTime creationdate;

  PlaceModel(
      {this.id,
      this.title,
      this.body,
      this.location,
      this.images,
      this.creationdate});

  Map<String, dynamic> toMap() {
    return ({
      "id": id,
      "title": title,
      "body": body,
      "location": location,
      "images": images.toString(),
      "creation_date": creationdate.toString().substring(0, 10)
    });
  }
}
