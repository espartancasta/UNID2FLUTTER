import 'package:flutter/material.dart';

class MessagesPage extends StatelessWidget {
  const MessagesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Messages')),
        body: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Buscar',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: 7,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, i) {
                    return ListTile(
                      leading: const CircleAvatar(backgroundImage: AssetImage('assets/images/doctor.png')),
                      title: const Text('Doctor Name'),
                      subtitle: const Text('Hola, ¿estás disponible?'),
                      trailing: const Text('12:30', style: TextStyle(color: Colors.grey)),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abrir chat (no implementado)')));
                      },
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
