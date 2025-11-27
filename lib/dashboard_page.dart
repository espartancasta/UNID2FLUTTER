import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

// 👇 Importamos tu pantalla de citas con alias "ap"
import 'appointment_page.dart' as ap;

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // Helper para parsear la fecha venga como venga
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Tomamos todas las citas; para la tarea es suficiente
    final appointmentsQuery = FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('date', descending: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Médico',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF0A0A0A),
      body: StreamBuilder<QuerySnapshot>(
        stream: appointmentsQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;
          final totalAppointments = docs.length;

          final now = DateTime.now();

          // Próximas citas: fecha futura y no completed/cancelled
          final upcoming = docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final date = _parseDate(data['date']);
            final status = (data['status'] ?? '').toString().toLowerCase();
            if (date == null) return false;
            return date.isAfter(now) &&
                status != 'completed' &&
                status != 'cancelled';
          }).toList();

          // Pacientes únicos por patientId (si no tienes este campo se queda en 0 y no truena)
          final patients = <String>{};
          for (var d in docs) {
            final data = d.data() as Map<String, dynamic>;
            final pid = (data['patientId'] ?? '').toString();
            if (pid.isNotEmpty) patients.add(pid);
          }
          final totalPatients = patients.length;

          // Ordenamos las próximas citas por fecha
          final upcomingSorted = List<QueryDocumentSnapshot>.from(upcoming);
          upcomingSorted.sort((a, b) {
            final da = _parseDate(
                (a.data() as Map<String, dynamic>)['date']);
            final db = _parseDate(
                (b.data() as Map<String, dynamic>)['date']);
            if (da == null || db == null) return 0;
            return da.compareTo(db);
          });

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tarjetas de estadísticas
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _statCard('Total citas', totalAppointments.toString(),
                        Icons.calendar_today),
                    _statCard('Citas próximas', upcoming.length.toString(),
                        Icons.schedule),
                    _statCard('Pacientes', totalPatients.toString(),
                        Icons.person),
                  ],
                ),
                const SizedBox(height: 24),

                const Text(
                  'Próximas citas',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 12),

                if (upcomingSorted.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Text(
                        'No hay citas próximas.',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  )
                else
                  for (var i = 0;
                      i <
                          (upcomingSorted.length < 5
                              ? upcomingSorted.length
                              : 5);
                      i++)
                    _appointmentTile(context, upcomingSorted[i]),
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
          boxShadow: const [BoxShadow(color: Colors.white12, blurRadius: 8)],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.cyanAccent),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Tile de próxima cita: al tocar, abre AppointmentDetailPage
  // ----------------------------------------------------------
  Widget _appointmentTile(BuildContext context, QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final date = _parseDate(data['date']);
    final dateStr = date != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(date)
        : 'Sin fecha';

    // Campos de la cita
    final title = (data['title'] ?? 'Cita médica').toString();
    final doctor = (data['doctor'] ?? 'Médico').toString();
    final notes = (data['notes'] ?? '').toString();
    final status = (data['status'] ?? 'pending').toString();

    // Nombre que mostramos en la lista
    final displayName = data['patientName'] ?? data['patientId'] ?? 'Paciente';

    // Construimos el Appointment que usa tu AppointmentDetailPage
    final appt = ap.Appointment(
      id: doc.id,
      title: title,
      doctor: doctor,
      date: date ?? DateTime.now(),
      notes: notes,
      status: status,
    );

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF222233),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: const Icon(Icons.person, color: Colors.white),
        title: Text(
          displayName.toString(),
          style: const TextStyle(color: Colors.white),
        ),
        subtitle: Text(
          '$dateStr • $status',
          style: const TextStyle(color: Colors.white70),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ap.AppointmentDetailPage(appointment: appt),
            ),
          );
        },
      ),
    );
  }
}
