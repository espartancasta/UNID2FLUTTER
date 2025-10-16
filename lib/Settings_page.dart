import 'package:flutter/material.dart';
import 'profile_page.dart';

class SettingsPage extends StatelessWidget {
  final VoidCallback? onLogout;
  const SettingsPage({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            ListTile(
              leading: const CircleAvatar(
                  backgroundImage: AssetImage('assets/images/doctor.png')),
              title: const Text('Dear Programmer'),
              subtitle: const Text('Profile'),
            ),
            const SizedBox(height: 8),
            _tile(context, Icons.person_outline, 'Profile', () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProfilePage()));
            }),
            _tile(context, Icons.privacy_tip_outlined, 'Privacy', () {
              _showInfo(context, 'Privacy', 'Aquí va el texto informativo de privacidad.');
            }),
            _tile(context, Icons.info_outline, 'About Us', () {
              _showInfo(context, 'About Us', 'Aplicación de ejemplo para agendar citas médicas.');
            }),
            _tile(context, Icons.settings, 'General', () {
              _showInfo(context, 'General', 'Opciones generales de la app.');
            }),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Log Out', style: TextStyle(color: Colors.red)),
              onTap: () {
                if (onLogout != null) onLogout!();
                else Navigator.popUntil(context, (route) => route.isFirst);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext ctx, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF6C63FF)),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showInfo(BuildContext ctx, String title, String body) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
