import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final pb = PocketBase('http://macbook-air-de-martin.local:8090');
  List<RecordModel> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _subscribeToFavorites();
  }

  @override
  void dispose() {
    pb.collection('favorites').unsubscribe('*');
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final records = await pb.collection('favorites').getFullList(
        sort: '-created',
      );
      if (mounted) {
        setState(() {
          _favorites = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erreur chargement favoris : $e");
    }
  }

  void _subscribeToFavorites() {
    pb.collection('favorites').subscribe('*', (e) {
      _loadFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC), 
      appBar: AppBar(
        title: const Text("Mes Favoris ⭐", style: TextStyle(color: Color(0xFF1D1D47))),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1D1D47)),
          onPressed: () => context.pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? const Center(child: Text("Aucun favori pour le moment"))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 25),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    final item = _favorites[index];
                    
                    final String name = item.data['product_name'] ?? "Produit inconnu";
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
                            // --- CARTE BLANCHE (Copie exacte de HomePage) ---
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
                            // --- IMAGE DU PRODUIT (Copie exacte de HomePage) ---
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
  }

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