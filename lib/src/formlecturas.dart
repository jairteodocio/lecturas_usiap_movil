import 'package:flutter/material.dart';
import 'package:lecturas_usiap_movil/database/databaseshelper.dart';
import 'package:lecturas_usiap_movil/src/sqlite_a_firebase/syncLocalToFirebase.dart';

class Formlecturas extends StatefulWidget {
  final String id;
  const Formlecturas({super.key, required this.id});

  @override
  State<Formlecturas> createState() => _FormlecturasState();
}

class _FormlecturasState extends State<Formlecturas> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController lecAntController = TextEditingController();
  final TextEditingController lecNuevaController = TextEditingController();

  @override
  void initState() {
    super.initState();
    idController.text = widget.id; // Asignar el ID escaneado
    buscarLecturaAnterior(); // Llamar a la función para cargar datos
  }

  @override
  void dispose() {
    idController.dispose();
    lecAntController.dispose();
    lecNuevaController.dispose();
    super.dispose();
  }

  /// ✅ FUNCIÓN PARA BUSCAR LA LECTURA ANTERIOR Y MOSTRARLA EN EL CAMPO
  void buscarLecturaAnterior() async {
    final dbHelper = DatabaseHelper();
    final lectura = await dbHelper.getLecturaById(widget.id);

    if (lectura != null) {
      setState(() {
        lecAntController.text =
            lectura['lecrura_a'] ?? ''; // Cargar lectura anterior
      });
    } else {
      setState(() {
        lecAntController.text =
            'No registrada'; // Si no existe, mostrar mensaje
      });
    }
  }

  /// ✅ FUNCIÓN PARA GUARDAR LA NUEVA LECTURA
  void guardarLectura() async {
    final nuevaLectura = lecNuevaController.text.trim();

    if (nuevaLectura.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingrese la nueva lectura')),
      );
      return;
    }

    final dbHelper = DatabaseHelper();
    await dbHelper.updateLectura(widget.id, nuevaLectura); // Guardar en SQLite

    syncLocalToFirebase(); // Sincronizar con Firebase

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lectura guardada exitosamente')),
    );

    Navigator.pop(context); // Cerrar formulario tras guardar
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Formulario de Lecturas')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: formulario(),
        ),
      ),
    );
  }

  Widget formulario() {
    return Column(
      children: [
        TextFormField(
          controller: idController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelText: 'ID',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: lecAntController,
          readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelText: 'Lectura anterior',
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: lecNuevaController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelText: 'Lectura nueva',
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: guardarLectura,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
