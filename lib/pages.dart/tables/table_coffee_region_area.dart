import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';

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

  // COLORES DEL GRÁFICO (Opción C)
  final Color azul = const Color(0xFF1A73E8);
  final Color amarillo = const Color(0xFFF9AB00);

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

  // FILTRO
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

  // LISTA SOLO DISPONIBLES
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

  // ================================================================
  //                 *** DIÁLOGO STATUS IP ***
  // ================================================================

  void _showIpSummaryDialog() {
    String clienteHeader = _headers.firstWhere(
      (h) => h.toLowerCase().contains("cliente"),
      orElse: () => "",
    );

    int total = _data.length;
    int disponibles =
        _data.where((row) => (row[clienteHeader] ?? "").trim().isEmpty).length;
    int ocupadas = total - disponibles;

    double pDisp = total == 0 ? 0 : (disponibles / total) * 100;
    double pOcc = total == 0 ? 0 : (ocupadas / total) * 100;

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Center(
            child: Text(
              "Status IP",
              style: TextStyle(
                color: Colors.black,
                fontSize: 16,
                height: 1.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          content: SizedBox(
            width: 400,
            height: 300,
            child: Column(
              children: [
                CustomPaint(
                  size: const Size(220, 220),
                  painter: _CircularChartPainter(
                    disponibles: disponibles,
                    ocupadas: ocupadas,
                    azul: azul,
                    amarillo: amarillo,
                  ),
                ),

                const SizedBox(height: 16),

                // ===========================
                //      LEYENDAS CON %
                // ===========================
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(azul,
                            "Disponibles: $disponibles (${pDisp.toStringAsFixed(1)}%)"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _legendItem(amarillo,
                            "Ocupadas: $ocupadas (${pOcc.toStringAsFixed(1)}%)"),
                      ],
                    ),
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

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(text),
      ],
    );
  }

  // BOTÓN NEGRO
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

  // ================================================================
  //                 *** DIÁLOGO EDITAR FILA ***
  // ================================================================
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

  // ================================================================
  //                   *** INTERFAZ PRINCIPAL ***
  // ================================================================
  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // BUSCADOR Y BOTONES
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
            ElevatedButton(
              onPressed: _showIpSummaryDialog,
              style: blackButton(),
              child: const Text("Status IP"),
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

        // TABLA
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 12,
                  color: Colors.black12,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowHeight: 48,
                    dataRowHeight: 56,
                    columnSpacing: 36,
                    dividerThickness: 0, // QUITA LÍNEAS
                    //color de la cabecera de la tabla
                    // headingRowColor: MaterialStateProperty.all(
                    //   Colors.grey.shade200,
                    // ),
                    columns: [
                      const DataColumn(
                        label: Text(
                          "Opciones",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      ..._headers.map(
                        (h) => DataColumn(
                          label: Text(
                            h,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ],
                    rows: _filteredData.map((row) {
                      return DataRow(
                        color: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.hovered)) {
                            return Colors.grey.shade100;
                          }
                          return Colors.white;
                        }),
                        cells: [
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
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// =====================================================================
//                       *** PINTOR DEL GRÁFICO ***
// =====================================================================
class _CircularChartPainter extends CustomPainter {
  final int disponibles;
  final int ocupadas;
  final Color azul;
  final Color amarillo;

  _CircularChartPainter({
    required this.disponibles,
    required this.ocupadas,
    required this.azul,
    required this.amarillo,
  });

  @override
  void paint(Canvas canvas, Size size) {
    double total = (disponibles + ocupadas).toDouble();
    if (total == 0) return;

    double angleDisponible = (disponibles / total) * 2 * pi;
    double angleOcupadas = (ocupadas / total) * 2 * pi;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width * 0.40;

    final paintDisponible = Paint()
      ..color = azul
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    final paintOcupadas = Paint()
      ..color = amarillo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.round;

    // Arco disponibles
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2,
      angleDisponible,
      false,
      paintDisponible,
    );

    // Arco ocupadas
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -pi / 2 + angleDisponible,
      angleOcupadas,
      false,
      paintOcupadas,
    );

    // TEXTO CENTRO

    TextPainter tp = TextPainter(
      text: TextSpan(
        text: "Total de IP: $total",
        style: const TextStyle(
          color: Colors.black,
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    tp.layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
