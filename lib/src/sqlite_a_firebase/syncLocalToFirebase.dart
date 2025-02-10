import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lecturas_usiap_movil/database/databaseshelper.dart';

Future<void> syncLocalToFirebase() async {
  final db = await DatabaseHelper().database;
  final List<Map<String, dynamic>> localData = await db.query('lecturas');

  // Obtener IDs de los datos en SQLite
  Set<String> localIds =
      localData.map((lectura) => lectura['num_c'].toString()).toSet();

  // 1️⃣ Obtener todos los documentos en Firebase
  final firebaseCollection = FirebaseFirestore.instance.collection('lecturas');
  final firebaseDocs = await firebaseCollection.get();

  // 2️⃣ Comparar y eliminar los que no están en SQLite
  for (var doc in firebaseDocs.docs) {
    if (!localIds.contains(doc.id)) {
      await firebaseCollection.doc(doc.id).delete(); // Borra de Firebase
    }
  }

  // 3️⃣ Subir los datos locales a Firebase
  for (var lectura in localData) {
    final docRef = firebaseCollection.doc(lectura['num_c'].toString());

    // Verifica si el documento ya existe
    final docSnapshot = await docRef.get();

    if (docSnapshot.exists) {
      // Si el documento existe, actualiza los datos
      await docRef.update({
        'lecrura_n':
            lectura['lecrura_n'], // Actualiza solo el campo 'lecrura_a'
        // Agrega más campos si es necesario
      });
    } else {
      // Si el documento no existe, crea uno nuevo
      await docRef.set({
        'lecrura_a': lectura['lecrura_a'], // Establece el campo 'lecrura_a'
        // Agrega más campos si es necesario
      });
    }
  }
}
