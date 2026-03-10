import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/model/product_recall.dart'; // Import du modèle de rappel
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/screens/product/product_fetcher.dart';
import 'package:formation_flutter/screens/product/states/success/product_header.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab0.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab1.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab2.dart';
import 'package:formation_flutter/screens/product/states/success/tabs/product_tab3.dart';
import 'package:provider/provider.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';

class ProductPageBody extends StatefulWidget {
  const ProductPageBody({super.key});

  @override
  State<ProductPageBody> createState() => _ProductPageBodyState();
}

class _ProductPageBodyState extends State<ProductPageBody> {
  late ProductDetailsCurrentTab _tab;
  ProductRecall? _recall; // Variable pour stocker le rappel s'il existe

  @override
  void initState() {
    super.initState();
    _tab = ProductDetailsCurrentTab.summary;
    // On lance la vérification du rappel dès l'ouverture
    _checkForRecall();
  }

  // Fonction pour interroger ta table 'rappels' sur PocketBase
  Future<void> _checkForRecall() async {
    // Récupération sécurisée du produit depuis le Fetcher
    final state = context.read<ProductFetcher>().state;
    if (state is! ProductFetcherSuccess) return;
    final product = state.product;

    final pb = PocketBase('http://macbook-air-de-martin.local:8090');

    try {
      final result = await pb.collection('rappels').getList(
        filter: 'barcode = "${product.barcode}"',
      );

      if (result.items.isNotEmpty && mounted) {
        setState(() {
          _recall = ProductRecall.fromPocketBase(result.items.first.data);
        });
      }
    } catch (e) {
      debugPrint("Erreur lors de la récupération du rappel : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;

    return Provider<Product>(
      create: (_) =>
          (context.read<ProductFetcher>().state as ProductFetcherSuccess)
              .product,
      child: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: <Widget>[
                const ProductPageHeader(),
                
                // --- AJOUT DU BANDEAU RAPPEL ICI (ENTRE HEADER ET TABS) ---
                if (_recall != null)
                  SliverToBoxAdapter(
                    child: _RecallBanner(recall: _recall!),
                  ),

                SliverPadding(
                  padding: const EdgeInsetsDirectional.only(top: 10.0),
                  sliver: SliverToBoxAdapter(
                    child: _getBody(),
                  ),
                ),
              ],
            ),
          ),
          BottomNavigationBar(
            currentIndex: _tab.index,
            onTap: (int position) => setState(
              () => _tab = ProductDetailsCurrentTab.values[position],
            ),
            selectedItemColor: const Color(0xFF1D1D47),
            unselectedItemColor: Colors.grey,
            items: ProductDetailsCurrentTab.values
                .map(
                  (ProductDetailsCurrentTab tab) => BottomNavigationBarItem(
                    icon: Icon(tab.icon),
                    label: tab.label(localizations),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  Widget _getBody() {
    return switch (_tab) {
      ProductDetailsCurrentTab.summary => const ProductTab0(),
      ProductDetailsCurrentTab.info => const ProductTab1(),
      ProductDetailsCurrentTab.nutrition => const ProductTab2(),
      ProductDetailsCurrentTab.nutritionalValues => const ProductTab3(),
    };
  }
}

// Widget interne pour le bandeau rose d'alerte
class _RecallBanner extends StatelessWidget {
  final ProductRecall recall;
  const _RecallBanner({required this.recall});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: InkWell(
        onTap: () => context.push('/recall', extra: recall),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFFB2B2), // Rose clair
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFE63E11)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Ce produit fait l'objet d'un rappel produit",
                  style: TextStyle(
                    color: Color(0xFFE63E11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFFE63E11)),
            ],
          ),
        ),
      ),
    );
  }
}

enum ProductDetailsCurrentTab {
  summary(AppIcons.tab_barcode),
  info(AppIcons.tab_fridge),
  nutrition(AppIcons.tab_nutrition),
  nutritionalValues(AppIcons.tab_array);

  const ProductDetailsCurrentTab(this.icon);

  final IconData icon;

  String label(AppLocalizations appLocalizations) => switch (this) {
    ProductDetailsCurrentTab.summary => appLocalizations.product_tab_summary,
    ProductDetailsCurrentTab.info => appLocalizations.product_tab_properties,
    ProductDetailsCurrentTab.nutrition => appLocalizations.product_tab_nutrition,
    ProductDetailsCurrentTab.nutritionalValues => appLocalizations.product_tab_nutrition_facts,
  };
}