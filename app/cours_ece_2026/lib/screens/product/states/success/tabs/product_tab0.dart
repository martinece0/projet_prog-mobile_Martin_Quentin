import 'package:flutter/material.dart';
import 'package:formation_flutter/l10n/app_localizations.dart';
import 'package:formation_flutter/model/product.dart';
import 'package:formation_flutter/res/app_colors.dart';
import 'package:formation_flutter/res/app_icons.dart';
import 'package:formation_flutter/res/app_theme_extension.dart';
import 'package:provider/provider.dart';

class ProductTab0 extends StatelessWidget {
  const ProductTab0({super.key});

  static const double _kHorizontalPadding = 20.0;

  @override
  Widget build(BuildContext context) {
    // Tab0 redevient un StatelessWidget car il n'affiche plus que les scores et les infos fixes
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _Scores(),
        Padding(
          padding: EdgeInsetsDirectional.symmetric(
            horizontal: _kHorizontalPadding,
            vertical: 30.0,
          ),
          child: _Info(),
        ),
      ],
    );
  }
}

// --- LES SOUS-WIDGETS RESTENT IDENTIQUES ---

class _Scores extends StatelessWidget {
  const _Scores();
  static const double _horizontalPadding = 20.0;
  static const double _verticalPadding = 18.0;

  @override
  Widget build(BuildContext context) {
    final Product product = context.read<Product>();

    return DefaultTextStyle(
      style: context.theme.altText,
      child: Container(
        color: AppColors.grey1,
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: _verticalPadding,
                horizontal: _horizontalPadding,
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 44,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(end: 5.0),
                        child: _Nutriscore(
                          nutriscore: product.nutriScore ?? ProductNutriScore.unknown,
                        ),
                      ),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      flex: 66,
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 25.0),
                        child: _NovaGroup(
                          novaScore: product.novaScore ?? ProductNovaScore.unknown,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsetsDirectional.symmetric(
                vertical: _verticalPadding,
                horizontal: _horizontalPadding,
              ),
              child: _GreenScore(
                greenScore: product.greenScore ?? ProductGreenScore.unknown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nutriscore extends StatelessWidget {
  const _Nutriscore({required this.nutriscore});
  final ProductNutriScore nutriscore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppLocalizations.of(context)!.nutriscore, style: context.theme.title3),
        const SizedBox(height: 5.0),
        Image.asset(_findAssetName(), height: 42.0),
      ],
    );
  }

  String _findAssetName() {
    return switch (nutriscore) {
      ProductNutriScore.A => 'res/drawables/nutriscore_a.png',
      ProductNutriScore.B => 'res/drawables/nutriscore_b.png',
      ProductNutriScore.C => 'res/drawables/nutriscore_c.png',
      ProductNutriScore.D => 'res/drawables/nutriscore_d.png',
      ProductNutriScore.E => 'res/drawables/nutriscore_e.png',
      ProductNutriScore.unknown => 'res/drawables/nutriscore_unknown.png',
    };
  }
}

class _NovaGroup extends StatelessWidget {
  const _NovaGroup({required this.novaScore});
  final ProductNovaScore novaScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppLocalizations.of(context)!.nova_group, style: context.theme.title3),
        const SizedBox(height: 5.0),
        Text(_findLabel(), style: const TextStyle(color: AppColors.grey2)),
      ],
    );
  }

  String _findLabel() {
    return switch (novaScore) {
      ProductNovaScore.group1 => 'Aliments non transformés',
      ProductNovaScore.group2 => 'Ingrédients culinaires transformés',
      ProductNovaScore.group3 => 'Aliments transformés',
      ProductNovaScore.group4 => 'Produits ultra-transformés',
      ProductNovaScore.unknown => 'Score inconnu',
    };
  }
}

class _GreenScore extends StatelessWidget {
  const _GreenScore({required this.greenScore});
  final ProductGreenScore greenScore;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(AppLocalizations.of(context)!.greenscore, style: context.theme.title3),
        const SizedBox(height: 5.0),
        Row(
          children: <Widget>[
            Icon(_findIcon(), color: _findIconColor()),
            const SizedBox(width: 10.0),
            Expanded(child: Text(_findLabel(), style: const TextStyle(color: AppColors.grey2))),
          ],
        ),
      ],
    );
  }

  IconData _findIcon() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppIcons.ecoscore_a_plus,
      ProductGreenScore.A => AppIcons.ecoscore_a,
      ProductGreenScore.B => AppIcons.ecoscore_b,
      ProductGreenScore.C => AppIcons.ecoscore_c,
      ProductGreenScore.D => AppIcons.ecoscore_d,
      ProductGreenScore.E => AppIcons.ecoscore_e,
      ProductGreenScore.F => AppIcons.ecoscore_f,
      ProductGreenScore.unknown => AppIcons.ecoscore_e,
    };
  }

  Color _findIconColor() {
    return switch (greenScore) {
      ProductGreenScore.APlus => AppColors.greenScoreAPlus,
      ProductGreenScore.A => AppColors.greenScoreA,
      ProductGreenScore.B => AppColors.greenScoreB,
      ProductGreenScore.C => AppColors.greenScoreC,
      ProductGreenScore.D => AppColors.greenScoreD,
      ProductGreenScore.E => AppColors.greenScoreE,
      ProductGreenScore.F => AppColors.greenScoreF,
      ProductGreenScore.unknown => Colors.transparent,
    };
  }

  String _findLabel() {
    return switch (greenScore) {
      ProductGreenScore.APlus || ProductGreenScore.A => 'Très faible impact environnemental',
      ProductGreenScore.B => 'Faible impact environnemental',
      ProductGreenScore.C => "Impact modéré",
      ProductGreenScore.D => 'Impact élevé',
      ProductGreenScore.E || ProductGreenScore.F => 'Impact très élevé',
      ProductGreenScore.unknown => 'Score inconnu',
    };
  }
}

class _Info extends StatelessWidget {
  const _Info();

  @override
  Widget build(BuildContext context) {
    final AppLocalizations localizations = AppLocalizations.of(context)!;
    final Product product = context.read<Product>();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _ProductItemValue(label: localizations.product_quantity, value: product.quantity ?? '-'),
        _ProductItemValue(
          label: localizations.product_countries,
          value: product.manufacturingCountries?.join(', ') ?? '-',
          includeDivider: false,
        ),
        const SizedBox(height: 15.0),
        Row(
          children: <Widget>[
            Expanded(
              child: _ProductBubble(
                label: localizations.product_vegan,
                isOn: product.isVegan == ProductAnalysis.yes,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ProductBubble(
                label: localizations.product_vegetarian,
                isOn: product.isVegetarian == ProductAnalysis.yes,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProductItemValue extends StatelessWidget {
  const _ProductItemValue({required this.label, required this.value, this.includeDivider = true});
  final String label;
  final String value;
  final bool includeDivider;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Row(
            children: [
              Expanded(child: Text(label)),
              Expanded(child: Text(value, textAlign: TextAlign.end)),
            ],
          ),
        ),
        if (includeDivider) const Divider(height: 1.0),
      ],
    );
  }
}

class _ProductBubble extends StatelessWidget {
  const _ProductBubble({required this.label, required this.isOn});
  final String label;
  final bool isOn;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppColors.blueLight, borderRadius: BorderRadius.circular(10.0)),
      padding: const EdgeInsets.all(10.0),
      child: Row(
        children: [
          Icon(isOn ? AppIcons.checkmark : AppIcons.close, color: AppColors.white),
          const SizedBox(width: 10.0),
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.white))),
        ],
      ),
    );
  }
}