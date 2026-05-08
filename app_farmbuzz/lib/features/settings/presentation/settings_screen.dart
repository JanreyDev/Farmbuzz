import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmbuzz/core/theme/app_colors.dart';
import 'package:farmbuzz/features/settings/presentation/widgets/setting_tile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedTab = 'Account';
  
  // Settings State
  bool _loginAlerts = true;
  bool _autoRenew = true;
  bool _showInSearch = true;
  bool _activityFeed = true;
  bool _onlineStatus = true;
  bool _sensitiveContent = false;
  bool _aiLabeledContent = true;
  bool _autoplayVideos = true;
  bool _voiceResponses = false;
  bool _helpImproveAi = true;
  bool _reduceMotion = false;
  bool _highContrast = false;
  String _selectedTheme = 'Light';
  String _selectedLanguage = 'Tagalog';

  final List<String> _tabs = [
    'Account',
    'Security',
    'Subscription',
    'Notifications',
    'Privacy',
    'Messages',
    'Content',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section with Search
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search settings...',
                        hintStyle: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[400],
                        ),
                        icon: Icon(Icons.search, size: 20, color: Colors.grey[400]),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Tab Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _tabs.map((tab) => _buildTabChip(tab)).toList(),
                    ),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Summary Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=janrey'),
                            ),
                            PositionAt(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt, size: 12, color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Janrey',
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                '@janrey',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: BorderSide(color: Colors.grey[200]!),
                            ),
                          ),
                          child: Text(
                            'View profile',
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Sections based on tab or all
                  if (_selectedTab == 'Account' || _selectedTab == 'All') ...[
                    _buildSectionHeader(Icons.person_outlined, 'ACCOUNT', 'Basic information visible on your profile'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      const SettingTile(title: 'Name', subtitle: 'Janrey'),
                      const SettingTile(title: 'Username', subtitle: '@janrey'),
                      const SettingTile(title: 'Bio', subtitle: 'Add a short bio'),
                      const SettingTile(title: 'Phone', subtitle: '+639619174255', tag: 'Primary'),
                      const SettingTile(title: 'Email', subtitle: 'Add an email'),
                      const SettingTile(title: 'Location', subtitle: 'Arayat, Pampanga'),
                      const SettingTile(title: 'Date of birth', subtitle: 'Private · used for age-restricted content', isLast: true),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  if (_selectedTab == 'Security' || _selectedTab == 'All') ...[
                    _buildSectionHeader(Icons.lock_outlined, 'SECURITY', 'Security and login settings'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      const SettingTile(title: 'Password', subtitle: 'Last changed 47 days ago'),
                      SettingTile(
                        title: 'Two-factor authentication', 
                        subtitle: 'Add an extra layer of security',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('OFF', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.orange)),
                            const SizedBox(width: 8),
                            Icon(Icons.chevron_right, size: 20, color: Colors.grey[300]),
                          ],
                        ),
                      ),
                      SettingTile(
                        title: 'Login alerts', 
                        subtitle: 'Email me when someone signs in from a new device',
                        switchValue: _loginAlerts,
                        onSwitchChanged: (v) => setState(() => _loginAlerts = v),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _buildSectionSubtitle('Active sessions', action: 'Sign out of all others'),
                    const SizedBox(height: 8),
                    _buildSettingsContainer([
                      _buildActiveSessionTile('Windows PC · Chrome 128', 'Angeles, Pampanga — 112.198.72.44 · 1h ago', isThisDevice: true),
                      _buildActiveSessionTile('iPhone 14 · Safari 17', 'Arayat, Pampanga — 110.191.10.22 · 9h ago'),
                      _buildActiveSessionTile('iPad · Safari 17', 'Manila, NCR — 49.145.205.111 · 3d ago', isLast: true),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  if (_selectedTab == 'Subscription' || _selectedTab == 'All') ...[
                    _buildSectionHeader(Icons.card_membership_outlined, 'SUBSCRIPTION & BILLING', 'Manage your plans and payments'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      SettingTile(
                        title: 'CURRENT PLAN', 
                        subtitle: 'Pro',
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
                          child: Text('Manage plan', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: const Icon(Icons.star, color: Colors.green, size: 20),
                        ),
                      ),
                      const SettingTile(title: 'Payment methods', subtitle: 'Manage saved cards, GCash, Maya'),
                      const SettingTile(title: 'Invoice history', subtitle: 'Download past receipts'),
                      SettingTile(
                        title: 'Auto-renew', 
                        subtitle: 'Renews monthly on the 15th',
                        switchValue: _autoRenew,
                        onSwitchChanged: (v) => setState(() => _autoRenew = v),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  if (_selectedTab == 'Privacy' || _selectedTab == 'All') ...[
                    _buildSectionHeader(Icons.visibility_outlined, 'PRIVACY', 'Who can see and contact you'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      SettingTile(
                        title: 'Profile visibility', 
                        subtitle: 'Anyone on FarmBuzz',
                        trailing: _buildDropdown('Public'),
                      ),
                      SettingTile(
                        title: 'Show in search', 
                        subtitle: 'Allow your profile to appear in FarmBuzz search and Google',
                        switchValue: _showInSearch,
                        onSwitchChanged: (v) => setState(() => _showInSearch = v),
                      ),
                      SettingTile(
                        title: 'Who can message me', 
                        subtitle: 'Everyone',
                        trailing: _buildDropdown('Everyone'),
                      ),
                      SettingTile(
                        title: 'Who can tag me', 
                        subtitle: 'Followers',
                        trailing: _buildDropdown('Followers'),
                      ),
                      SettingTile(
                        title: 'Who can comment on my posts', 
                        subtitle: 'Everyone',
                        trailing: _buildDropdown('Everyone'),
                      ),
                      SettingTile(
                        title: 'Show my activity feed', 
                        subtitle: 'Let others see your likes and comments',
                        switchValue: _activityFeed,
                        onSwitchChanged: (v) => setState(() => _activityFeed = v),
                      ),
                      SettingTile(
                        title: 'Show online status', 
                        subtitle: 'Let others see when you\'re active',
                        switchValue: _onlineStatus,
                        onSwitchChanged: (v) => setState(() => _onlineStatus = v),
                        isLast: true,
                      ),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  if (_selectedTab == 'Content' || _selectedTab == 'All') ...[
                    _buildSectionHeader(Icons.grid_view_outlined, 'CONTENT PREFERENCES', 'Tailor your feed and discovery'),
                    const SizedBox(height: 12),
                    _buildSettingsContainer([
                      SettingTile(
                        title: 'Feed sort', 
                        subtitle: 'Top posts first',
                        trailing: _buildDropdown('Top'),
                      ),
                      SettingTile(
                        title: 'Show sensitive content', 
                        subtitle: 'Posts flagged by the community as graphic',
                        switchValue: _sensitiveContent,
                        onSwitchChanged: (v) => setState(() => _sensitiveContent = v),
                      ),
                      SettingTile(
                        title: 'Show AI-labeled content', 
                        subtitle: 'Posts created or augmented by AI',
                        switchValue: _aiLabeledContent,
                        onSwitchChanged: (v) => setState(() => _aiLabeledContent = v),
                      ),
                      SettingTile(
                        title: 'Autoplay videos', 
                        subtitle: 'Videos will play automatically when in view',
                        switchValue: _autoplayVideos,
                        onSwitchChanged: (v) => setState(() => _autoplayVideos = v),
                      ),
                      _buildBloodlinesSection(),
                    ]),
                    const SizedBox(height: 32),
                  ],

                  _buildSectionHeader(Icons.agriculture_outlined, 'FARM PREFERENCES', 'Regional and operational settings'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(title: 'Weight units', subtitle: 'Kilograms (kg)', trailing: _buildDropdown('Kilograms (kg)')),
                    SettingTile(title: 'Length units', subtitle: 'Centimeters (cm)', trailing: _buildDropdown('Centimeters (cm)')),
                    SettingTile(title: 'Temperature units', subtitle: 'Celsius (C)', trailing: _buildDropdown('Celsius (C)')),
                    SettingTile(title: 'Currency', subtitle: 'Philippine Peso (₱)', trailing: _buildDropdown('PHP')),
                    SettingTile(title: 'Timezone', subtitle: 'Asia/Manila (PHT)', trailing: _buildDropdown('Asia/Manila (PHT)')),
                    SettingTile(
                      title: 'Low-stock alert threshold', 
                      subtitle: 'Alert when any bird count falls below 10',
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(4)),
                        child: Text('10', style: GoogleFonts.inter(fontSize: 13, color: Colors.black)),
                      ),
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.auto_awesome_outlined, 'BANTAY AI', 'How your farm assistant behaves'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(title: 'Assistance level', subtitle: 'Suggest daily tasks', trailing: _buildDropdown('Balanced')),
                    SettingTile(title: 'Response language', subtitle: 'Taglish', trailing: _buildDropdown('Taglish')),
                    SettingTile(
                      title: 'Voice responses', 
                      subtitle: 'Read answers aloud when available',
                      switchValue: _voiceResponses,
                      onSwitchChanged: (v) => setState(() => _voiceResponses = v),
                    ),
                    SettingTile(
                      title: 'Help improve Bantay AI', 
                      subtitle: 'Share anonymized conversations to improve future responses',
                      switchValue: _helpImproveAi,
                      onSwitchChanged: (v) => setState(() => _helpImproveAi = v),
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.shopping_bag_outlined, 'COMMERCE', 'Shop and ordering preferences'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    const SettingTile(title: 'Saved addresses', subtitle: '2 addresses · Default: Home'),
                    const SettingTile(title: 'Saved payment methods', subtitle: 'COD, GCash'),
                    const SettingTile(title: 'Receipt email', subtitle: 'Send order receipts to your email', isLast: true),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.translate, 'LANGUAGE', 'Choose your preferred language'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    _buildLanguageGrid(),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.palette_outlined, 'APPEARANCE', 'Customize your viewing experience'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(
                      title: 'Theme', 
                      subtitle: _selectedTheme,
                      trailing: _buildThemeSegmentedButton(),
                    ),
                    SettingTile(title: 'Font size', subtitle: 'Medium', trailing: _buildDropdown('Medium')),
                    SettingTile(title: 'Density', subtitle: 'Comfortable', trailing: _buildDropdown('Comfortable')),
                    SettingTile(
                      title: 'Reduce motion', 
                      subtitle: 'Minimize animations and transitions',
                      switchValue: _reduceMotion,
                      onSwitchChanged: (v) => setState(() => _reduceMotion = v),
                    ),
                    SettingTile(
                      title: 'High contrast', 
                      subtitle: 'Stronger borders and text contrast',
                      switchValue: _highContrast,
                      onSwitchChanged: (v) => setState(() => _highContrast = v),
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.link, 'CONNECTED APPS', 'Manage third-party integrations'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(
                      title: 'Facebook', 
                      subtitle: 'Sign in with Facebook',
                      trailing: _buildConnectButton('Connect', Colors.blue),
                    ),
                    SettingTile(
                      title: 'Google', 
                      subtitle: 'Sign in with Google',
                      trailing: _buildConnectButton('Connect', Colors.redAccent),
                    ),
                    const SettingTile(title: 'Business API tokens', subtitle: 'For brands with API access — managed on your Business dashboard', isLast: true),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.gavel_outlined, 'LEGAL & DATA (RA 10173)', 'Data privacy and terms'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(
                      title: 'Download your data', 
                      subtitle: 'Get a copy of your profile, posts, farm records, and orders (ZIP)',
                      trailing: _buildConnectButton('Request export', Colors.green),
                    ),
                    const SettingTile(title: 'Correction request', subtitle: 'Ask us to update information we hold about you'),
                    const SettingTile(title: 'Consent history', subtitle: 'What you\'ve agreed to and when'),
                    const SettingTile(title: 'Terms of Service', subtitle: '', trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey)),
                    const SettingTile(title: 'Privacy Policy', subtitle: '', trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey)),
                    const SettingTile(title: 'Cookie preferences', subtitle: '', trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey), isLast: true),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.help_outlined, 'HELP & SUPPORT', 'Get assistance and information'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    const SettingTile(title: 'Contact support', subtitle: 'Email us or start a chat'),
                    const SettingTile(title: 'FAQ', subtitle: '', trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey)),
                    const SettingTile(title: 'Report a bug', subtitle: ''),
                    const SettingTile(title: 'Feature request', subtitle: '', trailing: Icon(Icons.open_in_new, size: 16, color: Colors.grey)),
                    const SettingTile(title: 'Changelog', subtitle: 'What\'s new in FarmBuzz'),
                    const SettingTile(title: 'About FarmBuzz', subtitle: 'Operated by Promovino Inc.', isLast: true),
                  ]),

                  const SizedBox(height: 32),
                  
                  _buildSectionHeader(Icons.warning_amber_rounded, 'DANGER ZONE', 'Critical account actions'),
                  const SizedBox(height: 12),
                  _buildSettingsContainer([
                    SettingTile(
                      title: 'Sign out', 
                      subtitle: 'End your session on this device',
                      trailing: const Icon(Icons.logout, size: 18, color: Colors.redAccent),
                      onTap: () {},
                    ),
                    const SettingTile(title: 'Deactivate account', subtitle: 'Temporarily hide your profile — reversible for 30 days'),
                    SettingTile(
                      title: 'Delete account', 
                      subtitle: 'Permanent · 30-day grace period',
                      trailing: const Icon(Icons.delete_outline, size: 18, color: Colors.redAccent),
                      isLast: true,
                      onTap: () {},
                    ),
                  ]),

                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'FarmBuzz by Promovino Inc. · v1.0.0 · Terms · Privacy',
                      style: GoogleFonts.inter(fontSize: 10, color: Colors.grey[400]),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabChip(String label) {
    final bool isSelected = _selectedTab == label;
    IconData? icon;
    switch (label) {
      case 'Account': icon = Icons.person_outlined; break;
      case 'Security': icon = Icons.lock_outlined; break;
      case 'Subscription': icon = Icons.card_membership_outlined; break;
      case 'Notifications': icon = Icons.notifications_none_outlined; break;
      case 'Privacy': icon = Icons.visibility_outlined; break;
      case 'Messages': icon = Icons.chat_bubble_outlined; break;
      case 'Content': icon = Icons.grid_view_outlined; break;
    }
    
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = label),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? const Color(0xFFE2E8F0) : Colors.transparent),
          boxShadow: isSelected ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ] : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16, color: isSelected ? Colors.black : Colors.grey[600]),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? Colors.black : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.black87),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContainer(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildActiveSessionTile(String title, String subtitle, {bool isLast = false, bool isThisDevice = false}) {
    return SettingTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
        child: Icon(title.contains('iPhone') ? Icons.phone_iphone : Icons.laptop, size: 20, color: Colors.grey[400]),
      ),
      title: title,
      subtitle: subtitle,
      tag: isThisDevice ? 'THIS DEVICE' : null,
      trailing: isThisDevice ? null : TextButton(
        onPressed: () {},
        child: Text('Sign out', style: GoogleFonts.plusJakartaSans(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.redAccent)),
      ),
      isLast: isLast,
    );
  }

  Widget _buildDropdown(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black87),
        ],
      ),
    );
  }

  Widget _buildBloodlinesSection() {
    final bloodlines = ['Kelso', 'Sweater', 'Hatch', 'Roundhead', 'Albany', 'Lemon', 'Grey', 'Radio', 'Claret', 'Butcher'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bloodlines in my feed',
            style: GoogleFonts.plusJakartaSans(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Showing all bloodlines',
            style: GoogleFonts.inter(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: bloodlines.map((b) => Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(8)),
                child: Text(b, style: GoogleFonts.inter(fontSize: 11, color: Colors.grey[600])),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionSubtitle(String title, {String? action}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54),
          ),
          if (action != null)
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Text(action, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.redAccent)),
            ),
        ],
      ),
    );
  }

  Widget _buildThemeSegmentedButton() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.all(2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: ['Light', 'Dark', 'System'].map((t) {
          final isSelected = _selectedTheme == t;
          return GestureDetector(
            onTap: () => setState(() => _selectedTheme = t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                boxShadow: isSelected ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))] : null,
              ),
              child: Text(
                t,
                style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, color: isSelected ? Colors.black : Colors.grey[500]),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildConnectButton(String label, Color color) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        side: BorderSide(color: color.withOpacity(0.3)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minimumSize: const Size(0, 32),
      ),
      child: Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildLanguageGrid() {
    final languages = ['Tagalog', 'English', 'Cebuano', 'Ilocano', 'Hiligaynon', 'Bikol', 'Waray', 'Pangasinan', 'Kapampangan', 'Chavacano', 'Maranao', 'Maguindanao', 'Tausug', 'Surigaonon', 'Kinaray-a', 'Aklanon'];
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: languages.map((l) {
          final isSelected = _selectedLanguage == l;
          return GestureDetector(
            onTap: () => setState(() => _selectedLanguage = l),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? Colors.green.withOpacity(0.05) : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isSelected ? Colors.green : Colors.grey[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isSelected) ...[
                    const Icon(Icons.check, size: 12, color: Colors.green),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    l,
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.w500, color: isSelected ? Colors.green : Colors.grey[600]),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Simple Helper for Stack positioning
class PositionAt extends StatelessWidget {
  final Alignment alignment;
  final Widget child;
  const PositionAt({super.key, required this.alignment, required this.child});
  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: alignment == Alignment.bottomRight || alignment == Alignment.bottomLeft ? 0 : null,
      right: alignment == Alignment.bottomRight || alignment == Alignment.topRight ? 0 : null,
      left: alignment == Alignment.bottomLeft || alignment == Alignment.topLeft ? 0 : null,
      top: alignment == Alignment.topRight || alignment == Alignment.topLeft ? 0 : null,
      child: child,
    );
  }
}
