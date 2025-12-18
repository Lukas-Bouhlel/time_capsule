import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../providers/capsule_provider.dart';
import '../providers/location_provider.dart';
import '../models/capsule_model.dart';
import '../routes/router.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CapsuleProvider>(context, listen: false).loadCapsules();
    });
  }

  void _showCapsuleDialog(Capsule capsule, double distance) {
    bool canOpen = distance <= 50;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(capsule.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              canOpen ? "🎉 Vous êtes sur place !" : "🔒 Trop loin (${distance.round()} m)",
              style: TextStyle(
                color: canOpen ? Colors.green : Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            if (!canOpen)
              const Text("Rapprochez-vous à moins de 50m pour voir le contenu."),
            
            if (canOpen) ...[
              const SizedBox(height: 10),
              if (capsule.imageUrl != null)
                Image.network(
                  capsule.imageUrl!,
                  height: 150,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.broken_image),
                ),
              const SizedBox(height: 10),
              Text(capsule.description),
            ]
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);

    if (locationProvider.isLoading || locationProvider.userPosition == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text("Recherche du signal GPS..."),
            ],
          ),
        ),
      );
    }

    final userPos = locationProvider.userPosition!;
    final userLatLng = LatLng(userPos.latitude, userPos.longitude);

    final nearbyCapsules = capsuleProvider.capsules.where((capsule) {
      double dist = locationProvider.getDistanceFromUser(capsule.latitude, capsule.longitude);
      return dist <= 1000;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Radar TimeCapsule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => capsuleProvider.loadCapsules(),
          )
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: userLatLng,
          initialZoom: 16.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.timecapsule.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: userLatLng,
                width: 40,
                height: 40,
                child: const Icon(Icons.navigation, color: Colors.blue, size: 30),
              ),
              ...nearbyCapsules.map((capsule) {
                double dist = locationProvider.getDistanceFromUser(capsule.latitude, capsule.longitude);
                
                return Marker(
                  point: LatLng(capsule.latitude, capsule.longitude),
                  width: 60,
                  height: 60,
                  child: GestureDetector(
                    onTap: () => _showCapsuleDialog(capsule, dist),
                    child: Column(
                      children: [
                        Image.asset(
                          dist <= 50
                              ? 'assets/icons/flag_vert.png'
                              : 'assets/icons/flag_rouge.png',
                          width: 20,
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
      
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, RouteManager.create),
        label: const Text("Enterrer ici"),
        icon: const Icon(Icons.add_location_alt),
        foregroundColor: Colors.white,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}