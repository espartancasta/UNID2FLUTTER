import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 🔹 MODELO DE CITA
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

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'doctor': doctor,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

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

/// 🔹 PÁGINA PRINCIPAL DE CITAS
class AppointmentPage extends StatefulWidget {
  const AppointmentPage({super.key});

  @override
  State<AppointmentPage> createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  final CollectionReference appointmentsRef =
      FirebaseFirestore.instance.collection('appointments');

  /// Método para forzar la recarga
  Future<void> _refreshAppointments() async {
    setState(() {}); // fuerza reconstrucción del StreamBuilder
    await Future.delayed(const Duration(milliseconds: 400));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('💫 Tus Citas Médicas'),
        backgroundColor: const Color(0xFF8A2BE2),
        elevation: 10,
        shadowColor: const Color(0xFFFF00FF),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: RefreshIndicator(
          onRefresh: _refreshAppointments, // 🔹 Gesto 1: recargar al deslizar
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
                  .map((doc) => Appointment.fromMap(
                      doc.id, doc.data() as Map<String, dynamic>))
                  .toList();

              return ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appt = appointments[index];
                  return _buildAppointmentCard(context, appt);
                },
              );
            },
          ),
        ),
      ),
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

  /// 🔹 Tarjeta visual con gestos integrados
  Widget _buildAppointmentCard(BuildContext context, Appointment appt) {
    return Dismissible(
      key: Key(appt.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) async {
        // 🔹 Gesto 2: deslizar para eliminar
        await FirebaseFirestore.instance
            .collection('appointments')
            .doc(appt.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${appt.title} eliminada')),
        );
      },
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        // 🔹 Gesto 3: detectar tap y long press
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AppointmentDetailPage(appointment: appt),
            ),
          );
        },
        onLongPress: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Has presionado largo en ${appt.title}')),
          );
        },
        child: Card(
          color: const Color(0xFF1A1A1A),
          margin: const EdgeInsets.only(bottom: 14),
          elevation: 6,
          shadowColor: const Color(0xFF00FFFF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          child: ListTile(
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
          ),
        ),
      ),
    );
  }
}

/// 🔹 FORMULARIO DE CREAR/EDITAR CITAS (igual que antes)
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
              _buildInputField(_titleController, 'Motivo'),
              _buildInputField(_doctorController, 'Médico'),
              _buildInputField(_notesController, 'Notas', maxLines: 2),
              const SizedBox(height: 20),

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
                      await appointmentsRef.add(Appointment(
                        id: '',
                        title: _titleController.text,
                        doctor: _doctorController.text,
                        date: finalDate,
                        notes: _notesController.text,
                      ).toMap());
                    } else {
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

  Widget _buildPickerTile(BuildContext context,
      {required IconData icon, required String label, required VoidCallback onTap}) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF00FFFF)),
      title: Text(label, style: const TextStyle(color: Colors.white70)),
      onTap: onTap,
    );
  }
}

/// 🔹 DETALLE DE CITA
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
          ],
        ),
      ),
    );
  }

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
