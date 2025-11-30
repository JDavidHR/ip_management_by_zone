import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:clipboard/clipboard.dart';
import 'package:mc_dashboard/core/components/mcTextfield.dart';

class PassHerramientasPage extends StatefulWidget {
  const PassHerramientasPage({super.key});

  @override
  _PassHerramientasPageState createState() => _PassHerramientasPageState();
}

class _PassHerramientasPageState extends State<PassHerramientasPage> {
  Map<String, dynamic> passwordsData = {};
  List<dynamic> filteredItems = [];
  String selectedCategory = "";
  TextEditingController newCategoryController = TextEditingController();
  TextEditingController equipoController = TextEditingController();
  TextEditingController userController = TextEditingController();
  List<TextEditingController> passwordControllers = [TextEditingController()];
  TextEditingController urlController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    filteredItems = passwordsData.entries
        .expand((entry) => entry.value)
        .map((e) => e["equipo"].toString())
        .toList();
    _loadJson();
  }

  Future<void> _loadJson() async {
    try {
      final file = File('lib/json_files/pass_herramientas.json');
      if (await file.exists()) {
        String data = await file.readAsString();
        setState(() {
          passwordsData = json.decode(data);
          filteredItems = passwordsData.keys.toList();
        });
      }
    } catch (e) {
      print("Error loading JSON: $e");
    }
  }

  Future<void> _saveJson() async {
    try {
      final file = File('lib/json_files/pass_herramientas.json');
      await file
          .writeAsString(json.encode(passwordsData, toEncodable: (e) => e));
    } catch (e) {
      print("Error saving JSON: $e");
    }
  }

  void _addPasswordField() {
    setState(() {
      passwordControllers.add(TextEditingController());
    });
  }

  void _removePasswordField(int index) {
    setState(() {
      if (passwordControllers.length > 1) {
        passwordControllers.removeAt(index);
      }
    });
  }

  void _addEntry() {
    showDialog(
      barrierColor: Colors.blue.withOpacity(0.5),
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value:
                          selectedCategory.isNotEmpty ? selectedCategory : null,
                      items: [
                        ...passwordsData.keys
                            .map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                )),
                        const DropdownMenuItem(
                          value: "Nueva Categoría",
                          child: Text("Nueva Categoría"),
                        ),
                      ],
                      onChanged: (value) {
                        setDialogState(() {
                          selectedCategory = value!;
                        });
                      },
                      decoration: const InputDecoration(labelText: "Categoría"),
                    ),
                    const SizedBox(height: 8),
                    if (selectedCategory == "Nueva Categoría")
                      McTextField(
                        controller: newCategoryController,
                        labelText: "Nombre de nueva categoría",
                      ),
                    const SizedBox(height: 8),
                    McTextField(
                      controller: equipoController,
                      labelText: "Equipo",
                    ),
                    const SizedBox(height: 8),
                    McTextField(
                      controller: userController,
                      labelText: "Usuario",
                    ),
                    Column(
                      children:
                          List.generate(passwordControllers.length, (index) {
                        return Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
                                child: McTextField(
                                  controller: passwordControllers[index],
                                  labelText: "Contraseña ${index + 1}",
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setDialogState(() {
                                  _addPasswordField();
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () {
                                setDialogState(() {
                                  _removePasswordField(index);
                                });
                              },
                            ),
                          ],
                        );
                      }),
                    ),
                    McTextField(
                      controller: urlController,
                      labelText: "URL",
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    String category = selectedCategory == "Nueva Categoría"
                        ? newCategoryController.text
                        : selectedCategory;
                    if (category.isEmpty || equipoController.text.isEmpty)
                      return;

                    if (!passwordsData.containsKey(category)) {
                      passwordsData[category] = [];
                    }

                    passwordsData[category].add({
                      "equipo": equipoController.text,
                      "user": userController.text,
                      ...Map.fromIterable(
                        passwordControllers.where((p) => p.text.isNotEmpty),
                        key: (p) =>
                            "password${passwordControllers.indexOf(p) + 1}",
                        value: (p) => p.text,
                      ),
                      "url": urlController.text,
                    });

                    _saveJson();
                    Navigator.pop(context);
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

  void _copyToClipboard(String text) {
    FlutterClipboard.copy(text).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Copiado al portapapeles")),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: filteredItems.length,
        itemBuilder: (context, index) {
          String category = filteredItems[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            elevation: 4,
            child: ExpansionTile(
              title: Text(category),
              children: passwordsData[category].map<Widget>((entry) {
                return Card(
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry["equipo"],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Usuario: ${entry["user"]}"),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(entry["user"]),
                            ),
                          ],
                        ),
                        ...entry.keys
                            .where((key) =>
                                key.startsWith("password") &&
                                entry[key].isNotEmpty)
                            .map((key) => Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Contraseña: ${entry[key]}"),
                                    IconButton(
                                      icon: const Icon(Icons.copy),
                                      onPressed: () =>
                                          _copyToClipboard(entry[key]),
                                    ),
                                  ],
                                )),
                        if (entry["url"] != null && entry["url"].isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("URL: ${entry["url"]}"),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () => _copyToClipboard(entry["url"]),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        tooltip: "Agregar nuevo item",
        mini: true,
        onPressed: _addEntry,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}
