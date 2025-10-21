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

  // === Warna label formality ===
  Color _getFormalityColor(String level) {
    switch (level.toLowerCase()) {
      case "casual":
        return Colors.green;
      case "polite":
        return Colors.amber;
      case "formal":
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  // === Ubah label formality jadi versi bahasa Indonesia ===
  String _getFormalityLabel(String level) {
    switch (level.toLowerCase()) {
      case "casual":
        return "Kasual";
      case "polite":
        return "Sopan";
      case "formal":
        return "Formal";
      default:
        return "Tidak Diketahui";
    }
  }

  @override
  Widget build(BuildContext context) {
    final formalityColor = _getFormalityColor(levelFormality);
    final formalityLabel = _getFormalityLabel(levelFormality);

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
                  // Nama
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Role + Level Formalitas
                  Row(
                    children: [
                      Text(
                        role,
                        style: const TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: formalityColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          formalityLabel,
                          style: TextStyle(
                            fontSize: 12,
                            color: formalityColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 5),

                  // Deskripsi
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      height: 1.3,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
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
