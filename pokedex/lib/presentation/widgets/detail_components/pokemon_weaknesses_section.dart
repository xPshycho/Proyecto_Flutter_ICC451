import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/pokemon.dart';
import '../../../core/constants/pokemon_constants.dart';
import 'section_card.dart';

class PokemonWeaknessesSection extends StatelessWidget {
  final Pokemon pokemon;

  const PokemonWeaknessesSection({
    super.key,
    required this.pokemon,
  });

  static const _multipliers = [4.0, 2.0, 1.0, 0.5, 0.25, 0.0];

  @override
  Widget build(BuildContext context) {
    final effectiveness = pokemon.typeEffectiveness;

    return SectionCard(
      title: 'DAÑO',
      icon: Icons.shield_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMultiplierBadges(),
          const SizedBox(height: 16),
          _buildTypeEffectivenessGrid(effectiveness),
        ],
      ),
    );
  }

  Widget _buildMultiplierBadges() {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: _multipliers
          .map((m) => _buildBadge(_getMultiplierLabel(m)))
          .toList(),
    );
  }

  Widget _buildBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildTypeEffectivenessGrid(dynamic effectiveness) {
    final typeMultipliers = _collectTypeMultipliers(effectiveness);

    if (typeMultipliers.isEmpty) return const SizedBox.shrink();

    final sortedEntries = _sortByMultiplier(typeMultipliers);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: sortedEntries
          .map((e) => _buildTypeChip(e.key, e.value))
          .toList(),
    );
  }

  Map<String, double> _collectTypeMultipliers(dynamic effectiveness) {
    return {
      for (final type in effectiveness.superEffectiveTypes) type: 4.0,
      for (final type in effectiveness.veryEffectiveTypes) type: 2.0,
      for (final type in effectiveness.resistantTypes) type: 0.5,
      for (final type in effectiveness.veryResistantTypes) type: 0.25,
      for (final type in effectiveness.immuneTypes) type: 0.0,
    };
  }

  List<MapEntry<String, double>> _sortByMultiplier(
    Map<String, double> typeMultipliers,
  ) {
    return typeMultipliers.entries.toList()
      ..sort((a, b) {
        final compareMultiplier = b.value.compareTo(a.value);
        return compareMultiplier != 0
            ? compareMultiplier
            : a.key.compareTo(b.key);
      });
  }

  Widget _buildTypeChip(String type, double multiplier) {
    final typeColor = PokemonConstants.getTypeColor(type);
    final icon = PokemonConstants.getTypeIcon(type);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: typeColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            type,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          _buildMultiplierIndicator(_getMultiplierLabel(multiplier)),
        ],
      ),
    );
  }

  Widget _buildMultiplierIndicator(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  String _getMultiplierLabel(double multiplier) {
    return switch (multiplier) {
      4.0 => '×4',
      2.0 => '×2',
      1.0 => '×1',
      0.5 => '×½',
      0.25 => '×¼',
      0.0 => '×0',
      _ => '×1',
    };
  }
}
