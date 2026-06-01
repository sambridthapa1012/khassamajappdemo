import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ✅ Free Spark Plan Registration Method
  Future<String?> registerUser({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String citizenshipNo,
    required String citizenshipFrontBase64,
    required String citizenshipBackBase64,
  }) async {
    User? createdUser;
    try {
      // 1. Create account entry in Firebase Auth panel
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      createdUser = userCred.user;

      if (createdUser != null) {
        String uid = createdUser.uid;

        // 2. Save account profile along with compressed Base64 strings directly inside Firestore
        await FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .set({
          "uid": uid,
          "name": name,
          "phone": phone,
          "email": email,
          "citizenshipNo": citizenshipNo,
          "citizenshipFront": citizenshipFrontBase64,
          "citizenshipBack": citizenshipBackBase64,
          "createdAt": FieldValue.serverTimestamp(),
          "role": "member",
        });
      }

      return null; // Absolute success!
    } catch (e) {
      // 🚨 AUTOMATIC ROLLBACK: Wipes the Auth entry if Firestore insertion crashes,
      // preventing "Email already exists" loops on user retry.
      if (createdUser != null) {
        try {
          await createdUser.delete();
        } catch (rollbackError) {
          print("Rollback deletion failed: $rollbackError");
        }
      }

      if (e is FirebaseAuthException) {
        return e.message ?? "प्रमाणीकरण त्रुटि (Authentication Error)";
      }
      return "दर्ता प्रक्रियामा त्रुटि आयो: ${e.toString()}";
    }
  }

  // ✅ LOGIN
  Future<String?> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          return 'यो इमेल दर्ता गरिएको छैन।';
        case 'wrong-password':
          return 'गलत पासवर्ड। कृपया फेरि जाँच गर्नुहोस्।';
        case 'invalid-email':
          return 'कृपया मान्य इमेल ठेगाना राख्नुहोस्।';
        default:
          return e.message ?? 'लगइन गर्दा समस्या आयो।';
      }
    } catch (e) {
      return "त्रुटि: ${e.toString()}";
    }
  }

  // ✅ LOGOUT
  Future<String?> logout() async {
    try {
      await _auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}