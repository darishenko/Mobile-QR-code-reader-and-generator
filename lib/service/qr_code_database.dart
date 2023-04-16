// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:path/path.dart';
import 'package:qr_reader_and_generator/model/qr_code.dart';
import 'package:sqflite/sqflite.dart';

class QrCodeDatabase {
  final String databaseName = 'qrCode';
  static QrCodeDatabase instance = QrCodeDatabase._init();
  static Database? _database;

  QrCodeDatabase._init();

  Future<Database> get database async {
    _database ??= await _initDB('$databaseName.db');
    return _database!;
  }

  Future _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const boolType = 'BOOLEAN NOT NULL';
    const textType = 'TEXT NOT NULL';

    await db.execute('''
    CREATE TABLE $databaseName(
    ${QRCodeField.id} $idType,
    ${QRCodeField.prioritise} $boolType,
    ${QRCodeField.content} $textType,
    ${QRCodeField.createdTime} $textType
    );
    ''');
  }

  Future<QRCode> addQrCode(QRCode qrCode) async {
    final db = await instance.database;
    final id = await db.insert(databaseName, qrCode.toJson());
    return qrCode.copy(id: id);
  }

  Future<QRCode> readQrCode(int id) async {
    final db = await instance.database;

    final result = await db.query(databaseName,
        columns: QRCodeField.values,
        where: '${QRCodeField.id} = ?',
        whereArgs: [id]);

    if (result.isNotEmpty) {
      return QRCode.fromJson(result.first);
    } else {
      throw Exception('ID $id  is not found');
    }
  }

  Future<List<QRCode>> readAllQrCodes() async {
    final db = await instance.database;
    const orderBy =
        '${QRCodeField.prioritise} ASC, ${QRCodeField.createdTime} DESC';
    final result = await db.query(databaseName, orderBy: orderBy);
    List<QRCode> qrCodeList =
        result.isNotEmpty ? result.map((e) => QRCode.fromJson(e)).toList() : [];
    return qrCodeList;
  }

  Future<int> updateQrCode(QRCode qrCode) async {
    final db = await instance.database;
    return db.update(
      databaseName,
      qrCode.toJson(),
      where: '${QRCodeField.id} = ?',
      whereArgs: [qrCode.id],
    );
  }

  Future<int> deleteQrCode(int id) async {
    final db = await instance.database;

    return db
        .delete(databaseName, where: '${QRCodeField.id} = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
    _database = null;
  }
}
