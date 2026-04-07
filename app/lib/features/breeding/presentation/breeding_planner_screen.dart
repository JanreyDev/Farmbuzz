import 'package:flutter/material.dart';

const Color _kBg = Color(0xFFF0F2F5);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFE2E6EB);
const Color _kMuted = Color(0xFF7C828C);
const Color _kGold = Color(0xFFC9A227);

class BreedingPlannerScreen extends StatelessWidget {
  const BreedingPlannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const pairings = [
      _Pairing(
        status: 'HATCHED',
        statusColor: Color(0xFF2EA54A),
        statusBg: Color(0xFFDFF2E5),
        date: 'Mar 10, 2026',
        sire: 'Thunder',
        sireLine: 'Kelso',
        sireRecord: '8W-1L',
        dam: 'Pearl',
        damLine: 'Sweater',
        damRecord: 'Proven',
        statsLeft: '12 eggs',
        statsMid: '9 hatched',
        statsRight: 'Apr 1, 2026',
        note: '75% hatch rate. Strong chicks.',
      ),
      _Pairing(
        status: 'INCUBATING',
        statusColor: Color(0xFFE68621),
        statusBg: Color(0xFFFFEEDB),
        date: 'Mar 25, 2026',
        sire: 'Inferno',
        sireLine: 'Sweater',
        sireRecord: '12W-2L',
        dam: 'Ruby',
        damLine: 'Hatch',
        damRecord: 'Proven',
        statsLeft: '8 eggs',
        statsMid: 'Apr 15, 2026',
        statsRight: '',
        note: 'Day 10. Candling shows 7 fertile.',
      ),
      _Pairing(
        status: 'PLANNED',
        statusColor: Color(0xFF7C828C),
        statusBg: Color(0xFFE9EDF1),
        date: 'Apr 22, 2026',
        sire: 'Viper',
        sireLine: 'Hatch',
        sireRecord: '5W-0L',
        dam: 'Jade',
        damLine: 'Roundhead',
        damRecord: 'Linebred',
        statsLeft: 'Planned',
        statsMid: 'May 2026',
        statsRight: '',
        note: 'Pairing reserved for next cycle.',
      ),
    ];

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
                      'Breeding Planner',
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
                color: _kBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  children: [
                    const Row(
                      children: [
                        Expanded(
                          child: _TopStat(value: '3', label: 'Total Pairs', color: Color(0xFF1F2230)),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: _TopStat(value: '1', label: 'Incubating', color: Color(0xFFE68621)),
                        ),
                        SizedBox(width: 6),
                        Expanded(
                          child: _TopStat(value: '9', label: 'Hatched', color: Color(0xFF2EA54A)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...pairings.map(
                      (pair) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PairingCard(pair: pair),
                      ),
                    ),
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

class _TopStat extends StatelessWidget {
  const _TopStat({required this.value, required this.label, required this.color});

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(fontSize: 16, color: color, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: _kMuted, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _PairingCard extends StatelessWidget {
  const _PairingCard({required this.pair});

  final _Pairing pair;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: pair.statusBg, borderRadius: BorderRadius.circular(4)),
                child: Text(
                  pair.status,
                  style: TextStyle(fontSize: 9, color: pair.statusColor, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              Text(pair.date, style: const TextStyle(fontSize: 10, color: _kMuted)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _BirdPanel(role: 'SIRE', name: pair.sire, line: pair.sireLine, record: pair.sireRecord),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 6),
                child: CircleAvatar(
                  radius: 10,
                  backgroundColor: Color(0xFFE9EDF1),
                  child: Text('x', style: TextStyle(fontSize: 12, color: _kMuted)),
                ),
              ),
              Expanded(
                child: _BirdPanel(role: 'DAM', name: pair.dam, line: pair.damLine, record: pair.damRecord),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.circle_outlined, size: 11, color: Color(0xFFE3A320)),
              const SizedBox(width: 4),
              Text(pair.statsLeft, style: const TextStyle(fontSize: 10, color: _kMuted)),
              const SizedBox(width: 10),
              const Icon(Icons.check_circle_outline, size: 11, color: Color(0xFF2EA54A)),
              const SizedBox(width: 4),
              Text(pair.statsMid, style: const TextStyle(fontSize: 10, color: _kMuted)),
              if (pair.statsRight.isNotEmpty) ...[
                const SizedBox(width: 10),
                const Icon(Icons.calendar_month_outlined, size: 11, color: Color(0xFF2D78FF)),
                const SizedBox(width: 4),
                Text(pair.statsRight, style: const TextStyle(fontSize: 10, color: _kMuted)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: Color(0xFFE8EBEF)),
          const SizedBox(height: 6),
          Text(pair.note, style: const TextStyle(fontSize: 11, color: _kMuted, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}

class _BirdPanel extends StatelessWidget {
  const _BirdPanel({
    required this.role,
    required this.name,
    required this.line,
    required this.record,
  });

  final String role;
  final String name;
  final String line;
  final String record;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(role, style: const TextStyle(fontSize: 8, color: _kMuted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF1F2230))),
          const SizedBox(height: 3),
          Text(line, style: const TextStyle(fontSize: 10, color: _kGold, fontWeight: FontWeight.w700)),
          const SizedBox(height: 2),
          Text(record, style: const TextStyle(fontSize: 10, color: _kMuted, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _Pairing {
  const _Pairing({
    required this.status,
    required this.statusColor,
    required this.statusBg,
    required this.date,
    required this.sire,
    required this.sireLine,
    required this.sireRecord,
    required this.dam,
    required this.damLine,
    required this.damRecord,
    required this.statsLeft,
    required this.statsMid,
    required this.statsRight,
    required this.note,
  });

  final String status;
  final Color statusColor;
  final Color statusBg;
  final String date;
  final String sire;
  final String sireLine;
  final String sireRecord;
  final String dam;
  final String damLine;
  final String damRecord;
  final String statsLeft;
  final String statsMid;
  final String statsRight;
  final String note;
}
