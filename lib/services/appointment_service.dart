import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/appointment.dart';

class AppointmentService {
  final CollectionReference appointmentsRef =
      FirebaseFirestore.instance.collection('appointments');

  // CREATE
  Future<void> addAppointment(Appointment appointment) async {
    await appointmentsRef.add(appointment.toMap());
  }

  // READ (Stream para que la UI se actualice sola)
  Stream<List<Appointment>> getAppointments() {
    return appointmentsRef.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return Appointment.fromMap(doc.id, doc.data() as Map<String, dynamic>);
      }).toList();
    });
  }

  // UPDATE
  Future<void> updateAppointment(Appointment appointment) async {
    await appointmentsRef.doc(appointment.id).update(appointment.toMap());
  }

  // DELETE
  Future<void> deleteAppointment(String id) async {
    await appointmentsRef.doc(id).delete();
  }
}
