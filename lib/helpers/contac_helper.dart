import 'package:contact_list/mode/contact.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

final String contactTable = "contactTable";
final String idColumn = "idColumn";
final String nameColumn = "nameColumn";
final String emailColumn = "emailColumn";
final String phoneColumn = "phoneColumn";
final String imgColumn = "imgColumn";

class ContactHelper {
  static final ContactHelper _instance = ContactHelper.internal();

  factory ContactHelper() => _instance;

  ContactHelper.internal();

  Database _database;

  Future<Database> get database async =>
      _database != null ? _database : await init();

  Future<Database> init() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, "Contact.db");
    return await openDatabase(path, version: 1,
        onCreate: (Database db, int newerVersion) async {
      await db.execute(
          "CREATE TABLE $contactTable($idColumn INTEGER PRIMARY KEY, $nameColumn TEXT, $emailColumn TEXT, $phoneColumn TEXT, $imgColumn TEXT)");
    });
  }

  Future<Contact> saveContact(Contact contact) async {
    Database contactDatabase = await database;
    contact.id = await contactDatabase.insert(contactTable, contact.toMap());
    return contact;
  }

  Future<Contact> getContact(int id) async {
    Database contactDatabase = await database;
    List<Map> maps = await contactDatabase.query(contactTable,
        columns: [idColumn, nameColumn, emailColumn, phoneColumn, imgColumn],
        where: "$idColumn = ?",
        whereArgs: [id]);

    return maps.length > 0 ? Contact.fromMap(maps.first) : null;
  }

  Future<int> deleteContact(int id) async {
    Database databaseContact = await database;
    return await databaseContact
        .delete(contactTable, where: "$idColumn = ?", whereArgs: [id]);
  }

  Future<Contact> updateContact(Contact contact) async {
    Database databaseContact = await database;
    contact.id = await databaseContact.update(contactTable, contact.toMap(),
        where: "$idColumn = ?", whereArgs: [contact.id]);
    return contact;
  }

  Future<List<Contact>> getAllContacts() async {
    Database databaseContact = await database;
    List maps = await databaseContact.rawQuery("SELECT * FROM $contactTable");

    List<Contact> listContact = List();
    maps.forEach((map) {
      listContact.add(Contact.fromMap(map));
    });

    return listContact;
  }

  Future<int> getCountContact() async {
    Database databaseContact = await database;
    return Sqflite.firstIntValue(
        await databaseContact.rawQuery("SELECT COUNT(*) FROM $contactTable"));
  }

  Future<Null> close() async {
    Database databaseContact = await database;
    return await databaseContact.close();
  }
}
