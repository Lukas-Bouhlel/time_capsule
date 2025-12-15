import 'package:flutter/material.dart';

class AppTheme {
  // Nos couleurs personnalisées
  static final Color primaryColor = Color(0xFF6200EE); // Violet mystique
  static final Color accentColor = Color(0xFF03DAC6);  // Cyan moderne
  
  // Le thème global de l'app
  static final ThemeData lightTheme = ThemeData(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: Colors.grey[100], // Fond gris très clair
    
    // Style de la barre de navigation (AppBar)
    appBarTheme: AppBarTheme(
      backgroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    ),

    // Style des boutons flottants
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: accentColor,
    ),
    
    // On peut ajouter d'autres styles ici (TextTheme, ButtonTheme...)
  );
}