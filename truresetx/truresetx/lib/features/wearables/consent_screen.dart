import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';

class ConsentScreen extends StatefulWidget {
  const ConsentScreen({super.key});

  @override
  State<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends State<ConsentScreen> {
  bool _hr = false;
  bool _location = false;
  bool _mic = false;

  Future<void> _deleteAccountData() async {
    // Replace the URL below with your deployed function URL (region + project).
    final url = Uri.parse(
        'https://us-central1-YOUR_PROJECT.cloudfunctions.net/deleteUserData');
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Not signed in');
      final token = await user.getIdToken();
      final resp = await http.post(url, headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      });
      if (resp.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Deletion started')));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Deletion failed: ${resp.statusCode}')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Deletion failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Permissions & Consent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select data types to share:'),
            CheckboxListTile(
                title: const Text('Heart rate'),
                value: _hr,
                onChanged: (v) => setState(() => _hr = v ?? false)),
            CheckboxListTile(
                title: const Text('Location / GPS'),
                value: _location,
                onChanged: (v) => setState(() => _location = v ?? false)),
            CheckboxListTile(
                title: const Text('Microphone / Noise level'),
                value: _mic,
                onChanged: (v) => setState(() => _mic = v ?? false)),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: _deleteAccountData,
                child: const Text('Delete my data')),
          ],
        ),
      ),
    );
  }
}
