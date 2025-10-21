import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
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

  void _save() {
    if (!_form.currentState!.validate()) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Información guardada (simulado).')),
    );
    Navigator.pop(context); // volver a Settings
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Perfil')),
        body: Padding(
          padding: const EdgeInsets.all(14),
          child: Form(
            key: _form,
            child: ListView(
              children: [
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Nombre completo'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa nombre' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _age,
                  decoration: const InputDecoration(labelText: 'Edad'),
                  keyboardType: TextInputType.number,
                  validator: (v) => (v == null || v.isEmpty) ? 'Ingresa edad' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _birthPlace,
                  decoration: const InputDecoration(labelText: 'Lugar de nacimiento'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _conditions,
                  decoration: const InputDecoration(labelText: 'Padecimientos / Alergias'),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C63FF)),
                    child: const Text('Guardar'),
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
