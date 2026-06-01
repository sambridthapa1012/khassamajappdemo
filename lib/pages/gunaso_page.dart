import 'package:flutter/material.dart';

class GunasoPage extends StatefulWidget {
  const GunasoPage({super.key});

  @override
  State<GunasoPage> createState() => _GunasoPageState();
}

class _GunasoPageState extends State<GunasoPage> {
  final _formKey = GlobalKey<FormState>();
  final complaintController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("गुनासो"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: complaintController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "तपाईंको गुनासो लेख्नुहोस्",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter your complaint";
                  }
                  return null;
                },
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("गुनासो पठाइयो")),
                      );
                    }
                  },
                  child: const Text("Submit"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}