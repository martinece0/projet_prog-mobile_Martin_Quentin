import 'package:flutter/material.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/empty/product_page_empty.dart';
import 'package:formation_flutter/screens/product/states/error/product_page_error.dart';
import 'package:formation_flutter/screens/product/states/success/product_page_body.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:share_plus/share_plus.dart'; // <--- IMPORTANT

class ProductPage extends StatefulWidget {
  const ProductPage({super.key, required this.barcode})
    : assert(barcode.length > 0);

  final String barcode;

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final pb = PocketBase('http://macbook-air-de-martin.local:8090');
  String? _favoriteId;

  @override
  void initState() {
    super.initState();
    _checkIfFavorite();
  }

  Future<void> _checkIfFavorite() async {
    try {
      final result = await pb.collection('favorites').getList(
        filter: 'barcode = "${widget.barcode}"',
      );
      if (mounted) {
        setState(() {
          _favoriteId = result.items.isNotEmpty ? result.items.first.id : null;
        });
      }
    } catch (e) {
      debugPrint("Erreur vérification favoris : $e");
    }
  }

void _shareProduct(BuildContext context) {
    final state = context.read<ProductFetcher>().state;
    if (state is ProductFetcherSuccess) {
      final product = state.product;
      
      // On récupère la boîte de rendu du bouton pour donner la position à l'iPad
      final box = context.findRenderObject() as RenderBox?;
      
      Share.share(
        'Découvre ce produit sur Open Food Facts : ${product.name ?? 'Produit'}\n'
        'https://world.openfoodfacts.org/product/${product.barcode}',
        subject: product.name,
        // Cette ligne règle ton erreur PlatformException
        sharePositionOrigin: box!.localToGlobal(Offset.zero) & box.size,
      );
    }
  }

  void _toggleFavorite(BuildContext context) async {
    final state = context.read<ProductFetcher>().state;
    if (state is! ProductFetcherSuccess) return;
    final product = state.product;

    try {
      if (_favoriteId == null) {
        final record = await pb.collection('favorites').create(body: {
          'barcode': product.barcode,
          'product_name': product.name ?? "Inconnu",
          'image_url': product.picture ?? "",
          'nutriscore': product.nutriScore?.name ?? "unknown",
        });
        setState(() => _favoriteId = record.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ajouté aux favoris ⭐")),
          );
        }
      } else {
        await pb.collection('favorites').delete(_favoriteId!);
        setState(() => _favoriteId = null);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Retiré des favoris")),
          );
        }
      }
    } catch (e) {
      debugPrint("Erreur PocketBase : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final MaterialLocalizations materialLocalizations =
        MaterialLocalizations.of(context);

    return ChangeNotifierProvider<ProductFetcher>(
      create: (_) => ProductFetcher(barcode: widget.barcode),
      child: Builder(
        builder: (newContext) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Consumer<ProductFetcher>(
                  builder: (BuildContext context, ProductFetcher notifier, _) {
                    return switch (notifier.state) {
                      ProductFetcherLoading() => const ProductPageEmpty(),
                      ProductFetcherError(error: var err) => ProductPageError(error: err),
                      ProductFetcherSuccess() => const ProductPageBody(),
                    };
                  },
                ),
                
                // BOUTON FERMER (Haut Gauche)
                PositionedDirectional(
                  top: 0.0,
                  start: 0.0,
                  child: _HeaderIcon(
                    icon: AppIcons.close,
                    tooltip: materialLocalizations.closeButtonTooltip,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),

                // BOUTON PARTAGER (Haut Droite)
                PositionedDirectional(
                  top: 0.0,
                  end: 0.0,
                  child: _HeaderIcon(
                    icon: AppIcons.share,
                    tooltip: materialLocalizations.shareButtonLabel,
                    onPressed: () => _shareProduct(newContext), // <--- ACTION LIÉE
                  ),
                ),

                // BOUTON FAVORIS (À gauche du bouton partager)
                PositionedDirectional(
                  top: 0.0,
                  end: 55.0, // Espacement entre les deux boutons
                  child: _HeaderIcon(
                    icon: _favoriteId != null ? Icons.star : Icons.star_border,
                    tooltip: "Favoris",
                    onPressed: () => _toggleFavorite(newContext), // <--- ACTION LIÉE
                  ),
                ),
              ],
            ),
          );
        }
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({required this.icon, required this.tooltip, this.onPressed});

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(8.0),
        child: Material(
          type: MaterialType.transparency,
          child: Tooltip(
            message: tooltip,
            child: InkWell(
              onTap: onPressed, // Si null, ne fait rien
              customBorder: const CircleBorder(),
              child: Ink(
                padding: const EdgeInsetsDirectional.all(12.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.20),
                ),
                child: Icon(icon, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}