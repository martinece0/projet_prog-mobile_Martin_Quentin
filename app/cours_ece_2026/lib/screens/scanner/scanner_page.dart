import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:formation_flutter/services/auth_service.dart';
import 'package:formation_flutter/api/open_food_facts_api.dart';
import 'package:formation_flutter/model/product.dart';

class ScannerPage extends StatefulWidget { // On passe en StatefulWidget pour gérer le verrou
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  // --- LE VERROU ---
  bool _isProcessing = false; 

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scannez un produit')),
      body: MobileScanner(
        onDetect: (capture) async {
          // Si on est déjà en train de traiter un code, on ignore les suivants
          if (_isProcessing) return;

          final List<Barcode> barcodes = capture.barcodes;
          if (barcodes.isNotEmpty) {
            final String? code = barcodes.first.rawValue;
            
            if (code != null) {
              // On active le verrou immédiatement
              setState(() {
                _isProcessing = true;
              });

              try {
                // 1. Récupération des infos
                Product product = await OpenFoodFactsAPI().getProduct(code);
                
                if (mounted) {
                  // 2. Enregistrement unique dans PocketBase
                  await context.read<AuthService>().addToHistory(product);
                  
                  // 3. Navigation
                  context.pushReplacement('/product', extra: code);
                }
              } catch (e) {
                print("Erreur scan: $e");
                // En cas d'erreur, on libère le verrou pour permettre de réessayer
                setState(() {
                  _isProcessing = false;
                });
              }
            }
          }
        },
      ),
    );
  }
}