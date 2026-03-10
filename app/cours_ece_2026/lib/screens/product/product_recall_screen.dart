import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:formation_flutter/model/product_recall.dart';

class ProductRecallScreen extends StatelessWidget {
  final ProductRecall recall;

  const ProductRecallScreen({super.key, required this.recall});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rappel d'un produit"),
        centerTitle: false,
        actions: [
          // On utilise un Builder pour obtenir le contexte spécifique du bouton
          Builder(
            builder: (buttonContext) {
              return IconButton(
                icon: const Icon(Icons.reply), // Icône de partage
                onPressed: () {
                  if (recall.link != null) {
                    // On récupère la position du bouton pour l'iPad
                    final RenderBox? box = buttonContext.findRenderObject() as RenderBox?;
                    
                    Share.share(
                      "⚠️ Alerte Rappel Produit : ${recall.title}\nConsultez les détails ici : ${recall.link}",
                      sharePositionOrigin: box != null 
                          ? box.localToGlobal(Offset.zero) & box.size 
                          : null,
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Titre principal
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 25.0, horizontal: 20.0),
              child: Text(
                recall.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1D1D47),
                ),
              ),
            ),
            
            // Sections d'informations avec bandeaux bleus
            _buildInfoSection("Dates de commercialisation", recall.dateInfo),
            _buildInfoSection("Distributeurs", recall.distributors),
            _buildInfoSection("Zone géographique", recall.zone),
            _buildInfoSection("Motif du rappel", recall.reason),
            _buildInfoSection("Risques encourus", recall.risks),
            
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoSection(String title, String? content) {
    if (content == null || content.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: const BoxDecoration(
            color: Color(0xFFF0F2FF), // Bleu ciel
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1D1D47),
              fontSize: 16,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 15, 20, 25),
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              height: 1.4,
              color: Color(0xFF1D1D47),
            ),
          ),
        ),
      ],
    );
  }
}