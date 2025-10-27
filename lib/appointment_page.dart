import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 MODELO DE CITA (Define la estructura de los datos)
class Appointment {
  String id;
  String title;
  String doctor;
  DateTime date;
  String notes;

  Appointment({
    required this.id,
    required this.title,
    required this.doctor,
    required this.date,
    required this.notes,
  });

  /// Convierte el objeto Appointment a un mapa para guardarlo en Firebase
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'doctor': doctor,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  /// Crea una instancia de Appointment a partir de un mapa (datos de Firestore)
  factory Appointment.fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      title: map['title'] ?? '',
      doctor: map['doctor'] ?? '',
      date: DateTime.parse(map['date']),
      notes: map['notes'] ?? '',
    );
  }
}

/// 🔹 PÁGINA PRINCIPAL DE CITAS (READ - Lista)
class AppointmentPage extends StatelessWidget {
  const AppointmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    final CollectionReference appointmentsRef =
        FirebaseFirestore.instance.collection('appointments');

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // Fondo negro para resaltar los neones
      appBar: AppBar(
        title: const Text('💫 Tus Citas Médicas'),
        backgroundColor: const Color(0xFF8A2BE2), // Morado neón
        elevation: 10,
        shadowColor: const Color(0xFFFF00FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: StreamBuilder<QuerySnapshot>(
          stream: appointmentsRef.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00FFFF)));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  '⚡ No tienes citas agendadas.',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              );
            }

            final appointments = snapshot.data!.docs
                .map((doc) =>
                    Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>))
                .toList();

            return ListView.builder(
              itemCount: appointments.length,
              itemBuilder: (context, index) {
                final appt = appointments[index];
                return _buildAppointmentCard(context, appt, appointmentsRef);
              },
            );
          },
        ),
      ),

      /// Botón flotante de agregar cita
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF00FFFF),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEditAppointmentPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  /// 🔹 Tarjeta visual para mostrar cada cita
  Widget _buildAppointmentCard(
      BuildContext context, Appointment appt, CollectionReference appointmentsRef) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 6,
      shadowColor: const Color(0xFF00FFFF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ListTile(
        onTap: () {
          // Navegar al detalle de la cita
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailPage(appointment: appt),
            ),
          );
        },
        leading: const CircleAvatar(
          backgroundColor: Color(0xFF8A2BE2),
          child: Icon(Icons.local_hospital, color: Colors.white),
        ),
        title: Text(
          appt.title,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFFFF00FF)),
        ),
        subtitle: Text(
          '${appt.doctor}\n${appt.date.day}/${appt.date.month}/${appt.date.year} • ${appt.date.hour}:${appt.date.minute.toString().padLeft(2, '0')}',
          style: const TextStyle(color: Colors.white70),
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// Botón editar (UPDATE)
            IconButton(
              icon: const Icon(Icons.edit, color: Color(0xFF00FFFF)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateEditAppointmentPage(appointment: appt),
                  ),
                );
              },
            ),

            /// Botón eliminar (DELETE)
            IconButton(
              icon: const Icon(Icons.delete, color: Color(0xFFFF007F)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: const Color(0xFF1E1E1E),
                    title: const Text('Eliminar cita',
                        style: TextStyle(color: Colors.white)),
                    content: const Text(
                      '¿Estás seguro que quieres eliminar esta cita?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancelar',
                            style: TextStyle(color: Color(0xFF00FFFF))),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Eliminar',
                            style: TextStyle(color: Color(0xFFFF007F))),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  await appointmentsRef.doc(appt.id).delete();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 🔹 FORMULARIO PARA CREAR O EDITAR CITAS
class CreateEditAppointmentPage extends StatefulWidget {
  final Appointment? appointment;
  const CreateEditAppointmentPage({this.appointment, super.key});

  @override
  State<CreateEditAppointmentPage> createState() =>
      _CreateEditAppointmentPageState();
}

class _CreateEditAppointmentPageState extends State<CreateEditAppointmentPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _doctorController;
  late TextEditingController _notesController;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.appointment?.title ?? '');
    _doctorController =
        TextEditingController(text: widget.appointment?.doctor ?? '');
    _notesController = TextEditingController(text: widget.appointment?.notes ?? '');
    _selectedDate = widget.appointment?.date;
    _selectedTime = widget.appointment != null
        ? TimeOfDay(
            hour: widget.appointment!.date.hour,
            minute: widget.appointment!.date.minute)
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final CollectionReference appointmentsRef =
        FirebaseFirestore.instance.collection('appointments');

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        title: Text(widget.appointment == null ? 'Nueva Cita' : 'Editar Cita'),
        backgroundColor: const Color(0xFF8A2BE2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              /// Campos de texto
              _buildInputField(_titleController, 'Motivo'),
              _buildInputField(_doctorController, 'Médico'),
              _buildInputField(_notesController, 'Notas', maxLines: 2),

              const SizedBox(height: 20),

              /// Selector de fecha
              _buildPickerTile(
                context,
                icon: Icons.calendar_today,
                label: _selectedDate == null
                    ? 'Selecciona fecha'
                    : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
              ),

              /// Selector de hora
              _buildPickerTile(
                context,
                icon: Icons.access_time,
                label: _selectedTime == null
                    ? 'Selecciona hora'
                    : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
                onTap: () async {
                  TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime:
                        _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) setState(() => _selectedTime = picked);
                },
              ),

              const SizedBox(height: 30),

              /// Botón Guardar/Actualizar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFFF),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate() &&
                      _selectedDate != null &&
                      _selectedTime != null) {
                    DateTime finalDate = DateTime(
                      _selectedDate!.year,
                      _selectedDate!.month,
                      _selectedDate!.day,
                      _selectedTime!.hour,
                      _selectedTime!.minute,
                    );

                    if (widget.appointment == null) {
                      // Crear nueva cita
                      await appointmentsRef.add(Appointment(
                        id: '',
                        title: _titleController.text,
                        doctor: _doctorController.text,
                        date: finalDate,
                        notes: _notesController.text,
                      ).toMap());
                    } else {
                      // Actualizar cita existente
                      await appointmentsRef.doc(widget.appointment!.id).update(
                            Appointment(
                              id: widget.appointment!.id,
                              title: _titleController.text,
                              doctor: _doctorController.text,
                              date: finalDate,
                              notes: _notesController.text,
                            ).toMap(),
                          );
                    }
                    Navigator.pop(context);
                  }
                },
                child: Text(widget.appointment == null ? 'Guardar' : 'Actualizar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para campos de texto con estilo neón
  Widget _buildInputField(TextEditingController controller, String label,
      {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFFFF00FF)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00FFFF)),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFFF00FF), width: 2),
        ),
      ),
      validator: (value) => value == null || value.isEmpty ? 'Obligatorio' : null,
    );
  }

  /// Widget auxiliar para los selectores de fecha/hora
  Widget _buildPickerTile(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFFF)),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }
}

/// 🔹 DETALLE DE CITA (READ - Detallado)
class AppointmentDetailPage extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailPage({required this.appointment, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('🔍 Detalle de Cita'),
        backgroundColor: const Color(0xFF8A2BE2),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.title,
                style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF00FF))),
            const Divider(color: Color(0xFF00FFFF)),

            _buildDetailRow(Icons.person, 'Médico', appointment.doctor),
            _buildDetailRow(Icons.calendar_today, 'Fecha',
                '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'),
            _buildDetailRow(Icons.access_time, 'Hora',
                '${appointment.date.hour}:${appointment.date.minute.toString().padLeft(2, '0')}'),
            _buildDetailRow(Icons.notes, 'Notas',
                appointment.notes.isEmpty ? 'Ninguna' : appointment.notes),

            const SizedBox(height: 30),

            /// Botón para editar desde el detalle
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            CreateEditAppointmentPage(appointment: appointment)),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.black),
                label: const Text('Editar Cita'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00FFFF),
                  foregroundColor: Colors.black,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Componente visual para mostrar información detallada
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF00FF), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.white70)),
              const SizedBox(height: 2),
              SizedBox(
                width: 300,
                child: Text(value,
                    style:
                        const TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
