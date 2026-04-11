import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const double _kMarketplaceInset = 14;
const Color _kMarketplaceBg = Color(0xFFF5F5F5);
const Color _kMarketplaceDivider = Color(0xFFE8F5E9);
const Color _kMarketplaceMuted = Color(0xFF7B818A);
const Color _kMarketplaceCard = Color(0xFFE8F5E9);
const Color _kMarketplaceCardBorder = Color(0xFFCFE4D1);
const Color _kMarketplaceBgDark = Color(0xFF1F1F1F);
const Color _kMarketplaceCardDark = Color(0xFF242628);
const Color _kMarketplaceBorderDark = Color(0xFF35383D);
const Color _kMarketplaceMutedDark = Color(0xFFB0B8B2);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final screenBg = isDark ? _kMarketplaceBgDark : _kMarketplaceBg;

    return Scaffold(
      backgroundColor: screenBg,
      appBar: const FarmBuzzHomeAppBar(),
      drawer: const FarmBuzzAppDrawer(),
      body: SafeArea(
        top: false,
        bottom: false,
        child: ColoredBox(
          color: screenBg,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 12),
                  children: const [
                    _SearchBar(),
                    _CategorySlider(),
                    _FeaturedSection(),
                    _InsetBar(),
                    _AllListingsSection(),
                  ],
                ),
              ),
              Theme(
                data: theme.copyWith(cardColor: screenBg),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          color: isDark ? const Color(0xFF1C1F22) : const Color(0xFFF0F2F5),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? _kMarketplaceBorderDark : const Color(0xFFE2E6EB),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.search,
              size: 18,
              color: isDark ? _kMarketplaceMutedDark : const Color(0xFF9097A0),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Search marketplace...',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark
                      ? _kMarketplaceMutedDark
                      : const Color(0xFF9097A0),
                ),
              ),
            ),
            const Icon(Icons.tune, size: 16, color: _kPrimaryGreen),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: width,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: data.selected
                  ? _kPrimaryGreen
                  : (isDark ? _kMarketplaceCardDark : const Color(0xFFE8F5E9)),
              shape: BoxShape.circle,
              border: Border.all(
                color: data.selected
                    ? _kLightGreen
                    : (isDark
                          ? _kMarketplaceBorderDark
                          : const Color(0xFFB7DDB9)),
              ),
            ),
            child: Icon(
              data.icon,
              size: 21,
              color: data.selected
                  ? Colors.white
                  : (isDark ? _kLightGreen : _kDarkGreen),
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
                  ? (isDark ? _kLightGreen : _kDarkGreen)
                  : (isDark ? _kMarketplaceMutedDark : const Color(0xFF72807A)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Row(
            children: [
              const Icon(Icons.star_border, size: 19, color: _kPrimaryGreen),
              const SizedBox(width: 4),
              Text(
                'Featured',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : _kDarkGreen,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          Text(
            'All Listings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : _kDarkGreen,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageHeight = emphasized ? 152.0 : 126.0;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? _kMarketplaceCardDark : _kMarketplaceCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? _kMarketplaceBorderDark : _kMarketplaceCardBorder,
          ),
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
                        return ColoredBox(
                          color: isDark
                              ? const Color(0xFF1C1F22)
                              : const Color(0xFFE9ECF0),
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
                        return ColoredBox(
                          color: isDark
                              ? const Color(0xFF1C1F22)
                              : const Color(0xFFE9ECF0),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_outlined,
                              size: 20,
                              color: isDark
                                  ? _kMarketplaceMutedDark
                                  : const Color(0xFF9DA3AC),
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
                        color: isDark
                            ? const Color(0xFF1F3B22)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'FEATURED',
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: _kLightGreen,
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
                      color: isDark ? Colors.white : const Color(0xFF1F2230),
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    data.price,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _kPrimaryGreen,
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
                        color: isDark
                            ? const Color(0xFF1F3B22)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        data.category,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w700,
                          color: isDark ? _kLightGreen : _kDarkGreen,
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
                          style: TextStyle(
                            fontSize: 9,
                            color: isDark
                                ? _kMarketplaceMutedDark
                                : _kMarketplaceMuted,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _kMarketplaceInset),
      child: Divider(
        height: 8,
        thickness: 7,
        color: isDark ? const Color(0xFF2A2D31) : _kMarketplaceDivider,
      ),
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




