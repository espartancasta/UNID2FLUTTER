import 'package:flutter/material.dart';

class PrivacyPage extends StatelessWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text(
          'Privacy',
          style: TextStyle(
            color: Color(0xFFFF00FF),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A0A0A),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: const [
            Text(
              'Política de privacidad',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Esta aplicación ha sido desarrollada para gestionar citas médicas de forma '
              'segura y sencilla. Valoramos la privacidad de nuestros usuarios, por lo que '
              'el tratamiento de la información personal se realiza con el máximo cuidado.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '1. Datos que recopilamos',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Para poder ofrecer el servicio de gestión de citas médicas, la aplicación '
              'puede solicitar y almacenar los siguientes datos:\n\n'
              '• Datos de perfil: nombre completo, correo electrónico y número de teléfono.\n'
              '• Información de la cuenta: contraseña cifrada y configuración de la cuenta.\n'
              '• Historial de citas: fecha, hora, especialidad y médico asignado.\n'
              '• Datos técnicos: modelo de dispositivo, versión del sistema operativo y '
              'tokens de notificación para el envío de recordatorios.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '2. Uso de la información',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La información recolectada se utiliza exclusivamente para:\n\n'
              '• Crear y administrar su cuenta de usuario.\n'
              '• Permitir la reserva, consulta y cancelación de citas médicas.\n'
              '• Enviar recordatorios de citas y notificaciones importantes.\n'
              '• Mejorar el funcionamiento y la seguridad de la aplicación.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '3. Almacenamiento y protección de datos',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Los datos se almacenan en servicios en la nube con conexiones seguras. '
              'La contraseña del usuario nunca se guarda en texto plano y se aplican '
              'métodos de cifrado para proteger la información sensible.\n\n'
              'El acceso a los datos está limitado únicamente al personal autorizado de '
              'la institución o clínica responsable del sistema.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '4. Compartición de la información',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La información del usuario no se vende ni se comparte con terceros para fines '
              'publicitarios.\n\n'
              'Los datos relacionados con las citas sólo podrán ser consultados por el '
              'personal médico y administrativo de la clínica para brindar el servicio '
              'de atención correspondiente.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '5. Permisos y notificaciones',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'La aplicación puede solicitar permisos para mostrar notificaciones. Estas '
              'notificaciones se utilizan para recordar citas, informar cambios de horario '
              'o avisar sobre mensajes importantes relacionados con su atención médica.\n\n'
              'El usuario puede activar o desactivar las notificaciones desde el apartado '
              '“General” en la sección de ajustes.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '6. Derechos del usuario',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'El usuario puede:\n\n'
              '• Consultar los datos básicos de su perfil.\n'
              '• Modificar su información de contacto.\n'
              '• Solicitar la eliminación de su cuenta desde el área administrativa de la clínica.\n\n'
              'Al desinstalar la aplicación, se eliminan los datos locales del dispositivo, '
              'aunque parte de la información asociada a citas ya realizadas puede mantenerse '
              'en los registros de la clínica por motivos administrativos.',
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              '7. Cambios a esta política',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Cualquier cambio importante en esta política de privacidad será notificado a '
              'través de la propia aplicación o de los medios de contacto registrados.\n\n'
              'El uso continuo de la aplicación después de las actualizaciones implica la '
              'aceptación de las nuevas condiciones.',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}
