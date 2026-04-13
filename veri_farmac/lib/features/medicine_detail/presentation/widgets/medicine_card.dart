// Card with medicine summary for lists.
// Shows name, registry, laboratory and StatusBadge

import 'package:flutter/material.dart';

import '../../domain/entities/medicine.dart';
import 'status_badge.dart';

// Card that shows a medicine summary.
// Used in history and search results.
class MedicineCard extends StatelessWidget {
  const MedicineCard({
    super.key,
    required this.medicine,
    this.onPress,
  });

  final Medicine      medicine;
  final VoidCallback? onPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onPress,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row: name and badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Medicine name
                  Expanded(
                    child: Text(
                      medicine.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Status badge
                  StatusBadge(condition: medicine.condition),
                ],
              ),

              const SizedBox(height: 8),

              // Sanitary registry
              _InfoRow(
                icon: Icons.verified_outlined,
                text: medicine.sanitaryRecord,
              ),

              const SizedBox(height: 4),

              // Laboratory
              _InfoRow(
                icon: Icons.business_outlined,
                text: medicine.laboratory,
              ),

              // Active ingredient (if present)
              if (medicine.activeIngredient != null) ...[
                const SizedBox(height: 4),
                _InfoRow(
                  icon: Icons.science_outlined,
                  text: '${medicine.activeIngredient}'
                      '${medicine.concentration != null ? ' ${medicine.concentration}' : ''}',
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Information row with icon and text
class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.text});

  final IconData icon;
  final String   text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
