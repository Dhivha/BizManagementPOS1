// Profile Widget
import 'package:bizmanagement/providers/auth_provider.dart';
import 'package:bizmanagement/utils/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        return Stack(
          children: [
            // Dark background
            Container(
              color: AppTheme.backgroundDark,
            ),
            // Main content
            SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Profile Header Card
                  Container(
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.circular(24),
                    //   color: AppTheme.primaryNavy.withValues(alpha: 0.9),
                    //   border: Border.all(
                    //     color: AppTheme.gold.withValues(alpha: 0.3),
                    //     width: 1.5,
                    //   ),
                    //   boxShadow: [
                    //     BoxShadow(
                    //       color: AppTheme.gold.withValues(alpha: 0.2),
                    //       blurRadius: 20,
                    //       spreadRadius: 2,
                    //       offset: const Offset(0, 8),
                    //     ),
                    //   ],
                    // ),
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.gold,
                                AppTheme.darkGold,
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 48,
                            backgroundColor: AppTheme.primaryNavy,
                            child: Text(
                              user?.fullName.substring(0, 1).toUpperCase() ??
                                  'You',
                              style: const TextStyle(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          user?.fullName ?? 'User',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '@${user?.username ?? 'user'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Personal Information Card
                  _buildProfileSectionCard(
                    'Personal Information',
                    [
                      _buildProfileDetailRow(Icons.person, 'Full Name',
                          user?.fullName ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(Icons.account_circle, 'Username',
                          user?.username ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(
                          Icons.phone, 'Phone', user?.phone ?? 'Not provided'),
                      if (user?.phone2 != null && user!.phone2!.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        _buildProfileDetailRow(
                            Icons.phone_android, 'Phone 2', user.phone2!),
                      ],
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(Icons.badge, 'ID Number',
                          user?.idNumber ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(
                          Icons.cake,
                          'Date of Birth',
                          user?.dateOfBirth != null
                              ? '${user!.dateOfBirth.day}/${user.dateOfBirth.month}/${user.dateOfBirth.year}'
                              : 'Not provided'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Work Information Card
                  _buildProfileSectionCard(
                    'Work Information',
                    [
                      _buildProfileDetailRow(Icons.business, 'Department',
                          user?.department ?? 'Not provided'),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(Icons.work, 'Position',
                          _getPositionName(user?.position)),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(
                        user?.isActive == true
                            ? Icons.check_circle
                            : Icons.cancel,
                        'Status',
                        user?.isActive == true ? 'Active' : 'Inactive',
                        color:
                            user?.isActive == true ? Colors.green : Colors.red,
                      ),
                      const SizedBox(height: 16),
                      _buildProfileDetailRow(
                          Icons.calendar_today,
                          'Member Since',
                          user?.createdAt != null
                              ? '${user!.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}'
                              : 'Not available'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Options
                  _buildProfileOptionsCard(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildProfileSectionCard(String title, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.primaryNavy.withValues(alpha: 0.8),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 20),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProfileOptionsCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: AppTheme.primaryNavy.withValues(alpha: 0.8),
        border: Border.all(
          color: AppTheme.gold.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildOptionTile(
            context,
            Icons.edit,
            'Edit Profile',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Edit Profile feature coming soon!')),
              );
            },
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          _buildOptionTile(
            context,
            Icons.security,
            'Privacy & Security',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Privacy Settings feature coming soon!')),
              );
            },
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          _buildOptionTile(
            context,
            Icons.help,
            'Help & Support',
            () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Help & Support feature coming soon!')),
              );
            },
          ),
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          _buildOptionTile(
            context,
            Icons.info,
            'About',
            () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('About BizManagement'),
                  content: const Text(
                      'Version 1.0.0\nA professional business management application.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile(
      BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: AppTheme.gold, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: Colors.white38,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileDetailRow(IconData icon, String label, String value,
      {Color? color}) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (color ?? AppTheme.gold).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 18,
            color: color ?? AppTheme.gold,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
              letterSpacing: 0.3,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color ?? Colors.white,
              letterSpacing: 0.3,
            ),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  String _getPositionName(int? position) {
    switch (position) {
      case 0:
        return 'Administrator';
      case 1:
        return 'Manager';
      case 2:
        return 'Employee';
      case 3:
        return 'Supervisor';
      default:
        return 'Not specified';
    }
  }
}
