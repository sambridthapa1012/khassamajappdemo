import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:khassamajapp/pages/sanskritik_gallery_page.dart';
import 'package:khassamajapp/pages/members_page.dart';
import 'profile_page.dart'; // नयाँ प्रोफाइल पेज इम्पोर्ट गरियो
import 'register_page.dart';
import 'history_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Widget _buildBase64Image(String rawBase64, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (rawBase64.isEmpty) {
      return Container(
          color: Colors.grey[300],
          width: width,
          height: height,
          child: const Icon(Icons.image, color: Colors.grey)
      );
    }
    final String cleanBase64 = rawBase64.contains(',') ? rawBase64.split(',')[1] : rawBase64;
    try {
      return Image.memory(
        base64Decode(cleanBase64),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            Container(color: Colors.grey[300], width: width, height: height, child: const Icon(Icons.broken_image, color: Colors.grey)),
      );
    } catch (e) {
      return Container(color: Colors.grey[300], width: width, height: height, child: const Icon(Icons.broken_image, color: Colors.grey));
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "नमस्ते! खस ",
          style: TextStyle(color: Color(0xFF0F3460), fontWeight: FontWeight.bold, fontSize: 24),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle, size: 32, color: Color(0xFF0F3460)),
            onPressed: () {
              if (currentUser != null) {
                // १. यदि रजिस्टर/लगइन छ भने नयाँ प्रोफाइल पेजमा लैजाने
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserProfilePage()),
                );
              } else {
                // २. यदि लगइन छैन भने दर्ता पानामा लैजाने
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterPage()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // सदस्य ब्यानर बटन
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage()));
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3460), Color(0xFF951B1B)],
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: const [
                      BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 3))
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "सदस्यता लिनुहोस्",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(left: 16, top: 10, bottom: 8),
              child: Text(
                "हाम्रा यादहरु",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            // ब्यानर
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('home_banners').orderBy('rank', descending: false).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const SizedBox(height: 200, child: Center(child: CircularProgressIndicator()));
                }
                final bannerDocs = snapshot.data!.docs;
                if (bannerDocs.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("कुनै ब्यानर उपलब्ध छैन।"),
                  );
                }

                return CarouselSlider(
                  options: CarouselOptions(
                    height: 200,
                    autoPlay: true,
                    viewportFraction: 0.9,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                  ),
                  items: bannerDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: _buildBase64Image(data["image"] ?? '', width: double.infinity),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            // ताजा सूचना
            const Padding(
              padding: EdgeInsets.only(left: 16, top: 20, bottom: 8),
              child: Text(
                "ताजा सूचना (समाचार)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('suchana_list').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                final newsDocs = snapshot.data!.docs;
                if (newsDocs.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("कुनै समाचार उपलब्ध छैन।"));

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: newsDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = newsDocs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const CircleAvatar(
                            radius: 22,
                            backgroundColor: Color(0xFFFFF0F0),
                            child: Icon(
                              Icons.notifications_active,
                              color: Color(0xFF951B1B),
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item["title"] ?? 'शीर्षक उपलब्ध छैन',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item["date"] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 25),

            // सामुदायिक कार्यक्रम
            const Padding(
              padding: EdgeInsets.only(left: 16, bottom: 8),
              child: Text(
                "सामुदायिक कार्यक्रम",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('samudayik_karyakram').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final eventDocs = snapshot.data!.docs;
                if (eventDocs.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("कुनै कार्यक्रम तय गरिएको छैन।"));

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: eventDocs.length,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemBuilder: (context, index) {
                    final event = eventDocs[index].data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.only(top: 5.0),
                            child: Icon(Icons.circle, size: 10, color: Color(0xFF951B1B)),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event["title"] ?? '',
                                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  event["date"] ?? '',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            // ग्यालेरी
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 20, bottom: 10, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "सांस्कृतिक ग्यालेरी",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SanskritikGalleryPage()),
                      );
                    },
                    child: const Text(
                      "थप हेर्नुहोस् >",
                      style: TextStyle(color: Color(0xFF951B1B), fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sanskritik_gallery').limit(4).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final galleryDocs = snapshot.data!.docs;
                if (galleryDocs.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("ग्यालेरी खाली छ।"));

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: galleryDocs.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.3,
                    ),
                    itemBuilder: (context, index) {
                      final gall = galleryDocs[index].data() as Map<String, dynamic>;
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildBase64Image(gall["image"] ?? ''),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            // केन्द्रीय सदस्यहरू
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "हाम्रा केन्द्रीय सदस्यहरू",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text("थप हेर्नुहोस् >", style: TextStyle(color: Color(0xFF951B1B), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("(आजै जान्नुहोस्)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 240,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('kendriya_sadasyaharu').orderBy('rank', descending: false).snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final memberDocs = snapshot.data!.docs;
                  if (memberDocs.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("सदस्य थपिएको छैन।"));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: memberDocs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final m = memberDocs[index].data() as Map<String, dynamic>;
                      return Container(
                        width: 150,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildBase64Image(m["image"] ?? '', height: 160, width: 150),
                            ),
                            const SizedBox(height: 6),
                            Text(m["name"] ?? 'नाम', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text(m["designation"] ?? 'पद', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            // वीर पुर्खाहरू
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "हाम्रा वीर पुर्खाहरू",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryPage()));
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: const [
                        Text("थप हेर्नुहोस् >", style: TextStyle(color: Color(0xFF951B1B), fontSize: 13, fontWeight: FontWeight.bold)),
                        Text("(आजै जान्नुहोस्)", style: TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: 250,
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('hamra_bir_purkha').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return const SizedBox();
                  final purkhaDocs = snapshot.data!.docs;
                  if (purkhaDocs.isEmpty) return const Padding(padding: EdgeInsets.all(16.0), child: Text("सूची खाली छ।"));

                  return ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: purkhaDocs.length,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    itemBuilder: (context, index) {
                      final p = purkhaDocs[index].data() as Map<String, dynamic>;
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.symmetric(horizontal: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEF),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEFE6C9)),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: _buildBase64Image(p["image"] ?? '', height: 140, width: 154),
                            ),
                            const SizedBox(height: 6),
                            Text(p["name"] ?? 'नाम', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF333333))),
                            const SizedBox(height: 2),
                            Text(p["desc"] ?? 'विवरण', style: const TextStyle(fontSize: 11, color: Colors.grey), maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}