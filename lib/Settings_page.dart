import 'package:flutter/material.dart';
import 'profile_page.dart';

/// PÁGINA DE CONFIGURACIÓN CON ESTILO NEÓN
class SettingsPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const SettingsPage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // Barra superior
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Color(0xFFFF00FF), // Título fucsia neón
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF0A0A0A), // Fondo negro
          elevation: 4,
        ),
        backgroundColor: const Color(0xFF0A0A0A), // Fondo general negro
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Perfil del usuario
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              title: const Text(
                'Dear Programmer',
                style: TextStyle(color: Colors.white), // Texto blanco
              ),
              subtitle: const Text(
                'Profile',
                style: TextStyle(color: Color(0xFF00FFFF)), // Subtítulo turquesa neón
              ),
            ),
            const SizedBox(height: 8),

            // Opciones de configuración
            _tile(context, Icons.person_outline, 'Profile', () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (_) => const ProfilePage()));
            }),
            _tile(context, Icons.privacy_tip_outlined, 'Privacy', () {
              _showInfo(context, 'Privacy', 'Aquí va el texto informativo de privacidad.');
            }),
            _tile(context, Icons.info_outline, 'About Us', () {
              _showInfo(context, 'About Us',
                  'Aplicación de ejemplo para agendar citas médicas.');
            }),
            _tile(context, Icons.settings, 'General', () {
              _showInfo(context, 'General', 'Opciones generales de la app.');
            }),

            const Divider(color: Color(0xFF00FFFF)), // Separador turquesa

            // Opción de cerrar sesión
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF00FF)), // Ícono fucsia
              title: const Text(
                'Log Out',
                style: TextStyle(color: Color(0xFFFF00FF)), // Texto fucsia
              ),
              onTap: () {
                if (onLogout != null) {
                  onLogout!();
                } else {
                  Navigator.popUntil(context, (route) => route.isFirst);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de tile personalizado con estilo neón
  Widget _tile(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFFF)), // Ícono turquesa neón
      title: Text(title, style: const TextStyle(color: Colors.white)), // Texto blanco
      trailing: const Icon(Icons.arrow_forward_ios,
          size: 16, color: Color(0xFFFF00FF)), // Flecha fucsia neón
      onTap: onTap,
    );
  }

  /// Mostrar ventana de información
  void _showInfo(BuildContext ctx, String title, String body) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A), // Fondo negro del dialogo
        title: Text(title, style: const TextStyle(color: Color(0xFFFF00FF))), // Título fucsia
        content: Text(body, style: const TextStyle(color: Colors.white)), // Texto blanco
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar', style: TextStyle(color: Color(0xFF00FFFF))), // Botón turquesa
          ),
        ],
      ),
    );
  }
}
