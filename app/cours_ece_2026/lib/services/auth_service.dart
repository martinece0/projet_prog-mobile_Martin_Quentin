import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:formation_flutter/model/product.dart';

class AuthService extends ChangeNotifier {
  final PocketBase pb;
  bool isLoading = false;
  String? error;

  AuthService(this.pb);

  bool get isAuthenticated => pb.authStore.isValid;

  // --- CONNEXION ---
  Future<bool> login(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await pb.collection('users').authWithPassword(email.trim(), password.trim());
      notifyListeners(); 
      return true; 
    } catch (e) {
      print("ERREUR LOGIN: $e");
      error = "Email ou mot de passe incorrect";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- INSCRIPTION (Correction du rouge ici) ---
  Future<bool> register(String email, String password) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      final cleanEmail = email.trim();
      final cleanPassword = password.trim();

      // 1. Création du compte dans PocketBase
      await pb.collection('users').create(body: {
        'email': cleanEmail,
        'password': cleanPassword,
        'passwordConfirm': cleanPassword,
        'emailVisibility': true,
      });
      
      // 2. Connexion automatique après inscription
      return await login(cleanEmail, cleanPassword);
    } catch (e) {
      print("ERREUR INSCRIPTION: $e"); 
      error = "Erreur lors de l'inscription. L'email est peut-être déjà utilisé.";
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // --- RÉCUPÉRER L'HISTORIQUE ---
  Future<List<RecordModel>> getHistory() async {
    if (!isAuthenticated) return [];
    try {
      return await pb.collection('history').getFullList(
        filter: 'user = "${pb.authStore.model.id}"', 
        sort: '-created',
      );
    } catch (e) {
      print("Erreur historique : $e");
      return [];
    }
  }

  // --- AJOUTER À L'HISTORIQUE ---
  Future<void> addToHistory(Product product) async {
    if (!isAuthenticated) return;
    try {
      await pb.collection('history').create(body: {
        'barcode': product.barcode,
        'product_name': product.name ?? 'Produit inconnu',
        'brand': (product.brands != null && product.brands!.isNotEmpty) 
            ? product.brands!.first 
            : 'Marque inconnue',
        'image_url': product.picture ?? '', 
        'nutriscore': product.nutriScore?.name ?? 'unknown',
        'user': pb.authStore.model.id,
      });
      
      notifyListeners(); 
    } catch (e) {
      print("Erreur ajout historique : $e");
    }
  }

  // --- DÉCONNEXION ---
  void logout() {
    pb.authStore.clear();
    notifyListeners();
  }
}