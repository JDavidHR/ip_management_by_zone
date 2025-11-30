import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PassHerramientasPage extends StatefulWidget {
  const PassHerramientasPage({super.key});

  @override
  _PassHerramientasPageState createState() => _PassHerramientasPageState();
}

class _PassHerramientasPageState extends State<PassHerramientasPage> {
  Map<String, dynamic> _data = {};
  List<Map<String, String>> _filteredItems = [];
  String _searchText = "";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    String jsonString =
        await rootBundle.loadString('lib/json_files/pass_herramientas.json');
    Map<String, dynamic> jsonData = json.decode(jsonString);
    setState(() {
      _data = jsonData;
      _filteredItems = _getAllItems();
    });
  }

  List<Map<String, String>> _getAllItems() {
    List<Map<String, String>> items = [];
    _data.forEach((category, list) {
      for (var item in list) {
        Map<String, String> formattedItem = {
          "equipo": item["equipo"] ?? "",
          "user": item["user"] ?? "",
          "category": category
        };

        if (item.containsKey("password1")) {
          for (int i = 1; i <= 8; i++) {
            formattedItem["password$i"] = item["password$i"] ?? "";
          }
        } else if (item.containsKey("password")) {
          formattedItem["password"] = item["password"] ?? "";
        }

        if (item.containsKey("url")) {
          formattedItem["url"] = item["url"] ?? "";
        }

        items.add(formattedItem);
      }
    });
    return items;
  }

  void _filterItems(String query) {
    setState(() {
      _searchText = query;
      if (query.isEmpty) {
        _filteredItems = _getAllItems();
      } else {
        _filteredItems = _getAllItems().where((item) {
          return item["equipo"]!.toLowerCase().contains(query.toLowerCase()) ||
              item["user"]!.toLowerCase().contains(query.toLowerCase()) ||
              (item["password"]?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Copiado al portapapeles")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                  labelText: "Buscar...", border: OutlineInputBorder()),
              onChanged: _filterItems,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredItems.length,
              itemBuilder: (context, index) {
                var item = _filteredItems[index];
                return Card(
                  child: ListTile(
                    title: Text(item["equipo"]!),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Usuario: ${item["user"]}"),
                            IconButton(
                              icon: const Icon(Icons.copy),
                              onPressed: () => _copyToClipboard(item["user"]!),
                            )
                          ],
                        ),
                        for (int i = 1; i <= 8; i++)
                          if (item.containsKey("password$i") &&
                              item["password$i"]!.isNotEmpty)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Password$i: ${item["password$i"]}"),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: () =>
                                      _copyToClipboard(item["password$i"]!),
                                )
                              ],
                            ),
                        if (item.containsKey("password") &&
                            item["password"]!.isNotEmpty)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Password: ${item["password"]}"),
                              IconButton(
                                icon: const Icon(Icons.copy),
                                onPressed: () =>
                                    _copyToClipboard(item["password"]!),
                              )
                            ],
                          ),
                        if (item.containsKey("url"))
                          InkWell(
                            onTap: () {},
                            child: Text(
                              "URL: ${item["url"]}",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          )
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
