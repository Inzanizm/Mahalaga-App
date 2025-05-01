import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class HotlineScreen extends StatelessWidget {
  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Pet Doctor', 'phone': '+1234567890'},
    {'name': 'Services Provider', 'phone': '+1987654321'},
    {'name': 'I Dunno', 'phone': '+1029384756'},
  ];

  HotlineScreen({super.key});

  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982),
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B9982),
        title: const Text('Emergency Contacts'),
        leading: const BackButton(color: Colors.white),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: emergencyContacts.map((contact) {
          return Card(
            color: Colors.grey.shade600,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.greenAccent),
              title: Text(contact['name']!, style: const TextStyle(color: Colors.white)),
              subtitle: Text(contact['phone']!, style: const TextStyle(color: Colors.white70)),
              onTap: () => _makePhoneCall(contact['phone']!),
            ),
          );
        }).toList(),
      ),
    );
  }
}
