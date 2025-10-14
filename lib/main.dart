import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login Citas Médicas',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00FFFF), // azul neón
          secondary: Color(0xFFFF00FF), // magenta neón
          surface: Color(0xFF1A1A2E),
          error: Colors.redAccent,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFB0BEC5)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1F2235),
          labelStyle: const TextStyle(color: Colors.cyanAccent),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF00FFFF), width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFFF00FF), width: 2.0),
          ),
        ),
        snackBarTheme: const SnackBarThemeData(
          backgroundColor: Color(0xFF1F1B24),
          contentTextStyle: TextStyle(color: Colors.cyanAccent),
        ),
      ),
      home: LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _signIn() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomePage(user: userCredential.user!),
            ),
          );
        }
      } on FirebaseAuthException catch (e) {
        String message = "Ocurrió un error.";
        if (e.code == 'user-not-found') {
          message = "No se encontró un usuario con ese correo.";
        } else if (e.code == 'wrong-password') {
          message = "Contraseña incorrecta.";
        } else {
          message = e.message ?? "Error desconocido.";
        }
        _showErrorSnackbar(message);
      }
    }
  }

  Future<void> _createAccount() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );
        _showSuccessSnackbar("¡Cuenta creada con éxito! Por favor, inicia sesión.");
      } on FirebaseAuthException catch (e) {
        String message = "Ocurrió un error al crear la cuenta.";
        if (e.code == 'weak-password') {
          message = 'La contraseña es muy débil.';
        } else if (e.code == 'email-already-in-use') {
          message = 'El correo electrónico ya está en uso.';
        } else {
          message = e.message ?? "Error desconocido.";
        }
        _showErrorSnackbar(message);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (emailController.text.trim().isEmpty) {
      _showErrorSnackbar("Por favor, ingrese su correo para restablecer la contraseña.");
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: emailController.text.trim());
      _showSuccessSnackbar("Se ha enviado un enlace para restablecer la contraseña a su correo.");
    } on FirebaseAuthException catch (e) {
      _showErrorSnackbar(e.message ?? "No se pudo enviar el correo de restablecimiento.");
    }
  }

  void _showErrorSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.pinkAccent),
      );
    }
  }

  void _showSuccessSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.cyanAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.medical_services_outlined, size: 80, color: Colors.cyanAccent),
                  const SizedBox(height: 16),
                  const Text(
                    "Bienvenido de Nuevo",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent,
                      shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 10)],
                    ),
                  ),
                  const Text(
                    "Inicia sesión para agendar tu cita",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 40),

                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Correo Electrónico',
                      prefixIcon: Icon(Icons.email_outlined, color: Colors.cyanAccent),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese su correo electrónico';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Correo no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      prefixIcon: Icon(Icons.lock_outline, color: Colors.pinkAccent),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Por favor ingrese su contraseña";
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _resetPassword,
                      child: const Text('¿Olvidaste tu contraseña?',
                          style: TextStyle(color: Colors.pinkAccent)),
                    ),
                  ),
                  const SizedBox(height: 24),

                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.cyanAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      shadowColor: Colors.pinkAccent,
                      elevation: 8,
                    ),
                    child: const Text('Iniciar Sesión',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("¿No tienes una cuenta?"),
                      TextButton(
                        onPressed: _createAccount,
                        child: const Text('Crear una cuenta nueva',
                            style: TextStyle(
                              color: Colors.cyanAccent,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  final User user;
  const HomePage({super.key, required this.user});

  Future<void> _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      appBar: AppBar(
        title: const Text("Página Principal"),
        backgroundColor: Colors.cyanAccent,
        foregroundColor: Colors.black,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("¡Bienvenido!",
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.cyanAccent,
                    shadows: [Shadow(color: Colors.pinkAccent, blurRadius: 10)])),
            const SizedBox(height: 8),
            Text(user.email ?? "Usuario", style: const TextStyle(fontSize: 18, color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _signOut(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Cerrar Sesión'),
            ),
          ],
        ),
      ),
    );
  }
}
