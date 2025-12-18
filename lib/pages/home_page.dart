import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:time_capsule/pages/create_capsule_page.dart';
import '../providers/capsule_provider.dart';
import '../providers/location_provider.dart';
import '../providers/user_provider.dart';
import '../services/auth_service.dart';
import '../models/capsule_model.dart';

class HomePage extends StatefulWidget {
  final void Function(String route, {dynamic arguments})? onNavigate;
  const HomePage({super.key, this.onNavigate});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final MapController _mapController = MapController();
  static const int openThreshold = 50;

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

      await locProvider.getUserLocation();
      capProvider.loadCapsules();
    });
  }

  void _showCapsuleDialog(Capsule capsule, double distance) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bool canOpen = distance <= openThreshold;
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
              // Affiche le nom du créateur avec fallback lisible
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Créé par : ',
                      style: tt.bodySmall?.copyWith(
                        fontStyle: FontStyle.italic,
                        color: cs.onSurface,
                      ),
                    ),
                    TextSpan(
                      text: (capsule.creator.isNotEmpty ? capsule.creator : 'Inconnu'),
                      style: tt.bodySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                canOpen ? "🎉 Vous êtes sur place !" : "🔒 Trop loin (${distance.round()} m)",
                style: tt.bodyMedium?.copyWith(
                  color: canOpen ? cs.tertiary : cs.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              if (!canOpen)
                Text(
                  "Rapprochez-vous à moins de ${openThreshold}m pour voir le contenu.",
                  style: tt.bodyMedium?.copyWith(color: cs.onSurface),
                ),
              if (canOpen) ...[
                const SizedBox(height: 10),
                if (capsule.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      capsule.imageUrl!,
                      height: 150,
                      width: dialogWidth,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) =>
                          Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                    ),
                  ),
                const SizedBox(height: 10),
                Text(capsule.description, style: tt.bodyMedium),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
          if (canOpen)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _openCapsule(capsule);
              },
              child: const Text("Ouvrir"),
            ),
        ],
      ),
    );
  }

  void _openCapsule(Capsule capsule) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final double dialogWidth = MediaQuery.of(context).size.width * 0.8;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cs.surface,
        surfaceTintColor: cs.surfaceTint,
        title: Text(capsule.title, style: tt.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (capsule.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  capsule.imageUrl!,
                  height: 180,
                  width: dialogWidth,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) =>
                      Icon(Icons.broken_image, color: cs.onSurfaceVariant),
                ),
              ),
            const SizedBox(height: 10),
            Text(
              capsule.description.isNotEmpty
                  ? capsule.description
                  : 'Aucun contenu.',
              style: tt.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
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
              Text(
                locationProvider.error ?? "Position introuvable",
                style: tt.bodyMedium,
              ),
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
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.timecapsule.app',
          ),
          MarkerLayer(
            markers: [
              Marker(
                point: userLatLng,
                width: 40,
                height: 40,
                child: Icon(Icons.navigation, color: cs.primary, size: 30),
              ),
              ...nearbyCapsules.map((capsule) {
                final dist = locationProvider.getDistanceFromUser(
                  capsule.latitude,
                  capsule.longitude,
                );

                final bool isMine =
                    currentUser != null && capsule.creator == currentUser;

                final String flagAsset = isMine
                    ? 'assets/icons/flag_orange.png'
                    : (dist <= 50
                          ? 'assets/icons/flag_vert.png'
                          : 'assets/icons/flag_rouge.png');

                return Marker(
                  point: LatLng(capsule.latitude, capsule.longitude),
                  width: 72,
                  height: 72,
                  child: GestureDetector(
                    onTap: () {
                      if (dist <= openThreshold) {
                        _openCapsule(capsule);
                      } else {
                        _showCapsuleDialog(capsule, dist);
                      }
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(flagAsset, width: 22, height: 22),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: cs.outlineVariant),
                          ),
                          constraints: const BoxConstraints(maxWidth: 90),
                          child: Text(
                            capsule.title,
                            style: tt.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
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
