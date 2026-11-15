import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'account_settings_page.dart';
import 'officials_page.dart';
import 'residents_page.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const Color primaryBlue = Color(0xFF0F2D52);
  static const Color accentBlue = Color(0xFF2563EB);
  static const Color backgroundColor = Color(0xFFF4F7FB);
  static const Color surfaceBorder = Color(0xFFE2E8F0);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final residents = FirebaseFirestore.instance.collection('residents');
    final officials = FirebaseFirestore.instance.collection('officials');
    final staffEmail = user?.email ?? 'staff@barangay.gov.ph';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: surfaceBorder, height: 1),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.account_balance_rounded,
                color: primaryBlue,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Barangay Portal',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AccountSettingsPage(),
                  ),
                );
              },
              tooltip: 'Account Settings',
              icon: CircleAvatar(
                radius: 17,
                backgroundColor: accentBlue.withValues(alpha: 0.12),
                child: const Icon(
                  Icons.person_rounded,
                  color: accentBlue,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 960),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HERO WELCOME BANNER
                  _buildWelcomeBanner(staffEmail),

                  const SizedBox(height: 32),

                  // OVERVIEW SECTION
                  _buildSectionHeader(
                    title: 'System Overview',
                    subtitle: 'Real-time population and leadership metrics',
                  ),

                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 600;

                      // RESIDENT STATISTICS
                      final residentStat = StreamBuilder<QuerySnapshot>(
                        stream: residents.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _statCard(
                              title: 'Total Residents',
                              value: '--',
                              badgeText: 'Sync Error',
                              badgeColor: Colors.red,
                              icon: Icons.groups_rounded,
                              accentColor: accentBlue,
                            );
                          }

                          if (!snapshot.hasData) {
                            return _loadingCard();
                          }

                          return _statCard(
                            title: 'Total Residents',
                            value: _formatNumber(snapshot.data!.docs.length),
                            badgeText: 'Active Records',
                            badgeColor: const Color(0xFF10B981),
                            icon: Icons.groups_rounded,
                            accentColor: accentBlue,
                          );
                        },
                      );

                      // OFFICIAL STATISTICS
                      final officialStat = StreamBuilder<QuerySnapshot>(
                        stream: officials.snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.hasError) {
                            return _statCard(
                              title: 'Barangay Officials',
                              value: '--',
                              badgeText: 'Sync Error',
                              badgeColor: Colors.red,
                              icon: Icons.verified_user_rounded,
                              accentColor: const Color(0xFF7C3AED),
                            );
                          }

                          if (!snapshot.hasData) {
                            return _loadingCard();
                          }

                          return _statCard(
                            title: 'Barangay Officials',
                            value: _formatNumber(snapshot.data!.docs.length),
                            badgeText: 'Incumbent',
                            badgeColor: const Color(0xFF7C3AED),
                            icon: Icons.verified_user_rounded,
                            accentColor: const Color(0xFF7C3AED),
                          );
                        },
                      );

                      if (isWide) {
                        return Row(
                          children: [
                            Expanded(child: residentStat),
                            const SizedBox(width: 16),
                            Expanded(child: officialStat),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          residentStat,
                          const SizedBox(height: 14),
                          officialStat,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 32),

                  // QUICK ACCESS SECTION
                  _buildSectionHeader(
                    title: 'Quick Actions',
                    subtitle: 'Manage records and administrative settings',
                  ),

                  const SizedBox(height: 16),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 680;

                      // RESIDENTS CARD
                      final residentCard = _actionCard(
                        title: 'Manage Residents',
                        description: 'Add new profiles, update household data, and search resident records.',
                        icon: Icons.people_alt_rounded,
                        color: accentBlue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ResidentsPage(),
                            ),
                          );
                        },
                      );

                      // OFFICIALS CARD
                      final officialsCard = _actionCard(
                        title: 'Barangay Officials',
                        description: 'Assign committees, update designations, and manage official rosters.',
                        icon: Icons.badge_rounded,
                        color: const Color(0xFF7C3AED),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OfficialsPage(),
                            ),
                          );
                        },
                      );

                      // SETTINGS CARD
                      final settingsCard = _actionCard(
                        title: 'Account Settings',
                        description: 'Update staff credentials, security preferences, and profile info.',
                        icon: Icons.tune_rounded,
                        color: const Color(0xFF0D9488),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AccountSettingsPage(),
                            ),
                          );
                        },
                      );

                      if (isWide) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: residentCard),
                            const SizedBox(width: 16),
                            Expanded(child: officialsCard),
                            const SizedBox(width: 16),
                            Expanded(child: settingsCard),
                          ],
                        );
                      }

                      return Column(
                        children: [
                          residentCard,
                          const SizedBox(height: 14),
                          officialsCard,
                          const SizedBox(height: 14),
                          settingsCard,
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 40),

                  // FOOTER
                  Center(
                    child: Text(
                      'Barangay Information Management System',
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
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

  // WELCOME BANNER
  Widget _buildWelcomeBanner(String staffEmail) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F2D52), Color(0xFF1E40AF), Color(0xFF2563EB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          // DECORATIVE CIRCLES
          Positioned(
            right: -30,
            top: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),

          Positioned(
            right: 60,
            bottom: -60,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Colors.lightBlueAccent,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'ADMINISTRATION PORTAL',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Welcome back, Staff',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    Icon(
                      Icons.alternate_email_rounded,
                      size: 15,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        staffEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // SECTION HEADER
  Widget _buildSectionHeader({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            color: primaryBlue,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.blueGrey.shade500),
        ),
      ],
    );
  }

  // LOADING CARD
  Widget _loadingCard() {
    return Container(
      height: 132,
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceBorder),
      ),
      child: const Center(
        child: SizedBox(
          height: 24,
          width: 24,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: accentBlue),
        ),
      ),
    );
  }

  // STATISTICS CARD
  Widget _statCard({
    required String title,
    required String value,
    required String badgeText,
    required Color badgeColor,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: accentColor, size: 24),
              ),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Text(
            value,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: primaryBlue,
              letterSpacing: -0.8,
              height: 1.1,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            title,
            style: TextStyle(
              color: Colors.blueGrey.shade600,
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // QUICK ACTION CARD
  Widget _actionCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        hoverColor: color.withValues(alpha: 0.03),
        splashColor: color.withValues(alpha: 0.08),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 25),
                  ),

                  Container(
                    height: 32,
                    width: 32,
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.arrow_outward_rounded,
                      size: 16,
                      color: primaryBlue,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16.5,
                  fontWeight: FontWeight.w700,
                  color: primaryBlue,
                  letterSpacing: -0.2,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: Colors.blueGrey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // NUMBER FORMATTER
  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
