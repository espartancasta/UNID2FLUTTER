import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'About Us',
          style: TextStyle(
            color: Color(0xFFFF00FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Sobre la aplicación',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Esta aplicación forma parte de un sistema de gestión de citas médicas diseñado '
              'para clínicas y consultorios que desean ofrecer a sus pacientes una forma más '
              'rápida y organizada de agendar sus consultas.\n\n'
              'Desde la app, los pacientes pueden revisar sus próximas citas, consultar '
              'información básica de su médico y recibir recordatorios para evitar olvidos.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Objetivo',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'El objetivo principal es reducir tiempos de espera y mejorar la comunicación '
              'entre pacientes y personal médico. Al centralizar la información de las citas '
              'en una sola plataforma, se facilita la organización diaria de la clínica y se '
              'ofrece una mejor experiencia al paciente.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Características principales',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• Registro y autenticación de pacientes.\n'
              '• Listado de próximas citas con fecha, hora y especialidad.\n'
              '• Historial básico de citas realizadas.\n'
              '• Recordatorios mediante notificaciones.\n'
              '• Sección de consejos y recomendaciones generales de salud.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Tecnologías utilizadas',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La aplicación móvil está desarrollada con Flutter, lo que permite ejecutarla '
              'en dispositivos Android (y potencialmente iOS) con una sola base de código.\n\n'
              'Para la autenticación y el almacenamiento de datos en la nube se emplean '
              'servicios como Firebase, mientras que el panel administrativo de la clínica '
              'puede estar implementado con tecnologías web como Laravel y PostgreSQL.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Equipo de desarrollo',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'El proyecto fue desarrollado como parte de un plan de formación en desarrollo '
              'de software, integrando buenas prácticas de programación, diseño de interfaces '
              'y uso de servicios en la nube.\n\n'
              'Desarrollador responsable: Dear Programmer.\n'
              'Rol: Desarrollador Full-Stack / Mobile.\n',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              'Contacto',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Para dudas, sugerencias o reportes relacionados con el funcionamiento de la '
              'aplicación, puede ponerse en contacto con el área de soporte de la clínica o '
              'con el administrador del sistema.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
