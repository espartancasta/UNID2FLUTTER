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
      appBar: AppBar(
        title: Text(['Inicio', 'Mensajes', 'Perfil', 'Configuración'][_selectedIndex]),
        backgroundColor: const Color(0xFF6C63FF),
        centerTitle: true,
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
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }

  /// 🔹 Contenido principal de la pantalla Home
  Widget _buildHomeContent(BuildContext context, String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "¡Hola, $name! ¿En qué podemos ayudarte?",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 🔹 Botones principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AppointmentPage()), // <--- quitamos const
                ),
                icon: const Icon(Icons.calendar_today),
                label: const Text("Agendar una Cita"),
              ),
              ElevatedButton.icon(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TipsPage()), // <--- quitamos const
                ),
                icon: const Icon(Icons.medical_services_outlined),
                label: const Text("Consejos Médicos"),
              ),
            ],
          ),

          const SizedBox(height: 30),

          // 🔹 Lista de Especialistas
          const Text("Especialistas",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          for (var esp in [
            "Cardiólogo",
            "Dentista",
            "Pediatra",
            "Dermatólogo",
            "Nutriólogo"
          ])
            Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: const Icon(Icons.person, color: Color(0xFF6C63FF)),
                title: Text(esp),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ),

          const SizedBox(height: 30),

          // 🔹 Sección adicional (Doctores o información)
          const Text("Doctores Populares",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Dr. Alejandro Cruz"),
            subtitle: Text("Cardiólogo"),
          ),
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Dra. Sofía Jiménez"),
            subtitle: Text("Nutrióloga"),
          ),
        ],
      ),
    );
  }
}
