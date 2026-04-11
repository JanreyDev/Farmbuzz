import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/theme/app_theme.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:flutter/material.dart';

const double _kMarketplaceInset = 14;
const Color _kMarketplaceBg = Color(0xFFF1F1F1);
const Color _kMarketplaceDivider = Color(0xFFE6E9ED);
const Color _kMarketplaceMuted = Color(0xFF7B818A);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _kMarketplaceBg,
      body: SafeArea(
        child: ColoredBox(
          color: _kMarketplaceBg,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 12),
                  children: const [
                    _TopBarSurface(),
                    _SearchBar(),
                    _CategorySlider(),
                    _FeaturedSection(),
                    _InsetBar(),
                    _AllListingsSection(),
                  ],
                ),
              ),
              Theme(
                data: theme.copyWith(cardColor: _kMarketplaceBg),
                child: AppBottomNav(
                  activeItem: AppBottomNavItem.market,
                  onItemTap: (item) => _handleNav(context, item),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleNav(BuildContext context, AppBottomNavItem item) {
    if (item == AppBottomNavItem.home) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else if (item == AppBottomNavItem.explore) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.farmDashboard);
    } else if (item == AppBottomNavItem.profile) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.profile);
    } else if (item == AppBottomNavItem.create) {
      Navigator.of(context).pushReplacementNamed(AppRoutes.groups);
    }
  }
}

class _TopBarSurface extends StatelessWidget {
  const _TopBarSurface();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(
                _kMarketplaceInset,
                6,
                _kMarketplaceInset,
                6,
              ),
              child: _TopBar(),
            ),
            Container(
              height: 1,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                alpha: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Center(
            child: Text(
              'Marketplace',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1F2230),
                height: 1,
              ),
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back),
              visualDensity: VisualDensity.compact,
              tooltip: 'Back',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: kGoldAccent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                '+ Sell',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kMarketplaceInset,
        10,
        _kMarketplaceInset,
        8,
      ),
      child: Container(
        height: 36,
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
                'Search marketplace...',
                style: TextStyle(fontSize: 13, color: Color(0xFF9097A0)),
              ),
            ),
            Icon(Icons.tune, size: 16, color: kGoldAccent),
          ],
        ),
      ),
    );
  }
}

class _CategorySlider extends StatelessWidget {
  const _CategorySlider();

  @override
  Widget build(BuildContext context) {
    const categories = [
      _CategoryData(
        icon: Icons.sports_mma,
        label: 'Battle Cocks',
        selected: true,
      ),
      _CategoryData(icon: Icons.flag, label: 'Stags'),
      _CategoryData(icon: Icons.favorite_border, label: 'Brood Hens'),
      _CategoryData(icon: Icons.egg_alt_outlined, label: 'Feeds'),
      _CategoryData(icon: Icons.medical_services_outlined, label: 'Supplies'),
      _CategoryData(icon: Icons.grass_outlined, label: 'Vitamins'),
      _CategoryData(icon: Icons.pets_outlined, label: 'Others'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_kMarketplaceInset, 8, 0, 0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const spacing = 8.0;
          const visibleItems = 4.5;
          final itemWidth =
              (constraints.maxWidth - (spacing * (visibleItems - 1))) /
              visibleItems;

          return SizedBox(
            height: 84,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, index) => const SizedBox(width: spacing),
              itemBuilder: (_, index) =>
                  _CategoryItem(data: categories[index], width: itemWidth),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.data, required this.width});

  final _CategoryData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.selected ? _kPrimaryGreen : const Color(0xFFEAF4EB),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.selected ? _kLightGreen : const Color(0xFFCFE4D1),
              ),
            ),
            child: Icon(
              data.icon,
              size: 21,
              color: data.selected ? Colors.white : _kDarkGreen,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: data.selected
                  ? _kDarkGreen
                  : const Color(0xFF72807A),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection();

  @override
  Widget build(BuildContext context) {
    const featured = [
      _ListingData(
        title: 'Pure Kelso Stags (7 months)',
        price: '\u20B18,500',
        category: 'Kelso',
        location: 'San Fernando, Pampanga',
        imageUrl: 'https://picsum.photos/id/1025/900/700',
        featured: true,
      ),
      _ListingData(
        title: 'Battle Cock - 12 Wins',
        price: '\u20B125,000',
        category: '',
        location: 'Batangas City',
        imageUrl: 'https://picsum.photos/id/1044/900/700',
        featured: true,
      ),
      _ListingData(
        title: 'Grey Hatch Trio Package',
        price: '\u20B118,000',
        category: 'Hatch',
        location: 'Tarlac City',
        imageUrl: 'https://picsum.photos/id/237/900/700',
        featured: true,
      ),
      _ListingData(
        title: 'Roundhead Breeder Pair',
        price: '\u20B112,500',
        category: 'Roundhead',
        location: 'Angeles City',
        imageUrl: 'https://picsum.photos/id/433/900/700',
        featured: true,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(_kMarketplaceInset, 10, 0, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.star_border, size: 19, color: Color(0xFFAA7E14)),
              SizedBox(width: 4),
              Text(
                'Featured',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1F2230),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              const spacing = 10.0;
              const visibleCards = 1.75;
              final cardWidth =
                  (constraints.maxWidth - (spacing * (visibleCards - 1))) /
                  visibleCards;

              return SizedBox(
                height: 244,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: featured.length,
                  separatorBuilder: (_, index) =>
                      const SizedBox(width: spacing),
                  itemBuilder: (_, index) => _ListingCard(
                    data: featured[index],
                    width: cardWidth,
                    emphasized: true,
                    showCategory: false,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _AllListingsSection extends StatelessWidget {
  const _AllListingsSection();

  @override
  Widget build(BuildContext context) {
    const listings = [
      _ListingData(
        title: 'Pure Kelso Stags (7 months)',
        price: '\u20B18,500',
        category: 'Kelso',
        location: 'San Fernando, Pampanga',
        imageUrl: 'https://picsum.photos/id/1074/900/700',
      ),
      _ListingData(
        title: 'Sweater Brood Hen - Proven',
        price: '\u20B115,000',
        category: 'Sweater',
        location: 'Tarlac City',
        imageUrl: 'https://picsum.photos/id/169/900/700',
      ),
      _ListingData(
        title: 'Hatch Pullet - Ready',
        price: '\u20B17,200',
        category: 'Hatch',
        location: 'Angeles City',
        imageUrl: 'https://picsum.photos/id/582/900/700',
      ),
      _ListingData(
        title: 'Roundhead Breeder Trio',
        price: '\u20B122,000',
        category: 'Roundhead',
        location: 'Nueva Ecija',
        imageUrl: 'https://picsum.photos/id/593/900/700',
      ),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        _kMarketplaceInset,
        10,
        _kMarketplaceInset,
        12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Listings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1F2230),
              height: 1,
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            itemCount: listings.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.74,
            ),
            itemBuilder: (context, index) =>
                _ListingCard(data: listings[index]),
          ),
        ],
      ),
    );
  }
}

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.data,
    this.width,
    this.emphasized = false,
    this.showCategory = true,
  });

  final _ListingData data;
  final double? width;
  final bool emphasized;
  final bool showCategory;

  @override
  Widget build(BuildContext context) {
    final imageHeight = emphasized ? 152.0 : 126.0;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFE2E6EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  child: SizedBox(
                    height: imageHeight,
                    width: double.infinity,
                    child: Image.network(
                      data.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const ColoredBox(
                          color: Color(0xFFE9ECF0),
                          child: Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.6,
                              ),
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const ColoredBox(
                          color: Color(0xFFE9ECF0),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 20,
                              color: Color(0xFF9DA3AC),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (data.featured)
                  Positioned(
                    left: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8EFCF),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'FEATURED',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFA67913),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 7, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: emphasized ? 12 : 11,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1F2230),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFBB8610),
                      height: 1,
                    ),
                  ),
                  if (showCategory && data.category.isNotEmpty) ...[
                    const SizedBox(height: 2),
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
                        data.category,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFB68512),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 10,
                        color: _kMarketplaceMuted,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          data.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 9,
                            color: _kMarketplaceMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsetBar extends StatelessWidget {
  const _InsetBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: _kMarketplaceInset),
      child: Divider(height: 8, thickness: 7, color: _kMarketplaceDivider),
    );
  }
}

class _CategoryData {
  const _CategoryData({
    required this.icon,
    required this.label,
    this.selected = false,
  });

  final IconData icon;
  final String label;
  final bool selected;
}

class _ListingData {
  const _ListingData({
    required this.title,
    required this.price,
    required this.category,
    required this.location,
    required this.imageUrl,
    this.featured = false,
  });

  final String title;
  final String price;
  final String category;
  final String location;
  final String imageUrl;
  final bool featured;
}


