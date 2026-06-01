import 'package:flutter/material.dart';

class SamparkaPage extends StatelessWidget {
  const SamparkaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("सम्पर्क"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            ListTile(
              leading: Icon(Icons.phone),
              title: Text("फोन"),
              subtitle: Text("+977-9800000000"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.email),
              title: Text("इमेल"),
              subtitle: Text("info@khassamaj.com"),
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text("ठेगाना"),
              subtitle: Text("काठमाडौं, नेपाल"),
            ),
          ],
        ),
      ),
    );
  }
}