import 'package:flutter/material.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:provider/provider.dart';

class ProductTab1 extends StatelessWidget {
  const ProductTab1({super.key});

  @override
  Widget build(BuildContext context) {
    final product = context.read<Product>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SECTION INGRÉDIENTS ---
          _buildSectionHeader("Ingrédients"),
          const SizedBox(height: 10),
          if (product.ingredients != null && product.ingredients!.isNotEmpty)
            ...product.ingredients!.map((ingredient) => _buildCharacteristicRow(ingredient))
          else
            const Text("Aucune information sur les ingrédients"),

          const SizedBox(height: 30),

          // --- SECTION ALLERGÈNES ---
          _buildSectionHeader("Substances allergènes"),
          const SizedBox(height: 10),
          _buildTextList(product.allergens, "Aucune"),

          const SizedBox(height: 30),

          // --- SECTION ADDITIFS ---
          _buildSectionHeader("Additifs"),
          const SizedBox(height: 10),
          // Les additifs sont une Map<String, String> dans ton modèle
          _buildTextList(product.additives?.keys.toList(), "Aucune"),
        ],
      ),
    );
  }

  // Widget pour les titres de section bleus (comme sur la capture)
  Widget _buildSectionHeader(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2FF), // Bleu très clair pour le fond
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFF1D1D47),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }

  // Widget pour chaque ligne d'ingrédient
  Widget _buildCharacteristicRow(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1D1D47),
        ),
      ),
    );
  }

  // Widget générique pour afficher "Aucune" ou la liste de texte
  Widget _buildTextList(List<String>? list, String emptyMessage) {
    if (list == null || list.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          emptyMessage,
          style: const TextStyle(fontSize: 15, color: Color(0xFF1D1D47)),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list.map((item) => _buildCharacteristicRow(item)).toList(),
    );
  }
}