import 'package:flutter/material.dart';
import '../models/region.dart';

class RegionalGridView extends StatelessWidget {
  final Function(Region)? onRegionSelected;

  const RegionalGridView({super.key, this.onRegionSelected});

  @override
  Widget build(BuildContext context) {
    const double imageAspectRatio = 1084 / 720;
    const double textHeightRatio = 0.12;
    const double cardAspectRatio = imageAspectRatio * (1 - textHeightRatio);

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: cardAspectRatio,
      ),
      itemCount: allRegions.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final region = allRegions[index];

        // Si es la última región (Paldea), centramos en su fila
        if (index == allRegions.length - 1) {
          return Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.4,
              child: _buildRegionCard(context, region),
            ),
          );
        }

        return _buildRegionCard(context, region);
      },
    );
  }

  // Construye una tarjeta individual para una región.
  Widget _buildRegionCard(BuildContext context, Region region) {
    return InkWell(
      onTap: () {
        if (onRegionSelected != null) {
          onRegionSelected!(region);
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen de los starters
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: Image.asset(
                  region.imagePath,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.image_not_supported, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Nombre de la región
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Text(
                region.name,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
