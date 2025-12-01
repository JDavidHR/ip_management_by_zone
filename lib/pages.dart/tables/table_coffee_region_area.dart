import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TableCoffeeRegionArea extends StatefulWidget {
  const TableCoffeeRegionArea({super.key});

  @override
  State<TableCoffeeRegionArea> createState() => _TableCoffeeRegionAreaState();
}

class _TableCoffeeRegionAreaState extends State<TableCoffeeRegionArea> {
  List<Map<String, String>> _data = [];
  List<Map<String, String>> _filteredData = [];
  List<String> _headers = [];

  bool _isLoading = true;
  bool _showOnlyAvailable = false;

  final TextEditingController _filterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExcel();
  }

  Future<void> _loadExcel() async {
    ByteData data = await rootBundle.load("assets/bd_local/tabla_zonas.xlsx");
    var bytes = data.buffer.asUint8List();
    var excel = Excel.decodeBytes(bytes);

    Sheet? sheet = excel["Hoja 1"];
    if (sheet == null) return;

    List<Map<String, String>> rows = [];

    _headers = sheet.rows.first.map((cell) {
      return (cell?.value?.toString() ?? "").trim();
    }).toList();

    for (int i = 1; i < sheet.rows.length; i++) {
      Map<String, String> row = {};

      for (int j = 0; j < _headers.length; j++) {
        var cell = sheet.rows[i][j];
        String value = cell?.value?.toString() ?? "";

        if (value.endsWith(".0")) {
          value = value.replaceAll(".0", "");
        }

        row[_headers[j]] = value;
      }

      rows.add(row);
    }

    setState(() {
      _data = rows;
      _filteredData = rows;
      _isLoading = false;
    });
  }

  void _filterTable(String query) {
    query = query.toLowerCase();
    List<Map<String, String>> baseList =
        _showOnlyAvailable ? _onlyAvailableList() : _data;

    setState(() {
      _filteredData = baseList.where((row) {
        return row.values.any((value) {
          return value.toLowerCase().contains(query);
        });
      }).toList();
    });
  }

  List<Map<String, String>> _onlyAvailableList() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    return _data.where((row) {
      return (row[clienteHeader] ?? "").trim().isEmpty;
    }).toList();
  }

  void _toggleAvailableFilter() {
    setState(() {
      _showOnlyAvailable = !_showOnlyAvailable;
      _filteredData = _showOnlyAvailable ? _onlyAvailableList() : _data;
    });

    _filterTable(_filterController.text);
  }

  void _showIpSummaryDialog() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    int total = _data.length;
    int disponibles =
        _data.where((row) => (row[clienteHeader] ?? "").trim().isEmpty).length;
    int ocupadas = total - disponibles;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Resumen de IP"),
          content: Text(
            "IP totales: $total\n"
            "IP disponibles: $disponibles\n"
            "IP ocupadas: $ocupadas",
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cerrar"))
          ],
        );
      },
    );
  }

  ButtonStyle blackButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  // ===========================================================
  //  *** DIALOGO PARA EDITAR UNA FILA ***
  // ===========================================================
  void _editRow(Map<String, String> row) {
    Map<String, TextEditingController> controllers = {};

    for (var header in _headers) {
      controllers[header] = TextEditingController(text: row[header]);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Editar registro"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                children: _headers.map((h) {
                  bool disabled = h.toLowerCase().contains("vlan") ||
                      h.toLowerCase().contains("dir. ip");

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: TextField(
                      controller: controllers[h],
                      enabled: !disabled,
                      decoration: InputDecoration(
                        labelText: h,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar"),
              onPressed: () => Navigator.pop(context),
            ),
            ElevatedButton(
              style: blackButton(),
              child: const Text("Guardar"),
              onPressed: () {
                setState(() {
                  // Guardar los cambios en la fila original
                  for (var h in _headers) {
                    if (!(h.toLowerCase().contains("vlan") ||
                        h.toLowerCase().contains("dir. ip"))) {
                      row[h] = controllers[h]!.text;
                    }
                  }
                });

                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  // ===========================================================
  //  *** UI PRINCIPAL ***
  // ===========================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 350,
              child: TextField(
                controller: _filterController,
                decoration: InputDecoration(
                  hintText: "Buscar...",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                onChanged: _filterTable,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _showIpSummaryDialog,
              style: blackButton(),
              child: const Text("Resumen IP"),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: () {
                _toggleAvailableFilter();
                _filterTable(_filterController.text);
              },
              style: blackButton(),
              child:
                  Text(_showOnlyAvailable ? "Mostrar todo" : "IP disponibles"),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
                child: DataTable(
              headingRowHeight: 48,
              dataRowHeight: 56,
              columnSpacing: 40,
              columns: [
                const DataColumn(
                  label: Text(
                    "Opciones",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                ..._headers.map(
                  (h) => DataColumn(
                    label: Text(
                      h,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                ),
              ],
              rows: _filteredData.map((row) {
                return DataRow(cells: [
                  // === PRIMERA COLUMNA: BOTÓN EDITAR ===
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: () => _editRow(row),
                    ),
                  ),

                  // === RESTO DE COLUMNAS: DATOS ===
                  ..._headers.map((h) {
                    return DataCell(
                      SizedBox(
                        width: 150,
                        child: Text(row[h] ?? ""),
                      ),
                    );
                  }).toList(),
                ]);
              }).toList(),
            )),
          ),
        )
      ],
    );
  }
}
