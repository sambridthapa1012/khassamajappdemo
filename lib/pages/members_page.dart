import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class KendriyaSadasyaharuPage extends StatelessWidget {
  const KendriyaSadasyaharuPage({super.key});

  // 📞 फोन कल गर्ने फङ्सन
  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await launchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch phone call');
    }
  }

  // ✉️ इमेल पठाउने फङ्सन
  Future<void> _sendEmail(String emailAddress) async {
    final Uri launchUri = Uri(scheme: 'mailto', path: emailAddress);
    if (await launchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      debugPrint('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color bgCream = Color(0xFFFAF6F0);
    const Color textDark = Color(0xFF3E2723);
    const Color primaryMaroon = Color(0xFF5D3A1A);
    const Color accentGold = Color(0xFF8B5E3C);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: bgCream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: accentGold),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'नेतृत्व र समिति',
          style: TextStyle(
            color: accentGold,
            fontSize: 14,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // हेडर सेक्सन
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Text(
                    'केन्द्रीय सदस्यहरू',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: primaryMaroon,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 2,
                    color: accentGold,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'खस समाजको उत्थान र अधिकारका लागि अहोरात्र खटिनुहुने आदरणीय केन्द्रीय कार्यसमितिका पदाधिकारी तथा सदस्यहरू।',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: textDark,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // रियल-टाइम डाटा लिने स्ट्रिम (rank को आधारमा क्रमबद्ध मिलाइएको)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('kendriya_sadasyaharu')
                  .orderBy('rank', descending: false)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('डाटा लोड गर्न समस्या भयो।'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: accentGold),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('हाल कुनै सदस्यहरूको सूची उपलब्ध छैन।'));
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final String name = data['name'] ?? 'सदस्यको नाम';
                    final String designation = data['designation'] ?? 'पद';
                    final String phone = data['phone'] ?? '';
                    final String email = data['email'] ?? '';

                    final String rawBase64 = data['image'] ?? '';
                    final String cleanBase64 = rawBase64.contains(',')
                        ? rawBase64.split(',')[1]
                        : rawBase64;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: accentGold.withOpacity(0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Row(
                            children: [
                              // सदस्यको गोलो तस्बिर प्रोफाइल
                              Container(
                                width: 75,
                                height: 75,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(color: accentGold.withOpacity(0.3), width: 2),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: cleanBase64.isNotEmpty
                                      ? Image.memory(
                                    base64Decode(cleanBase64),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                    const Icon(Icons.person, size: 40, color: Colors.grey),
                                  )
                                      : const Icon(Icons.person, size: 40, color: Colors.grey),
                                ),
                              ),

                              const SizedBox(width: 16),

                              // सदस्यको नाम र पद विवरण
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: primaryMaroon,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: accentGold.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        designation,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: accentGold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // 📞 र ✉️ एक्सन बटनहरू
                              Row(
                                children: [
                                  if (phone.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.call, color: Colors.green, size: 22),
                                      onPressed: () => _makePhoneCall(phone),
                                    ),
                                  if (email.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.email, color: Colors.blue, size: 22),
                                      onPressed: () => _sendEmail(email),
                                    ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}