import 'package:flutter/material.dart';
import 'package:lecturas_usiap_movil/database/databaseshelper.dart';
import 'package:lecturas_usiap_movil/src/firebase_a_sqlite/syncFirebaseToLocal.dart';
import 'package:lecturas_usiap_movil/src/sqlite_a_firebase/syncLocalToFirebase.dart';

class ListaLecturasScreen extends StatefulWidget {
  const ListaLecturasScreen({super.key});

  @override
  State<ListaLecturasScreen> createState() => _ListaLecturasScreenState();
}

class _ListaLecturasScreenState extends State<ListaLecturasScreen> {
  final DatabaseHelper dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> lecturas = [];

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final db = await dbHelper.database;
    final result = await db.query('lecturas');
    setState(() {
      lecturas = result;
    });
  }

  void _editarLectura(Map<String, dynamic> lectura) {
    TextEditingController lecturaAController =
        TextEditingController(text: lectura['lecrura_a']);
    TextEditingController lecturaNController =
        TextEditingController(text: lectura['lecrura_n']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Editar Lectura'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: lecturaAController,
              decoration: InputDecoration(labelText: 'Lectura Anterior'),
            ),
            TextField(
              controller: lecturaNController,
              decoration: InputDecoration(labelText: 'Lectura Nueva'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await dbHelper.updateLectura(
                  lectura['num_c'], lecturaNController.text);
              Navigator.pop(context);
              _cargarDatos();
              syncLocalToFirebase();
            },
            child: Text('Guardar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  Future<void> _borrarLectura(String numC) async {
    final db = await dbHelper.database;
    await db.delete('lecturas', where: 'num_c = ?', whereArgs: [numC]);
    _cargarDatos();
  }

  Future<void> _borrarTodaLaBase() async {
    final db = await dbHelper.database;
    await db.delete('lecturas'); // Borra todos los registros de la tabla
    _cargarDatos();
  }

  Future<void> _descargarDeFirebase() async {
    await syncFirebaseToLocal();
    _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lista de Lecturas'),
        actions: [
          IconButton(
            icon: Icon(Icons.download), // 🔽 Icono de descarga
            onPressed:
                _descargarDeFirebase, // Llama a la función para descargar datos
          ),
          IconButton(
            icon: Icon(Icons.delete_forever),
            onPressed: () {
              _borrarTodaLaBase();
              syncLocalToFirebase();
            },
          ),
        ],
      ),
      body: lecturas.isEmpty
          ? Center(child: Text('No hay lecturas registradas'))
          : ListView.builder(
              itemCount: lecturas.length,
              itemBuilder: (context, index) {
                final lectura = lecturas[index];
                return Card(
                  child: ListTile(
                    title: Text('Número de contrato: ${lectura['num_c']}'),
                    subtitle: Text(
                        'Lectura Anterior: ${lectura['lecrura_a']}\nLectura Nueva: ${lectura['lecrura_n']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editarLectura(lectura),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _borrarLectura(lectura['num_c']);
                            syncLocalToFirebase();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
