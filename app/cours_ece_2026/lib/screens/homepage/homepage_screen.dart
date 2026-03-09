import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/screens/homepage/homepage_empty.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:go_router/go_router.dart';
import 'package:pocketbase/pocketbase.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final auth = context.watch<AuthService>(); 

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), // Fond gris clair
      appBar: AppBar(
        title: Text(localizations.my_scans_screen_title),
        centerTitle: false,
        actions: <Widget>[
          // 1. Bouton SCAN
          IconButton(
            onPressed: () => context.push('/scanner'),
            icon: Icon(AppIcons.barcode),
          ),
          // 2. Bouton FAVORIS (L'étoile est de retour !)
          IconButton(
            onPressed: () => context.push('/favorites'),
            icon: const Icon(Icons.star_border, color: Color(0xFF1D1D47)),
          ),
          // 3. Bouton DÉCONNEXION
          IconButton(
            onPressed: () => auth.logout(),
            icon: const Icon(Icons.logout, color: Color(0xFF1D1D47)),
          ),
          const SizedBox(width: 8.0),
        ],
      ),
      body: FutureBuilder<List<RecordModel>>(
        future: auth.getHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final history = snapshot.data ?? [];

          // --- GESTION DE LA PAGE VIDE ---
          if (history.isEmpty) {
            return HomePageEmpty(onScan: () => context.push('/scanner'));
          }

          return RefreshIndicator(
            onRefresh: () async => auth.notifyListeners(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
              itemCount: history.length,
              itemBuilder: (context, index) {
                final item = history[index];
                
                // Extraction des données de ta table PocketBase
                final String name = item.data['product_name'] ?? "Produit inconnu";
                final String brand = item.data['brand'] ?? "";
                final String imageUrl = item.data['image_url'] ?? "";
                final String nutriscore = item.data['nutriscore'] ?? "unknown";
                final String barcode = item.data['barcode'] ?? "";

                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: GestureDetector(
                    onTap: () => context.push('/product', extra: barcode),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // --- CARTE BLANCHE ---
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(left: 35),
                          padding: const EdgeInsets.fromLTRB(75, 20, 16, 20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.07),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Color(0xFF1D1D47),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                brand,
                                style: TextStyle(color: Colors.grey[500], fontSize: 14),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  _buildNutriScoreDot(nutriscore),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Nutriscore : ${nutriscore.toUpperCase()}",
                                    style: const TextStyle(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // --- IMAGE DU PRODUIT ---
                        Positioned(
                          left: 0,
                          top: 5,
                          bottom: 5,
                          child: Container(
                            width: 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty 
                                ? Image.network(imageUrl, fit: BoxFit.cover)
                                : Container(
                                    color: Colors.grey[200],
                                    child: const Icon(Icons.fastfood, color: Colors.grey),
                                  ),
                            ),
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
    );
  }

  // Fonction pour les points de couleur Nutriscore
  Widget _buildNutriScoreDot(String score) {
    Color color;
    switch (score.toLowerCase()) {
      case 'a': color = const Color(0xFF038141); break;
      case 'b': color = const Color(0xFF85BB2F); break;
      case 'c': color = const Color(0xFFFECB02); break;
      case 'd': color = const Color(0xFFEE8100); break;
      case 'e': color = const Color(0xFFE63E11); break;
      default: color = Colors.grey;
    }
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}