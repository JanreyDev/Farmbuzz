import 'package:app/app/theme/app_theme.dart';
import 'package:flutter/material.dart';

const double _kCockpitInset = 14;
const Color _kCockpitBg = Color(0xFFF1F1F1);
const Color _kCockpitMuted = Color(0xFF7B818A);

class CockpitDirectoryScreen extends StatelessWidget {
  const CockpitDirectoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const cockpits = [
      _CockpitData(
        name: 'Capitol Cockpit Arena',
        location: 'San Fernando, Pampanga',
        schedule: 'Wed, Sat, Sun - 8AM',
        rating: '4.7 (234)',
        events: '3 events',
        distance: '12km',
        amenities: ['Parking', 'Food Court', 'AC Seating', 'Vet On-Site'],
      ),
      _CockpitData(
        name: 'Tarlac Gallera',
        location: 'Tarlac City',
        schedule: 'Thu, Sat - 7AM',
        rating: '4.3 (156)',
        events: '2 events',
        distance: '28km',
        amenities: ['Parking', 'Food Stalls', 'Weighing Station'],
      ),
      _CockpitData(
        name: 'Thunderdome Arena',
        location: 'Angeles City',
        schedule: 'Fri, Sat, Sun - 9AM',
        rating: '4.8 (312)',
        events: '5 events',
        distance: '18km',
        amenities: ['Parking', 'VIP Lounge', 'Vet On-Site'],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ColoredBox(
          color: _kCockpitBg,
          child: Column(
            children: [
              const _Header(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(_kCockpitInset, 8, _kCockpitInset, 10),
                  children: [
                    const SizedBox(height: 6),
                    const _SearchBar(),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 6),
                      child: _FilterChips(),
                    ),
                    const SizedBox(height: 12),
                    const _MapPreviewCard(),
                    const SizedBox(height: 30),
                    const Text(
                      'Nearby Cockpits',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1F2230),
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...cockpits.map(
                      (cockpit) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CockpitCard(data: cockpit),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF2C3240), size: 20),
          ),
          const Expanded(
            child: Text(
              'Cockpit Directory',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2230),
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.map_outlined, color: kGoldAccent, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F2F5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      child: const Row(
        children: [
          Icon(Icons.search, size: 18, color: Color(0xFF9097A0)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Search cockpits by name or location...',
              style: TextStyle(fontSize: 12, color: Color(0xFF9097A0)),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips();

  @override
  Widget build(BuildContext context) {
    const chips = ['All', 'Nearby', 'Pampanga', 'Tarlac', 'Batangas'];
    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, index) => const SizedBox(width: 6),
        itemBuilder: (_, index) {
          final selected = index == 0;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFFF7EFD7) : const Color(0xFFE7EAEE),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: selected ? kGoldAccent : const Color(0xFFDEE2E8),
              ),
            ),
            child: Text(
              chips[index],
              style: TextStyle(
                fontSize: 11,
                color: selected ? const Color(0xFFA67913) : const Color(0xFF6F7680),
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MapPreviewCard extends StatelessWidget {
  const _MapPreviewCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E6EB)),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 38, color: Color(0xFF8A9098)),
          SizedBox(height: 6),
          Text(
            'Map view of 4 cockpits',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF3F4552),
            ),
          ),
          SizedBox(height: 2),
          Text(
            'Tap to expand full map',
            style: TextStyle(fontSize: 11, color: _kCockpitMuted),
          ),
        ],
      ),
    );
  }
}

class _CockpitCard extends StatelessWidget {
  const _CockpitCard({required this.data});

  final _CockpitData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDDE2E8)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  data.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1F2230),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFDFF4E0),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'LICENSED',
                  style: TextStyle(
                    fontSize: 9.5,
                    color: Color(0xFF519E5D),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: _kCockpitMuted),
              const SizedBox(width: 2),
              Text(data.location, style: const TextStyle(fontSize: 11, color: _kCockpitMuted)),
              const Spacer(),
              Text(
                data.distance,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFB68512),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              const Icon(Icons.schedule, size: 12, color: Color(0xFFB68512)),
              const SizedBox(width: 3),
              Text(data.schedule, style: const TextStyle(fontSize: 10.5, color: Color(0xFF59606C))),
              const SizedBox(width: 10),
              const Icon(Icons.star, size: 12, color: Color(0xFFB68512)),
              const SizedBox(width: 2),
              Text(data.rating, style: const TextStyle(fontSize: 10.5, color: Color(0xFF59606C))),
              const SizedBox(width: 10),
              const Icon(Icons.event_note_outlined, size: 12, color: Color(0xFF4E86D9)),
              const SizedBox(width: 2),
              Text(data.events, style: const TextStyle(fontSize: 10.5, color: Color(0xFF59606C))),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: data.amenities
                .map(
                  (amenity) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDEFF3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      amenity,
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF6F7680),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 8),
          const Divider(color: Color(0xFFE4E8ED), height: 1),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CardAction(icon: Icons.near_me_outlined, label: 'Directions'),
              _CardAction(icon: Icons.call_outlined, label: 'Call'),
              _CardAction(icon: Icons.event_outlined, label: 'Events'),
            ],
          ),
        ],
      ),
    );
  }
}

class _CardAction extends StatelessWidget {
  const _CardAction({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: const Color(0xFFB68512)),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFFB68512),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CockpitData {
  const _CockpitData({
    required this.name,
    required this.location,
    required this.schedule,
    required this.rating,
    required this.events,
    required this.distance,
    required this.amenities,
  });

  final String name;
  final String location;
  final String schedule;
  final String rating;
  final String events;
  final String distance;
  final List<String> amenities;
}
