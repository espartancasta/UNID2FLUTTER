import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'messages_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'appointment_page.dart';
import 'tips_page.dart';
import 'dashboard_page.dart';
import 'services/graphics_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // 🔹 Rol del usuario: 'paciente', 'medico' o 'invitado'
  String _role = 'invitado';
  bool _loadingRole = true;

  bool get _isDoctor => _role == 'medico';

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  // 🔹 Carga el rol desde Firestore: users/{uid}.role
  Future<void> _loadUserRole() async {
    final user = widget.user;
    if (user == null) {
      setState(() {
        _role = 'invitado';
        _loadingRole = false;
      });
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = doc.data();
      setState(() {
        _role = (data?['role'] ?? 'paciente').toString();
        _loadingRole = false;
      });
    } catch (e) {
      setState(() {
        _role = 'paciente';
        _loadingRole = false;
      });
    }
  }

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

    final List<Widget> pages = [
      _buildHome(userName),
      const MessagesPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildNeonAppBar(),
      body: _loadingRole
          ? const Center(child: CircularProgressIndicator())
          : AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: Container(
                key: ValueKey(_selectedIndex),
                width: double.infinity,
                height: double.infinity,
                child: pages[_selectedIndex],
              ),
            ),
      bottomNavigationBar: _buildNeonNavbar(),
    );
  }

  // ------------------------------------------------
  // APPBAR NEÓN
  // ------------------------------------------------
  AppBar _buildNeonAppBar() {
    return AppBar(
      title: Text(
        ['Inicio', 'Mensajes', 'Perfil', 'Ajustes'][_selectedIndex],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Color(0xFF00FFFF), blurRadius: 12)],
        ),
      ),
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
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
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: _logout,
        )
      ],
    );
  }

  // ------------------------------------------------
  // NAVBAR NEÓN
  // ------------------------------------------------
  Widget _buildNeonNavbar() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF111122),
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
      selectedItemColor: const Color(0xFF00FFFF),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Inicio"),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: "Mensajes"),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: "Perfil"),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Ajustes"),
      ],
    );
  }

  // ------------------------------------------------
  // HOME
  // ------------------------------------------------
  Widget _buildHome(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNeonGreeting(name),
          const SizedBox(height: 8),
          Text(
            'Rol: ${_role[0].toUpperCase()}${_role.substring(1)}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 30),

          _buildSectionTitle("Acciones rápidas", Colors.cyanAccent),
          const SizedBox(height: 16),

          // 🔥 BOTONES EN UNA SOLA FILA (SCROLL HORIZONTAL)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // SOLO MÉDICO → Dashboard
                if (_isDoctor) ...[
                  _buildNeonButton(
                    icon: Icons.dashboard_customize,
                    label: "Dashboard",
                    color1: const Color(0xFF00FFFF),
                    color2: const Color(0xFF6C63FF),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DashboardPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _buildNeonButton(
                    icon: Icons.show_chart,
                    label: "Gráficas",
                    color1: const Color(0xFF00FFAA),
                    color2: const Color(0xFF00FFFF),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const GraphicsPage()),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],

                // TODOS LOS ROLES → Agendar Cita
                _buildNeonButton(
                  icon: Icons.calendar_today,
                  label: "Agendar Cita",
                  color1: const Color(0xFF6C63FF),
                  color2: const Color(0xFF00FFFF),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AppointmentPage()),
                  ),
                ),
                const SizedBox(width: 12),

                // TODOS LOS ROLES → Consejos
                _buildNeonButton(
                  icon: Icons.medical_services_outlined,
                  label: "Consejos",
                  color1: const Color(0xFFFF00FF),
                  color2: const Color(0xFF00FFFF),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const TipsPage()),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 35),

          _buildSectionTitle("Especialistas", Colors.cyanAccent),
          const SizedBox(height: 10),
          ..._buildSpecialists(),
          const SizedBox(height: 30),

          _buildSectionTitle("Doctores Populares", Colors.pinkAccent),
          const SizedBox(height: 10),
          _buildDoctorTile("Dr. Alejandro Cruz", "Cardiólogo"),
          _buildDoctorTile("Dra. Sofía Jiménez", "Nutrióloga"),
        ],
      ),
    );
  }

  // ------------------------------------------------
  // WIDGETS AUXILIARES
  // ------------------------------------------------
  Widget _buildNeonGreeting(String name) {
    return ShaderMask(
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
    );
  }

  Widget _buildSectionTitle(String title, Color shadowColor) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: shadowColor,
        shadows: [Shadow(color: shadowColor.withOpacity(0.8), blurRadius: 10)],
      ),
    );
  }

  // Especialistas con nombre predefinido y SIN flechita
  List<Widget> _buildSpecialists() {
    final specialists = [
      {'especialidad': 'Cardiólogo', 'doctor': 'Dr. Alejandro Cruz'},
      {'especialidad': 'Dentista', 'doctor': 'Dra. Mariana López'},
      {'especialidad': 'Pediatra', 'doctor': 'Dr. Luis Herrera'},
      {'especialidad': 'Dermatólogo', 'doctor': 'Dra. Carla Ruiz'},
      {'especialidad': 'Nutriólogo', 'doctor': 'Dra. Sofía Jiménez'},
    ];

    return specialists
        .map(
          (esp) => Container(
            margin: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1A1A2E), Color(0xFF23234B)],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.blueAccent.withOpacity(0.3),
                  blurRadius: 8,
                ),
              ],
            ),
            child: ListTile(
              leading: const Icon(Icons.person, color: Colors.cyanAccent),
              title: Text(
                esp['especialidad']!,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                esp['doctor']!,
                style: const TextStyle(color: Colors.white70),
              ),
            ),
          ),
        )
        .toList();
  }

  Widget _buildNeonButton({
    required IconData icon,
    required String label,
    required Color color1,
    required Color color2,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [color1, color2]),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [BoxShadow(color: color1.withOpacity(0.6), blurRadius: 15)],
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorTile(String name, String specialty) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2C2C54), Color(0xFF24243E)],
        ),
        borderRadius: BorderRadius.circular(12),
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
        subtitle: Text(
          specialty,
          style: const TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}
