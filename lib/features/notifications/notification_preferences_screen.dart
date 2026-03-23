import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'logic/notification_cubit.dart';
import 'logic/notification_state.dart';
import '../../core/models/notification_preference_model.dart';

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationCubit>().loadPreferences();
  }

  IconData _getEventIcon(String eventType) {
    if (eventType.contains('ticket_created')) return Icons.add_circle_outline;
    if (eventType.contains('ticket_updated')) return Icons.edit_outlined;
    if (eventType.contains('ticket_assigned')) return Icons.assignment_outlined;
    if (eventType.contains('ticket_resolved')) return Icons.check_circle_outline;
    if (eventType.contains('assignment_accepted')) return Icons.thumb_up_outlined;
    if (eventType.contains('assignment_declined')) return Icons.thumb_down_outlined;
    if (eventType.contains('assignment_status')) return Icons.sync_alt_rounded;
    if (eventType.contains('ticket_voted')) return Icons.how_to_vote_outlined;
    if (eventType.contains('media_uploaded')) return Icons.image_outlined;
    return Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Notification Preferences',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF0D2137),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationActionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red.shade400,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        },
        buildWhen: (previous, current) {
          return current is NotificationLoading ||
              current is NotificationPreferencesLoaded ||
              current is NotificationError;
        },
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return _buildErrorWidget(state.error);
          }

          if (state is NotificationPreferencesLoaded) {
            return _buildPreferencesList(state.preferences);
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  Widget _buildPreferencesList(List<NotificationPreferenceModel> preferences) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info note
          Container(
            padding: const EdgeInsets.all(14),
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
                    'Configure how you receive notifications for each event type.',
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
          const SizedBox(height: 20),

          // Preference cards
          ...preferences.map((pref) => _buildPreferenceCard(pref)),
        ],
      ),
    );
  }

  Widget _buildPreferenceCard(NotificationPreferenceModel pref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 12),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D3B66).withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getEventIcon(pref.eventType),
              color: const Color(0xFF0D3B66),
              size: 20,
            ),
          ),
          title: Text(
            pref.displayName,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1D26),
            ),
          ),
          subtitle: Text(
            pref.iconHint,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
          ),
          children: [
            _buildChannelToggle(
              icon: Icons.notifications_active_outlined,
              label: 'Push Notifications',
              value: pref.pushEnabled,
              onChanged: (val) {
                context.read<NotificationCubit>().updatePreference(
                      pref.eventType,
                      pushEnabled: val,
                    );
              },
            ),
            _buildChannelToggle(
              icon: Icons.email_outlined,
              label: 'Email',
              value: pref.emailEnabled,
              onChanged: (val) {
                context.read<NotificationCubit>().updatePreference(
                      pref.eventType,
                      emailEnabled: val,
                    );
              },
            ),
            _buildChannelToggle(
              icon: Icons.cell_tower_outlined,
              label: 'Broadcast',
              value: pref.broadcastEnabled,
              onChanged: (val) {
                context.read<NotificationCubit>().updatePreference(
                      pref.eventType,
                      broadcastEnabled: val,
                    );
              },
            ),
            _buildChannelToggle(
              icon: Icons.sms_outlined,
              label: 'SMS',
              value: pref.smsEnabled,
              onChanged: (val) {
                context.read<NotificationCubit>().updatePreference(
                      pref.eventType,
                      smsEnabled: val,
                    );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChannelToggle({
    required IconData icon,
    required String label,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
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

  Widget _buildErrorWidget(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.error_outline,
                  size: 48, color: Colors.red.shade300),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load preferences',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1D26),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.red.shade400),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  context.read<NotificationCubit>().loadPreferences(),
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D3B66),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
