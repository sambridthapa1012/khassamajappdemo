import 'package:flutter/material.dart';
import 'history_page.dart';
import 'gunaso_page.dart';
import 'samparka_page.dart';
import 'members_page.dart';

class OthersPage extends StatelessWidget {
  const OthersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Aru (Others)")),
      body: ListView(
        children: [

          ListTile(
            leading: const Icon(Icons.volunteer_activism),
            title: const Text("सहयोग (Sahayog)"),
            onTap: () {},
          ),

          ListTile(
            leading: const Icon(Icons.contact_phone),
            title: const Text("सम्पर्क (Samparka)"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SamparkaPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.report_problem),
            title: const Text("गुनासो (Complain)"),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GunasoPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("इतिहास (History)"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.groups),
            title: const Text("केन्द्रीय सदस्यहरू"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KendriyaSadasyaharuPage()),
              );

            },
          ),
        ],
      ),
    );
  }
}