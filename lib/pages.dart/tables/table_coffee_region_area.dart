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

  final TextEditingController _filterController = TextEditingController();

  bool _showOnlyAvailable = false; // PARA MOSTRAR SOLO IP DISPONIBLES

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

    // Encabezados
    _headers = sheet.rows.first.map((cell) {
      return (cell?.value?.toString() ?? "").trim();
    }).toList();

    // Filas
    for (int i = 1; i < sheet.rows.length; i++) {
      Map<String, String> row = {};

      for (int j = 0; j < _headers.length; j++) {
        var cell = sheet.rows[i][j];
        String value = cell?.value?.toString() ?? "";

        // Convertir 6.0 → 6
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

  // Obtener lista de IP disponibles (cliente vacío)
  List<Map<String, String>> _onlyAvailableList() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    if (clienteHeader.isEmpty) return _data;

    return _data.where((row) {
      return (row[clienteHeader] ?? "").trim().isEmpty;
    }).toList();
  }

  // BOTÓN PARA MOSTRAR SOLO IP DISPONIBLES
  void _toggleAvailableFilter() {
    setState(() {
      _showOnlyAvailable = !_showOnlyAvailable;

      if (_showOnlyAvailable) {
        _filteredData = _onlyAvailableList();
      } else {
        _filteredData = _data;
      }
    });
  }

  // DIALOGO DE RESUMEN DE IPS
  void _showIpSummaryDialog() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    if (clienteHeader.isEmpty) return;

    int total = _data.length;
    int disponibles = _data.where((row) {
      return (row[clienteHeader] ?? "").trim().isEmpty;
    }).length;

    int ocupadas = total - disponibles;

    showDialog(
      context: context,
      builder: (context) {
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
              child: const Text("Cerrar"),
            ),
          ],
        );
      },
    );
  }

  // ==== ESTILOS DE BOTÓN ====
  ButtonStyle blackButton() {
    return ElevatedButton.styleFrom(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8), // ← Borde 8px
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_headers.isEmpty) {
      return const Center(
        child: Text(
          "No se pudieron cargar los encabezados de la tabla.",
          style: TextStyle(color: Colors.red, fontSize: 18),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ==== BUSCADOR + BOTONES ====
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
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: _filterTable,
              ),
            ),
            const SizedBox(width: 12),

            // BOTÓN: CONTAR IPS
            ElevatedButton(
              onPressed: _showIpSummaryDialog,
              style: blackButton(),
              child: const Text("Resumen IP"),
            ),

            const SizedBox(width: 12),

            // BOTÓN: MOSTRAR SOLO DISPONIBLES
            ElevatedButton(
              onPressed: () {
                _toggleAvailableFilter();
                _filterTable(_filterController.text);
              },
              style: blackButton(),
              child: Text(
                _showOnlyAvailable ? "Mostrar todo" : "IP disponibles",
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ==== TABLA ====
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: DataTable(
                  headingRowHeight: 48,
                  dataRowHeight: 56,
                  columnSpacing: 40,
                  columns: _headers
                      .map(
                        (h) => DataColumn(
                          label: Text(
                            h,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  rows: _filteredData.map(
                    (row) {
                      return DataRow(
                        cells: _headers.map(
                          (h) {
                            return DataCell(
                              SizedBox(
                                width: 150,
                                child: Text(
                                  row[h] ?? "",
                                  softWrap: true,
                                ),
                              ),
                            );
                          },
                        ).toList(),
                      );
                    },
                  ).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
