import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'messages_page.dart';
import 'Settings_page.dart';
import 'profile_page.dart';

class HomePage extends StatefulWidget {
  final User? user;
  const HomePage({super.key, this.user});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // Páginas para la BottomNavigationBar
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeView(user: widget.user),
      const MessagesPage(),
      SettingsPage(onLogout: _handleLogout),
    ];
  }

  void _onTap(int idx) => setState(() => _selectedIndex = idx);

  void _handleLogout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // cada página maneja su propio AppBar / SafeArea
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.message_outlined), label: 'Mensajes'),
          BottomNavigationBarItem(icon: Icon(Icons.settings_outlined), label: 'Configuración'),
        ],
      ),
    );
  }
}

class HomeView extends StatelessWidget {
  final User? user;
  const HomeView({super.key, this.user});

  final List<String> specialists = const [
    'Cardiólogo',
    'Pediatra',
    'Dermatólogo',
    'Ginecólogo',
    'Nutriólogo',
  ];

  @override
  Widget build(BuildContext context) {
    final displayName = user?.email?.split('@').first ?? 'Alex';
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Home', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: CircleAvatar(
                backgroundImage: AssetImage('assets/images/doctor.png'),
              ),
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('¡Hola, $displayName!', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text('¿En qué podemos ayudarte?', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 18),

              // Opciones: Agendar / Consejos
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: _actionCard(
                      context,
                      icon: Icons.calendar_month_outlined,
                      title: 'Agendar una Cita',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ir a Agendar (no implementado)')));
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _actionCard(
                      context,
                      icon: Icons.medical_services_outlined,
                      title: 'Consejos Médicos',
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Consejos médicos (no implementado)')));
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Text('Especialistas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),

              // Lista de especialistas (horizontal)
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: specialists.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) {
                    return _specialistCard(specialists[i]);
                  },
                ),
              ),

              const SizedBox(height: 18),
              const Text('Doctores Populares', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),

              // Grid de doctores
              Expanded(
                child: GridView.builder(
                  itemCount: 4,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.88,
                  ),
                  itemBuilder: (context, idx) {
                    return _doctorCard(context, 'Dr. Nombre $idx', 'Especialidad');
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionCard(BuildContext ctx, {required IconData icon, required String title, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            CircleAvatar(radius: 22, backgroundColor: const Color(0xFF6C63FF), child: Icon(icon, color: Colors.white)),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _specialistCard(String name) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 26, backgroundImage: AssetImage('assets/images/doctor.png')),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _doctorCard(BuildContext context, String name, String specialty) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(radius: 30, backgroundImage: AssetImage('assets/images/doctor.png')),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(specialty, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
