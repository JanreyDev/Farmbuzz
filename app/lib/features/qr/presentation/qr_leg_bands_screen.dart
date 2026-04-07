import 'package:flutter/material.dart';

const Color _kQrBg = Color(0xFFF0F2F5);
const Color _kQrSurface = Colors.white;
const Color _kQrBorder = Color(0xFFE2E6EB);
const Color _kQrMuted = Color(0xFF7C828C);
const Color _kGold = Color(0xFFC9A227);

class QrLegBandsScreen extends StatelessWidget {
  const QrLegBandsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const birds = [
      _QrBirdData(name: 'Thunder', bloodline: 'Kelso', weight: '2.1kg'),
      _QrBirdData(name: 'Inferno', bloodline: 'Sweater', weight: '2.4kg'),
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
                      'QR Leg Bands',
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
                    icon: const Icon(Icons.photo_camera_outlined),
                    color: _kGold,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: _kQrBg,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 12, 14, 20),
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8EA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFEBDDB8)),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Color(0xFFC38F15),
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'QR Code Leg Bands',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFC38F15),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Generate unique QR codes for each bird. Scan to instantly view health records, lineage, and fight history.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _kQrMuted,
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 46,
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
                        icon: const Icon(Icons.qr_code_scanner, size: 19),
                        label: const Text(
                          'Scan Existing Band',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Your Birds',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...birds.map(
                      (bird) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _BirdQrCard(data: bird),
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

class _BirdQrCard extends StatelessWidget {
  const _BirdQrCard({required this.data});

  final _QrBirdData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kQrSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _kQrBorder),
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined, color: _kGold, size: 16),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1F2230),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFAF2DE),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          data.bloodline,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFB68512),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        data.weight,
                        style: const TextStyle(
                          fontSize: 10,
                          color: _kQrMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFFCAD1D8),
                style: BorderStyle.solid,
              ),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_2, size: 26, color: Color(0xFF8B929C)),
                SizedBox(height: 4),
                Text(
                  'QR Code',
                  style: TextStyle(fontSize: 10, color: _kQrMuted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFE8EBEF)),
          const SizedBox(height: 10),
          Row(
            children: const [
              Expanded(child: _BirdAction(label: 'Generate', icon: Icons.download)),
              SizedBox(width: 8),
              Expanded(child: _BirdAction(label: 'Print', icon: Icons.print_outlined)),
              SizedBox(width: 8),
              Expanded(child: _BirdAction(label: 'Share', icon: Icons.share_outlined)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BirdAction extends StatelessWidget {
  const _BirdAction({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      decoration: BoxDecoration(
        color: const Color(0xFFFAF7EE),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 13, color: const Color(0xFFB68512)),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: Color(0xFFB68512),
            ),
          ),
        ],
      ),
    );
  }
}

class _QrBirdData {
  const _QrBirdData({
    required this.name,
    required this.bloodline,
    required this.weight,
  });

  final String name;
  final String bloodline;
  final String weight;
}
