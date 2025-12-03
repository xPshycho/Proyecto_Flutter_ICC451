import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/pokemon.dart';
import 'section_card.dart';

class PokemonStatsSection extends StatefulWidget {
  final Pokemon pokemon;

  const PokemonStatsSection({
    super.key,
    required this.pokemon,
  });

  @override
  State<PokemonStatsSection> createState() => _PokemonStatsSectionState();
}

class _PokemonStatsSectionState extends State<PokemonStatsSection> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _translateStatName(String stat) {
    final translations = {
      'hp': 'PS',
      'attack': 'Ataque',
      'defense': 'Defensa',
      'special-attack': 'At. Esp.',
      'special-defense': 'Def. Esp.',
      'speed': 'Velocidad',
    };
    return translations[stat] ?? stat;
  }

  String _getShortStatName(String stat) {
    final shortNames = {
      'hp': 'PS',
      'attack': 'ATK',
      'defense': 'DEF',
      'special-attack': 'SpA',
      'special-defense': 'SpD',
      'speed': 'SPD',
    };
    return shortNames[stat] ?? stat;
  }

  Color _getStatColor(String stat) {
    final colors = {
      'hp': Colors.red,
      'attack': Colors.orange,
      'defense': Colors.blue,
      'special-attack': Colors.purple,
      'special-defense': Colors.green,
      'speed': Colors.pink,
    };
    return colors[stat] ?? Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pokemon.stats.isEmpty) return const SizedBox.shrink();

    return SectionCard(
      title: 'ESTADÍSTICAS',
      icon: Icons.analytics_outlined,
      actions: [
        _buildPageIndicator(0),
        const SizedBox(width: 4),
        _buildPageIndicator(1),
      ],
      child: SizedBox(
        height: 350,
        child: PageView(
          controller: _pageController,
          onPageChanged: (page) {
            setState(() {
              _currentPage = page;
            });
          },
          children: [
            _buildRadarChart(),
            _buildBarChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;

    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey[600],
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildRadarChart() {
    final orderedStats = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];

    final statValues = orderedStats
        .where((stat) => widget.pokemon.stats.containsKey(stat))
        .map((stat) => widget.pokemon.stats[stat]!.toDouble())
        .toList();

    final statNames = orderedStats
        .where((stat) => widget.pokemon.stats.containsKey(stat))
        .map((stat) => _getShortStatName(stat))
        .toList();
  
    final statRawValues = orderedStats
        .where((stat) => widget.pokemon.stats.containsKey(stat))
        .map((stat) => widget.pokemon.stats[stat]!)
        .toList();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: RadarChart(
              RadarChartData(
                radarShape: RadarShape.polygon,
                tickCount: 5,
                ticksTextStyle: const TextStyle(
                  color: Colors.transparent,
                  fontSize: 10,
                ),
                radarBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                  width: 2,
                ),
                gridBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
                tickBorderData: BorderSide(
                  color: isDarkMode ? Colors.grey[800]! : Colors.grey[200]!,
                  width: 1,
                ),
                getTitle: (index, angle) {
                  if (index >= statNames.length) {
                    return const RadarChartTitle(text: '');
                  }

                  return RadarChartTitle(
                    text: '${statNames[index]}\n${statRawValues[index]}',
                    angle: 0,
                    positionPercentageOffset: 0.15,
                  );
                },
                titleTextStyle: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black87,
                  height: 1.3,
                ),
                dataSets: [
                  // Dataset invisible para forzar la escala a 255
                  RadarDataSet(
                    fillColor: Colors.transparent,
                    borderColor: Colors.transparent,
                    borderWidth: 0,
                    entryRadius: 0,
                    dataEntries: List.generate(
                      statValues.length,
                      (_) => const RadarEntry(value: 255),
                    ),
                  ),
                  RadarDataSet(
                    fillColor: (isDarkMode ? Colors.blue[400]! : Colors.blue)
                        .withValues(alpha: 0.2),
                    borderColor: isDarkMode ? Colors.blue[400]! : Colors.blue,
                    borderWidth: 2,
                    entryRadius: 0,
                    dataEntries: statValues
                        .map((value) => RadarEntry(value: value))
                        .toList(),
                  ),
                ],
                radarBackgroundColor: Colors.transparent,
                radarTouchData: RadarTouchData(
                  enabled: false,
                ),
              ),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Total: ${statRawValues.reduce((a, b) => a + b)}',
          style: TextStyle(
            fontSize: 10,
            color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildBarChart() {
    final orderedStats = [
      'hp',
      'attack',
      'defense',
      'special-attack',
      'special-defense',
      'speed',
    ];

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            ...orderedStats
                .where((stat) => widget.pokemon.stats.containsKey(stat))
                .map((stat) {
              final value = widget.pokemon.stats[stat]!;
              final percentage = (value / 255).clamp(0.0, 1.0);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Stat name - flexible width with minimum
                      SizedBox(
                        width: 80,
                        child: Text(
                          _translateStatName(stat),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Value - fixed small width
                      SizedBox(
                        width: 45,
                        child: Text(
                          value.toString(),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Progress bar - takes remaining space
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: percentage,
                            backgroundColor: isDarkMode
                                ? Colors.grey[800]!.withValues(alpha: 0.5)
                                : Colors.grey.withAlpha(51),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              _getStatColor(stat),
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Text(
              'Total: ${widget.pokemon.stats.values.reduce((a, b) => a + b)}',
              style: TextStyle(
                fontSize: 10,
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

