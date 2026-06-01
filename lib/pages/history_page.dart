import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("खस समाजको इतिहास"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // 🔶 Top Banner Image
            Stack(
              children: [
                Image.asset(
                  "assets/images/khas_group.jpg",
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const Positioned(
                  bottom: 20,
                  left: 16,
                  right: 16,
                  child: Text(
                    "खस समुदाय",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // 🔶 Origin Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "उत्पत्ति (Origin)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔶 Origin Text
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "खस समुदाय नेपालको प्राचीन र गौरवशाली जातीय समूह हो। यसको इतिहास हिमालय क्षेत्रसँग गहिरो रूपमा जोडिएको छ। खसहरूलाई बहादुरी, शासन प्रणाली, र सांस्कृतिक धरोहरका लागि चिनिन्छ। समयसँगै खस समुदायले नेपालको एकता, भाषा, र संस्कृति निर्माणमा महत्वपूर्ण भूमिका खेलेको छ।",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 25),

            // 🔶 Contribution Images Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "योगदानहरू (Contributions)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 15),

            // 🔶 Image Gallery
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  buildImage("assets/images/contribution1.jpg"),
                  buildImage("assets/images/contribution2.jpg"),
                  buildImage("assets/images/contribution3.jpg"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 🔶 Contribution Essay
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "खस समुदायले नेपालको इतिहासमा महत्वपूर्ण योगदान दिएको छ। प्राचीन कालदेखि नै यो समुदायले प्रशासन, सैनिक शक्ति, र सांस्कृतिक विकासमा अग्रणी भूमिका खेलेको छ। विशेषगरी भाषा विकास, राष्ट्रिय एकता, र समाज निर्माणमा खस समुदायको योगदान अतुलनीय रहेको छ। आज पनि खस समुदायले नेपालको समृद्धि र पहिचानलाई बलियो बनाउन निरन्तर योगदान दिइरहेको छ।",
                style: TextStyle(fontSize: 15, height: 1.6),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget buildImage(String path) {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: 250,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
