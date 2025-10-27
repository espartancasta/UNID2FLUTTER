import 'package:flutter/material.dart';
// IMPORTACIONES DE FIREBASE AGREGADAS/CONFIRMADAS
import 'package:cloud_firestore/cloud_firestore.dart'; 
import 'package:firebase_auth/firebase_auth.dart'; 

/// PÁGINA DE PERFIL CON ESTILO NEÓN
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Controladores y FormKey
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

  /// **FUNCIÓN CORREGIDA** para guardar datos en Firebase Firestore y manejar la navegación.
  Future<void> _save() async {
    // 1. Validar el formulario
    if (!_form.currentState!.validate()) {
      return;
    }

    // 2. Obtener el ID del usuario autenticado
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error: Debes iniciar sesión para guardar el perfil.')),
         );
      }
      return;
    }

    // 3. Crear el objeto de datos (Map) a guardar
    final userData = {
      'nombre_completo': _name.text.trim(),
      'edad': int.tryParse(_age.text.trim()) ?? 0, 
      'lugar_nacimiento': _birthPlace.text.trim(),
      'padecimientos_alergias': _conditions.text.trim(),
      'ultima_actualizacion': FieldValue.serverTimestamp(), 
    };

    // 4. Enviar los datos a Cloud Firestore
    try {
      await FirebaseFirestore.instance
          .collection('users') // Colección 'users'
          .doc(user.uid) // Documento con el UID del usuario
          .set(
            userData,
            SetOptions(merge: true), 
          );

      // 5. Manejar el éxito y la navegación de forma segura:
      if (mounted) {
        // Mostrar mensaje de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ ¡Perfil guardado en Firebase!'), duration: Duration(seconds: 2)),
        );

        // **PASO CLAVE:** Esperar un poco para que el SnackBar se muestre y la operación se asiente.
        await Future.delayed(const Duration(milliseconds: 500));
        
        // **CORRECCIÓN DEL BUG:** Verificar si hay una pantalla a la cual volver.
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context); 
        } 
      }
    } catch (e) {
      // 6. Manejar el error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Error al guardar perfil: $e')),
        );
      }
    }
  }
  
  // Opcional: Cargar los datos existentes al iniciar la pantalla.
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
      print('Error al cargar datos: $e');
    }
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        // AppBar con neón (sin cambios)
        appBar: AppBar(
          title: const Text(
            'Perfil',
            style: TextStyle(
              color: Color(0xFFFF00FF), // Título fucsia neón
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF0A0A0A), // Fondo negro
          elevation: 4,
        ),
        backgroundColor: const Color(0xFF0A0A0A), // Fondo general negro
        body: Padding(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                const SizedBox(height: 12),

                // Campo Nombre
                TextFormField(
                  controller: _name,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa nombre' : null,
                ),

                const SizedBox(height: 12),

                // Campo Edad
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa edad' : null,
                ),

                const SizedBox(height: 12),

                // Campo Lugar de nacimiento
                TextFormField(
                  controller: _birthPlace,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Lugar de nacimiento',
                    labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Campo Padecimientos / Alergias
                TextFormField(
                  controller: _conditions,
                  maxLines: 3,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Padecimientos / Alergias',
                    labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
                    filled: true,
                    fillColor: const Color(0xFF1A1A1A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFF00FFFF)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Botón Guardar
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save, // Llama a la función corregida _save()
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF00FF), // Fucsia neón
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Guardar',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
}