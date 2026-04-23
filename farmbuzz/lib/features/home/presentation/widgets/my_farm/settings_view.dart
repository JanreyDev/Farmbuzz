import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'farm_common_widgets.dart';

class FarmSettingsView extends StatelessWidget {
  const FarmSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FarmSettingsHero(),
        const SizedBox(height: 32),
        const FarmSectionHeader(
          label: 'FARM INFO',
          title: 'Farm info',
          subtitle: 'Name, bio, and type. Shown wherever your farm appears.',
          actionLabel: 'View public profile',
          onAction: null,
        ),
        const SizedBox(height: 24),
        const FarmSettingsForm(),
        const SizedBox(height: 48),
        const FarmPrivacySection(),
        const SizedBox(height: 48),
        const FarmLocationSection(),
        const SizedBox(height: 48),
        const FarmDataSection(),
        const SizedBox(height: 24),
        const FarmLockedInfoBox(),
        const SizedBox(height: 48),
        const FarmDangerZone(),
        const SizedBox(height: 80),
      ],
    );
  }
}

class FarmSettingsHero extends StatelessWidget {
  const FarmSettingsHero({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFDCFCE7), Color(0xFFF0FDF4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  right: 24,
                  top: 24,
                  child: Text(
                    'GAMEFOWL',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.premiumGreen.withOpacity(0.3),
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Transform.translate(
            offset: const Offset(0, -35),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: AppColors.premiumGreen,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.settings_outlined, color: Colors.white, size: 32),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Farm name',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      FarmSettingsBadge(
                        label: 'Gamefowl',
                        icon: Icons.eco_rounded,
                        color: Colors.orange[800]!,
                        bgColor: Colors.orange[50]!,
                      ),
                      const SizedBox(width: 8),
                      FarmSettingsBadge(
                        label: 'Palawan · Est. 2026',
                        icon: Icons.location_on_rounded,
                        color: Colors.grey[600]!,
                        bgColor: Colors.grey[100]!,
                      ),
                      const SizedBox(width: 8),
                      const FarmSettingsBadge(
                        label: 'PRIMARY',
                        icon: Icons.bolt_rounded,
                        color: AppColors.premiumGreen,
                        bgColor: Color(0xFFDCFCE7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FarmSettingsBadge extends StatelessWidget {
  const FarmSettingsBadge({
    super.key,
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class FarmSettingsForm extends StatelessWidget {
  const FarmSettingsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FarmSettingsField(
            label: 'FARM NAME',
            required: true,
            placeholder: 'Farm name',
          ),
          const SizedBox(height: 24),
          const FarmSettingsField(
            label: 'BIO',
            placeholder: 'e.g. Third-generation gamefowl breeder. Kelso x Sweater focus. Based in Tarlac since 1998.',
            isTextArea: true,
            hint: 'Tell people who you are — focus breed, years in the field, your edge.',
          ),
          const SizedBox(height: 24),
          const FarmSettingsField(
            label: 'FARM TYPE',
            locked: true,
            hint: 'Type determines your lifecycle stages, KPIs, and vaccines. Changing it would break your historical records.',
            value: 'Gamefowl',
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF1F5F9),
                foregroundColor: Colors.grey[400],
                disabledBackgroundColor: const Color(0xFFF1F5F9),
                disabledForegroundColor: Colors.grey[400],
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                'Saved',
                style: GoogleFonts.plusJakartaSans(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FarmSettingsField extends StatelessWidget {
  const FarmSettingsField({
    super.key,
    required this.label,
    this.required = false,
    this.placeholder = '',
    this.isTextArea = false,
    this.locked = false,
    this.hint,
    this.value,
  });

  final String label;
  final bool required;
  final String placeholder;
  final bool isTextArea;
  final bool locked;
  final String? hint;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 0.5,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text('*', style: TextStyle(color: Colors.red, fontSize: 12)),
            ],
            if (locked) ...[
              const SizedBox(width: 4),
              Text(
                '— locked',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Text(
            hint!,
            style: TextStyle(fontSize: 10, color: Colors.grey[400], height: 1.4),
          ),
        ],
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: isTextArea ? 16 : 14,
          ),
          decoration: BoxDecoration(
            color: locked ? const Color(0xFFFFF7ED) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: locked ? const Color(0xFFFFEDD5) : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              if (locked && value == 'Gamefowl') ...[
                Icon(Icons.eco_rounded, size: 14, color: Colors.orange[800]),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  value ?? placeholder,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    color: value != null ? Colors.black : Colors.grey[300],
                    fontWeight: value != null ? FontWeight.w500 : FontWeight.w400,
                  ),
                ),
              ),
              if (locked)
                Icon(Icons.lock_outline_rounded, size: 16, color: Colors.grey[300]),
            ],
          ),
        ),
        if (isTextArea)
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '0/500',
                style: TextStyle(fontSize: 10, color: Colors.grey[300]),
              ),
            ),
          ),
      ],
    );
  }
}

class FarmPrivacySection extends StatelessWidget {
  const FarmPrivacySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Privacy',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Who sees what about your farm on the community side.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: FarmPrivacyCard(
                icon: Icons.public_rounded,
                title: 'Public',
                subtitle: 'Anyone on FarmBuzz can see your farm page — flagship birds, province, specialty.',
                isActive: true,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FarmPrivacyCard(
                icon: Icons.people_outline_rounded,
                title: 'Followers only',
                subtitle: 'Only people you approve as followers see your farm details.',
                isActive: false,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FarmPrivacyCard(
                icon: Icons.lock_outline_rounded,
                title: 'Private',
                subtitle: 'Only you + your team. Nothing shown on your public profile.',
                isActive: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.save_outlined, size: 18),
          label: Text(
            'Save privacy',
            style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.premiumGreen,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ],
    );
  }
}

class FarmPrivacyCard extends StatelessWidget {
  const FarmPrivacyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 140,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive ? AppColors.premiumGreen : Colors.grey[200]!,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFFDCFCE7) : Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: isActive ? AppColors.premiumGreen : Colors.grey[400],
                ),
              ),
              if (isActive)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.premiumGreen,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'ON',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class FarmLocationSection extends StatelessWidget {
  const FarmLocationSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Recorded when you created the farm. Public only at the province level.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            children: [
              const FarmLocationItem(
                label: 'PROVINCE',
                value: 'Palawan',
                badgeLabel: 'SHOWN',
                badgeColor: AppColors.premiumGreen,
                isLast: false,
              ),
              FarmLocationItem(
                label: 'CITY / MUNICIPALITY',
                value: 'Aborlan',
                badgeLabel: 'PRIVATE',
                badgeColor: Colors.grey[400]!,
                isLast: false,
              ),
              FarmLocationItem(
                label: 'BARANGAY',
                value: 'Apo-Aporawan',
                badgeLabel: 'PRIVATE',
                badgeColor: Colors.grey[400]!,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FarmLocationItem extends StatelessWidget {
  const FarmLocationItem({
    super.key,
    required this.label,
    required this.value,
    required this.badgeLabel,
    required this.badgeColor,
    required this.isLast,
  });

  final String label;
  final String value;
  final String badgeLabel;
  final Color badgeColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_outlined, size: 18, color: Colors.grey[400]),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey[400],
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(
                  badgeLabel == 'SHOWN' ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  size: 12,
                  color: badgeColor,
                ),
                const SizedBox(width: 4),
                Text(
                  badgeLabel,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FarmDataSection extends StatelessWidget {
  const FarmDataSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your data',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Under RA 10173 (Data Privacy Act), you can export or delete everything anytime.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.file_download_outlined, color: AppColors.premiumGreen),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Export everything',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Birds, health logs, breeding cycles, certificates, team activity, photos — packaged as a ZIP archive. Takes a few minutes; we\'ll email you when the download is ready.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: Text(
                        'Export all farm data',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black,
                        side: BorderSide(color: Colors.grey[200]!),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FarmLockedInfoBox extends StatelessWidget {
  const FarmLockedInfoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFEF3C7)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lock_outline_rounded, size: 18, color: Color(0xFFB45309)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Farm type is locked — here\'s why',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Lifecycle stages, KPIs, and vaccine schedules all depend on what kind of farm this is. Changing it mid-stream would break your historical records. If you need a different farm type, create a new farm instead.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFFB45309).withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FarmDangerZone extends StatelessWidget {
  const FarmDangerZone({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Danger zone',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Irreversible. Read carefully.',
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2F2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFEE2E2)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delete "Farm name"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                        children: [
                          const TextSpan(text: 'All data removed — birds, health logs, breeding cycles, certificates, team records, photos. Certificates already scanned by the public will show as '),
                          TextSpan(
                            text: 'REVOKED',
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          const TextSpan(text: 'but remain traceable (tamper-evident chain). This can\'t be undone.'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.delete_outline_rounded, size: 18),
                      label: Text(
                        'Delete farm permanently',
                        style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w700),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFEF4444),
                        side: const BorderSide(color: Color(0xFFFCA5A5)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
