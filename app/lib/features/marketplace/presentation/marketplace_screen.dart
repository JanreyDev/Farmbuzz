import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const double _kMarketplaceInset = 14;
const Color _kMarketplaceBg = Color(0xFFF5F5F5);
const Color _kMarketplaceDivider = Color(0xFFE8F5E9);
const Color _kMarketplaceMuted = Color(0xFF7B818A);
const Color _kMarketplaceCard = Colors.white;
const Color _kMarketplaceCardBorder = Color(0xFFE2E6EB);
const Color _kMarketplaceBgDark = Color(0xFF1F1F1F);
const Color _kMarketplaceCardDark = Color(0xFF242628);
const Color _kMarketplaceBorderDark = Color(0xFF35383D);
const Color _kMarketplaceMutedDark = Color(0xFFB0B8B2);
const Color _kPrimaryGreen = Color(0xFF2E7D32);
const Color _kDarkGreen = Color(0xFF1B5E20);
const Color _kLightGreen = Color(0xFF66BB6A);

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final Set<String> _wishlistIds = <String>{};
  final Set<String> _cartIds = <String>{};

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
                  children: [
                    _TopActionsBar(
                      wishlistCount: _wishlistIds.length,
                      cartCount: _cartIds.length,
                      onTapSell: () => _showCollectionMessage(
                        context,
                        title: 'Sell listing draft',
                        count: 0,
                        suffix: 'feature coming soon',
                      ),
                      onTapWishlist: () => _showCollectionMessage(
                        context,
                        title: 'Wishlist',
                        count: _wishlistIds.length,
                      ),
                      onTapCart: () => _showCollectionMessage(
                        context,
                        title: 'Cart',
                        count: _cartIds.length,
                      ),
                    ),
                    const _SearchBar(),
                    const _CategorySlider(),
                    _FeaturedSection(
                      wishlistIds: _wishlistIds,
                      cartIds: _cartIds,
                      onToggleWishlist: _toggleWishlist,
                      onToggleCart: _toggleCart,
                    ),
                    const _InsetBar(),
                    _AllListingsSection(
                      wishlistIds: _wishlistIds,
                      cartIds: _cartIds,
                      onToggleWishlist: _toggleWishlist,
                      onToggleCart: _toggleCart,
                    ),
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

  void _toggleWishlist(String id) {
    setState(() {
      if (_wishlistIds.contains(id)) {
        _wishlistIds.remove(id);
      } else {
        _wishlistIds.add(id);
      }
    });
  }

  void _toggleCart(String id) {
    setState(() {
      if (_cartIds.contains(id)) {
        _cartIds.remove(id);
      } else {
        _cartIds.add(id);
      }
    });
  }

  void _showCollectionMessage(
    BuildContext context, {
    required String title,
    required int count,
    String suffix = '',
  }) {
    final tail = suffix.isEmpty ? '' : ' ($suffix)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title items: $count$tail'),
        duration: const Duration(milliseconds: 900),
      ),
    );
  }
}

class _TopActionsBar extends StatelessWidget {
  const _TopActionsBar({
    required this.wishlistCount,
    required this.cartCount,
    required this.onTapSell,
    required this.onTapWishlist,
    required this.onTapCart,
  });

  final int wishlistCount;
  final int cartCount;
  final VoidCallback onTapSell;
  final VoidCallback onTapWishlist;
  final VoidCallback onTapCart;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(_kMarketplaceInset, 2, _kMarketplaceInset, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: onTapSell,
            style: OutlinedButton.styleFrom(
              foregroundColor: _kPrimaryGreen,
              side: const BorderSide(color: _kPrimaryGreen),
              visualDensity: VisualDensity.compact,
            ),
            icon: const Icon(Icons.storefront_outlined, size: 16),
            label: const Text('Sell'),
          ),
          const SizedBox(width: 8),
          _CountIconButton(
            icon: Icons.favorite_border,
            count: wishlistCount,
            tooltip: 'Wishlist',
            onTap: onTapWishlist,
          ),
          const SizedBox(width: 8),
          _CountIconButton(
            icon: Icons.shopping_cart_outlined,
            count: cartCount,
            tooltip: 'Cart',
            onTap: onTapCart,
          ),
        ],
      ),
    );
  }
}

class _CountIconButton extends StatelessWidget {
  const _CountIconButton({
    required this.icon,
    required this.count,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: isDark ? _kMarketplaceCardDark : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? _kMarketplaceBorderDark : _kMarketplaceCardBorder,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: _kPrimaryGreen),
              const SizedBox(width: 6),
              Text(
                '$count',
                style: const TextStyle(
                  color: _kPrimaryGreen,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          color: isDark ? const Color(0xFF1C1F22) : Colors.white,
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
        icon: Icons.bakery_dining_outlined,
        label: 'Feeds',
        selected: true,
      ),
      _CategoryData(icon: Icons.settings_outlined, label: 'Equipments'),
      _CategoryData(icon: Icons.medication_outlined, label: 'Medications'),
      _CategoryData(icon: Icons.grass_outlined, label: 'Vitamins'),
      _CategoryData(icon: Icons.health_and_safety_outlined, label: 'Supplements'),
      _CategoryData(icon: Icons.shopping_basket_outlined, label: 'Feeders'),
      _CategoryData(icon: Icons.more_horiz, label: 'Others'),
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
                  : (isDark ? _kMarketplaceCardDark : Colors.white),
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
  const _FeaturedSection({
    required this.wishlistIds,
    required this.cartIds,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final Set<String> wishlistIds;
  final Set<String> cartIds;
  final ValueChanged<String> onToggleWishlist;
  final ValueChanged<String> onToggleCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const featured = [
      _ListingData(
        title: 'High-Protein Breeder Mix (10kg)',
        price: '\u20B11,250',
        category: 'Feeds',
        location: 'San Fernando, Pampanga',
        imageUrl: 'https://images.pexels.com/photos/5946720/pexels-photo-5946720.jpeg?auto=compress&cs=tinysrgb&w=800',
        featured: true,
      ),
      _ListingData(
        title: 'Automatic Galvanized Feeder (5kg)',
        price: '\u20B11,850',
        category: 'Equipments',
        location: 'Batangas City',
        imageUrl: 'https://images.pexels.com/photos/2255459/pexels-photo-2255459.jpeg?auto=compress&cs=tinysrgb&w=800',
        featured: true,
      ),
      _ListingData(
        title: 'Premium Vitamin & Electrolyte Kit',
        price: '\u20B12,400',
        category: 'Vitamins',
        location: 'Tarlac City',
        imageUrl: 'https://images.pexels.com/photos/3683074/pexels-photo-3683074.jpeg?auto=compress&cs=tinysrgb&w=800',
        featured: true,
      ),
      _ListingData(
        title: 'Conditioning Multi-Vitamin Syrup',
        price: '\u20B1950',
        category: 'Supplements',
        location: 'Angeles City',
        imageUrl: 'https://images.pexels.com/photos/3683102/pexels-photo-3683102.jpeg?auto=compress&cs=tinysrgb&w=800',
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
                height: 258,
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
                    isWishlisted: wishlistIds.contains(featured[index].title),
                    inCart: cartIds.contains(featured[index].title),
                    onToggleWishlist: () =>
                        onToggleWishlist(featured[index].title),
                    onToggleCart: () => onToggleCart(featured[index].title),
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
  const _AllListingsSection({
    required this.wishlistIds,
    required this.cartIds,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final Set<String> wishlistIds;
  final Set<String> cartIds;
  final ValueChanged<String> onToggleWishlist;
  final ValueChanged<String> onToggleCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    const listings = [
      _ListingData(
        title: 'Organic Layer Pellets (25kg)',
        price: '\u20B12,800',
        category: 'Feeds',
        location: 'San Fernando, Pampanga',
        imageUrl: 'https://images.pexels.com/photos/5946722/pexels-photo-5946722.jpeg?auto=compress&cs=tinysrgb&w=800',
      ),
      _ListingData(
        title: 'Calcium & Egg Booster Tablets',
        price: '\u20B1650',
        category: 'Supplements',
        location: 'Tarlac City',
        imageUrl: 'https://images.pexels.com/photos/3683101/pexels-photo-3683101.jpeg?auto=compress&cs=tinysrgb&w=800',
      ),
      _ListingData(
        title: 'Hanging Plastic Feeder (3kg)',
        price: '\u20B1450',
        category: 'Feeders',
        location: 'Angeles City',
        imageUrl: 'https://images.pexels.com/photos/1002703/pexels-photo-1002703.jpeg?auto=compress&cs=tinysrgb&w=800',
      ),
      _ListingData(
        title: 'Poultry Dewormer Solution',
        price: '\u20B11,100',
        category: 'Medications',
        location: 'Nueva Ecija',
        imageUrl: 'https://images.pexels.com/photos/3683081/pexels-photo-3683081.jpeg?auto=compress&cs=tinysrgb&w=800',
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
              childAspectRatio: 0.76,
            ),
            itemBuilder: (context, index) =>
                _ListingCard(
                  data: listings[index],
                  isWishlisted: wishlistIds.contains(listings[index].title),
                  inCart: cartIds.contains(listings[index].title),
                  onToggleWishlist: () => onToggleWishlist(listings[index].title),
                  onToggleCart: () => onToggleCart(listings[index].title),
                ),
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
    required this.isWishlisted,
    required this.inCart,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final _ListingData data;
  final double? width;
  final bool emphasized;
  final bool showCategory;
  final bool isWishlisted;
  final bool inCart;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imageHeight = emphasized ? 162.0 : 136.0;

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
                Positioned(
                  top: 6,
                  right: 6,
                  child: Row(
                    children: [
                      _ActionIconChip(
                        icon: isWishlisted ? Icons.favorite : Icons.favorite_border,
                        active: isWishlisted,
                        onTap: onToggleWishlist,
                        darkMode: isDark,
                      ),
                      const SizedBox(width: 6),
                      _ActionIconChip(
                        icon: inCart
                            ? Icons.shopping_cart
                            : Icons.add_shopping_cart_outlined,
                        active: inCart,
                        onTap: onToggleCart,
                        darkMode: isDark,
                      ),
                    ],
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

class _ActionIconChip extends StatelessWidget {
  const _ActionIconChip({
    required this.icon,
    required this.active,
    required this.onTap,
    required this.darkMode,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final bool darkMode;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: active ? _kPrimaryGreen : Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 15,
          color: Colors.white,
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




