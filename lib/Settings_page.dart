import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'profile_page.dart';
import 'privacy_page.dart';
import 'about_us_page.dart';
import 'general_settings_page.dart';

/// PÁGINA DE CONFIGURACIÓN CON ESTILO NEÓN
class SettingsPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const SettingsPage({super.key, this.onLogout});

  // 🔹 Manejamos aquí el logout por si no nos pasan callback
  Future<void> _handleLogout(BuildContext context) async {
    if (onLogout != null) {
      onLogout!(); // usa el callback del HomePage
      return;
    }

    // Logout directo desde aquí
    await FirebaseAuth.instance.signOut();

    // Volver a la pantalla de login (ruta '/')
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Color(0xFFFF00FF), // Título fucsia neón
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 4,
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            // Perfil del usuario (también navega a ProfilePage)
            ListTile(
              leading: const CircleAvatar(
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
              title: const Text(
                'Dear Programmer',
                style: TextStyle(color: Colors.white),
              ),
              subtitle: const Text(
                'Profile',
                style: TextStyle(color: Color(0xFF00FFFF)),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfilePage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),

            // Opciones de configuración
            _tile(context, Icons.person_outline, 'Profile', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            }),
            _tile(context, Icons.privacy_tip_outlined, 'Privacy', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PrivacyPage(),
                ),
              );
            }),
            _tile(context, Icons.info_outline, 'About Us', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AboutUsPage(),
                ),
              );
            }),
            _tile(context, Icons.settings, 'General', () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const GeneralSettingsPage(),
                ),
              );
            }),

            const Divider(color: Color(0xFF00FFFF)),

            // 🔹 Opción de cerrar sesión (botón morado)
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Color(0xFFFF00FF),
              ),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Color(0xFFFF00FF)),
              ),
              onTap: () => _handleLogout(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget de tile personalizado con estilo neón
  Widget _tile(
      BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFFF)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Color(0xFFFF00FF),
      ),
      onTap: onTap,
    );
  }
}
