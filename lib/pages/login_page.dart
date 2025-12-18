import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/pages/register_page.dart';
import '../services/auth_service.dart';
import '../providers/user_provider.dart';
import '../screens/delayed_animation.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obscureText = true;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty){
      return;
    }

    setState(() => _isLoading = true);

    bool success = await AuthService.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      await context.read<UserProvider>().loadUserData();
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Échec de la connexion. Vérifiez vos identifiants."),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 20),
                DelayedAnimation(
                  delay: 200,
                  child: Text(
                    "TimeCapsule",
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                    ),
                  ),
                ),
                SizedBox(height: 30),
                DelayedAnimation(
                  delay: 400,
                  child: TextField(
                    controller: _emailController,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    decoration: InputDecoration(
                      hintText: "Email",
                      hintStyle: const TextStyle(color: Colors.black),
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface,
                          width: 2.0, // Épaisseur de la bordure
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                DelayedAnimation(
                  delay: 600,
                  child: TextField(
                    controller: _passwordController,
                    style: const TextStyle(color: Colors.black),
                    cursorColor: Colors.black,
                    obscureText: _obscureText,
                    decoration: InputDecoration(
                      hintText: "Mot de passe",
                      hintStyle: const TextStyle(color: Colors.black),
                      labelStyle: const TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureText
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureText = !_obscureText;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: theme.colorScheme.onSurface,
                          width: 2.0, // Épaisseur de la bordure
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                DelayedAnimation(
                  delay: 800,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onSurface,
                      foregroundColor: theme.colorScheme.onPrimary,
                      minimumSize: Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isLoading
                        ? null
                        : _login, // Désactive le bouton si chargement
                    child: _isLoading
                        ? SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            "SE CONNECTER",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
const SizedBox(height: 20),
DelayedAnimation(
  delay: 1000,
  child: Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Pas encore de compte ? "),
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const RegisterPage()),
          );
        },
        child: Text(
          "S'inscrire",
          style: TextStyle(
            color: theme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  ),
),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
