class ProductRecall {
  final String id;
  final String title;
  final String? distributors;
  final String? zone;
  final String? reason;
  final String? risks;
  final String? link;
  final String? dateInfo;

  ProductRecall({
    required this.id,
    required this.title,
    this.distributors,
    this.zone,
    this.reason,
    this.risks,
    this.link,
    this.dateInfo,
  });

  factory ProductRecall.fromPocketBase(Map<String, dynamic> data) {
    return ProductRecall(
      id: data['id'] ?? '',
      // On utilise les noms de colonnes exacts de ta photo
      title: data['nom_produit'] ?? "Rappel Produit",
      distributors: data['distributeurs'],
      zone: data['zone_geographique'],
      reason: data['motif_rappel'],
      risks: data['risques_encourus'],
      link: data['lien_pdf'], 
      dateInfo: data['dates_commercialisation'],
    );
  }
}