// lib/services/graphics_page.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class GraphicsPage extends StatefulWidget {
  const GraphicsPage({super.key});

  @override
  State<GraphicsPage> createState() => _GraphicsPageState();
}

class _GraphicsPageState extends State<GraphicsPage> {
  /// --------------------------------------------
  /// Helper para parsear fechas desde Firestore
  /// --------------------------------------------
  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  /// --------------------------------------------
  /// Citas por mes (para BarChart)
  /// --------------------------------------------
  Future<Map<String, int>> _getAppointmentsPerMonth() async {
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .orderBy('date')
        .get();

    final Map<String, int> monthly = {};

    for (var doc in query.docs) {
      final data = doc.data();
      final date = _parseDate(data['date']);
      if (date == null) continue;

      // ej. "oct 2025"
      final key = DateFormat('MMM yyyy', 'es').format(date);

      monthly[key] = (monthly[key] ?? 0) + 1;
    }

    return monthly;
  }

  /// --------------------------------------------
  /// Citas COMPLETED vs PENDING (para PieChart)
  /// --------------------------------------------
  Future<Map<String, int>> _getStatusCount() async {
    final query =
        await FirebaseFirestore.instance.collection('appointments').get();

    int completed = 0;
    int pending = 0;

    for (var doc in query.docs) {
      final data = doc.data();
      final status = (data['status'] ?? 'pending').toString().toLowerCase();

      if (status == 'completed') completed++;
      if (status == 'pending') pending++;
    }

    return {
      "Completadas": completed,
      "Pendientes": pending,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          "Gráficas de Citas",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ------------------------------------
            // 📊 GRÁFICA DE BARRAS: CITAS POR MES
            // ------------------------------------
            _buildSectionTitle("Citas por Mes"),
            const SizedBox(height: 8),
            SizedBox(
              height: 260,
              child: Row(
                children: [
                  // Etiqueta vertical (eje Y)
                  const RotatedBox(
                    quarterTurns: 3,
                    child: Text(
                      "Número de citas",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FutureBuilder<Map<String, int>>(
                      future: _getAppointmentsPerMonth(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        if (!snapshot.hasData ||
                            snapshot.data!.entries.isEmpty) {
                          return const Center(
                            child: Text(
                              "No hay datos de citas por mes.",
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                          );
                        }

                        final data = snapshot.data!;
                        final labels = data.keys.toList();
                        final values = data.values.toList();

                        return BarChart(
                          BarChartData(
                            borderData: FlBorderData(show: false),
                            barGroups: List.generate(labels.length, (i) {
                              return BarChartGroupData(
                                x: i,
                                barRods: [
                                  BarChartRodData(
                                    toY: values[i].toDouble(),
                                    width: 18,
                                    borderRadius: BorderRadius.circular(6),
                                    // color se hereda del tema de fl_chart, no es obligatorio
                                  ),
                                ],
                              );
                            }),
                            gridData: FlGridData(
                              show: true,
                              drawVerticalLine: false,
                              getDrawingHorizontalLine: (value) =>
                                  FlLine(color: Colors.white12, strokeWidth: 0.5),
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 36,
                                  getTitlesWidget: (value, meta) {
                                    final index = value.toInt();
                                    if (index < 0 || index >= labels.length) {
                                      return const SizedBox();
                                    }
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        labels[index],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 9,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 28,
                                  getTitlesWidget: (value, meta) {
                                    if (value % 1 != 0) {
                                      return const SizedBox.shrink();
                                    }
                                    return Text(
                                      value.toInt().toString(),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 9,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles:
                                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            const Align(
              alignment: Alignment.center,
              child: Text(
                "Mes",
                style: TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),

            const SizedBox(height: 32),

            // --------------------------------------------
            // 🥧 GRÁFICA DE PASTEL: COMPLETADAS VS PENDIENTES
            // --------------------------------------------
            _buildSectionTitle("Citas Completadas vs Pendientes"),
            const SizedBox(height: 8),
            FutureBuilder<Map<String, int>>(
              future: _getStatusCount(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (!snapshot.hasData) {
                  return const Text(
                    "No hay datos para generar la gráfica.",
                    style: TextStyle(color: Colors.white70),
                  );
                }

                final data = snapshot.data!;
                final completed = data["Completadas"]!.toDouble();
                final pending = data["Pendientes"]!.toDouble();
                final total = completed + pending;

                if (total == 0) {
                  return const Text(
                    "No hay citas registradas aún.",
                    style: TextStyle(color: Colors.white70),
                  );
                }

                return Column(
                  children: [
                    SizedBox(
                      height: 230,
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                          sections: [
                            PieChartSectionData(
                              color: Colors.greenAccent,
                              value: completed,
                              title:
                                  "${((completed / total) * 100).toInt()}%",
                              radius: 90,
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            PieChartSectionData(
                              color: Colors.cyanAccent,
                              value: pending,
                              title:
                                  "${((pending / total) * 100).toInt()}%",
                              radius: 90,
                              titleStyle: const TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Leyenda
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendDot(Colors.greenAccent, "Completadas"),
                        const SizedBox(width: 16),
                        _buildLegendDot(Colors.cyanAccent, "Pendientes"),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --------------------------------------------
  // Widgets auxiliares
  // --------------------------------------------
  Widget _buildSectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.cyanAccent,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
