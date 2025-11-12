import 'package:flutter/material.dart';

/// PÁGINA DE TIPS CON ESTILO NEÓN Y BOTÓN DE REGRESAR
class TipsPage extends StatelessWidget {
  const TipsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Lista de tips con título y descripción
    final List<Map<String, String>> tips = [
      {
        'title': 'Mantente hidratado 💧',
        'desc':
            'Bebe al menos 8 vasos de agua al día para mantener tu cuerpo activo y saludable.'
      },
      {
        'title': 'Haz ejercicio 🏃‍♂️',
        'desc':
            'Dedica al menos 30 minutos diarios a caminar, correr o realizar actividad física.'
      },
      {
        'title': 'Duerme bien 😴',
        'desc':
            'Procura dormir entre 7 y 8 horas para recuperar energía y mejorar tu concentración.'
      },
      {
        'title': 'Come saludable 🥗',
        'desc':
            'Incluye frutas, verduras y proteínas en tu dieta. Evita el exceso de azúcares.'
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Fondo negro para neón
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 0,
        title: const Text(
          'Health Tips',
          style: TextStyle(
              color: Color(0xFFFF00FF), fontWeight: FontWeight.bold), // Título fucsia neón
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF00FFFF)), // Flecha turquesa neón
          onPressed: () => Navigator.pop(context), // Botón de regresar
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: tips.length,
        itemBuilder: (context, index) {
          final tip = tips[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.only(bottom: 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: const Color(0xFF1A1A1A), // Fondo oscuro de la tarjeta
            child: ListTile(
              // Icono estilo neón
              leading: const Icon(Icons.favorite, color: Color(0xFFFF00FF)),
              title: Text(
                tip['title']!,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00FFFF)), // Título turquesa neón
              ),
              subtitle: Text(
                tip['desc']!,
                style: const TextStyle(color: Colors.white), // Texto blanco
              ),
              // Efecto al tocar (opcional)
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Tip: ${tip['title']}'),
                  backgroundColor: const Color(0xFFFF00FF),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
