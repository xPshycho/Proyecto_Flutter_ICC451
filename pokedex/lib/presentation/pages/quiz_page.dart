import 'package:flutter/material.dart';

/// Página del Quiz de Pokémon
/// Permite al usuario seleccionar modalidad de juego y ver el salón de la fama
class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // Modalidad seleccionada por el usuario
  String _selectedMode = 'Silueta';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Poke Quiz",
          style: TextStyle(
            fontFamily: 'Pixelated',
            fontSize: 20,
            color: Color(0xFF46FC2A),
            shadows: [
              Shadow(color: Colors.black, blurRadius: 4, offset: Offset(2, 2))
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10),
          child: Column(
            children: [
              _buildHallOfFame(),
              const SizedBox(height: 20),
              _buildAchievementsButton(),
              const SizedBox(height: 20),
              _buildModeSelection(),
              const SizedBox(height: 30),
              _buildPlayButton(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Construye el contenedor del Salón de la Fama con ranking de jugadores
  Widget _buildHallOfFame() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD2D2D2),
            Color(0xFF323232),
          ],
          stops: [0.0, 1.0],
        ),
      ),
      child: Column(
        children: [
          const Text(
            "Salón de la Fama",
            style: TextStyle(
              fontFamily: 'Pixelated',
              fontSize: 20  ,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 15),
          _buildRankRow(
              rank: 1,
              name: "Ash",
              time: "1:00:34",
              score: "99,999",
              trophyAsset: "assets/images/trophies/first.png",
          ),
          _buildRankRow(
              rank: 2,
              name: "Cac",
              time: "0:20:24",
              score: "9,999",
              trophyAsset: "assets/images/trophies/second.png",
          ),
          _buildRankRow(
              rank: 3,
              name: "z2z",
              time: "0:10:48",
              score: "1,320",
              trophyAsset: "assets/images/trophies/third.png",
          ),
          _buildRankRow(rank: 4, name: "nic", time: "0:03:20", score: "643"),
          _buildRankRow(rank: 5, name: "mis", time: "0:00:40", score: "100"),
        ],
      ),
    );
  }

  /// Construye una fila individual del ranking
  Widget _buildRankRow({
    required int rank,
    required String name,
    required String time,
    required String score,
    String? trophyAsset,
  }) {
    Color gradientColor = const Color(0xFF323232);

    if(rank == 1){
      gradientColor = const Color(0xFFFFF58D);
    } else if(rank == 2){
      gradientColor = const Color(0xFFF8F8F8);
    } else if(rank == 3) {
      gradientColor = const Color(0xFFF0CF90);
    }

    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      gradient: LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          gradientColor,
          Color(0xFF323232),
        ],
        stops: [0.0, 0.25],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      height: 45,
      decoration: decoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: trophyAsset != null
                  ? Image.asset(trophyAsset, width: 24, height: 24)
                  : Text(
                "$rank.",
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                name,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 60,
              child: Text(
                score,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontFamily: 'Pixelated',
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón de logros con contador
  Widget _buildAchievementsButton() {
    return Container(
      width: double.infinity,
      height: 70,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7D64B7), Color(0xFF40335E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        children: const [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                "Logros",
                style: TextStyle(
                    fontFamily: 'Pixelated',
                    fontSize: 22,
                    color: Colors.white,
                    shadows: [Shadow(offset: Offset(2, 2), color: Colors.black26)]
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 12,
            child: Text(
              "0/99",
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el panel de selección de modalidad con opciones
  Widget _buildModeSelection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF7D64B7),
            Color(0xFF5F4D8C),
            Color(0xFF4E3E71),
            Color(0xFF40335E),
            Color(0xFF372C51)
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Align(
            child: Text(
              "Modalidad",
              style: TextStyle(
                fontFamily: 'Pixelated',
                fontSize: 24,
                color: Color(0xFFFF9B47),
                shadows: [Shadow(offset: Offset(2, 2), color: Colors.black38)]
              ),
            ),
          ),
          const SizedBox(height: 10),
          _buildRadioOption("Silueta", "x 1"),
          _buildRadioOption("Descripción", "x 1.5"),
          _buildRadioOption("Numero", "x 2"),
          _buildRadioOption("Sonido", "x 3"),
        ],
      ),
    );
  }

  /// Construye una opción de radio button personalizada
  Widget _buildRadioOption(String label, String multiplier) {
    bool isSelected = _selectedMode == label;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMode = label;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: Colors.transparent,
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.transparent,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const Spacer(),
            Text(
              multiplier,
              style: const TextStyle(
                fontFamily: 'Pixelated',
                color: Colors.white70,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construye el botón principal de jugar
  Widget _buildPlayButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () {
          print("Iniciando juego en modo: $_selectedMode");
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF46FC2A), Color(0xFF256215)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight  ,
            ),
          ),
          child: const Center(
            child: Text(
              "Jugar",
              style: TextStyle(
                  fontFamily: 'Pixelated',
                  fontSize: 28,
                  color: Colors.white,
                  shadows: [Shadow(offset: Offset(2,2), color: Colors.black54)]
              ),
            ),
          ),
        ),
      ),
    );
  }
}

