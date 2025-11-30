import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<Map<String, dynamic>> _users = [];
  final TextEditingController _cedulaController = TextEditingController();
  bool _isLoggedIn = false;
  String _userName = "";

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    String data = await rootBundle.loadString('lib/json_files/user.json');
    List<dynamic> jsonList = json.decode(data);
    setState(() {
      _users = jsonList.cast<Map<String, dynamic>>();
    });
  }

  void _login() {
    var user = _users.firstWhere(
      (u) => u["user"] == _cedulaController.text,
      orElse: () => {},
    );

    if (user.isNotEmpty) {
      setState(() {
        _isLoggedIn = true;
        _userName = user['name'];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Usuario no encontrado")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoggedIn
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/lottie/check.json', // Ruta de la animación Lottie
                    width: 150,
                    height: 150,
                    repeat: false,
                    onLoaded: (composition) {
                      Future.delayed(composition.duration, () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const DashboardBasePage()),
                        );
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Bienvenido $_userName",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logos/MC_logo.png',
                    width: 200,
                    height: 100,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: McTextField(
                      controller: _cedulaController,
                      labelText: "Ingrese su cédula",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 200,
                    child: MCButton(
                      text: "Ingresar",
                      onPressed: _login,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
