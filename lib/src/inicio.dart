import 'package:flutter/material.dart';
import 'package:lecturas_usiap_movil/ListaLecturasScreen.dart';
import 'package:lecturas_usiap_movil/src/formlecturas.dart';
import 'package:lecturas_usiap_movil/src/registros.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class Inicio extends StatefulWidget {
  const Inicio({super.key});

  @override
  State<Inicio> createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  String _scanBarcode = 'Unknown';
  final MobileScannerController _controller = MobileScannerController();
  // Método para escanear el código de barras
  Future<void> scanBarcodeNormal() async {
    // Mostramos la vista de escaneo en una nueva pantalla para que el usuario pueda escanear
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Escanear código de barras')),
          body: MobileScanner(
            controller: _controller,
            onDetect: (BarcodeCapture barcodeCapture) {
              final String? barcodeScanRes =
                  barcodeCapture.barcodes.first.rawValue;
              if (barcodeScanRes != null && barcodeScanRes.isNotEmpty) {
                // Detenemos el lector después de detectar el código
                _controller.stop();
                // Llamamos a una función separada para manejar la lógica asíncrona
                setState(() {
                  _scanBarcode = barcodeScanRes;
                });

                // Navegamos a la nueva pantalla con el código escaneado
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Formlecturas(id: _scanBarcode),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: Drawer(
        child: Column(
          children: [
            Expanded(
              child: ListView(padding: EdgeInsets.zero, children: [
                DrawerHeader(
                  decoration: BoxDecoration(color: Colors.teal),
                  child: Column(
                    children: [
                      Text(
                        'Menú Principal',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                ListTile(
                    leading: Icon(Icons.add_circle, color: Colors.teal),
                    title: Text('Ingresar lectura'),
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => Registros()));
                    }),
                ListTile(
                    leading: Icon(Icons.add_circle, color: Colors.teal),
                    title: Text('ver datos'),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ListaLecturasScreen()));
                    }),
              ]),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 16), // Espacio entre botones
              leercodgobarras(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget leercodgobarras() {
    return GestureDetector(
      onTap: () {
        // Lógica para el botón de acceso
        scanBarcodeNormal();
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16.0),
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Center(
          child: Text(
            'Registrar',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
