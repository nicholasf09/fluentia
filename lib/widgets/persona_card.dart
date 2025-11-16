import 'package:flutter/material.dart';

class PersonaCard extends StatelessWidget {
  final String name;
  final String role;
  final String levelFormality;
  final String description;
  final String imagePath;
  final VoidCallback onTap;

  const PersonaCard({
    super.key,
    required this.name,
    required this.role,
    required this.levelFormality,
    required this.description,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double textScale = screenWidth < 330
        ? 0.8
        : screenWidth < 380
            ? 0.9
            : screenWidth < 440
                ? 0.95
                : 1.0;
    double scaled(double baseSize) => baseSize * textScale;
    final double imageSize = screenWidth < 360 ? 62 : 70;
    final double horizontalSpacing = screenWidth < 360 ? 10 : 14;
    final EdgeInsets descriptionPadding =
        EdgeInsets.only(right: screenWidth < 360 ? 10 : 30);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === Gambar persona ===
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.cover,
              ),
            ),

            SizedBox(width: horizontalSpacing),

            // === Informasi persona ===
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === Nama + Label Formalitas ===
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: TextStyle(
                            fontSize: scaled(20),
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),

                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF4F8FFD), // biru tua
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(25), // semi-lingkaran
                        ),
                        child: Text(
                          role,
                            style: TextStyle(
                              fontSize: scaled(10),
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF4F8FFD),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),

                      const SizedBox(width: 6),
                      // === Teks formalitas dengan gradient + outline ===
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: const Color(0xFF4F8FFD), // biru tua
                            width: 1.2,
                          ),
                          borderRadius: BorderRadius.circular(25), // semi-lingkaran
                        ),
                        child: Text(
                          levelFormality,
                            style: TextStyle(
                              fontSize: scaled(10),
                              fontWeight: FontWeight.w300,
                              color: Color(0xFF4F8FFD),
                              letterSpacing: 0.1,
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),

                  // === Deskripsi ===
                  Padding(
                    padding: descriptionPadding,
                    child: Text(
                      description,
                      style: TextStyle(
                        fontSize: scaled(12),
                        color: Colors.black54,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
