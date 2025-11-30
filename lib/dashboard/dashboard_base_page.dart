import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mc_dashboard/pages.dart/equipos_page.dart';
import 'package:mc_dashboard/pages.dart/pass_herramientas_page.dart';
import 'package:mc_dashboard/pages.dart/pass_rg_page.dart';

class DashboardBasePage extends StatefulWidget {
  const DashboardBasePage({super.key});

  @override
  State<DashboardBasePage> createState() => _DashboardBasePageState();
}

class _DashboardBasePageState extends State<DashboardBasePage> {
  Widget _selectedPage = const EquiposPage();

  void _onMenuItemSelected(String page) {
    setState(() {
      switch (page) {
        case 'Equipos':
          _selectedPage = const EquiposPage();
          break;
        case 'Pass - RG':
          _selectedPage = const PassRGPage();
          break;
        case 'Pass-Herramientas':
          _selectedPage = PassHerramientasPage();
          break;
        default:
          _selectedPage = const Center(child: Text('Seleccione una opción'));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          BarLeft(onItemSelected: _onMenuItemSelected),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: _selectedPage,
            ),
          ),
        ],
      ),
    );
  }
}

class BarLeft extends StatelessWidget {
  final ValueChanged<String> onItemSelected;

  const BarLeft({super.key, required this.onItemSelected});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 250,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.lightBlue.withOpacity(0.6),
            ),
            child: Center(
              child: Image.asset(
                'assets/logos/MC_logo.png',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
          ),
          _buildMenuItem('Equipos', LucideIcons.monitor, onItemSelected),
          _buildMenuItem('Pass - RG', LucideIcons.badgeCheck, onItemSelected),
          _buildMenuItem('Pass-Herramientas', LucideIcons.box, onItemSelected),
          _buildMenuItem('INA', LucideIcons.users, onItemSelected),
          _buildMenuItem('ODC', LucideIcons.users, onItemSelected),
          _buildMenuItem('SR', LucideIcons.users, onItemSelected),
          _buildMenuItem(
              'Permisos de ingreso', LucideIcons.key, onItemSelected),
          _buildMenuItem('Fibras oscuras', LucideIcons.waves, onItemSelected),
          _buildMenuItem('Special', LucideIcons.star, onItemSelected),
          _buildMenuItem('Terceros', LucideIcons.users, onItemSelected),
          _buildMenuItem('Escalamiento Jerarquico', LucideIcons.trendingUp,
              onItemSelected),
          _buildMenuItem('Proyecto RUAV', LucideIcons.network, onItemSelected),
          _buildMenuItem('ITX', LucideIcons.cpu, onItemSelected),
          _buildMenuItem('CONT-N2-Residentes-Special-ISP', LucideIcons.server,
              onItemSelected),
          _buildMenuItem(
              'Clientes arquetipos', LucideIcons.briefcase, onItemSelected),
          _buildMenuItem('Directorio', LucideIcons.book, onItemSelected),
          _buildMenuItem('Perú', LucideIcons.flag, onItemSelected),
          _buildMenuItem('RB Meganet', LucideIcons.globe, onItemSelected),
          _buildMenuItem('Descuento-Indisponibilidad', LucideIcons.percent,
              onItemSelected),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
      String title, IconData icon, ValueChanged<String> onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => onTap(title),
    );
  }
}
