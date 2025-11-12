import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatelessWidget {
  const AppointmentDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de cita'),
        backgroundColor: Colors.blue,
      ),
      body: const Center(
        child: Text(
          'Aquí irá el detalle de la cita',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
