import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
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
  final uid = FirebaseAuth.instance.currentUser?.uid;

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
      _buildHome(userName),
      const MessagesPage(),
      const ProfilePage(),
      const SettingsPage(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: _buildNeonAppBar(),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: Container(
          key: ValueKey(_selectedIndex),
          width: double.infinity,
          height: double.infinity,
          child: _pages[_selectedIndex],
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
  // HOME + DASHBOARD INTEGRADO
  // ------------------------------------------------
  Widget _buildHome(String name) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildNeonGreeting(name),
          const SizedBox(height: 25),

          // 🔥 DASHBOARD ARRIBA
          _buildDashboardSection(),
          const SizedBox(height: 25),

          // Botones principales
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNeonButton(
                icon: Icons.calendar_today,
                label: "Agendar Cita",
                color1: const Color(0xFF6C63FF),
                color2: const Color(0xFF00FFFF),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AppointmentPage()),
                ),
              ),
              _buildNeonButton(
                icon: Icons.medical_services_outlined,
                label: "Consejos",
                color1: const Color(0xFFFF00FF),
                color2: const Color(0xFF00FFFF),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => TipsPage()),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),

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
  // DASHBOARD DE CITAS
  // ------------------------------------------------
  Widget _buildDashboardSection() {
    if (uid == null) return const SizedBox();

    final appointmentsQuery = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .orderBy('date', descending: false);

    return StreamBuilder<QuerySnapshot>(
      stream: appointmentsQuery.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        final docs = snapshot.data!.docs;
        final totalAppointments = docs.length;
        final now = Timestamp.now();

        final upcoming = docs.where((d) {
          final data = d.data() as Map<String, dynamic>;
          final ts = data['date'] as Timestamp?;
          final status = (data['status'] ?? '').toString().toLowerCase();
          if (ts == null) return false;
          return ts.compareTo(now) > 0 && status != 'completed' && status != 'cancelled';
        }).toList();

        final patients = <String>{};
        for (var d in docs) {
          final pid = (d.data() as Map<String, dynamic>)['patientId']?.toString() ?? '';
          if (pid.isNotEmpty) patients.add(pid);
        }

        final upcomingSorted = List.from(upcoming);
        upcomingSorted.sort((a, b) {
          final da = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
          final db = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
          if (da == null || db == null) return 0;
          return da.compareTo(db);
        });

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row de indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard('Total citas', totalAppointments.toString(), Icons.calendar_today),
                _statCard('Citas próximas', upcoming.length.toString(), Icons.schedule),
                _statCard('Pacientes', patients.length.toString(), Icons.person),
              ],
            ),
            const SizedBox(height: 20),

            // Próximas citas
            _buildSectionTitle("Próximas citas", Colors.cyanAccent),
            const SizedBox(height: 10),
            for (var i = 0; i < (upcomingSorted.length < 5 ? upcomingSorted.length : 5); i++)
              _appointmentTile(upcomingSorted[i]),
            if (upcomingSorted.isEmpty)
              const Text('No hay citas próximas.', style: TextStyle(color: Colors.white70)),
          ],
        );
      },
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
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
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

  List<Widget> _buildSpecialists() {
    final list = ["Cardiólogo", "Dentista", "Pediatra", "Dermatólogo", "Nutriólogo"];
    return list
        .map((esp) => Container(
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1A1A2E), Color(0xFF23234B)],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 8)],
              ),
              child: ListTile(
                leading: const Icon(Icons.person, color: Colors.cyanAccent),
                title: Text(esp, style: const TextStyle(color: Colors.white)),
                trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
              ),
            ))
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
        label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildDoctorTile(String name, String specialty) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF2C2C54), Color(0xFF24243E)]),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.pinkAccent.withOpacity(0.4), blurRadius: 10)],
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

  Widget _statCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.white12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.cyanAccent),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _appointmentTile(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['date'] as Timestamp?;
    final dateStr = ts != null ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toDate()) : 'Sin fecha';
    final patientName = data['patientName'] ?? data['patientId'] ?? 'Paciente';
    final status = data['status'] ?? 'pendiente';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.white),
        title: Text(patientName, style: const TextStyle(color: Colors.white)),
        subtitle: Text('$dateStr • $status', style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          onPressed: () {},
        ),
      ),
    );
  }
}
