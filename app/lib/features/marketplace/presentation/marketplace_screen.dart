import 'package:app/app/navigation/app_routes.dart';
import 'package:app/app/widgets/app_bottom_nav.dart';
import 'package:app/app/widgets/app_drawer.dart';
import 'package:app/features/home/presentation/widgets/custom_app_bar.dart';
import 'package:flutter/material.dart';

const Color _kStoreBgLight = Color(0xFFF5F5F5);
const Color _kStoreBgDark = Color(0xFF121212);
const Color _kStoreCardLight = Colors.white;
const Color _kStoreCardDark = Color(0xFF1A1A1A);
const Color _kStoreBorderDark = Color(0xFF2E2E2E);
const Color _kStorePrimary = Color(0xFF22C55E);
const Color _kStoreAccent = Color(0xFFDCFCE7);
const Color _kStoreMuted = Color(0xFF6B7280);

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final Set<String> _wishlistIds = <String>{};
  final Set<String> _cartIds = <String>{};
  String _selectedCategory = 'All';
  String _searchQuery = '';

  static const List<_StoreCategory> _categories = [
    _StoreCategory(label: 'All', icon: Icons.grid_view_rounded),
    _StoreCategory(label: 'Feeds', icon: Icons.grain_outlined),
    _StoreCategory(label: 'Equip', icon: Icons.precision_manufacturing_outlined),
    _StoreCategory(label: 'Meds', icon: Icons.medication_outlined),
    _StoreCategory(label: 'Vitamins', icon: Icons.science_outlined),
    _StoreCategory(label: 'Others', icon: Icons.more_horiz_rounded),
  ];

  static const List<_ListingData> _allListings = [
    _ListingData(
      id: 'l1',
      title: 'High-Protein Breeder Mix (10kg)',
      price: '\u20B11,250',
      category: 'Feeds',
      location: 'San Fernando, Pampanga',
      imageUrl: 'https://images.pexels.com/photos/5946720/pexels-photo-5946720.jpeg?auto=compress&cs=tinysrgb&w=900',
      featured: true,
    ),
    _ListingData(
      id: 'l2',
      title: 'Automatic Galvanized Feeder (5kg)',
      price: '\u20B11,850',
      category: 'Equip',
      location: 'Batangas City',
      imageUrl: 'https://images.pexels.com/photos/2255459/pexels-photo-2255459.jpeg?auto=compress&cs=tinysrgb&w=900',
      featured: true,
    ),
    _ListingData(
      id: 'l3',
      title: 'Premium Vitamin & Electrolyte Kit',
      price: '\u20B12,400',
      category: 'Vitamins',
      location: 'Tarlac City',
      imageUrl: 'https://images.pexels.com/photos/3683074/pexels-photo-3683074.jpeg?auto=compress&cs=tinysrgb&w=900',
      featured: true,
    ),
    _ListingData(
      id: 'l4',
      title: 'Organic Layer Pellets (25kg)',
      price: '\u20B12,800',
      category: 'Feeds',
      location: 'San Fernando, Pampanga',
      imageUrl: 'https://images.pexels.com/photos/5946722/pexels-photo-5946722.jpeg?auto=compress&cs=tinysrgb&w=900',
    ),
    _ListingData(
      id: 'l5',
      title: 'Calcium & Egg Booster Tablets',
      price: '\u20B1650',
      category: 'Vitamins',
      location: 'Tarlac City',
      imageUrl: 'https://images.pexels.com/photos/3683101/pexels-photo-3683101.jpeg?auto=compress&cs=tinysrgb&w=900',
    ),
    _ListingData(
      id: 'l6',
      title: 'Poultry Dewormer Solution',
      price: '\u20B11,100',
      category: 'Meds',
      location: 'Nueva Ecija',
      imageUrl: 'https://images.pexels.com/photos/3683081/pexels-photo-3683081.jpeg?auto=compress&cs=tinysrgb&w=900',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _kStoreBgDark : _kStoreBgLight;

    final filtered = _allListings.where((item) {
      final categoryOk = _selectedCategory == 'All' || item.category == _selectedCategory;
      final query = _searchQuery.trim().toLowerCase();
      final searchOk = query.isEmpty ||
          item.title.toLowerCase().contains(query) ||
          item.location.toLowerCase().contains(query);
      return categoryOk && searchOk;
    }).toList();

    final featured = filtered.where((item) => item.featured).toList();

    return Scaffold(
      backgroundColor: bg,
      drawer: const FarmBuzzAppDrawer(),
      appBar: const FarmBuzzHomeAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 92),
        children: [
          _TopActionRow(
            wishlistCount: _wishlistIds.length,
            cartCount: _cartIds.length,
            onTapSell: () => _showMessage('Sell Item', 0, suffix: 'coming soon'),
            onTapWishlist: () => _showMessage('Wishlist', _wishlistIds.length),
            onTapCart: _openCartScreen,
          ),
          const SizedBox(height: 12),
          _SearchBar(
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 14),
          _SectionTitle(title: 'Categories'),
          const SizedBox(height: 10),
          SizedBox(
            height: 92,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 18),
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = _selectedCategory == cat.label;
                return _CategoryItem(
                  data: cat,
                  selected: selected,
                  onTap: () => setState(() => _selectedCategory = cat.label),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          _SectionTitle(title: '⭐ Featured'),
          const SizedBox(height: 10),
          SizedBox(
            height: 286,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: featured.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final data = featured[i];
                return _FeaturedCard(
                  data: data,
                  isWishlisted: _wishlistIds.contains(data.id),
                  inCart: _cartIds.contains(data.id),
                  onTap: () => _openDetail(data),
                  onToggleWishlist: () => _toggleWishlist(data.id),
                  onToggleCart: () => _toggleCart(data.id),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          _SectionTitle(title: 'All Listings'),
          const SizedBox(height: 10),
          GridView.builder(
            itemCount: filtered.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (_, i) {
              final data = filtered[i];
              return _ListingCard(
                data: data,
                isWishlisted: _wishlistIds.contains(data.id),
                inCart: _cartIds.contains(data.id),
                onTap: () => _openDetail(data),
                onToggleWishlist: () => _toggleWishlist(data.id),
                onToggleCart: () => _toggleCart(data.id),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: AppBottomNav(
        activeItem: AppBottomNavItem.market,
        onItemTap: (item) => _handleNav(context, item),
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

  void _openDetail(_ListingData data) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => _ProductDetailScreen(data: data),
      ),
    );
  }

  Future<void> _openCartScreen() async {
    final initial = <String, int>{
      for (final id in _cartIds) id: 1,
    };
    final result = await Navigator.of(context).push<Map<String, int>>(
      MaterialPageRoute<Map<String, int>>(
        builder: (_) => _CartScreen(
          allListings: _allListings,
          initialQuantities: initial,
        ),
      ),
    );
    if (!mounted || result == null) return;
    setState(() {
      _cartIds
        ..clear()
        ..addAll(result.keys);
    });
  }

  void _showMessage(String title, int count, {String suffix = ''}) {
    final tail = suffix.isEmpty ? '' : ' ($suffix)';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title items: $count$tail'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.count,
    required this.onTap,
  });

  final IconData icon;
  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isDark ? _kStoreCardDark : _kStoreCardLight,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB)),
            ),
            child: Icon(icon, size: 20, color: _kStorePrimary),
          ),
          if (count > 0)
            Positioned(
              right: -3,
              top: -3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: _kStorePrimary,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(
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

class _TopActionRow extends StatelessWidget {
  const _TopActionRow({
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        FilledButton.icon(
          onPressed: onTapSell,
          style: FilledButton.styleFrom(
            backgroundColor: isDark ? _kStorePrimary.withValues(alpha: 0.20) : _kStoreAccent,
            foregroundColor: _kStorePrimary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
          ),
          icon: const Icon(Icons.add_rounded),
          label: const Text(
            'Sell',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        const Spacer(),
        _HeaderIcon(
          icon: Icons.favorite_border_rounded,
          count: wishlistCount,
          onTap: onTapWishlist,
        ),
        const SizedBox(width: 8),
        _HeaderIcon(
          icon: Icons.shopping_cart_outlined,
          count: cartCount,
          onTap: onTapCart,
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: 'Search feeds, equipment...',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: const Icon(Icons.tune_rounded),
        filled: true,
        fillColor: isDark ? _kStoreCardDark : const Color(0xFFF1F5F9),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide(color: isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: const BorderSide(color: _kStorePrimary, width: 1.4),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.data,
    required this.selected,
    required this.onTap,
  });

  final _StoreCategory data;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 66,
        child: Column(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: selected
                    ? (isDark ? _kStorePrimary.withValues(alpha: 0.2) : _kStoreAccent)
                    : (isDark ? _kStoreCardDark : _kStoreCardLight),
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? _kStorePrimary.withValues(alpha: 0.65)
                      : (isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB)),
                ),
              ),
              child: Icon(data.icon, color: selected ? _kStorePrimary : _kStoreMuted),
            ),
            const SizedBox(height: 7),
            Text(
              data.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? _kStorePrimary : _kStoreMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({
    required this.data,
    required this.isWishlisted,
    required this.inCart,
    required this.onTap,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final _ListingData data;
  final bool isWishlisted;
  final bool inCart;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 220,
      child: _CardShell(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CardImage(
                imageUrl: data.imageUrl,
                height: 146,
                featured: true,
                showCartAction: false,
                isWishlisted: isWishlisted,
                inCart: inCart,
                onToggleWishlist: onToggleWishlist,
                onToggleCart: onToggleCart,
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      data.price,
                      style: const TextStyle(
                        color: _kStorePrimary,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      data.location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDark ? const Color(0xFF9CA3AF) : _kStoreMuted,
                        fontSize: 12,
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

class _ListingCard extends StatelessWidget {
  const _ListingCard({
    required this.data,
    required this.isWishlisted,
    required this.inCart,
    required this.onTap,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final _ListingData data;
  final bool isWishlisted;
  final bool inCart;
  final VoidCallback onTap;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleCart;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _CardShell(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardImage(
              imageUrl: data.imageUrl,
              height: 120,
              featured: false,
              showCartAction: true,
              isWishlisted: isWishlisted,
              inCart: inCart,
              onToggleWishlist: onToggleWishlist,
              onToggleCart: onToggleCart,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, height: 1.25),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    data.price,
                    style: const TextStyle(
                      color: _kStorePrimary,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isDark ? const Color(0xFF9CA3AF) : _kStoreMuted,
                      fontSize: 12,
                    ),
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

class _CardShell extends StatelessWidget {
  const _CardShell({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? _kStoreCardDark : _kStoreCardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB)),
      ),
      child: child,
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.imageUrl,
    required this.height,
    required this.featured,
    required this.showCartAction,
    required this.isWishlisted,
    required this.inCart,
    required this.onToggleWishlist,
    required this.onToggleCart,
  });

  final String imageUrl;
  final double height;
  final bool featured;
  final bool showCartAction;
  final bool isWishlisted;
  final bool inCart;
  final VoidCallback onToggleWishlist;
  final VoidCallback onToggleCart;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Image.network(imageUrl, fit: BoxFit.cover),
          ),
        ),
        if (featured)
          Positioned(
            left: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _kStoreAccent,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Text(
                'FEATURED',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: _kStorePrimary),
              ),
            ),
          ),
        Positioned(
          right: 8,
          top: 8,
          child: Row(
            children: [
              _OverlayAction(icon: isWishlisted ? Icons.favorite : Icons.favorite_border, active: isWishlisted, onTap: onToggleWishlist),
              if (showCartAction) ...[
                const SizedBox(width: 6),
                _OverlayAction(icon: inCart ? Icons.shopping_cart : Icons.add_shopping_cart_outlined, active: inCart, onTap: onToggleCart),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _OverlayAction extends StatelessWidget {
  const _OverlayAction({
    required this.icon,
    required this.active,
    required this.onTap,
  });

  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: active ? _kStorePrimary : Colors.black.withValues(alpha: 0.40),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

class _ProductDetailScreen extends StatefulWidget {
  const _ProductDetailScreen({required this.data});

  final _ListingData data;

  @override
  State<_ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _CartScreen extends StatefulWidget {
  const _CartScreen({
    required this.allListings,
    required this.initialQuantities,
  });

  final List<_ListingData> allListings;
  final Map<String, int> initialQuantities;

  @override
  State<_CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<_CartScreen> {
  late final Map<String, int> _quantities = Map<String, int>.from(widget.initialQuantities);

  List<_ListingData> get _items =>
      widget.allListings.where((item) => _quantities.containsKey(item.id)).toList();

  double _priceToNumber(String raw) {
    final clean = raw.replaceAll('₱', '').replaceAll(',', '').trim();
    return double.tryParse(clean) ?? 0;
  }

  double get _subtotal => _items.fold<double>(
        0,
        (sum, item) => sum + (_priceToNumber(item.price) * (_quantities[item.id] ?? 1)),
      );

  double get _deliveryFee => _items.isEmpty ? 0 : 50;
  double get _total => _subtotal + _deliveryFee;

  String _peso(double value) {
    final fixed = value.toStringAsFixed(0);
    final chars = fixed.split('').reversed.toList();
    final parts = <String>[];
    for (var i = 0; i < chars.length; i++) {
      if (i > 0 && i % 3 == 0) parts.add(',');
      parts.add(chars[i]);
    }
    return '₱${parts.reversed.join()}';
  }

  void _changeQty(String id, int diff) {
    setState(() {
      final next = (_quantities[id] ?? 1) + diff;
      if (next <= 0) {
        _quantities.remove(id);
      } else {
        _quantities[id] = next;
      }
    });
  }

  void _remove(String id) {
    setState(() => _quantities.remove(id));
  }

  Future<void> _proceedCheckout() async {
    final placed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => _CheckoutScreen(
          items: _items,
          quantities: _quantities,
          subtotal: _subtotal,
          deliveryFee: _deliveryFee,
          total: _total,
          formatPeso: _peso,
        ),
      ),
    );
    if (!mounted || placed != true) return;
    setState(() => _quantities.clear());
    _closeWithResult();
  }

  void _closeWithResult() {
    Navigator.of(context).pop(_quantities);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _kStoreBgDark : _kStoreBgLight;
    final card = isDark ? _kStoreCardDark : _kStoreCardLight;
    final border = isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeWithResult();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          leading: IconButton(
            onPressed: _closeWithResult,
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
          ),
          title: const Text('My Cart'),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: _items.isEmpty
                  ? null
                  : () => setState(() => _quantities.clear()),
              icon: const Icon(Icons.delete_outline_rounded),
            ),
          ],
        ),
        body: _items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 96,
                        height: 96,
                        decoration: const BoxDecoration(
                          color: _kStoreAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.shopping_cart_outlined, size: 42, color: _kStorePrimary),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Your cart is empty',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Add items from Store to continue checkout.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _kStoreMuted),
                      ),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: _closeWithResult,
                        style: FilledButton.styleFrom(
                          backgroundColor: _kStorePrimary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        ),
                        child: const Text('Browse Store'),
                      ),
                    ],
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 180),
                itemCount: _items.length,
                itemBuilder: (_, index) {
                  final item = _items[index];
                  final qty = _quantities[item.id] ?? 1;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: card,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => _ProductDetailScreen(data: item),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(item.imageUrl, width: 84, height: 84, fit: BoxFit.cover),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.price,
                                  style: const TextStyle(
                                    color: _kStorePrimary,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  item.location,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: _kStoreMuted, fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    _QtyButton(icon: Icons.remove, onTap: () => _changeQty(item.id, -1)),
                                    const SizedBox(width: 8),
                                    AnimatedSwitcher(
                                      duration: const Duration(milliseconds: 180),
                                      child: Text(
                                        '$qty',
                                        key: ValueKey(qty),
                                        style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    _QtyButton(icon: Icons.add, onTap: () => _changeQty(item.id, 1)),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: () => _remove(item.id),
                                      child: const Text('Remove'),
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
                },
              ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: card,
            border: Border(top: BorderSide(color: border)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF222222) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Column(
                      children: [
                        _SummaryRow(label: 'Subtotal', value: _peso(_subtotal)),
                        const SizedBox(height: 6),
                        _SummaryRow(label: 'Delivery Fee', value: _peso(_deliveryFee)),
                        const SizedBox(height: 8),
                        _SummaryRow(
                          label: 'Total',
                          value: _peso(_total),
                          strong: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: _items.isEmpty ? null : _proceedCheckout,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: _kStorePrimary,
                      disabledBackgroundColor: Colors.grey.shade400,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text(
                      'Proceed to Checkout',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  const _QtyButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF242424) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.strong = false,
  });

  final String label;
  final String value;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            color: strong ? null : _kStoreMuted,
            fontWeight: strong ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontWeight: strong ? FontWeight.w900 : FontWeight.w700,
            color: strong ? _kStorePrimary : null,
          ),
        ),
      ],
    );
  }
}

class _CheckoutScreen extends StatelessWidget {
  const _CheckoutScreen({
    required this.items,
    required this.quantities,
    required this.subtotal,
    required this.deliveryFee,
    required this.total,
    required this.formatPeso,
  });

  final List<_ListingData> items;
  final Map<String, int> quantities;
  final double subtotal;
  final double deliveryFee;
  final double total;
  final String Function(double) formatPeso;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? _kStoreBgDark : _kStoreBgLight;
    final card = isDark ? _kStoreCardDark : _kStoreCardLight;
    final border = isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(false),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        centerTitle: true,
        title: const Text('Checkout'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 170),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: const Row(
              children: [
                Icon(Icons.location_on_outlined, color: _kStorePrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Delivery Address', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('San Fernando, Pampanga', style: TextStyle(color: _kStoreMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _kStoreMuted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: const Row(
              children: [
                Icon(Icons.wallet_outlined, color: _kStorePrimary),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Payment Method', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Cash on Delivery', style: TextStyle(color: _kStoreMuted)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: _kStoreMuted),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Order Items', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                ...items.map((item) {
                  final qty = quantities[item.id] ?? 1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(item.imageUrl, width: 52, height: 52, fit: BoxFit.cover),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('x$qty', style: const TextStyle(color: _kStoreMuted)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: card,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SummaryRow(label: 'Subtotal', value: formatPeso(subtotal)),
                const SizedBox(height: 6),
                _SummaryRow(label: 'Delivery Fee', value: formatPeso(deliveryFee)),
                const SizedBox(height: 8),
                _SummaryRow(label: 'Total', value: formatPeso(total), strong: true),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    backgroundColor: _kStorePrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text(
                    'Place Order',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailScreenState extends State<_ProductDetailScreen> {
  final PageController _pageController = PageController();
  int _page = 0;
  bool _saved = false;
  bool _expanded = false;

  List<String> get _images => [
        widget.data.imageUrl,
        'https://images.pexels.com/photos/5946722/pexels-photo-5946722.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/3683101/pexels-photo-3683101.jpeg?auto=compress&cs=tinysrgb&w=900',
        'https://images.pexels.com/photos/3683081/pexels-photo-3683081.jpeg?auto=compress&cs=tinysrgb&w=900',
      ];

  String get _description =>
      '${widget.data.title} is a trusted marketplace item for poultry and farm operations. '
      'Sourced from verified local suppliers, this product is ideal for daily farm use and long-term conditioning. '
      'Stored and packed carefully for consistent quality. Available for pickup and delivery depending on your location.';

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg = isDark ? _kStoreBgDark : _kStoreBgLight;
    final card = isDark ? _kStoreCardDark : _kStoreCardLight;
    final border = isDark ? _kStoreBorderDark : const Color(0xFFE5E7EB);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
        ),
        actions: [
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Share link copied')),
              );
            },
            icon: const Icon(Icons.ios_share_rounded),
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (_) => SafeArea(
                  child: Wrap(
                    children: const [
                      ListTile(leading: Icon(Icons.flag_outlined), title: Text('Report listing')),
                      ListTile(leading: Icon(Icons.visibility_off_outlined), title: Text('Hide listing')),
                    ],
                  ),
                ),
              );
            },
            icon: const Icon(Icons.more_horiz_rounded),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
        children: [
          SizedBox(
            height: 280,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _images.length,
                    onPageChanged: (index) => setState(() => _page = index),
                    itemBuilder: (_, index) => GestureDetector(
                      onTap: () {},
                      child: Image.network(
                        _images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            color: isDark ? const Color(0xFF242424) : const Color(0xFFECEFF3),
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: _OverlayAction(
                    icon: _saved ? Icons.favorite : Icons.favorite_border,
                    active: _saved,
                    onTap: () => setState(() => _saved = !_saved),
                  ),
                ),
                Positioned(
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '${_page + 1}/${_images.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            widget.data.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(
            widget.data.price,
            style: const TextStyle(
              color: _kStorePrimary,
              fontWeight: FontWeight.w900,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 16, color: _kStoreMuted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.data.location,
                  style: const TextStyle(color: _kStoreMuted),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _kStoreAccent,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  widget.data.category,
                  style: const TextStyle(
                    color: _kStorePrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 23,
                  backgroundImage: NetworkImage(
                    'https://images.pexels.com/photos/771742/pexels-photo-771742.jpeg?auto=compress&cs=tinysrgb&w=300',
                  ),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Golden Hatch Farm', style: TextStyle(fontWeight: FontWeight.w800)),
                      SizedBox(height: 3),
                      Text('Pampanga • 4.8 rating', style: TextStyle(color: _kStoreMuted, fontSize: 12)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening seller chat...')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _kStorePrimary,
                    side: const BorderSide(color: _kStorePrimary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: const Text('Message'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Description', style: TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text(
                  _expanded ? _description : _description.substring(0, 160),
                  style: const TextStyle(height: 1.45, color: _kStoreMuted),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Text(
                    _expanded ? 'See less' : 'See more',
                    style: const TextStyle(color: _kStorePrimary, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Product Details', style: TextStyle(fontWeight: FontWeight.w800)),
                SizedBox(height: 10),
                _DetailRow(label: 'Stock', value: '18 available'),
                _DetailRow(label: 'Weight/Size', value: '10kg pack'),
                _DetailRow(label: 'Category', value: 'Farm Supply'),
                _DetailRow(label: 'Delivery', value: 'Pickup / Courier'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: card,
          border: Border(top: BorderSide(color: border)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            child: Row(
              children: [
                OutlinedButton(
                  onPressed: () => setState(() => _saved = !_saved),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(56, 50),
                    side: BorderSide(color: _saved ? _kStorePrimary : border),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                  ),
                  child: Icon(
                    _saved ? Icons.favorite : Icons.favorite_border,
                    color: _saved ? _kStorePrimary : _kStoreMuted,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: _kStorePrimary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                    ),
                    child: const Text(
                      'Add to Cart',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: _kStoreMuted),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _StoreCategory {
  const _StoreCategory({required this.label, required this.icon});

  final String label;
  final IconData icon;
}

class _ListingData {
  const _ListingData({
    required this.id,
    required this.title,
    required this.price,
    required this.category,
    required this.location,
    required this.imageUrl,
    this.featured = false,
  });

  final String id;
  final String title;
  final String price;
  final String category;
  final String location;
  final String imageUrl;
  final bool featured;
}

