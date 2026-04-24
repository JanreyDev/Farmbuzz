import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';

enum SavedType { post, product, bird, club }

class SavedItem {
  final String title;
  final String subtitle;
  final String? imageUrl;
  final SavedType type;
  final String date;

  SavedItem({
    required this.title,
    required this.subtitle,
    this.imageUrl,
    required this.type,
    required this.date,
  });
}

class SavedCard extends StatelessWidget {
  final SavedItem item;

  const SavedCard({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Image / Placeholder
              Container(
                width: 100,
                color: Colors.grey[100],
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                      )
                    : _buildPlaceholder(),
              ),
              
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTypeTag(),
                          Text(
                            item.date,
                            style: GoogleFonts.inter(
                              fontSize: 10,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        item.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      const Spacer(),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Icon(Icons.bookmark, size: 18, color: AppColors.accentGreen),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    IconData icon;
    switch (item.type) {
      case SavedType.post: icon = Icons.article_outlined; break;
      case SavedType.product: icon = Icons.shopping_bag_outlined; break;
      case SavedType.bird: icon = Icons.egg_outlined; break;
      case SavedType.club: icon = Icons.groups_outlined; break;
    }
    return Center(child: Icon(icon, color: Colors.grey[300], size: 32));
  }

  Widget _buildTypeTag() {
    String label;
    Color color;
    switch (item.type) {
      case SavedType.post: label = 'POST'; color = Colors.blue; break;
      case SavedType.product: label = 'PRODUCT'; color = Colors.orange; break;
      case SavedType.bird: label = 'BIRD'; color = Colors.green; break;
      case SavedType.club: label = 'CLUB'; color = Colors.purple; break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
