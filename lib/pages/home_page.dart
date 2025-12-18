import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/pages/create_capsule_page.dart';
import 'package:time_capsule/widgets/capsule_marker.dart';
import '../providers/capsule_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../models/capsule_model.dart';
import '../widgets/capsule_immersive_view.dart';

class HomePage extends StatefulWidget {
  final void Function(String route, {dynamic arguments})? onNavigate;
  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  static const int openThreshold = 100;

  Future<void> _logout() async {
    await AuthService.logout();

    if (!mounted) return;

    Provider.of<UserProvider>(context, listen: false).clearUser();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final locProvider = Provider.of<LocationProvider>(context, listen: false);
      final capProvider = Provider.of<CapsuleProvider>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);

      await locProvider.getUserLocation();
      capProvider.loadCapsules();
      await userProvider.loadUserData();
    });
  }

  void _showCapsuleDialog(Capsule capsule, double distance) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final double dialogWidth = MediaQuery.of(context).size.width * 0.8;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        title: Text(capsule.title, style: tt.titleLarge),
        content: SizedBox(
          width: dialogWidth,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Par : ',
                    style: tt.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                  ),
                  Text(
                    capsule.author.isNotEmpty ? capsule.author : 'Inconnu',
                    style: tt.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: cs.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "🔒 Trop loin (${distance.round()} m)",
                style: tt.bodyMedium?.copyWith(
                  color: cs.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Rapprochez-vous à moins de ${openThreshold}m pour débloquer le contenu et les commentaires.",
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ],
          ),
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

  void _openCapsule(Capsule capsule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CapsuleImmersiveView(capsule: capsule),
    );
  }

  @override
  Widget build(BuildContext context) {
    final capsuleProvider = Provider.of<CapsuleProvider>(context);
    final locationProvider = Provider.of<LocationProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final currentUser = userProvider.username;

    if (locationProvider.isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 10),
              Text("Acquisition du GPS...", style: tt.bodyMedium),
            ],
          ),
        ),
      );
    }

    if (locationProvider.userPosition == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_off, size: 50, color: cs.error),
              const SizedBox(height: 10),
              Text(locationProvider.error ?? "Position introuvable"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => locationProvider.getUserLocation(),
                child: const Text("Réessayer"),
              ),
            ],
          ),
        ),
      );
    }

    final userPos = locationProvider.userPosition!;
    final userLatLng = LatLng(userPos.latitude, userPos.longitude);

    final nearbyCapsules = capsuleProvider.capsules.where((capsule) {
      final dist = locationProvider.getDistanceFromUser(
        capsule.latitude,
        capsule.longitude,
      );
      return dist <= 1000;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'Déconnexion',
          onPressed: _logout,
        ),
        title: const Text('Radar TimeCapsule'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Rafraîchir',
            onPressed: () => capsuleProvider.loadCapsules(),
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          initialCenter: userLatLng,
          initialZoom: 16.0,
          backgroundColor: cs.surface,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.timecapsule.app',
          ),
          MarkerLayer(
            markers: [
              ...nearbyCapsules.map((capsule) {
                final dist = locationProvider.getDistanceFromUser(
                  capsule.latitude,
                  capsule.longitude,
                );

                final bool isMine =
                    currentUser != null && capsule.author == currentUser;

                return Marker(
                  point: LatLng(capsule.latitude, capsule.longitude),
                  width: 80,
                  height: 80,
                  child: CapsuleMarker(
                    capsule: capsule,
                    isMine: isMine,
                    distance: dist,
                    onTap: () {
                      if (dist <= openThreshold || isMine) {
                        _openCapsule(capsule);
                      } else {
                        _showCapsuleDialog(capsule, dist);
                      }
                    },
                  ),
                );
              }),
              Marker(
                point: userLatLng,
                width: 25,
                height: 25,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateCapsulePage()),
          );

          if (mounted) {
            Provider.of<CapsuleProvider>(context, listen: false).loadCapsules();
          }
        },
        label: const Text("Enterrer ici"),
        icon: const Icon(Icons.add_location_alt),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
