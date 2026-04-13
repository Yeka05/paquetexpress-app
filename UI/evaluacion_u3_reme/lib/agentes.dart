import 'package:flutter/material.dart';
import 'servicio_api.dart';

class Agentes extends StatefulWidget {
  const Agentes({super.key});

  @override
  State<Agentes> createState() => _AgentesState();
}

class _AgentesState extends State<Agentes> {
  List agentes = [];

  final nombre = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final telefono = TextEditingController();
  bool activo = true;

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    agentes = await ServicioAPI.obtenerAgentes();
    setState(() {});
  }

  void agregar() async {
    await ServicioAPI.registrarAgente({
      "nombre": nombre.text,
      "email": email.text,
      "password": password.text,
      "telefono": telefono.text,
      "activo": activo,
    });

    nombre.clear();
    email.clear();
    password.clear();
    telefono.clear();
    activo = true; 

    cargar();
    Navigator.pop(context);
  }

  void abrirFormulario() {
  showDialog(
    context: context,
    builder: (_) {
      bool activoTemp = activo; // 👈 variable local

      return StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            title: const Text("Nuevo Agente"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombre,
                  decoration: const InputDecoration(labelText: "Nombre"),
                ),
                TextField(
                  controller: email,
                  decoration: const InputDecoration(labelText: "Email"),
                ),
                TextField(
                  controller: password,
                  decoration: const InputDecoration(labelText: "Password"),
                ),
                TextField(
                  controller: telefono,
                  decoration: const InputDecoration(labelText: "Teléfono"),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Activo"),
                    Switch(
                      value: activoTemp,
                      onChanged: (v) {
                        setStateDialog(() {
                          activoTemp = v; // 👈 ahora sí cambia
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  activo = activoTemp; // 👈 guardar valor final
                  agregar();
                },
                child: const Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: abrirFormulario,
        child: const Icon(Icons.add),
      ),
      body: ListView(
        children: agentes.map((a) {
          bool activo =
              a["activo"].toString() == "1" ||
              a["activo"].toString() == "true"; // ✅ CORREGIDO

          return ListTile(
            leading: Container(
              width: 12,
              height: 50,
              decoration: BoxDecoration(
                color: activo ? Colors.green : Colors.red,
                borderRadius: BorderRadius.circular(5),
              ),
            ),

            title: Text(a["id_agente"].toString()),

            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a["nombre"]),

                Text(
                  activo ? "Activo" : "Inactivo",
                  style: TextStyle(
                    color: activo ? Colors.green : Colors.red,
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