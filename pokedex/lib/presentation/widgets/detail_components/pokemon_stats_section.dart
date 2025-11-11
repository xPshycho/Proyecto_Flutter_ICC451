import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/models/pokemon.dart';

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

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 20,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
            ),
            const SizedBox(width: 8),
            Text(
              'ESTADÍSTICAS BASE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                color: isDarkMode ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 400,
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
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPageIndicator(0),
            const SizedBox(width: 8),
            _buildPageIndicator(1),
          ],
        ),
      ],
    );
  }

  Widget _buildPageIndicator(int index) {
    final isActive = _currentPage == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        width: isActive ? 24 : 8,
        height: 8,
        decoration: BoxDecoration(
          color: isActive
              ? (isDarkMode ? Colors.blue[400] : Colors.blue)
              : (isDarkMode ? Colors.grey[700] : Colors.grey[300]),
          borderRadius: BorderRadius.circular(4),
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
              swapAnimationDuration: const Duration(milliseconds: 400),
              swapAnimationCurve: Curves.easeInOut,
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

    final screenWidth = MediaQuery.of(context).size.width;
    final barWidth = screenWidth * 0.45;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
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
              child: Row(
                children: [
                  SizedBox(
                    width: 100,
                    child: Text(
                      _translateStatName(stat),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDarkMode ? Colors.white : Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 60,
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
                  SizedBox(
                    width: barWidth,
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
    );
  }
}

