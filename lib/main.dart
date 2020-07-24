import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dbhelper.dart';
import 'place.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainMap(),
    );
  }
}



class MainMap extends StatefulWidget {
  @override
  _MainMapState createState() => _MainMapState();
}

class _MainMapState extends State<MainMap> {

  DbHelper helper;

  final CameraPosition position = CameraPosition(
    target: LatLng(29.0221,-96.1234),
    zoom: 12,
  );

  List<Marker> markers = [];

  @override
  void initState(){
    helper = DbHelper();

    _getCurrentLocation().then((pos){
      addMarker(pos, 'currpos', 'You are Here!');
    }).catchError((err) => print(err.toString()));

    helper.insertMockData();
    _getData();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Treasure Mapp"),),
      body: Container(
        child: GoogleMap(
          initialCameraPosition: position,
          markers: Set<Marker>.of(markers),
        ),
      ),
    );
  }


  Future _getData() async{
    await helper.openDb();
    // await helper.testDb();
    List<Place> _places = await helper.getPlaces();
    for(Place p in _places){
      addMarker(Position(latitude: p.lat,longitude: p.lon), p.id.toString(), p.name);
    }
    setState(() {
      markers = markers;
    });
  }

  Future _getCurrentLocation() async {
    bool isGeolocationAvailable = await Geolocator().isLocationServiceEnabled();

    Position _position = Position(latitude: this.position.target.latitude,longitude: this.position.target.latitude);

    if(isGeolocationAvailable){
      try{
        _position = await Geolocator().getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best
        );
      }
      catch(error){
        return _position;
      }
    }
    return _position;
  }


  void addMarker(Position pos, String markerId, String markerTitle){
    final marker = Marker(
        markerId: MarkerId(markerId),
        position: LatLng(pos.latitude, pos.longitude),
        infoWindow: InfoWindow(title: markerTitle),
        icon: (markerId=='currpos')?
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure):BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange)
    );

    markers.add(marker);
    setState(() {
      markers = markers;
    });
  }



}
