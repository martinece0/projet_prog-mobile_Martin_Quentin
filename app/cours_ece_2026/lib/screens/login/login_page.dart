import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoginMode = true; // Pour basculer entre Connexion et Inscription

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // TITRE (image_12b4f8.png)
              Text(
                _isLoginMode ? "Connexion" : "Inscription",
                style: const TextStyle(
                  fontSize: 24, 
                  fontWeight: FontWeight.bold, 
                  color: Color(0xFF1D1B4B)
                ),
              ),
              const SizedBox(height: 60),
              
              // CHAMP EMAIL AVEC ICONE
              _buildTextField(
                controller: _emailController,
                hintText: "Adresse email",
                icon: Icons.email,
              ),
              const SizedBox(height: 15),
              
              // CHAMP MOT DE PASSE AVEC ICONE
              _buildTextField(
                controller: _passwordController,
                hintText: "Mot de passe",
                icon: Icons.lock,
                isPassword: true,
              ),
              const SizedBox(height: 60),

              if (authService.isLoading)
                const CircularProgressIndicator(color: Color(0xFFFFB300))
              else ...[
                // BOUTON CRÉER UN COMPTE (Uniquement en mode connexion)
                if (_isLoginMode) ...[
                  _buildYukaButton(
                    text: "Créer un compte",
                    onPressed: () => setState(() => _isLoginMode = false),
                  ),
                  const SizedBox(height: 20),
                ],

                // BOUTON PRINCIPAL (Se connecter ou S'inscrire)
                _buildYukaButton(
                  text: _isLoginMode ? "Se connecter" : "S'inscrire",
                  onPressed: () async {
                    bool success;
                    if (_isLoginMode) {
                      success = await authService.login(
                        _emailController.text, _passwordController.text
                      );
                    } else {
                      success = await authService.register(
                        _emailController.text, _passwordController.text
                      );
                    }
                    if (success && mounted) context.go('/');
                  },
                ),
                
                // LIEN POUR REVENIR AU LOGIN
                if (!_isLoginMode)
                  TextButton(
                    onPressed: () => setState(() => _isLoginMode = true),
                    child: const Text(
                      "J'ai déjà un compte", 
                      style: TextStyle(color: Color(0xFF1D1B4B))
                    ),
                  ),
              ],

              if (authService.error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    authService.error!, 
                    style: const TextStyle(color: Colors.red)
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // WIDGET POUR LES CHAMPS DE TEXTE ARRONDIS (image_12b4f8.png)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: const Color(0xFF1D1B4B), size: 20),
          hintText: hintText,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  // WIDGET POUR LES BOUTONS JAUNES AVEC FLÈCHE (image_12b4f8.png)
  Widget _buildYukaButton({required String text, required VoidCallback onPressed}) {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFB300),
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
          elevation: 0,
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(width: 20), // Équilibre l'icône de droite
            Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const Icon(Icons.arrow_forward, size: 20),
          ],
        ),
      ),
    );
  }
}