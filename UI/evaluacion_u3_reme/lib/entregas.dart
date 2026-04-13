import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:typed_data';
import 'servicio_api.dart';
import 'package:url_launcher/url_launcher.dart';

class Entregas extends StatefulWidget {
  const Entregas({super.key});

  @override
  State<Entregas> createState() => _EntregasState();
}

class _EntregasState extends State<Entregas> {
  List paquetes = [];
  List entregas = [];

  @override
  void initState() {
    super.initState();
    cargar();
  }

  void cargar() async {
    paquetes = await ServicioAPI.obtenerPaquetes();
    entregas = await ServicioAPI.obtenerEntregas();
    setState(() {});
  }

  void msg(String m) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(m)));
  }

  // GPS (solo respaldo)
  Future<Position> obtenerUbicacion() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  void abrirEntrega(int idPaquete) {
    String estado = "entregado";
    String comentario = "";

    // 🔥 CONTROLADORES PARA LAT Y LNG
    TextEditingController latController = TextEditingController();
    TextEditingController lngController = TextEditingController();

    XFile? imagenLocal;
    Uint8List? imagenBytes;
    bool cargando = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text("Realizar Entrega"),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    Text("Paquete ID: $idPaquete"),

                    const SizedBox(height: 10),

                    ElevatedButton(
                      onPressed: () async {
                        final picker = ImagePicker();
                        final img = await picker.pickImage(
                          source: ImageSource.camera,
                          imageQuality: 70,
                        );

                        if (img != null) {
                          imagenLocal = img;
                          imagenBytes = await img.readAsBytes();
                          setStateDialog(() {});
                        }
                      },
                      child: const Text("Seleccionar Imagen"),
                    ),

                    const SizedBox(height: 10),

                    if (imagenBytes != null)
                      Image.memory(imagenBytes!, height: 150),

                    if (imagenLocal != null)
                      const Text("Imagen cargada ✅"),

                    const SizedBox(height: 10),

                    DropdownButton<String>(
                      value: estado,
                      items: ["entregado", "no_entregado"]
                          .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) {
                        setStateDialog(() {
                          estado = v!;
                        });
                      },
                    ),

                    const SizedBox(height: 10),

                    TextField(
                      decoration:
                          const InputDecoration(labelText: "Comentario"),
                      onChanged: (v) => comentario = v,
                    ),

                    const SizedBox(height: 10),

                    // 🔥 INPUT LATITUD
                    TextField(
                      controller: latController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Latitud (ej: 20.5888)",
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🔥 INPUT LONGITUD
                    TextField(
                      controller: lngController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Longitud (ej: -100.3899)",
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                ElevatedButton(
                  onPressed: () async {
                    if (imagenBytes == null) {
                      msg("Debes seleccionar imagen");
                      return;
                    }

                    setStateDialog(() {
                      cargando = true;
                    });

                    try {
                      double lat;
                      double lng;

                      // 🔥 USAR COORDENADAS MANUALES SI EXISTEN
                      if (latController.text.isNotEmpty &&
                          lngController.text.isNotEmpty) {
                        lat = double.tryParse(latController.text) ?? 0;
                        lng = double.tryParse(lngController.text) ?? 0;
                      } else {
                        // 🔥 SI NO, USA GPS
                        Position pos = await obtenerUbicacion();
                        lat = pos.latitude;
                        lng = pos.longitude;
                      }

                      // VALIDACIÓN
                      if (lat == 0 || lng == 0) {
                        msg("Coordenadas inválidas");
                        return;
                      }

                      bool ok = await ServicioAPI.registrarEntrega(
                        idPaquete: idPaquete,
                        lat: lat,
                        lng: lng,
                        imagenBytes: imagenBytes!,
                        nombreImagen: imagenLocal!.name,
                        estado: estado,
                        comentario: comentario,
                      );

                      Navigator.pop(context);

                      if (ok) {
                        msg("Entrega realizada ✅");
                      } else {
                        msg("Error al entregar");
                      }

                      cargar();
                    } catch (e) {
                      Navigator.pop(context);
                      msg("Error: $e");
                    }
                  },
                  child: cargando
                      ? const CircularProgressIndicator()
                      : const Text("Guardar"),
                )
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(10),
      children: [
        const Text("Entregas Pendientes"),

        ...paquetes
            .where((p) => p["estatus"] != "entregado")
            .map((p) => Card(
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(p["codigo"]),
                        subtitle: Text(p["estatus"]),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            abrirEntrega(p["id_paquete"]),
                        child: const Text("Realizar Entrega"),
                      ),
                    ],
                  ),
                )),

        const Divider(),

        const Text("ENTREGAS REALIZADAS"),

        ...entregas.map((e) {
          String url =
              "http://127.0.0.1:8000/${e["foto_url"]}";

          return Card(
            child: Column(
              children: [
                ListTile(
                  title: Text("Paquete ${e["id_paquete"]}"),
                  subtitle: Text(e["estado"]),
                ),

                Image.network(
                  url,
                  height: 200,
                  errorBuilder: (_, __, ___) =>
                      const Text("No se pudo cargar imagen"),
                ),

                // 📍 TARJETA DE UBICACIÓN
                Container(
                  margin: const EdgeInsets.all(10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "📍 Ubicación\n"
                    "Lat: ${e["latitud"]}\n"
                    "Lng: ${e["longitud"]}",
                    textAlign: TextAlign.center,
                  ),
                ),

                ElevatedButton(
                  onPressed: () async {
                    final lat = e["latitud"];
                    final lng = e["longitud"];

                    final url = Uri.parse(
                        "https://www.google.com/maps/search/?api=1&query=$lat,$lng");

                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    } else {
                      msg("No se pudo abrir el mapa");
                    }
                  },
                  child: const Text("Ver ubicación"),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }
}