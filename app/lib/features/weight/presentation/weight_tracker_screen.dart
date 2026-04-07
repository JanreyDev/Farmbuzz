import 'package:flutter/material.dart';

const Color _kBg = Color(0xFFF0F2F5);
const Color _kSurface = Colors.white;
const Color _kBorder = Color(0xFFE2E6EB);
const Color _kMuted = Color(0xFF7C828C);
const Color _kGold = Color(0xFFC9A227);

class WeightTrackerScreen extends StatelessWidget {
  const WeightTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bars = [0.22, 0.30, 0.44, 0.56, 0.70, 0.63, 0.80, 0.88, 0.84, 0.89, 0.96, 0.96, 0.96];
    const history = [
      ('Apr 4', '2.10 kg', null),
      ('Apr 3', '2.10 kg', 'up'),
      ('Apr 2', '2.10 kg', 'up'),
      ('Apr 1', '2.08 kg', 'down'),
      ('Mar 31', '2.07 kg', 'down'),
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
                      'Weight Tracker',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: _kBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  children: [
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.shield_outlined, color: _kGold, size: 17),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Thunder',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1F2230),
                              ),
                            ),
                          ),
                          Icon(Icons.expand_more, color: Color(0xFF9AA1AA)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: const Column(
                        children: [
                          Text(
                            'CURRENT WEIGHT',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.2,
                              color: _kMuted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            '2.10 kg',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2230),
                              height: 1,
                            ),
                          ),
                          SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Target: 2.15 kg',
                                style: TextStyle(fontSize: 11, color: _kMuted),
                              ),
                              SizedBox(width: 8),
                              Text(
                                '0.05 kg to go',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _kGold,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Weight History',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2230),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 120,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: bars
                                  .map(
                                    (v) => Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 2),
                                        child: Container(
                                          height: 98 * v,
                                          decoration: BoxDecoration(
                                            color: _kGold,
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList(growable: false),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 44,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _kGold,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.add, size: 19),
                        label: const Text(
                          'Log New Weight',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'History',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: _kSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _kBorder),
                      ),
                      child: Column(
                        children: history.map((row) {
                          final trend = row.$3;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        row.$1,
                                        style: const TextStyle(fontSize: 12, color: _kMuted),
                                      ),
                                    ),
                                    Text(
                                      row.$2,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                        color: Color(0xFF1F2230),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      trend == 'up'
                                          ? Icons.arrow_drop_up
                                          : trend == 'down'
                                              ? Icons.arrow_drop_down
                                              : Icons.remove,
                                      color: trend == 'up'
                                          ? const Color(0xFF2EA54A)
                                          : trend == 'down'
                                              ? const Color(0xFFD23A3A)
                                              : Colors.transparent,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                              if (row != history.last)
                                const Divider(height: 1, color: Color(0xFFE8EBEF)),
                            ],
                          );
                        }).toList(growable: false),
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
