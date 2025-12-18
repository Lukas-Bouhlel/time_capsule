import 'package:flutter/material.dart';
import '../models/capsule_model.dart';

class CapsuleMarker extends StatelessWidget {
  final Capsule capsule;
  final bool isMine;
  final double distance;
  final VoidCallback onTap;

  const CapsuleMarker({
    super.key,
    required this.capsule,
    required this.isMine,
    required this.distance,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final String flagAsset = isMine
        ? 'assets/icons/flag_orange.png'
        : (distance <= 100
            ? 'assets/icons/flag_vert.png'
            : 'assets/icons/flag_rouge.png');

    return GestureDetector(
      onTap: onTap,
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ],
            ),
            constraints: const BoxConstraints(maxWidth: 90),
            child: Text(
              capsule.title,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 10,
              ),
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}