import 'package:flutter/material.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _statusUpdates = true;
  bool _newReports = true;
  bool _resolvedAlerts = true;
  bool _communityAlerts = false;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    // In-memory only in UI mode — defaults are set above
    if (mounted) setState(() {});
  }

  void _savePreference(String key, bool value) {
    // In-memory only — no SharedPreferences
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D2137),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Push Notifications
                  _buildSectionLabel('Push Notifications'),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildToggle(
                      icon: Icons.sync_alt_rounded,
                      title: 'Status Updates',
                      subtitle: 'When your report status changes',
                      value: _statusUpdates,
                      onChanged: (val) {
                        setState(() => _statusUpdates = val);
                        _savePreference('notif_status_updates', val);
                      },
                    ),
                    _divider(),
                    _buildToggle(
                      icon: Icons.campaign_outlined,
                      title: 'New Reports Nearby',
                      subtitle: 'Issues reported in your area',
                      value: _newReports,
                      onChanged: (val) {
                        setState(() => _newReports = val);
                        _savePreference('notif_new_reports', val);
                      },
                    ),
                    _divider(),
                    _buildToggle(
                      icon: Icons.check_circle_outline,
                      title: 'Resolved Alerts',
                      subtitle: 'When an issue is marked resolved',
                      value: _resolvedAlerts,
                      onChanged: (val) {
                        setState(() => _resolvedAlerts = val);
                        _savePreference('notif_resolved_alerts', val);
                      },
                    ),
                    _divider(),
                    _buildToggle(
                      icon: Icons.groups_outlined,
                      title: 'Community Alerts',
                      subtitle: 'General neighborhood announcements',
                      value: _communityAlerts,
                      onChanged: (val) {
                        setState(() => _communityAlerts = val);
                        _savePreference('notif_community_alerts', val);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Email Notifications
                  _buildSectionLabel('Email Notifications'),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildToggle(
                      icon: Icons.email_outlined,
                      title: 'Email Summaries',
                      subtitle: 'Receive weekly email digests',
                      value: _emailNotifications,
                      onChanged: (val) {
                        setState(() => _emailNotifications = val);
                        _savePreference('notif_email', val);
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // Info note
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D2137).withOpacity(0.06),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline,
                            size: 20, color: Colors.grey.shade600),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You can also manage notifications from your device settings.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
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

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade500,
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 56, color: Colors.grey.shade100);
  }

  Widget _buildToggle({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF0D3B66), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF1A1D26),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF0D3B66),
          ),
        ],
      ),
    );
  }
}
