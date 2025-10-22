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
                width: 70,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(width: 14),

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
                          style: const TextStyle(
                            fontSize: 20,
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
                            style: const TextStyle(
                              fontSize: 10,
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
                            style: const TextStyle(
                              fontSize: 10,
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
                    padding: const EdgeInsets.only(right: 30),
                    child: Text(
                      description,
                      style: const TextStyle(
                        fontSize: 13,
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
