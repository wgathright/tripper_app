import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:treasuremap/place.dart';

class DbHelper {
  List<Place> places = List<Place>();

  final int version = 1;
  Database db;

  Future<Database> openDb() async{
    if(db == null){
      db = await openDatabase(join(await getDatabasesPath(),
      'mapp.db'),
      onCreate: (database, version){
        database.execute(
          'CREATE TABLE places(id INTEGER PRIMARY KEY, name TEXT, lat DOUBLE, lon DOUBLE, image TEXT)');
      }, version: version);
    }
    return db;
  }


  static final DbHelper _dbHelper = DbHelper._internal();
  DbHelper._internal();

  factory DbHelper(){
    return _dbHelper;
  }


  Future insertMockData() async{
    db = await openDb();
    await db.execute('INSERT INTO places VALUES (1,"Beautifual park", 29.0110123, -96.3441011,"")');
    await db.execute('INSERT INTO places VALUES (2, "Best Pizza", 29.0110124, -96.3441001,"")');
    await db.execute('INSERT INTO places VALUES (3, "Great Mall", 29.0110125, -96.3441004,"")');

    List places = await db.rawQuery('select *  from places');
    print(places[0].toString());
  }

  Future<List<Place>> getPlaces() async {
    final List<Map<String, dynamic>> maps = await
    db.query('places');
    this.places = List.generate(maps.length,(i){
      return Place(
        maps[i]['id'],
        maps[i]['name'],
        maps[i]['lat'],
        maps[i]['lon'],
        maps[i]['image'],
      );
    });
    return places;
  }



}