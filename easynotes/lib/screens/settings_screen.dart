import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/note_service.dart';
import '../services/theme_service.dart';
import '../services/premium_service.dart';
import '../services/billing_service.dart';
import '../utils/constants.dart';
import 'premium_subscription_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = context.watch<ThemeService>();
    final noteService = context.watch<NoteService>();
    final premiumService = context.watch<PremiumService>();
    final billingService = context.watch<BillingService>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12),
        children: [
          // Premium Membership Card Banner
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PremiumSubscriptionScreen(),
                  ),
                );
              },
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: premiumService.isPremium
                        ? (isDark
                            ? [const Color(0xFF382A12), const Color(0xFF221A0C)]
                            : [const Color(0xFFFEF3D6), const Color(0xFFFDE6B0)])
                        : (isDark
                            ? [const Color(0xFF2B2538), const Color(0xFF1E1A29)]
                            : [const Color(0xFFF3EDF7), const Color(0xFFEADDFF)]),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: premiumService.isPremium
                        ? Colors.amber.withOpacity(0.5)
                        : Theme.of(context).colorScheme.primary.withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: premiumService.isPremium
                            ? Colors.amber.withOpacity(0.25)
                            : Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        premiumService.isPremium
                            ? Icons.workspace_premium_rounded
                            : Icons.auto_awesome_rounded,
                        color: premiumService.isPremium
                            ? Colors.amber
                            : Theme.of(context).colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            premiumService.isPremium ? 'Easy Notes Premium' : 'Upgrade to Premium',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            premiumService.isPremium
                                ? '${premiumService.daysRemaining} days remaining (Expires ${premiumService.expiryDate != null ? DateFormat('MMM d, yyyy').format(premiumService.expiryDate!) : 'active'})'
                                : 'Unlock full feature access & Google Play Billing passes',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.grey[300] : Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 28),

          // Appearance Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          RadioListTile<ThemeMode>(
            title: const Text('System Default'),
            subtitle: const Text('Follow Android device theme'),
            value: ThemeMode.system,
            groupValue: themeService.themeMode,
            onChanged: (val) {
              if (val != null) themeService.setThemeMode(val);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Light Mode'),
            value: ThemeMode.light,
            groupValue: themeService.themeMode,
            onChanged: (val) {
              if (val != null) themeService.setThemeMode(val);
            },
          ),
          RadioListTile<ThemeMode>(
            title: const Text('Dark Mode'),
            subtitle: const Text('OLED-friendly dark palette'),
            value: ThemeMode.dark,
            groupValue: themeService.themeMode,
            onChanged: (val) {
              if (val != null) themeService.setThemeMode(val);
            },
          ),

          const Divider(height: 32),

          // Google Play Billing & Purchases Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Google Play Purchases',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.restore_rounded),
            title: const Text('Restore Purchases'),
            subtitle: const Text('Sync previous purchases from Google Play Store'),
            trailing: billingService.isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.arrow_forward_ios_rounded, size: 14),
            onTap: () async {
              await billingService.restorePurchases();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      premiumService.isPremium
                          ? 'Active subscription verified & restored!'
                          : 'No active Google Play purchase found.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
          ),

          const Divider(height: 32),

          // Storage & Data Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'Storage & Offline Data',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Total Notes Stored'),
            trailing: Chip(
              label: Text('${noteService.totalNotesCount} notes'),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.offline_bolt_rounded),
            title: const Text('Offline Database'),
            subtitle: const Text('Powered by Hive NoSQL Engine • 0 KB Cloud Sync'),
          ),

          const Divider(height: 32),

          // About Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              'About Easy Notes',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 0.5,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Version'),
            subtitle: Text('${AppConstants.appVersion} (Build 1) - Production Ready'),
          ),
          ListTile(
            leading: const Icon(Icons.android_rounded),
            title: const Text('Package Name'),
            subtitle: const Text(AppConstants.packageName),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Privacy & Security'),
            subtitle: const Text('100% Private. No tracking, local encrypted storage.'),
          ),
        ],
      ),
    );
  }
}