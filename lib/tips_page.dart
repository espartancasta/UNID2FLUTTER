import 'package:flutter/material.dart';

class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> tips = [
      {
        'title': 'Mantente hidratado 💧',
        'desc': 'Bebe al menos 8 vasos de agua al día para mantener tu cuerpo activo y saludable.'
      },
      {
        'title': 'Haz ejercicio 🏃‍♂️',
        'desc': 'Dedica al menos 30 minutos diarios a caminar, correr o realizar actividad física.'
      },
      {
        'title': 'Duerme bien 😴',
        'desc': 'Procura dormir entre 7 y 8 horas para recuperar energía y mejorar tu concentración.'
      },
      {
        'title': 'Come saludable 🥗',
        'desc': 'Incluye frutas, verduras y proteínas en tu dieta. Evita el exceso de azúcares.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            elevation: 2,
            margin: const EdgeInsets.only(bottom: 15),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              title: Text(
                tip['title']!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(tip['desc']!),
              leading: const Icon(Icons.favorite, color: Color(0xFF6C63FF)),
            ),
          );
        },
      ),
    );
  }
}
