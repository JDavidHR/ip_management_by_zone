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

      // for (int j = 0; j < _headers.length; j++) {
      //   var cell = sheet.rows[i][j];
      //   row[_headers[j]] = cell?.value?.toString() ?? "";
      // }

      for (int j = 0; j < _headers.length; j++) {
        var cell = sheet.rows[i][j];

        String value = cell?.value?.toString() ?? "";

        // 👉 Convertir "6.0" → "6"
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
      _isLoading = false; // <- YA CARGÓ
    });
  }

  void _filterTable(String query) {
    query = query.toLowerCase();

    setState(() {
      _filteredData = _data.where((row) {
        return row.values.any((value) {
          return value.toLowerCase().contains(query);
        });
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    // ========= LOADING ==========
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ========= SIN COLUMNAS (evita error) ==========
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
        // ===== Buscador =====
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

        const SizedBox(height: 20),

        // ===== TABLA =====
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
