import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfilePage extends StatelessWidget {
  const UserProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "मेरो प्रोफाइल",
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F3460)),
      ),
      body: user == null
          ? const Center(child: Text("प्रयोगकर्ता लगइन भएको छैन।"))
          : StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          String displayName = user.displayName ?? "प्रयोगकर्ता";
          String email = user.email ?? "इमेल उपलब्ध छैन";
          String phone = "नखुलेको";

          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            displayName = userData['name'] ?? displayName;
            phone = userData['phone'] ?? phone;
          }

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // 🌟 यहाँ सच्याइएको छ
              children: [
                const SizedBox(height: 20),
                // प्रोफाइल तस्बिर (आइकन)
                const CircleAvatar(
                  radius: 50,
                  backgroundColor: Color(0xFF0F3460),
                  child: Icon(Icons.person, size: 60, color: Colors.white),
                ),
                const SizedBox(height: 20),

                // नाम र इमेल
                Text(
                  displayName,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F3460)),
                ),
                const SizedBox(height: 5),
                Text(
                  email,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),

                const SizedBox(height: 40),

                // विवरण कार्डहरू
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 1,
                  child: ListTile(
                    leading: const Icon(Icons.phone, color: Color(0xFF0F3460)),
                    title: const Text("मोबाइल नम्बर", style: TextStyle(fontWeight: FontWeight.w500)),
                    trailing: Text(phone, style: const TextStyle(color: Colors.black87, fontSize: 15)),
                  ),
                ),
                // 🌟 यदि युजर एडमिन हो भने मात्र यो बटन देखिन्छ
                if (snapshot.hasData && snapshot.data!.exists && (snapshot.data!.data() as Map<String, dynamic>)['role'] == 'admin') ...[
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3460),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
                      label: const Text("एडमिन प्यानल खोल्नुहोस्", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const AdminDashboard()),
                        );
                      },
                    ),
                  ),
                ],

                // यसले लगआउट बटनलाई स्क्रिनको सबैभन्दा तल पुर्‍याउँछ
                const Spacer(),

                // 🚪 लगआउट गर्नुहोस् (Most Downside)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF951B1B), // रातो थिम कलर
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      // कन्फर्मेसन बक्स देखाउने
                      bool? confirmLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text("लगआउट पुष्टि गर्नुहोस्"),
                          content: const Text("के तपाईं निश्चित रूपमा लगआउट गर्न चाहनुहुन्छ?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("होइन", style: TextStyle(color: Colors.grey)),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("हो", style: TextStyle(color: Color(0xFF951B1B))),
                            ),
                          ],
                        ),
                      );

                      if (confirmLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          Navigator.pop(context); // प्रोफाइल पेज बन्द गर्ने
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("सफलतापूर्वक लगआउट गरियो।")),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.logout, color: Colors.white),
                    label: const Text(
                      "लगआउट गर्नुहोस्",
                      style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }
}