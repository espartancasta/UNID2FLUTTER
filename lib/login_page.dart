import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // 🔹 NUEVO
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _obscurePassword = true;

  /// ------------------------------
  /// FUNCIÓN PARA INICIAR SESIÓN
  /// ------------------------------
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomePage(user: cred.user)),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión";
      if (e.code == 'user-not-found') {
        message = "Usuario no encontrado. Verifica tu correo.";
      } else if (e.code == 'wrong-password') {
        message = "Contraseña incorrecta. Inténtalo de nuevo.";
      } else if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// ------------------------------
  /// FUNCIÓN PARA REGISTRAR CUENTA
  /// (con nombre y rol)
  /// ------------------------------
  Future<void> _register(String fullName, String role) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 🔹 Guardar usuario en Firestore con rol
      await FirebaseFirestore.instance
          .collection('users')
          .doc(cred.user!.uid)
          .set({
        'name': fullName,
        'email': _emailController.text.trim(),
        'role': role, // "paciente" o "medico"
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('✅ Cuenta creada correctamente. Ahora inicia sesión.'),
          backgroundColor: Colors.green,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = "Error al crear la cuenta";
      if (e.code == 'email-already-in-use') {
        message = "Este correo ya está registrado.";
      } else if (e.code == 'weak-password') {
        message = "La contraseña es muy débil. Usa otra más segura.";
      } else if (e.message != null) {
        message = e.message!;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// ------------------------------
  /// DIÁLOGO PARA PEDIR NOMBRE Y ROL
  /// ------------------------------
  Future<void> _openRegisterDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final nameController = TextEditingController();
    String? selectedRole;
    final regKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          title: const Text(
            'Crear cuenta',
            style: TextStyle(color: Colors.white),
          ),
          content: Form(
            key: regKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // NOMBRE COMPLETO
                TextFormField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _neonDecoration(
                    label: "Nombre completo",
                    icon: Icons.person,
                    iconColor: const Color(0xFFFF00FF),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Ingresa tu nombre'
                      : null,
                ),
                const SizedBox(height: 12),
                // ROL (PACIENTE / MÉDICO)
                DropdownButtonFormField<String>(
                  value: selectedRole,
                  dropdownColor: const Color(0xFF1A1A1A),
                  decoration: _neonDecoration(
                    label: "Rol",
                    icon: Icons.badge,
                    iconColor: const Color(0xFF00FFFF),
                  ),
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'paciente',
                      child: Text('Paciente'),
                    ),
                    DropdownMenuItem(
                      value: 'medico',
                      child: Text('Médico'),
                    ),
                  ],
                  onChanged: (value) {
                    selectedRole = value;
                  },
                  validator: (v) =>
                      v == null ? 'Selecciona un rol' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Color(0xFF00FFFF)),
              ),
            ),
            TextButton(
              onPressed: () {
                if (!regKey.currentState!.validate()) return;
                if (selectedRole == null) return;

                Navigator.pop(ctx, {
                  'name': nameController.text.trim(),
                  'role': selectedRole!,
                });
              },
              child: const Text(
                'Registrar',
                style: TextStyle(color: Color(0xFFFF00FF)),
              ),
            ),
          ],
        );
      },
    );

    if (result != null && result['name'] != null && result['role'] != null) {
      await _register(result['name']!, result['role']!);
    }
  }

  /// ------------------------------
  /// FUNCIÓN PARA ENTRAR COMO INVITADO
  /// ------------------------------
  void _loginAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage(user: null)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: const Color(0xFF1A1A1A),
            elevation: 10,
            shadowColor: const Color(0xFFFF00FF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(22),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.local_hospital_outlined,
                      color: Color(0xFF00FFFF),
                      size: 80,
                      shadows: [
                        Shadow(
                          color: Color(0xFFFF00FF),
                          blurRadius: 14,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Doctor Appointment',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFF00FF),
                        shadows: [
                          Shadow(
                            color: Color(0xFF00FFFF),
                            blurRadius: 14,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 26),

                    // EMAIL
                    TextFormField(
                      controller: _emailController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _neonDecoration(
                        label: "Correo electrónico",
                        icon: Icons.email,
                        iconColor: const Color(0xFF00FFFF),
                      ),
                      validator: (v) =>
                          v != null && v.contains('@')
                              ? null
                              : "Correo inválido",
                    ),
                    const SizedBox(height: 16),

                    // CONTRASEÑA
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      style: const TextStyle(color: Colors.white),
                      decoration: _neonDecoration(
                        label: "Contraseña",
                        icon: Icons.lock,
                        iconColor: const Color(0xFFFF00FF),
                        suffix: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white70,
                          ),
                          onPressed: () {
                            setState(
                                () => _obscurePassword = !_obscurePassword);
                          },
                        ),
                      ),
                      validator: (v) =>
                          v != null && v.length >= 6
                              ? null
                              : "Mínimo 6 caracteres",
                    ),
                    const SizedBox(height: 28),

                    // BOTÓN INICIAR SESIÓN
                    ElevatedButton(
                      onPressed: _loading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00FFFF),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(
                              color: Colors.black,
                            )
                          : const Text(
                              "Iniciar sesión",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0A0A0A),
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),

                    // BOTÓN REGISTRO (abre el diálogo de nombre + rol)
                    TextButton(
                      onPressed: _loading ? null : _openRegisterDialog,
                      child: const Text(
                        "Crear cuenta nueva",
                        style: TextStyle(
                          color: Color(0xFFFF00FF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // BOTÓN INVITADO
                    TextButton(
                      onPressed: _loading ? null : _loginAsGuest,
                      child: const Text(
                        "Entrar como invitado",
                        style: TextStyle(
                          color: Color(0xFF00FFFF),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // DECORACIÓN NEÓN
  InputDecoration _neonDecoration({
    required String label,
    required IconData icon,
    required Color iconColor,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF00FFFF)),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      prefixIcon: Icon(icon, color: iconColor),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF00FFFF)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide:
            const BorderSide(color: Color(0xFFFF00FF), width: 2),
      ),
    );
  }
}
