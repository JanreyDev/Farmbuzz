import 'package:flutter/material.dart';

const Color _kBg = Color(0xFFF0F2F5);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFE2E6EB);
const Color _kMuted = Color(0xFF7C828C);
const Color _kGold = Color(0xFFC9A227);

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const filters = ['All', 'Vaccination', 'Deworming', 'Disease'];
    const records = [
      _HealthRecord(
        title: 'Deworming (Ivermectin)',
        bird: 'Thunder',
        date: 'Mar 5, 2026',
        nextDue: 'Apr 5, 2026',
        note: 'Oral administration. No adverse reaction.',
        status: 'UPCOMING',
        dotColor: Color(0xFFE3A320),
        statusBg: Color(0xFFE9EDF1),
        statusColor: Color(0xFF7C828C),
      ),
      _HealthRecord(
        title: 'Newcastle Disease Vaccine',
        bird: 'Thunder',
        date: 'Feb 15, 2026',
        nextDue: 'Aug 15, 2026',
        note: 'Intracular. Batch #NCD-2026-A.',
        status: 'COMPLETED',
        dotColor: Color(0xFF2EA54A),
        statusBg: Color(0xFFDFF2E5),
        statusColor: Color(0xFF2EA54A),
      ),
      _HealthRecord(
        title: 'Minor leg laceration',
        bird: 'Inferno',
        date: 'Mar 20, 2026',
        nextDue: null,
        note: 'From sparring. Cleaned and dressed. Healing well.',
        status: 'COMPLETED',
        dotColor: Color(0xFF2EA54A),
        statusBg: Color(0xFFDFF2E5),
        statusColor: Color(0xFF2EA54A),
      ),
      _HealthRecord(
        title: 'Pre-derby checkup',
        bird: 'Viper',
        date: 'Apr 2, 2026',
        nextDue: null,
        note: 'All clear. Fit for competition. Weight on target.',
        status: 'COMPLETED',
        dotColor: Color(0xFF2EA54A),
        statusBg: Color(0xFFDFF2E5),
        statusColor: Color(0xFF2EA54A),
      ),
      _HealthRecord(
        title: 'Deworming (Albendazole)',
        bird: 'Inferno',
        date: 'Mar 1, 2026',
        nextDue: 'Apr 1, 2026',
        note: 'Overdue by 3 days.',
        status: 'OVERDUE',
        dotColor: Color(0xFFD23A3A),
        statusBg: Color(0xFFE9EDF1),
        statusColor: Color(0xFF7C828C),
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
                      'Health Records',
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
                    SizedBox(
                      height: 32,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, index) => const SizedBox(width: 8),
                        itemBuilder: (_, index) => _FilterChip(
                          label: filters[index],
                          selected: index == 0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 110,
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_month_outlined, color: _kGold),
                          SizedBox(height: 8),
                          Text(
                            'Calendar View',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1F2230),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Coming soon',
                            style: TextStyle(fontSize: 11, color: _kMuted),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Records',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...records.map(
                      (record) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _HealthRecordCard(record: record),
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

class _FilterChip extends StatelessWidget {
  const _FilterChip({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFFBF4E3) : const Color(0xFFE8EBEF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: selected ? _kGold : const Color(0xFFDCE1E7)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: selected ? const Color(0xFFA57913) : const Color(0xFF6F7680),
        ),
      ),
    );
  }
}

class _HealthRecordCard extends StatelessWidget {
  const _HealthRecordCard({required this.record});

  final _HealthRecord record;

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
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: record.dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  record.title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: record.statusBg,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.status,
                  style: TextStyle(
                    fontSize: 9,
                    color: record.statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: record.bird,
                  style: const TextStyle(
                    fontSize: 10,
                    color: _kGold,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: '  ${record.date}',
                  style: const TextStyle(fontSize: 10, color: _kMuted),
                ),
              ],
            ),
          ),
          if (record.nextDue != null) ...[
            const SizedBox(height: 2),
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Next due: ',
                    style: TextStyle(fontSize: 10, color: _kMuted),
                  ),
                  TextSpan(
                    text: record.nextDue!,
                    style: TextStyle(
                      fontSize: 10,
                      color: record.status == 'OVERDUE' ? const Color(0xFFD23A3A) : _kMuted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 3),
          Text(
            record.note,
            style: const TextStyle(fontSize: 10, color: _kMuted),
          ),
        ],
      ),
    );
  }
}

class _HealthRecord {
  const _HealthRecord({
    required this.title,
    required this.bird,
    required this.date,
    required this.nextDue,
    required this.note,
    required this.status,
    required this.dotColor,
    required this.statusBg,
    required this.statusColor,
  });

  final String title;
  final String bird;
  final String date;
  final String? nextDue;
  final String note;
  final String status;
  final Color dotColor;
  final Color statusBg;
  final Color statusColor;
}
