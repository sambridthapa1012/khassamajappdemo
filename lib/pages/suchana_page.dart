import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // फायरबेस इम्पोर्ट थपियो

class SuchanaPage extends StatelessWidget {
  const SuchanaPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "सूचना",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F3460)),
      ),
      backgroundColor: Colors.grey[500], // हल्का पृष्ठभूमि
      body: StreamBuilder<QuerySnapshot>(
        // फायरबेसबाट डेटा तान्ने स्ट्रिम (नयाँ सूचना माथि देखाउन सम्भावित sorting थप्न सकिन्छ)
        stream: FirebaseFirestore.instance.collection('suchana_list').snapshots(),
        builder: (context, snapshot) {
          // डेटा लोड हुँदै गर्दा देखाउने लोडिङ एनिमेसन
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // यदि फायरबेसमा केही डेटा छैन भने
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "कुनै पनि सूचना उपलब्ध छैन।",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final suchanaDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: suchanaDocs.length,
            itemBuilder: (context, index) {
              // फायरबेसको डकुमेन्टबाट डाटा निकाल्ने
              final item = suchanaDocs[index].data() as Map<String, dynamic>;

              final String title = item["title"] ?? 'शीर्षक उपलब्ध छैन';
              final String desc = item["desc"] ?? 'विवरण उपलब्ध छैन';
              final String date = item["date"] ?? '';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: const Icon(
                    Icons.notifications_active,
                    color: Color(0xFF951B1B), // थीम कलर अनुसार रातो आइकन
                    size: 32,
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 6),
                      Text(
                        desc,
                        maxLines: 2, // होम स्क्रिनमा लामो टेक्स्ट भए बढीमा २ लाइन मात्र देखाउने
                        overflow: TextOverflow.ellipsis, // बाँकी टेक्स्ट लुकाएर ... देखाउने
                        style: TextStyle(color: Colors.grey[800], fontSize: 14),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        date,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  onTap: () {
                    // सूचनामा क्लिक गरेपछि पूरा विवरण पप-अप (Dialog) मा खुल्नेछ
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
                        ),
                        content: SingleChildScrollView(
                          child: Text(
                            desc,
                            style: const TextStyle(fontSize: 15, height: 1.4),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              "बन्द गर्नुहोस्",
                              style: TextStyle(color: Color(0xFF951B1B), fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}