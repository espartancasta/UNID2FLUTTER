import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// PÁGINA DE PERFIL CON ESTILO NEÓN
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // FormKey y controladores
  final _form = GlobalKey<FormState>();
  final TextEditingController _name = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _birthPlace = TextEditingController();
  final TextEditingController _conditions = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _birthPlace.dispose();
    _conditions.dispose();
    super.dispose();
  }

  /// FUNCIÓN PARA GUARDAR EN FIREBASE
  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Debes iniciar sesión para guardar el perfil.')),
        );
      }
      return;
    }

    final userData = {
      'nombre_completo': _name.text.trim(),
      'edad': int.tryParse(_age.text.trim()) ?? 0,
      'lugar_nacimiento': _birthPlace.text.trim(),
      'padecimientos_alergias': _conditions.text.trim(),
      'ultima_actualizacion': FieldValue.serverTimestamp(),
    };

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(userData, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ ¡Perfil guardado en Firebase!'),
            duration: Duration(seconds: 2),
          ),
        );

        await Future.delayed(const Duration(milliseconds: 500));

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('❌ Error al guardar perfil: $e')));
      }
    }
  }

  /// Cargar datos al iniciar la pantalla
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        setState(() {
          _name.text = data['nombre_completo'] ?? '';
          _age.text = (data['edad'] ?? '').toString();
          _birthPlace.text = data['lugar_nacimiento'] ?? '';
          _conditions.text = data['padecimientos_alergias'] ?? '';
        });
      }
    } catch (e) {
      print('⚠ Error al cargar datos: $e');
    }
  }

  /// DISEÑO
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Perfil',
            style: TextStyle(
              color: Color(0xFFFF00FF),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF0A0A0A),
          elevation: 4,
        ),
        backgroundColor: const Color(0xFF0A0A0A),

        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                const SizedBox(height: 12),

                _buildField(
                  controller: _name,
                  label: 'Nombre completo',
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa nombre' : null,
                ),

                const SizedBox(height: 12),

                _buildField(
                  controller: _age,
                  label: 'Edad',
                  keyboard: TextInputType.number,
                  validator: (v) => v == null || v.isEmpty ? 'Ingresa edad' : null,
                ),

                const SizedBox(height: 12),

                _buildField(
                  controller: _birthPlace,
                  label: 'Lugar de nacimiento',
                ),

                const SizedBox(height: 12),

                _buildField(
                  controller: _conditions,
                  label: 'Padecimientos / Alergias',
                  maxLines: 3,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF00FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style:
                          TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// WIDGET PARA CAMPOS CON ESTILO NEÓN
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    TextInputType keyboard = TextInputType.text,
    FormFieldValidator<String>? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: _neonBorder(),
        enabledBorder: _neonBorder(),
        focusedBorder: _neonBorder(focus: true),
      ),
      validator: validator,
    );
  }

  /// Bordes neón
  OutlineInputBorder _neonBorder({bool focus = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(
        color: focus ? const Color(0xFFFF00FF) : const Color(0xFF00FFFF),
        width: focus ? 2 : 1,
      ),
    );
  }
}
