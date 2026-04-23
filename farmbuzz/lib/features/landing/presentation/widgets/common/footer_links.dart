import 'package:flutter/material.dart';

class FooterLinks extends StatelessWidget {
  const FooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    const links = [
      'Privacy',
      'Terms',
      'Community',
      'Disclaimer',
      'Ambassador',
      'Age 18+',
    ];

    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final link in links)
            Text(
              link,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.62),
                fontSize: 11.5,
              ),
            ),
        ],
      ),
    );
  }
}
