import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; // ✅ Added for free compression
import '../services/auth_service.dart';
import '../routes/app_routes.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final name = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final citizenshipNo = TextEditingController();

  File? _frontImage;
  File? _backImage;
  final ImagePicker _picker = ImagePicker();

  final AuthService _auth = AuthService();
  bool loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    password.dispose();
    citizenshipNo.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isFront) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      setState(() {
        if (isFront) {
          _frontImage = File(pickedFile.path);
        } else {
          _backImage = File(pickedFile.path);
        }
      });
    }
  }

  void register() async {
    if (name.text.isEmpty || phone.text.isEmpty || password.text.isEmpty || citizenshipNo.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("कृपया सबै आवश्यक ताराचिह्न (*) विवरणहरू भर्नुहोस्।")),
      );
      return;
    }

    if (_frontImage == null || _backImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("कृपया नागरिकताको अगाडि र पछाडिको फोटो राख्नुहोस्।")),
      );
      return;
    }

    setState(() => loading = true);

    try {
      // 1. Compress front image in memory (Reduces size significantly to fit Firestore)
      var frontCompressedBytes = await FlutterImageCompress.compressWithFile(
        _frontImage!.absolute.path,
        minWidth: 400,
        minHeight: 400,
        quality: 15,
      );

      // 2. Compress back image in memory
      var backCompressedBytes = await FlutterImageCompress.compressWithFile(
        _backImage!.absolute.path,
        minWidth: 400,
        minHeight: 400,
        quality: 15,
      );

      if (frontCompressedBytes == null || backCompressedBytes == null) {
        throw Exception("तस्बिरहरू कम्प्रेस गर्दा समस्या आयो।");
      }

      // 3. Convert compressed bytes to Base64 Text Strings
      String frontBase64 = base64Encode(frontCompressedBytes);
      String backBase64 = base64Encode(backCompressedBytes);

      // 4. Pass Base64 strings to Auth Service
      String? result = await _auth.registerUser(
        name: name.text.trim(),
        phone: phone.text.trim(),
        email: email.text.trim(),
        password: password.text.trim(),
        citizenshipNo: citizenshipNo.text.trim(),
        citizenshipFrontBase64: frontBase64,
        citizenshipBackBase64: backBase64,
      );

      if (!mounted) return;
      setState(() => loading = false);

      if (result == null) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result)),
        );
      }
    } catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("त्रुटि: ${e.toString()}")),
      );
    }
  }

  InputDecoration _buildInputDecoration({required String labelText, required IconData prefixIcon, Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: const TextStyle(color: Colors.grey, fontSize: 14),
      prefixIcon: Icon(prefixIcon, color: const Color(0xFF0F3460), size: 22),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF8F9FA),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFFE9ECEF), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Color(0xFF0F3460), width: 2),
      ),
    );
  }

  Widget _buildPhotoUploadCard({required String label, required File? imageFile, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: const Color(0xFFF8F9FA),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFFE9ECEF), width: 1.5),
          ),
          child: imageFile != null
              ? ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(imageFile, fit: BoxFit.cover, width: double.infinity),
          )
              : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add_a_photo_outlined, color: Color(0xFF951B1B), size: 28),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF0F3460), size: 22),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              const Text(
                "नयाँ सदस्य दर्ता",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF0F3460), letterSpacing: .5),
              ),
              const SizedBox(height: 8),
              const Text(
                "खस समाज डिजिटल चौतारीमा जोडिन आफ्नो विवरण भर्नुहोस्।",
                style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 35),

              TextField(
                controller: name,
                keyboardType: TextInputType.name,
                decoration: _buildInputDecoration(labelText: "पूरा नाम (Full Name) *", prefixIcon: Icons.person_outline),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: phone,
                keyboardType: TextInputType.phone,
                decoration: _buildInputDecoration(labelText: "मोबाइल नम्बर (Phone) *", prefixIcon: Icons.phone_android_outlined),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                decoration: _buildInputDecoration(labelText: "इमेल (Email - ऐच्छिक)", prefixIcon: Icons.mail_outline_rounded),
              ),
              const SizedBox(height: 18),

              TextField(
                controller: citizenshipNo,
                keyboardType: TextInputType.text,
                decoration: _buildInputDecoration(labelText: "नागरिकता नम्बर (Citizenship No.) *", prefixIcon: Icons.badge_outlined),
              ),
              const SizedBox(height: 20),

              const Text(
                "नागरिकताको प्रमाण थप्नुहोस् (Citizenship Photos) *",
                style: TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  _buildPhotoUploadCard(
                    label: "अगाडिको भाग (Front)",
                    imageFile: _frontImage,
                    onTap: () => _pickImage(true),
                  ),
                  const SizedBox(width: 14),
                  _buildPhotoUploadCard(
                    label: "पछाडिको भाग (Back)",
                    imageFile: _backImage,
                    onTap: () => _pickImage(false),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              TextField(
                controller: password,
                obscureText: _obscurePassword,
                decoration: _buildInputDecoration(
                  labelText: "पासवर्ड (Password) *",
                  prefixIcon: Icons.lock_open_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              GestureDetector(
                onTap: loading ? null : register,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: loading ? [Colors.grey, Colors.grey.shade400] : [const Color(0xFF0F3460), const Color(0xFF951B1B)],
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: const Color(0xFF0F3460).withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5))],
                  ),
                  child: Center(
                    child: loading
                        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                        : const Text("खाता सिर्जना गर्नुहोस्", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}