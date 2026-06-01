import 'package:flutter/material.dart';
import '../models/purkha_model.dart';

class PurkhaCard extends StatelessWidget {
  final Purkha purkha;

  const PurkhaCard({super.key, required this.purkha});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        children: [
          Container(
            height: 200,
            width: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              image: DecorationImage(
                image: AssetImage(purkha.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 5),
          Text(purkha.name, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}