import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final uid = FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    if (uid == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dashboard')),
        body: const Center(child: Text('Debes iniciar sesión')),
      );
    }

    final appointmentsQuery = FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: uid)
        .orderBy('date', descending: false); // asume campo 'date' tipo Timestamp

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Médico'),
        backgroundColor: const Color(0xFF0A0A0A),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final totalAppointments = docs.length;

          final now = Timestamp.now();
          // próximas: fecha > ahora (future) y status != 'completed' (ajusta status según tu modelo)
          final upcoming = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final ts = data['date'] as Timestamp?;
            final status = (data['status'] ?? '').toString().toLowerCase();
            if (ts == null) return false;
            return ts.compareTo(now) > 0 && status != 'completed' && status != 'cancelled';
          }).toList();

          // pacientes únicos
          final patients = <String>{};
          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final pid = (data['patientId'] ?? '').toString();
            if (pid.isNotEmpty) patients.add(pid);
          }
          final totalPatients = patients.length;

          // tomamos las próximas 3 citas para mostrar
          final upcomingSorted = List.from(upcoming);
          upcomingSorted.sort((a, b) {
            final da = (a.data() as Map<String, dynamic>)['date'] as Timestamp?;
            final db = (b.data() as Map<String, dynamic>)['date'] as Timestamp?;
            if (da == null || db == null) return 0;
            return da.compareTo(db);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Row de indicadores
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Total citas', totalAppointments.toString(), Icons.calendar_today),
                    _statCard('Citas próximas', upcoming.length.toString(), Icons.schedule),
                    _statCard('Pacientes', totalPatients.toString(), Icons.person),
                  ],
                ),
                const SizedBox(height: 20),

                // Lista de próximas citas
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Próximas citas',
                      style: TextStyle(color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 10),
                for (var i = 0; i < (upcomingSorted.length < 5 ? upcomingSorted.length : 5); i++)
                  _appointmentTile(upcomingSorted[i]),
                if (upcomingSorted.isEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    child: const Text('No hay citas próximas.', style: TextStyle(color: Colors.white70)),
                  ),
              ],
            ),
          );
        },
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
        subtitle: Text('$dateStr • ${status.toString()}', style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
          onPressed: () {
            // Aquí podrías navegar a una página de detalles de cita
          },
        ),
      ),
    );
  }
}
