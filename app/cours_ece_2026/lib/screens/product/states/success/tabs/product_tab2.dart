import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';

class ProductTab2 extends StatelessWidget {
  const ProductTab2({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.read<Product>();
    final levels = product.nutrientLevels;
    final facts = product.nutritionFacts;

    // Utilisation d'un Padding + Column au lieu de ListView
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Repères nutritionnels pour 100g",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 20),
          _buildNutriRow(
            label: "Matières grasses / lipides",
            grams: facts?.fat?.per100g,
            level: levels?.fat,
            unit: facts?.fat?.unit ?? "g",
          ),
          const Divider(height: 32),
          _buildNutriRow(
            label: "Acides gras saturés",
            grams: facts?.saturatedFat?.per100g,
            level: levels?.saturatedFat,
            unit: facts?.saturatedFat?.unit ?? "g",
          ),
          const Divider(height: 32),
          _buildNutriRow(
            label: "Sucres",
            grams: facts?.sugar?.per100g,
            level: levels?.sugars,
            unit: facts?.sugar?.unit ?? "g",
          ),
          const Divider(height: 32),
          _buildNutriRow(
            label: "Sel",
            grams: facts?.salt?.per100g,
            level: levels?.salt,
            unit: facts?.salt?.unit ?? "g",
          ),
        ],
      ),
    );
  }

  Widget _buildNutriRow({
    required String label,
    required dynamic grams,
    required String? level,
    required String unit,
  }) {
    Color color;
    String message;

    switch (level?.toLowerCase()) {
      case 'low':
        color = const Color(0xFF038141);
        message = "Faible quantité";
        break;
      case 'moderate':
        color = const Color(0xFFFECB02);
        message = "Quantité modérée";
        break;
      case 'high':
        color = const Color(0xFFE63E11);
        message = "Quantité élevée";
        break;
      default:
        color = Colors.grey;
        message = "Donnée inconnue";
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D1D47),
            ),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "${grams ?? '?'} $unit",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              message,
              style: TextStyle(fontSize: 14, color: color),
            ),
          ],
        ),
      ],
    );
  }
}