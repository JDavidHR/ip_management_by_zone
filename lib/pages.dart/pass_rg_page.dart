import 'dart:convert';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class PassRGPage extends StatefulWidget {
  const PassRGPage({super.key});

  @override
  State<PassRGPage> createState() => _PassRGPageState();
}

class _PassRGPageState extends State<PassRGPage> {
  List<Map<String, String>> passRG = [];
  List<Map<String, String>> filteredPassRG = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPassRG();
    searchController.addListener(_filterPassRG);
  }

  @override
  void dispose() {
    searchController.removeListener(_filterPassRG);
    searchController.dispose();
    super.dispose();
  }

  Future<void> _loadPassRG() async {
    final String jsonString =
        await rootBundle.loadString('lib/json_files/pass_rg.json');
    final List<dynamic> jsonData = json.decode(jsonString);

    setState(() {
      passRG = jsonData
          .map((entry) => {
                'Region': entry.keys.first as String,
                'Contraseña': entry.values.first as String,
              })
          .toList();
      filteredPassRG = List.from(passRG);
    });
  }

  void _filterPassRG() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredPassRG = passRG
          .where((entry) => entry['Region']!.toLowerCase().contains(query))
          .toList();
    });
  }

  void _copyToClipboard(BuildContext context, String text) {
    FlutterClipboard.copy(text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Contraseña copiada")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              labelText: 'Buscar Región',
              prefixIcon: const Icon(Icons.search),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ),
        Expanded(
          child: filteredPassRG.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                  itemCount: filteredPassRG.length,
                  itemBuilder: (context, index) {
                    final region = filteredPassRG[index]['Region']!;
                    final codigo = filteredPassRG[index]['Contraseña']!;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 3,
                      child: ListTile(
                        title: Text(region,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        subtitle: Text('Contraseña: $codigo'),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy),
                          onPressed: () => _copyToClipboard(context, codigo),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
