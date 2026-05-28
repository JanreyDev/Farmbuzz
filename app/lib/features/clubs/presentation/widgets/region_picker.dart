import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';

class PhLocation {
  final String name;
  final String province;
  final bool isCity;

  const PhLocation({
    required this.name,
    required this.province,
    this.isCity = false,
  });
}

const List<PhLocation> _phLocations = [
  // NCR
  PhLocation(name: 'Manila', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Quezon City', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Caloocan', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Las Piñas', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Makati', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Malabon', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Mandaluyong', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Marikina', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Muntinlupa', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Navotas', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Parañaque', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Pasay', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Pasig', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Taguig', province: 'Metro Manila', isCity: true),
  PhLocation(name: 'Valenzuela', province: 'Metro Manila', isCity: true),
  // Luzon
  PhLocation(name: 'Angeles', province: 'Pampanga', isCity: true),
  PhLocation(name: 'Apalit', province: 'Pampanga'),
  PhLocation(name: 'Bacolor', province: 'Pampanga'),
  PhLocation(name: 'Candaba', province: 'Pampanga'),
  PhLocation(name: 'Floridablanca', province: 'Pampanga'),
  PhLocation(name: 'Guagua', province: 'Pampanga'),
  PhLocation(name: 'Lubao', province: 'Pampanga'),
  PhLocation(name: 'Mabalacat', province: 'Pampanga', isCity: true),
  PhLocation(name: 'Macabebe', province: 'Pampanga'),
  PhLocation(name: 'Magalang', province: 'Pampanga'),
  PhLocation(name: 'Masantol', province: 'Pampanga'),
  PhLocation(name: 'Mexico', province: 'Pampanga'),
  PhLocation(name: 'Minalin', province: 'Pampanga'),
  PhLocation(name: 'Porac', province: 'Pampanga'),
  PhLocation(name: 'San Fernando', province: 'Pampanga', isCity: true),
  PhLocation(name: 'San Luis', province: 'Pampanga'),
  PhLocation(name: 'San Simon', province: 'Pampanga'),
  PhLocation(name: 'Santa Ana', province: 'Pampanga'),
  PhLocation(name: 'Santa Rita', province: 'Pampanga'),
  PhLocation(name: 'Santo Tomas', province: 'Pampanga'),
  PhLocation(name: 'Sasmuan', province: 'Pampanga'),
  PhLocation(name: 'Cabanatuan', province: 'Nueva Ecija', isCity: true),
  PhLocation(name: 'Gapan', province: 'Nueva Ecija', isCity: true),
  PhLocation(name: 'Palayan', province: 'Nueva Ecija', isCity: true),
  PhLocation(name: 'San Jose', province: 'Nueva Ecija', isCity: true),
  PhLocation(name: 'Zaragoza', province: 'Nueva Ecija'),
  PhLocation(name: 'Batangas', province: 'Batangas', isCity: true),
  PhLocation(name: 'Lipa', province: 'Batangas', isCity: true),
  PhLocation(name: 'Tanauan', province: 'Batangas', isCity: true),
  PhLocation(name: 'Lucena', province: 'Quezon', isCity: true),
  PhLocation(name: 'Antipolo', province: 'Rizal', isCity: true),
  PhLocation(name: 'Cainta', province: 'Rizal'),
  PhLocation(name: 'Taytay', province: 'Rizal'),
  PhLocation(name: 'Baguio', province: 'Benguet', isCity: true),
  PhLocation(name: 'San Carlos', province: 'Pangasinan', isCity: true),
  PhLocation(name: 'Dagupan', province: 'Pangasinan', isCity: true),
  PhLocation(name: 'Urdaneta', province: 'Pangasinan', isCity: true),
  PhLocation(name: 'Vigan', province: 'Ilocos Sur', isCity: true),
  PhLocation(name: 'Laoag', province: 'Ilocos Norte', isCity: true),
  PhLocation(name: 'Tuguegarao', province: 'Cagayan', isCity: true),
  PhLocation(name: 'Cauayan', province: 'Isabela', isCity: true),
  PhLocation(name: 'Santiago', province: 'Isabela', isCity: true),
  PhLocation(name: 'Ilagan', province: 'Isabela', isCity: true),
  // Visayas
  PhLocation(name: 'Cebu City', province: 'Cebu', isCity: true),
  PhLocation(name: 'Mandaue', province: 'Cebu', isCity: true),
  PhLocation(name: 'Lapu-Lapu', province: 'Cebu', isCity: true),
  PhLocation(name: 'Danao', province: 'Cebu', isCity: true),
  PhLocation(name: 'Toledo', province: 'Cebu', isCity: true),
  PhLocation(name: 'Iloilo City', province: 'Iloilo', isCity: true),
  PhLocation(name: 'Passi', province: 'Iloilo', isCity: true),
  PhLocation(name: 'Bacolod', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Bago', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Cadiz', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Escalante', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Himamaylan', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Kabankalan', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'La Carlota', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Sagay', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'San Carlos', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Silay', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Sipalay', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Talisay', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Victorias', province: 'Negros Occidental', isCity: true),
  PhLocation(name: 'Dumaguete', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Bais', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Bayawan', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Canlaon', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Guihulngan', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Tanjay', province: 'Negros Oriental', isCity: true),
  PhLocation(name: 'Zamboanguita', province: 'Negros Oriental'),
  PhLocation(name: 'Tagbilaran', province: 'Bohol', isCity: true),
  PhLocation(name: 'Tacloban', province: 'Leyte', isCity: true),
  PhLocation(name: 'Ormoc', province: 'Leyte', isCity: true),
  PhLocation(name: 'Maasin', province: 'Southern Leyte', isCity: true),
  PhLocation(name: 'Calbayog', province: 'Samar', isCity: true),
  PhLocation(name: 'Catbalogan', province: 'Samar', isCity: true),
  PhLocation(name: 'Zumarraga', province: 'Samar'),
  // Mindanao
  PhLocation(name: 'Davao City', province: 'Davao del Sur', isCity: true),
  PhLocation(name: 'Digos', province: 'Davao del Sur', isCity: true),
  PhLocation(name: 'Panabo', province: 'Davao del Norte', isCity: true),
  PhLocation(name: 'Samal', province: 'Davao del Norte', isCity: true),
  PhLocation(name: 'Tagum', province: 'Davao del Norte', isCity: true),
  PhLocation(name: 'Mati', province: 'Davao Oriental', isCity: true),
  PhLocation(name: 'Cagayan de Oro', province: 'Misamis Oriental', isCity: true),
  PhLocation(name: 'El Salvador', province: 'Misamis Oriental', isCity: true),
  PhLocation(name: 'Gingoog', province: 'Misamis Oriental', isCity: true),
  PhLocation(name: 'Oroquieta', province: 'Misamis Occidental', isCity: true),
  PhLocation(name: 'Ozamiz', province: 'Misamis Occidental', isCity: true),
  PhLocation(name: 'Tangub', province: 'Misamis Occidental', isCity: true),
  PhLocation(name: 'General Santos', province: 'South Cotabato', isCity: true),
  PhLocation(name: 'Koronadal', province: 'South Cotabato', isCity: true),
  PhLocation(name: 'Kidapawan', province: 'North Cotabato', isCity: true),
  PhLocation(name: 'Iligan', province: 'Lanao del Norte', isCity: true),
  PhLocation(name: 'Marawi', province: 'Lanao del Sur', isCity: true),
  PhLocation(name: 'Butuan', province: 'Agusan del Norte', isCity: true),
  PhLocation(name: 'Cabadbaran', province: 'Agusan del Norte', isCity: true),
  PhLocation(name: 'Bayugan', province: 'Agusan del Sur', isCity: true),
  PhLocation(name: 'Surigao', province: 'Surigao del Norte', isCity: true),
  PhLocation(name: 'Bislig', province: 'Surigao del Sur', isCity: true),
  PhLocation(name: 'Tandag', province: 'Surigao del Sur', isCity: true),
  PhLocation(name: 'Zamboanga City', province: 'Zamboanga del Sur', isCity: true),
  PhLocation(name: 'Dapitan', province: 'Zamboanga del Norte', isCity: true),
  PhLocation(name: 'Dipolog', province: 'Zamboanga del Norte', isCity: true),
  PhLocation(name: 'Isabela', province: 'Basilan', isCity: true),
  PhLocation(name: 'Lamitan', province: 'Basilan', isCity: true),
  PhLocation(name: 'Pagadian', province: 'Zamboanga del Sur', isCity: true),
  PhLocation(name: 'Zamboanguita', province: 'Negros Oriental'),
];

class RegionPicker extends StatefulWidget {
  final String? selectedValue;
  final ValueChanged<String> onSelected;

  const RegionPicker({
    super.key,
    this.selectedValue,
    required this.onSelected,
  });

  @override
  State<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends State<RegionPicker> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<PhLocation> _filtered = [];
  bool _showDropdown = false;

  @override
  void initState() {
    super.initState();
    if (widget.selectedValue != null) {
      _controller.text = widget.selectedValue!;
    }
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showDropdown = false);
        });
      }
    });
  }

  void _onChanged(String query) {
    final q = query.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = [];
        _showDropdown = false;
      } else {
        _filtered = _phLocations
            .where((loc) =>
                loc.name.toLowerCase().contains(q) ||
                loc.province.toLowerCase().contains(q))
            .toList();
        _showDropdown = true;
      }
    });
  }

  void _select(PhLocation loc) {
    final value = '${loc.name}, ${loc.province}';
    _controller.text = value;
    _focusNode.unfocus();
    setState(() {
      _filtered = [];
      _showDropdown = false;
    });
    widget.onSelected(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search input
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: _focusNode.hasFocus
                  ? AppColors.accentGreen
                  : Colors.grey.shade300,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  LucideIcons.mapPin,
                  size: 16,
                  color: _focusNode.hasFocus
                      ? AppColors.accentGreen
                      : Colors.grey.shade500,
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  onChanged: _onChanged,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                  decoration: InputDecoration(
                    hintText: 'Search city or province…',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400, fontSize: 14),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              if (_controller.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _controller.clear();
                    setState(() {
                      _filtered = [];
                      _showDropdown = false;
                    });
                    widget.onSelected('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(LucideIcons.x,
                        size: 14, color: Colors.grey.shade400),
                  ),
                ),
            ],
          ),
        ),

        // Dropdown results
        if (_showDropdown && _filtered.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 4),
                shrinkWrap: true,
                itemCount: _filtered.length,
                separatorBuilder: (context, index) => Divider(
                  height: 1,
                  color: Colors.grey.shade100,
                  indent: 44,
                ),
                itemBuilder: (context, index) {
                  final loc = _filtered[index];
                  return InkWell(
                    onTap: () => _select(loc),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Icon(LucideIcons.mapPin,
                              size: 15, color: Colors.grey.shade400),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.name,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  loc.province,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.accentGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (loc.isCity)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.accentGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'CITY',
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.accentGreen,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        if (_showDropdown && _filtered.isEmpty)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(LucideIcons.searchX,
                    size: 16, color: Colors.grey.shade400),
                const SizedBox(width: 10),
                Text(
                  'No locations found',
                  style: TextStyle(
                      color: Colors.grey.shade500, fontSize: 13),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
