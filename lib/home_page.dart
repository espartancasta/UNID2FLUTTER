import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'appointment_page.dart';
import 'tips_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final userName = widget.user?.displayName ?? 'Usuario';

    final List<Widget> _pages = [
      _buildHomeContent(context, userName),
      const MessagesPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        title: Text(
          ['Inicio', 'Mensajes', 'Perfil', 'Configuración'][_selectedIndex],
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: Colors.cyanAccent, blurRadius: 12),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF00FFFF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF111122),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF00FFFF),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  /// 🔹 Contenido principal de la pantalla Home con estilo neón
  Widget _buildHomeContent(BuildContext context, String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF00FFFF), Color(0xFF6C63FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: Text(
              "¡Hola, $name! ¿En qué podemos ayudarte?",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 25),

          // 🔹 Botones principales con estilo neon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNeonButton(
                context,
                icon: Icons.calendar_today,
                label: "Agendar una Cita",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentPage()),
                ),
                color1: const Color(0xFF6C63FF),
                color2: const Color(0xFF00FFFF),
              ),
              _buildNeonButton(
                context,
                icon: Icons.medical_services_outlined,
                label: "Consejos Médicos",
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TipsPage()),
                ),
                color1: const Color(0xFFFF00FF),
                color2: const Color(0xFF00FFFF),
              ),
            ],
          ),

          const SizedBox(height: 40),

          const Text(
            "Especialistas",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.cyanAccent,
              shadows: [
                Shadow(color: Colors.cyan, blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(height: 10),

          for (var esp in [
            "Cardiólogo",
            "Dentista",
            "Pediatra",
            "Dermatólogo",
            "Nutriólogo"
          ])
            Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF23234B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.cyanAccent),
                title: Text(
                  esp,
                  style: const TextStyle(color: Colors.white),
                ),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.white70),
              ),
            ),

          const SizedBox(height: 30),

          const Text(
            "Doctores Populares",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent,
              shadows: [
                Shadow(color: Colors.pinkAccent, blurRadius: 10),
              ],
            ),
          ),
          const SizedBox(height: 10),

          _buildDoctorTile("Dr. Alejandro Cruz", "Cardiólogo"),
          _buildDoctorTile("Dra. Sofía Jiménez", "Nutrióloga"),
        ],
      ),
    );
  }

  /// 🔹 Botón con efecto neón
  Widget _buildNeonButton(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onPressed,
      required Color color1,
      required Color color2}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: color1.withOpacity(0.6), blurRadius: 15),
        ],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  /// 🔹 Tarjeta de doctor con toque brillante
  Widget _buildDoctorTile(String name, String specialty) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C54), Color(0xFF24243E)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.pinkAccent.withOpacity(0.4),
            blurRadius: 10,
          ),
        ],
      ),
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.pinkAccent,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(name, style: const TextStyle(color: Colors.white)),
        subtitle: Text(specialty, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}
