import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// this screen shows a list of emergency contact numbers na pwede i-call agad
class HotlineScreen extends StatelessWidget {
  // list of emergency contacts — pwedeng dagdagan if may local contacts kayo
  final List<Map<String, String>> emergencyContacts = [
    {'name': 'Vets In Practice', 'phone': '(02) 8531-1581'},
    {'name': 'Bureau of Animal Industry (BAI) Hotline', 'phone': '(02) 926-1522'},
    {'name': 'Batangas City Veterinary Office', 'phone': '(043) 984-7918'},
    {'name': 'Santa Rosa City Agriculture and Veterinary Office', 'phone': '(049) 8371-1363'},
    {'name': 'Antipolo City Veterinary Services', 'phone': '(02) 8683-8837'},
  ];

  HotlineScreen({super.key});

  // THIS FUNCTION TRIGGERS THE PHONE DIALER
  // pogi ni kyme pero focus muna sa logic ok
  void _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      // this throws an error if something goes wrong sa dial
      throw 'Could not launch $phoneNumber';
    }
  }

  // this shows a popup asking if sure ka na tatawag ka — para iwas mistaken call
  void _showCallConfirmationDialog(BuildContext context, String name, String phoneNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF6B705C),
        title: const Text(
          'Call Contact',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Do you want to call $name at $phoneNumber?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // close the dialog if nag-cancel
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // CLOSES THE DIALOG BOX
              _makePhoneCall(phoneNumber); // ACTUAL CALL TRIGGERED HERE
              // im gay (also: confirm button logic ends here)
            },
            child: const Text('Call', style: TextStyle(color: Colors.greenAccent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9B9982), // background matches app theme (earthy-ish)
      appBar: AppBar(
        backgroundColor: const Color(0xFF9B9982),
        title: const Text('Emergency Contacts', style: TextStyle(color: Colors.white)),
        leading: const BackButton(color: Colors.white), // THIS GOES BACK TO PREVIOUS SCREEN
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: emergencyContacts.map((contact) {
          return Card(
            color: Colors.grey.shade600, // darker shade for contrast
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              leading: const Icon(Icons.call, color: Colors.greenAccent), // classic call icon
              title: Text(contact['name']!, style: const TextStyle(color: Colors.white)),
              subtitle: Text(contact['phone']!, style: const TextStyle(color: Colors.white70)),
              onTap: () => _showCallConfirmationDialog(
                context,
                contact['name']!,
                contact['phone']!,
              ), // this triggers the confirmation popup
            ),
          );
        }).toList(), // loop through each contact and display as a card
      ),
    );
  }
}
