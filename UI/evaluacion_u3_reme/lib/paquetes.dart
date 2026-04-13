import 'package:flutter/material.dart';
import 'servicio_api.dart';

class Paquetes extends StatefulWidget {
  const Paquetes({super.key});

  @override
  State<Paquetes> createState() => _PaquetesState();
}

class _PaquetesState extends State<Paquetes> {
  List paquetes = [];

  final codigo = TextEditingController();
  final direccion = TextEditingController();
  final ciudad = TextEditingController();
  final estado = TextEditingController();
  final cp = TextEditingController();
  final destinatario = TextEditingController();
  final telefono = TextEditingController();

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    paquetes = await ServicioAPI.obtenerPaquetes();
    setState(() {});
  }

  void limpiar() {
    codigo.clear();
    direccion.clear();
    ciudad.clear();
    estado.clear();
    cp.clear();
    destinatario.clear();
    telefono.clear();
  }


  void agregar() async {
    var data = {
      "codigo": codigo.text,
      "direccion": direccion.text,
      "ciudad": ciudad.text,
      "estado": estado.text,
      "codigo_postal": cp.text,
      "destinatario": destinatario.text,
      "telefono_destinatario": telefono.text,
    };

    await ServicioAPI.registrarPaquete(data);

    Navigator.pop(context);

    limpiar();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Paquete registrado ✅"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Código: ${data["codigo"]}"),
              Text("Dirección: ${data["direccion"]}"),
              Text("Ciudad: ${data["ciudad"]}"),
              Text("Estado: ${data["estado"]}"),
              Text("CP: ${data["codigo_postal"]}"),
              Text("Destinatario: ${data["destinatario"]}"),
              Text("Teléfono: ${data["telefono_destinatario"]}"),

              const SizedBox(height: 10),

              Text(
                "Fecha de alta: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              cargar();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  void abrirFormulario() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nuevo Paquete"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: codigo,
                decoration: const InputDecoration(labelText: "Código"),
              ),
              TextField(
                controller: direccion,
                decoration: const InputDecoration(labelText: "Dirección"),
              ),
              TextField(
                controller: ciudad,
                decoration: const InputDecoration(labelText: "Ciudad"),
              ),
              TextField(
                controller: estado,
                decoration: const InputDecoration(labelText: "Estado"),
              ),
              TextField(
                controller: cp,
                decoration: const InputDecoration(labelText: "CP"),
              ),
              TextField(
                controller: destinatario,
                decoration: const InputDecoration(labelText: "Destinatario"),
              ),
              TextField(
                controller: telefono,
                decoration: const InputDecoration(labelText: "Teléfono"),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: agregar,
            child: const Text("Guardar"),
          ),
        ],
      ),
    );
  }

  // 🔥 COLOR POR ESTATUS
  Color getColorEstado(String estado) {
    switch (estado) {
      case "entregado":
        return Colors.green;
      case "en_camino":
        return const Color.fromARGB(255, 208, 255, 0);
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: paquetes.map((p) {
          // Fecha desde api
          String fecha = "Sin fecha";

          if (p["fecha_de_alta"] != null) {
            DateTime f = DateTime.parse(p["fecha_de_alta"]);
            fecha = "${f.day}/${f.month}/${f.year}";
          }

          return ListTile(
            leading: Container(
              width: 12,
              height: 50,
              decoration: BoxDecoration(
                color: getColorEstado(p["estatus"]),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            title: Text(p["codigo"]),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p["direccion"]),

                Text(
                  "Fecha: $fecha",
                  style: const TextStyle(fontSize: 12),
                ),

                Text(
                  p["estatus"].toUpperCase(),
                  style: TextStyle(
                    color: getColorEstado(p["estatus"]),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}