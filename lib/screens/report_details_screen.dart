import 'package:flutter/material.dart';
import '../models/report_model.dart';
import 'package:intl/intl.dart';
import '../mock_data.dart';

class ReportDetailsScreen extends StatelessWidget {
  const ReportDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final report = ModalRoute.of(context)!.settings.arguments as ReportModel;
    final isPending = report.status == 'Pending';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // Image app bar
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: report.imageUrl.isNotEmpty
                  ? Image.network(
                      report.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: Colors.grey.shade300,
                        child: const Icon(Icons.broken_image,
                            size: 64, color: Colors.grey),
                      ),
                    )
                  : Container(
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.image,
                          size: 64, color: Colors.grey),
                    ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    report.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Badges row
                  Row(
                    children: [
                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A237E).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.category,
                                size: 16, color: Color(0xFF1A237E)),
                            const SizedBox(width: 6),
                            Text(
                              report.category,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1A237E),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Status badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isPending
                              ? Colors.orange.withOpacity(0.15)
                              : Colors.green.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isPending
                                  ? Icons.schedule
                                  : Icons.check_circle,
                              size: 16,
                              color: isPending
                                  ? Colors.orange.shade700
                                  : Colors.green.shade700,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              report.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isPending
                                    ? Colors.orange.shade700
                                    : Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Description card
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    title: 'Description',
                    child: Text(
                      report.description,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                        height: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Location card
                  _buildInfoCard(
                    icon: Icons.location_on_outlined,
                    title: 'Location',
                    child: Text(
                      'Lat: ${report.latitude.toStringAsFixed(6)}\nLng: ${report.longitude.toStringAsFixed(6)}',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Date card
                  _buildInfoCard(
                    icon: Icons.calendar_today_outlined,
                    title: 'Reported On',
                    child: Text(
                      DateFormat('EEEE, MMMM d, yyyy – hh:mm a')
                          .format(report.createdAt),
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Admin actions (shown based on mock role)
                  if (MockUser.role == 'admin')
                    _buildAdminActions(context, report),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFF1A237E)),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1A237E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }

  Widget _buildAdminActions(BuildContext context, ReportModel report) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: () => _showChangeStatusDialog(context, report),
            icon: const Icon(Icons.edit_note_rounded),
            label: const Text(
              'Change Status',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => _showDeleteDialog(context, report),
            icon: const Icon(Icons.delete_outline),
            label: const Text(
              'Delete Report',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showChangeStatusDialog(BuildContext context, ReportModel report) {
    String selectedStatus = report.status;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              title: const Text(
                'Change Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Pending'),
                    value: 'Pending',
                    groupValue: selectedStatus,
                    activeColor: Colors.orange,
                    onChanged: (val) {
                      setDialogState(() => selectedStatus = val!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Open'),
                    value: 'Open',
                    groupValue: selectedStatus,
                    activeColor: const Color(0xFF4A90D9),
                    onChanged: (val) {
                      setDialogState(() => selectedStatus = val!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('In Progress'),
                    value: 'In Progress',
                    groupValue: selectedStatus,
                    activeColor: const Color(0xFFF39C12),
                    onChanged: (val) {
                      setDialogState(() => selectedStatus = val!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('Resolved'),
                    value: 'Resolved',
                    groupValue: selectedStatus,
                    activeColor: Colors.green,
                    onChanged: (val) {
                      setDialogState(() => selectedStatus = val!);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // UI mode: no backend call
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1A237E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, ReportModel report) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Delete Report',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          content:
              const Text('Are you sure you want to delete this report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                // UI mode: no backend call
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
