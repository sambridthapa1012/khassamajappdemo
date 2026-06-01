import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart'; // 👈 URL लन्चर आयात गरिएको

class SanskritikGalleryPage extends StatelessWidget {
  const SanskritikGalleryPage({super.key});

  // ✅ फेसबुक पेज खोल्ने सुरक्षित फङ्सन
  Future<void> _launchFacebookURL() async {
    final Uri url = Uri.parse('https://www.facebook.com/khassamaj'); // आफ्नो वास्तविक फेसबुक लिंक यहाँ राख्न सक्नुहुन्छ
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      debugPrint("Error launching URL: $e");
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
          'हाम्रो पहिचान, हाम्रो गौरव',
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
            // सांस्कृतिक सन्देश र हेडर
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  const Text(
                    'सांस्कृतिक धरोहर',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: primaryMaroon,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 2,
                    color: accentGold,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '"समय बित्दै जाला, तर हाम्रा पुर्खाहरूले छोडेर गएका कला, संस्कृति र संस्कारका यी पाटाहरू कहिल्यै धमिलो हुने छैनन्। यहाँको हरेक तस्वीरमा एउटा जीवन्त इतिहास मुस्कुराइरहेको छ।"',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: textDark,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Firestore बाट १० वा सोभन्दा बढी तस्बिरहरू देखाउने आकर्षक ग्रिड
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sanskritik_gallery').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('केही गल्ती भयो।'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: accentGold),
                  );
                }

                final docs = snapshot.data!.docs;

                if (docs.isEmpty) {
                  return const Center(child: Text('कुनै डाटा भेटिएन।'));
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // स्क्रोलिङ सहज बनाउन
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // एक लाइनमा २ वटा तस्बिर कार्डहरू
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.75, // कार्डको साइज सन्तुलित राख्न
                    ),
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final String rawBase64 = data['image'] ?? '';
                      final String cleanBase64 = rawBase64.contains(',')
                          ? rawBase64.split(',')[1]
                          : rawBase64;

                      return GestureDetector(
                        onTap: () => _showDetailedDialog(
                            context,
                            cleanBase64,
                            data['title'] ?? 'शीर्षक',
                            data['description'] ?? 'विवरण...'
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: accentGold.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // तस्बिर देखिने भाग
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                  child: cleanBase64.isNotEmpty
                                      ? Image.memory(
                                    base64Decode(cleanBase64),
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                      : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
                                ),
                              ),
                              // शीर्षक र छोटो विवरण
                              Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['title'] ?? 'सांस्कृतिक झलक',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: primaryMaroon,
                                        fontSize: 15,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      data['description'] ?? 'थप विवरणको लागि थिच्नुहोस्...',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: textDark.withOpacity(0.8),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

            // 🔵 फेसबुक लिंक सेक्शन (See More on Facebook)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentGold.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    const Text(
                      'हाम्रा थप सांस्कृतिक गतिविधि र तस्बिरहरू हेर्नको लागि हाम्रो आधिकारिक फेसबुक पेजमा जोडिनुहोस्।',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: textDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1877F2), // Facebook Blue Color
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      onPressed: _launchFacebookURL,
                      icon: const Icon(Icons.facebook, size: 22),
                      label: const Text(
                        'Facebook मा थप हेर्नुहोस्',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // तस्बिरमा क्लिक गर्दा खुल्ने विस्तृत संवाद (Pop-up Box)
  void _showDetailedDialog(BuildContext context, String base64Image, String title, String description) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFAF6F0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (base64Image.isNotEmpty)
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.memory(
                  base64Decode(base64Image),
                  fit: BoxFit.cover,
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF5D3A1A),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF3E2723),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('बन्द गर्नुहोस्', style: TextStyle(color: Color(0xFF8B5E3C), fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}