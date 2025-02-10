import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lecturas_usiap_movil/database/databaseshelper.dart';
import 'package:sqflite/sqflite.dart';

Future<void> syncFirebaseToLocal() async {
  final db = await DatabaseHelper().database;

  // Obtener los datos de Firebase
  final QuerySnapshot<Map<String, dynamic>> firebaseData =
      await FirebaseFirestore.instance.collection('lecturas').get();

  for (var doc in firebaseData.docs) {
    // Obtener los datos del documento
    final data = doc.data();

    // Agregar el ID del documento como 'num_c'
    data['num_c'] = doc.id;

    // Verifica si el documento ya existe en SQLite
    final existingLectura = await db.query(
      'lecturas',
      where: 'num_c = ?',
      whereArgs: [doc.id],
    );

    if (existingLectura.isEmpty) {
      // Si no existe, inserta el nuevo registro
      await db.insert(
        'lecturas',
        data,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      // Si existe, actualiza el registro
      await db.update(
        'lecturas',
        data,
        where: 'num_c = ?',
        whereArgs: [doc.id],
      );
    }
  }
}
