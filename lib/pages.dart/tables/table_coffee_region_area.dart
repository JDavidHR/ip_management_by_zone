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

    // Filas
    for (int i = 1; i < sheet.rows.length; i++) {
      Map<String, String> row = {};

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
      _isLoading = false;
    });
  }

  // ======================================================
  //    FILTRO DE BÚSQUEDA
  // ======================================================
  void _filterTable(String query) {
    query = query.toLowerCase();

    setState(() {
      _filteredData = _data.where((row) {
        return row.values.any(
          (value) => value.toLowerCase().contains(query),
        );
      }).toList();
    });
  }

  // ======================================================
  //    MOSTRAR ESTADÍSTICAS DE IP
  // ======================================================
  void _showIpStats() {
    int total = _data.length;

    int disponibles = _data.where((row) {
      String cliente = row["Clientes"]?.trim() ?? "";
      return cliente.isEmpty; // cliente vacío = IP libre
    }).length;

    int ocupadas = total - disponibles;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Estado de la tabla"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("IP totales: $total"),
              Text("IP disponibles: $disponibles"),
              Text("IP ocupadas: $ocupadas"),
            ],
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

  // ======================================================
  //    UI PRINCIPAL
  // ======================================================
  @override
  Widget build(BuildContext context) {
    // ===== LOADING =====
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // ===== ERROR: SIN HEADERS =====
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
        // ======================================================
        //    BUSCADOR + BOTONES
        // ======================================================
        Row(
          children: [
            // ==== BUSCADOR ====
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

            const SizedBox(width: 20),

            // ==== BOTÓN: VER IP DISPONIBLES ====
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: _showIpStats,
              child: const Text("Estado de la tabla"),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // ======================================================
        //    TABLA
        // ======================================================
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
