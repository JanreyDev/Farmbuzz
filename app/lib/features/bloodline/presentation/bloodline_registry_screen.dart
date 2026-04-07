import 'package:flutter/material.dart';

const Color _kBloodlineBg = Color(0xFFF0F2F5);
const Color _kBloodlineSurface = Colors.white;
const Color _kBloodlineBorder = Color(0xFFE2E6EB);
const Color _kBloodlineMuted = Color(0xFF7C828C);
const Color _kGold = Color(0xFFC9A227);

class BloodlineRegistryScreen extends StatelessWidget {
  const BloodlineRegistryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back),
                    color: const Color(0xFF1F2230),
                  ),
                  const Expanded(
                    child: Text(
                      'Bloodline Registry',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.add),
                    color: _kGold,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: _kBloodlineBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  children: const [
                    _TopStats(),
                    SizedBox(height: 14),
                    _SectionTitle(title: 'Family Tree', icon: Icons.hub_outlined),
                    SizedBox(height: 8),
                    _FamilyTreeCard(),
                    SizedBox(height: 14),
                    _SectionTitle(
                      title: 'All Roosters',
                      icon: Icons.shield_outlined,
                    ),
                    SizedBox(height: 8),
                    _RoosterList(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopStats extends StatelessWidget {
  const _TopStats();

  @override
  Widget build(BuildContext context) {
    const stats = [
      (value: '4', label: 'Total', color: Color(0xFF1F2230)),
      (value: '2', label: 'Active', color: Color(0xFF2FA64A)),
      (value: '88%', label: 'Win Rate', color: _kGold),
      (value: '3', label: 'Bloodlines', color: Color(0xFF2D78FF)),
    ];

    return Row(
      children: List.generate(stats.length, (index) {
        final stat = stats[index];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == stats.length - 1 ? 0 : 6),
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: _kBloodlineSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _kBloodlineBorder),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    stat.value,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: stat.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    ' ',
                    style: TextStyle(fontSize: 1),
                  ),
                  Text(
                    stat.label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: _kBloodlineMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _FamilyTreeCard extends StatelessWidget {
  const _FamilyTreeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: _kBloodlineSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBloodlineBorder),
      ),
      child: Column(
        children: [
          _BirdNode(
            name: 'Thunder',
            line1: 'Kelso',
            line2: '8W-1L',
            highlighted: true,
          ),
          const SizedBox(height: 8),
          Container(width: 2, height: 16, color: const Color(0xFFD8DDE3)),
          Container(height: 2, width: 150, color: const Color(0xFFD8DDE3)),
          const SizedBox(height: 10),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _BirdNode(name: 'Lightning', line1: 'Sire (Kelso)', line2: '12W-3L'),
              SizedBox(width: 8),
              _BirdNode(name: 'Storm', line1: 'Dam (Hatch)', line2: 'Brood'),
            ],
          ),
        ],
      ),
    );
  }
}

class _BirdNode extends StatelessWidget {
  const _BirdNode({
    required this.name,
    required this.line1,
    required this.line2,
    this.highlighted = false,
  });

  final String name;
  final String line1;
  final String line2;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: highlighted ? 74 : 62,
      padding: EdgeInsets.fromLTRB(8, highlighted ? 8 : 7, 8, highlighted ? 8 : 7),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFFFF8EA) : const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: highlighted ? _kGold : const Color(0xFFD8DDE3),
          width: highlighted ? 1.3 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            name,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: highlighted ? 10 : 9,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1F2230),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            line1,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFFC38F15),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            line2,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 8,
              color: Color(0xFF2B313B),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoosterList extends StatelessWidget {
  const _RoosterList();

  @override
  Widget build(BuildContext context) {
    const birds = [
      _BirdListItemData(
        name: 'Thunder',
        line: 'Kelso',
        age: '1yr 8mo',
        weight: '2.1kg',
        record: '8W  1L  0D',
        progress: 0.95,
        progressText: '95%',
        statusLabel: 'ACTIVE',
        statusBg: Color(0xFFDFF2E5),
        statusText: Color(0xFF2FA64A),
      ),
      _BirdListItemData(
        name: 'Inferno',
        line: 'Sweater',
        age: '6yr 3mo',
        weight: '2.4kg',
        record: '12W  2L  1D',
        progress: 0.88,
        progressText: '88%',
        statusLabel: 'CONDITIONING',
        statusBg: Color(0xFFDDEBFF),
        statusText: Color(0xFF2D78FF),
      ),
      _BirdListItemData(
        name: 'Viper',
        line: 'Hatch',
        age: '1yr 2mo',
        weight: '1.9kg',
        record: '5W  0L  0D',
        progress: 1.0,
        progressText: '100%',
        statusLabel: 'ACTIVE',
        statusBg: Color(0xFFDFF2E5),
        statusText: Color(0xFF2FA64A),
      ),
      _BirdListItemData(
        name: 'Phantom',
        line: 'Kelso-Sweater',
        age: '3yr 1mo',
        weight: '2.3kg',
        record: '18W  3L  0D',
        progress: 0.72,
        progressText: '72%',
        statusLabel: 'RETIRED',
        statusBg: Color(0xFFE9EDF1),
        statusText: Color(0xFF7C828C),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: _kBloodlineSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBloodlineBorder),
      ),
      child: Column(
        children: List.generate(birds.length, (index) {
          return Column(
            children: [
              _BirdListTile(data: birds[index]),
              if (index != birds.length - 1)
                const Divider(height: 1, color: Color(0xFFE8EBEF)),
            ],
          );
        }),
      ),
    );
  }
}

class _BirdListTile extends StatelessWidget {
  const _BirdListTile({required this.data});

  final _BirdListItemData data;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.shield_outlined, size: 16, color: _kGold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      data.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: data.statusBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.statusLabel,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: data.statusText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      data.line,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFFC38F15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.age,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kBloodlineMuted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.weight,
                      style: const TextStyle(
                        fontSize: 10,
                        color: _kBloodlineMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  data.record,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF2FA64A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: data.progress,
                          minHeight: 3,
                          backgroundColor: const Color(0xFFE4E8ED),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF2FA64A),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.progressText,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF5E6570),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.chevron_right, color: Color(0xFF9AA1AA)),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: _kGold),
        const SizedBox(width: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1F2230),
          ),
        ),
      ],
    );
  }
}

class _BirdListItemData {
  const _BirdListItemData({
    required this.name,
    required this.line,
    required this.age,
    required this.weight,
    required this.record,
    required this.progress,
    required this.progressText,
    required this.statusLabel,
    required this.statusBg,
    required this.statusText,
  });

  final String name;
  final String line;
  final String age;
  final String weight;
  final String record;
  final double progress;
  final String progressText;
  final String statusLabel;
  final Color statusBg;
  final Color statusText;
}
