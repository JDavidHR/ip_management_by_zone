import 'dart:math';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mc_dashboard/core/colors.dart';

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

  // ============================================================
  //  FILTROS
  // ============================================================

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

  // ============================================================
  //  ESTADÍSTICAS
  // ============================================================

  Map<String, int> _stats() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    int total = _data.length;
    int disponibles =
        _data.where((row) => (row[clienteHeader] ?? "").trim().isEmpty).length;
    int ocupadas = total - disponibles;

    return {
      "total": total,
      "disponibles": disponibles,
      "ocupadas": ocupadas,
    };
  }

  // ============================================================
  //  DIÁLOGO CON GRÁFICO CIRCULAR
  // ============================================================

  void _showIpSummaryDialog() {
    final stats = _stats();

    double disponiblesPercent =
        stats["total"]! == 0 ? 0 : stats["disponibles"]! / stats["total"]!;
    double ocupadasPercent =
        stats["total"]! == 0 ? 0 : stats["ocupadas"]! / stats["total"]!;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Center(
            child: Text("Estado de la tabla"),
          ),
          content: SizedBox(
            width: 300,
            height: 350,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // === GRÁFICO CIRCULAR ===
                SizedBox(
                  width: 200,
                  height: 200,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CustomPaint(
                        size: const Size(200, 200),
                        painter: _PieChartPainter(
                          disponiblesPercent,
                          ocupadasPercent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: MCPaletteColors.mcBlue,
                      width: 10,
                      height: 10,
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Text("Disponible: ${stats["disponibles"]}  "
                        "(${(disponiblesPercent * 100).toStringAsFixed(1)}%)"),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      color: MCPaletteColors.mcYellow,
                      width: 10,
                      height: 10,
                    ),
                    const SizedBox(
                      width: 10,
                      height: 10,
                    ),
                    Text("Ocupadas: ${stats["ocupadas"]}  "
                        "(${(ocupadasPercent * 100).toStringAsFixed(1)}%)"),
                  ],
                ),
              ],
            ),
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

  // ============================================================
  //  ESTILO BOTONES NEGROS
  // ============================================================

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

  // ============================================================
  //  DIALOGO PARA EDITAR
  // ============================================================

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

  // ============================================================
  //  UI PRINCIPAL
  // ============================================================

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
              child: const Text("Estado de la tabla"),
            ),
            const SizedBox(width: 12),
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

        const SizedBox(height: 16),

        // ============================================================
        //                   TABLA CON BOTÓN EDITAR
        // ============================================================

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
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.black),
                        onPressed: () => _editRow(row),
                      ),
                    ),
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
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
//   PAINTER PARA EL GRÁFICO CIRCULAR
// ============================================================

class _PieChartPainter extends CustomPainter {
  final double disponibles;
  final double ocupadas;

  _PieChartPainter(this.disponibles, this.ocupadas);

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()..style = PaintingStyle.fill;

    double radius = size.width / 2;
    Offset center = Offset(radius, radius);

    double startAngle = -pi / 2;

    // Verde para disponibles
    paint.color = MCPaletteColors.mcBlue;
    double sweepDisp = disponibles * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepDisp,
      true,
      paint,
    );

    // Rojo para ocupadas
    paint.color = MCPaletteColors.mcYellow;
    double sweepOcc = ocupadas * 2 * pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle + sweepDisp,
      sweepOcc,
      true,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
