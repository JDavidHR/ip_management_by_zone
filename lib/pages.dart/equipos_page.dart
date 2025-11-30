import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class EquiposPage extends StatefulWidget {
  const EquiposPage({super.key});

  @override
  State<EquiposPage> createState() => _EquiposPageState();
}

class _EquiposPageState extends State<EquiposPage> {
  Map<String, List<dynamic>> equipos = {
    'Equipos L3': [],
    'Equipos L2': [],
    'Conversores': []
  };

  @override
  void initState() {
    super.initState();
    _loadEquipos();
  }

  Future<void> _loadEquipos() async {
    final String jsonString =
        await rootBundle.loadString('lib/json_files/equipos.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      equipos['Equipos L3'] = jsonData['Equipos L3'] ?? [];
      equipos['Equipos L2'] = jsonData['Equipos L2'] ?? [];
      equipos['Conversores'] = jsonData['Conversores'] ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return equipos.values.every((list) => list.isEmpty)
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: equipos.entries.map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        final equipo = entry.value[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  equipo['VENDOR'] ?? 'Desconocido',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    'Referencia: ${equipo['REFERENCIA'] ?? ''}'),
                                Text('Capacidad: ${equipo['CAPACIDAD'] ?? ''}'),
                                Text('Estado: ${equipo['ESTADO'] ?? ''}'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }).toList(),
            ),
          );
  }
}
