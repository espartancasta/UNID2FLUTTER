import 'package:flutter/material.dart';

class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              '📅 Tus Citas Médicas',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333366),
              ),
            ),
            const SizedBox(height: 20),
            _buildAppointmentCard(
              'Consulta General',
              'Dr. Juan Pérez',
              'Martes, 22 de Octubre • 10:00 AM',
              Icons.local_hospital,
              Colors.indigo,
            ),
            const SizedBox(height: 10),
            _buildAppointmentCard(
              'Odontología',
              'Dra. María López',
              'Jueves, 24 de Octubre • 3:00 PM',
              Icons.medical_services,
              Colors.deepPurple,
            ),
            const SizedBox(height: 10),
            _buildAppointmentCard(
              'Psicología',
              'Lic. Ana Gómez',
              'Viernes, 25 de Octubre • 12:00 PM',
              Icons.psychology,
              Colors.pink,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentCard(
      String title, String doctor, String date, IconData icon, Color color) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$doctor\n$date'),
        isThreeLine: true,
        trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400),
      ),
    );
  }
}
