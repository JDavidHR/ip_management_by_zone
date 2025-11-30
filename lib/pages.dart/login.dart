import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'package:mc_dashboard/core/components/mcButton.dart';
import 'package:mc_dashboard/core/components/mcTextfield.dart';
import 'package:mc_dashboard/dashboard/dashboard_base_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _cedulaController = TextEditingController();
  bool _isLoggedIn = false;

  // ---------------------------------------------------------------------------
  //  OBTENER ARCHIVO EN LA RUTA: lib/json_files/login_registration.json
  // ---------------------------------------------------------------------------
  Future<File> _getLoginFile() async {
    return File('lib/json_files/login_registration.json');
  }

  // ---------------------------------------------------------------------------
  //  GUARDAR REGISTRO DE LOGIN
  // ---------------------------------------------------------------------------
  Future<void> _saveLoginRegistry() async {
    final file = await _getLoginFile();
    List<dynamic> registros = [];

    // Leer archivo si existe
    if (await file.exists()) {
      final contenido = await file.readAsString();
      if (contenido.isNotEmpty) {
        registros = json.decode(contenido);
      }
    }

    // Agregar nuevo registro
    registros.add({
      "cedula": _cedulaController.text,
      "fecha": DateTime.now().toString(), // fecha completa con hora
    });

    // Guardar archivo sobrescribiendo
    await file.writeAsString(json.encode(registros), flush: true);
  }

  // ---------------------------------------------------------------------------
  //  LOGIN — solo registra y da acceso
  // ---------------------------------------------------------------------------
  void _login() async {
    if (_cedulaController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Ingrese la cédula")),
      );
      return;
    }

    await _saveLoginRegistry();

    setState(() {
      _isLoggedIn = true;
    });
  }

  // ---------------------------------------------------------------------------
  //  UI COMPLETA
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF6A11CB),
              Color(0xFF2575FC),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Container(
            width: 900,
            height: 500,
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),

            // -------------------------------
            //  ANIMACIÓN DESPUÉS DEL LOGIN
            // -------------------------------
            child: _isLoggedIn
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset(
                        'assets/lottie/check.json',
                        width: 150,
                        height: 150,
                        repeat: false,
                        onLoaded: (composition) {
                          Future.delayed(composition.duration, () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DashboardBasePage(),
                              ),
                            );
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        "Bienvenido",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )

                // -------------------------------
                //  FORMULARIO DE LOGIN
                // -------------------------------
                : Row(
                    children: [
                      // LADO IZQUIERDO
                      Expanded(
                        child: Center(
                          child: Image.asset(
                            'assets/logos/MC_logo.png',
                            width: 260,
                            height: 260,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      // Línea divisoria
                      Container(
                        width: 1,
                        height: 300,
                        color: Colors.grey.shade300,
                      ),

                      // LADO DERECHO
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "IDENTIFICACIÓN",
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                            SizedBox(
                              width: 270,
                              child: McTextField(
                                controller: _cedulaController,
                                labelText: "CEDULA",
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: 270,
                              child: MCButton(
                                text: "ACCEDER",
                                onPressed: _login,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
