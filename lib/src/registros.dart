import 'package:flutter/material.dart';
import 'package:lecturas_usiap_movil/database/databaseshelper.dart';
import 'package:lecturas_usiap_movil/src/sqlite_a_firebase/syncLocalToFirebase.dart';

class Registros extends StatefulWidget {
  const Registros({super.key});

  @override
  State<Registros> createState() => _RegistrosState();
}

class _RegistrosState extends State<Registros> {
  final TextEditingController id = TextEditingController();
  final TextEditingController lecant = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('registros'),
      ),
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
          controller: id,
          // readOnly: true,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            labelText: 'ID',
          ),
        ),
        const Divider(),
        TextFormField(
          controller: lecant,

          /// readOnly: true,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              labelText: 'Lecrura anterior'),
        ),
        const Divider(),
        ElevatedButton(
            onPressed: () {
              registrarProducto();

              syncLocalToFirebase();
            },
            child: const Text('Guardar'))
      ],
    );
  }

  void registrarProducto() async {
    String numeroDeContrato = id.text;
    String lecturaAnterior = lecant.text;

    if (numeroDeContrato.isNotEmpty && lecturaAnterior.isNotEmpty) {
      // Crear el mapa del producto
      final lecturas = {
        'num_c': numeroDeContrato,
        'lecrura_a': lecturaAnterior,
      };

      // Guarda el lecturas en SQLite
      await DatabaseHelper().insertProducto(lecturas);

      // Limpia los campos después de registrar
      id.clear();
      lecant.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Producto registrado exitosamente')),
      );
      //Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, completa todos los campos')),
      );
    }
  }
}
