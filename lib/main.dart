import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'theme.dart';
import 'providers/location_provider.dart';
import 'providers/capsule_provider.dart';
import 'providers/user_provider.dart';
import 'providers/comment_provider.dart';
import 'routes/router.dart';
import 'pages/home_page.dart';
import 'package:timeago/timeago.dart' as timeago;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  timeago.setLocaleMessages('fr', timeago.FrMessages());

  try {
    await dotenv.load(fileName: ".env");
    print("✅ Fichier .env chargé avec succès");
  } catch (e) {
    print("⚠️ ERREUR: Impossible de charger .env : $e");
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationProvider()),
        ChangeNotifierProvider(create: (_) => CapsuleProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => CommentProvider()),
      ],
      child: MaterialApp(
        title: 'TimeCapsule',
        debugShowCheckedModeBanner: false,
        theme: MaterialTheme(ThemeData.light().textTheme).light(),
        darkTheme: MaterialTheme(ThemeData.dark().textTheme).dark(),
        themeMode: ThemeMode.system,
        home: const HomePage(),
        onGenerateRoute: AppRouter.generateRoute,
        initialRoute: '/', 
      ),
    );
  }
}