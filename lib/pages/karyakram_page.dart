import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // फायरबेस इम्पोर्ट थपियो

class KaryakramPage extends StatelessWidget {
  const KaryakramPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "सामुदायिक कार्यक्रम",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F3460)),
      ),
      backgroundColor: Colors.grey[100], // सफा ब्याकग्राउन्ड
      body: StreamBuilder<QuerySnapshot>(
        // होमपेज जस्तै 'samudayik_karyakram' कलेक्सनबाट डाटा तान्ने
        stream: FirebaseFirestore.instance.collection('samudayik_karyakram').snapshots(),
        builder: (context, snapshot) {
          // डाटा लोड हुँदै गर्दा लोडिङ एनिमेसन देखाउने
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // यदि फायरबेसमा कुनै कार्यक्रम छैन भने
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                "कुनै पनि कार्यक्रम तय गरिएको छैन।",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final eventDocs = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: eventDocs.length,
            itemBuilder: (context, index) {
              final event = eventDocs[index].data() as Map<String, dynamic>;

              final String title = event["title"] ?? 'शीर्षक उपलब्ध छैन';
              final String date = event["date"] ?? 'मिति उपलब्ध छैन';
              // यदि फायरबेसमा 'desc' फिल्ड थप्नुभयो भने यसले काम गर्छ, नत्र खाली बस्छ
              final String desc = event["desc"] ?? 'यस कार्यक्रमको विस्तृत विवरण हाल उपलब्ध छैन।';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFFFF0F0),
                    child: Icon(
                      Icons.event,
                      color: Color(0xFF951B1B), // थीम कलर रातो आइकन
                    ),
                  ),
                  title: Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2, // धेरै लामो शीर्षक भए २ लाइनमा सिमित गर्ने
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            date,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () {
                    // कार्यक्रममा क्लिक गरेपछि विस्तृत जानकारी पप-अप (Dialog) मा खुल्नेछ
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        title: Text(
                          title,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
                        ),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 16, color: Color(0xFF951B1B)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      date,
                                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 20),
                              Text(
                                desc,
                                style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black54),
                              ),
                            ],
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