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
  bool _showOnlyAvailable = false; // toggle para mostrar solo IP disponibles

  final TextEditingController _filterController = TextEditingController();

  // clave detectada de la columna cliente (por ejemplo: "Clientes")
  String? _clienteKey;

  @override
  void initState() {
    super.initState();
    _loadExcel();
    _filterController.addListener(() {
      _applyFilters();
    });
  }

  @override
  void dispose() {
    _filterController.dispose();
    super.dispose();
  }

  // ======================================================
  //    CARGAR EXCEL
  // ======================================================
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

    // detectar la columna cliente (insensible a mayúsculas/minúsculas)
    _clienteKey = _headers.firstWhere(
      (h) => h.toLowerCase().contains('cliente'),
      orElse: () => '',
    );
    if (_clienteKey == '') _clienteKey = null;

    // Filas
    for (int i = 1; i < sheet.rows.length; i++) {
      Map<String, String> row = {};

      for (int j = 0; j < _headers.length; j++) {
        var cell = sheet.rows[i][j];

        String value = cell?.value?.toString() ?? "";

        // Convertir "6.0" → "6"
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

  // ======================================================
  //    FILTROS (búsqueda + toggle disponibles)
  // ======================================================
  void _applyFilters() {
    final query = _filterController.text.toLowerCase();

    List<Map<String, String>> temp = _data.where((row) {
      if (query.isEmpty) return true;
      return row.values.any((value) => value.toLowerCase().contains(query));
    }).toList();

    if (_showOnlyAvailable) {
      if (_clienteKey != null) {
        temp = temp.where((row) {
          final cliente = (row[_clienteKey!] ?? "").trim();
          return cliente.isEmpty;
        }).toList();
      } else {
        // si no detecta columna cliente, no filtra (evita crash)
      }
    }

    setState(() {
      _filteredData = temp;
    });
  }

  void _filterTable(String _) {
    // el listener del controller ya llama _applyFilters(), pero mantenemos compatibilidad
    _applyFilters();
  }

  // ======================================================
  //    TOGGLE: mostrar solo IP disponibles / mostrar todo
  // ======================================================
  void _toggleAvailableIPs() {
    setState(() {
      _showOnlyAvailable = !_showOnlyAvailable;
      _applyFilters();
    });
  }

  // ======================================================
  //    MOSTRAR ESTADÍSTICAS DE IP
  // ======================================================
  void _showIPStats() {
    int total = _data.length;
    int disponibles = 0;
    if (_clienteKey != null) {
      disponibles =
          _data.where((row) => (row[_clienteKey!] ?? "").trim().isEmpty).length;
    } else {
      // si no hay columna cliente, consideramos 0 disponibles
      disponibles = 0;
    }
    int ocupadas = total - disponibles;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Estadísticas de IP"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("IP Totales: $total"),
            Text("IP Disponibles: $disponibles"),
            Text("IP Ocupadas: $ocupadas"),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Cerrar"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }

  // ======================================================
  //    UI PRINCIPAL
  // ======================================================
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
        // BUSCADOR + BOTONES
        Row(
          children: [
            // Buscador
            SizedBox(
              width: 400,
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
            const SizedBox(width: 16),

            // Botón estadísticas
            ElevatedButton.icon(
              onPressed: _showIPStats,
              icon: const Icon(Icons.info_outline),
              label: const Text("Ver IP disponibles"),
            ),

            const SizedBox(width: 12),

            // Toggle mostrar solo disponibles
            ElevatedButton.icon(
              onPressed: _toggleAvailableIPs,
              icon: Icon(
                  _showOnlyAvailable ? Icons.visibility_off : Icons.visibility),
              label: Text(_showOnlyAvailable
                  ? "Mostrar todo"
                  : "Mostrar solo IP disponibles"),
              style: ElevatedButton.styleFrom(
                backgroundColor: _showOnlyAvailable ? Colors.green : null,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // TABLA
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
