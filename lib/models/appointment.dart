// lib/models/appointment.dart

import 'package:cloud_firestore/cloud_firestore.dart'; // <- necesario para Timestamp
// Si no usas Firestore en todo el proyecto, puedes quitar esto y usar la rama alternativa del factory.

class Appointment {
  final String id;
  final String title;
  final String description;
  final DateTime date;

  Appointment({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
  });

  // Factory que parsea distintos tipos que podrías tener en Firestore
  factory Appointment.fromMap(String id, Map<String, dynamic> data) {
    final dynamic dateValue = data['date'];

    DateTime parsedDate;

    if (dateValue == null) {
      parsedDate = DateTime.now();
    } else if (dateValue is Timestamp) {
      // Fecha guardada como Timestamp de Cloud Firestore
      parsedDate = dateValue.toDate();
    } else if (dateValue is DateTime) {
      // Si ya es DateTime
      parsedDate = dateValue;
    } else if (dateValue is int) {
      // Si guardaste un timestamp en milisegundos
      parsedDate = DateTime.fromMillisecondsSinceEpoch(dateValue);
    } else if (dateValue is String) {
      // Si guardaste ISO string
      parsedDate = DateTime.tryParse(dateValue) ?? DateTime.now();
    } else {
      // Fallback seguro
      parsedDate = DateTime.now();
    }

    return Appointment(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      date: parsedDate,
    );
  }

  // Guardar en Firestore usando Timestamp para consistencia
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
    };
  }
}
