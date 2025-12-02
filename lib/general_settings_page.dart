import 'package:flutter/material.dart';

class GeneralSettingsPage extends StatefulWidget {
  const GeneralSettingsPage({super.key});

  @override
  State<GeneralSettingsPage> createState() => _GeneralSettingsPageState();
}

class _GeneralSettingsPageState extends State<GeneralSettingsPage> {
  bool _notificationsEnabled = true;
  bool _darkMode = true; // tu app ya es oscura, pero es un ejemplo
  bool _rememberSession = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'General',
          style: TextStyle(
            color: Color(0xFFFF00FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 4,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text(
              'Notificaciones',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Recibir recordatorios de citas',
              style: TextStyle(color: Color(0xFF00FFFF)),
            ),
            value: _notificationsEnabled,
            activeColor: const Color(0xFF00FFFF),
            onChanged: (v) {
              setState(() => _notificationsEnabled = v);
              // Aquí podrías guardar en SharedPreferences o Firebase
            },
          ),
          SwitchListTile(
            title: const Text(
              'Modo oscuro',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Usar tema oscuro en la aplicación',
              style: TextStyle(color: Color(0xFF00FFFF)),
            ),
            value: _darkMode,
            activeColor: const Color(0xFF00FFFF),
            onChanged: (v) {
              setState(() => _darkMode = v);
              // Aquí podrías disparar un cambio de tema global
            },
          ),
          SwitchListTile(
            title: const Text(
              'Recordar sesión',
              style: TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Mantener la sesión iniciada en este dispositivo',
              style: TextStyle(color: Color(0xFF00FFFF)),
            ),
            value: _rememberSession,
            activeColor: const Color(0xFF00FFFF),
            onChanged: (v) {
              setState(() => _rememberSession = v);
              // Guardar preferencia
            },
          ),
        ],
      ),
    );
  }
}
