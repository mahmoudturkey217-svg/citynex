import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/models/assignment_model.dart';
import '../../core/models/ticket_media_model.dart';
import '../../core/repositories/assignment_repository.dart';
import '../assignments/logic/assignment_cubit.dart';
import '../assignments/logic/assignment_state.dart';
import 'package:image_picker/image_picker.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final AssignmentModel assignment;

  const AssignmentDetailScreen({super.key, required this.assignment});

  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  final AssignmentRepository _repo = AssignmentRepository();
  final Map<int, String> _signedUrls = {};
  bool _loadingMedia = false;

  @override
  void initState() {
    super.initState();
    _loadMediaUrls();
  }

  Future<void> _loadMediaUrls() async {
    final media = widget.assignment.ticket.media;
    if (media == null || media.isEmpty) return;

    setState(() => _loadingMedia = true);

    for (var m in media) {
      try {
        final url = await _repo.getMediaSignedUrl(
            widget.assignment.ticket.id, m.id);
        if (mounted) {
          setState(() {
            _signedUrls[m.id] = url;
          });
        }
      } catch (e) {
        print('⚠️ Could not load signed URL for media ${m.id}: $e');
      }
    }

    if (mounted) setState(() => _loadingMedia = false);
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    final ticket = assignment.ticket;

    // Status styling
    Color statusColor;
    IconData statusIcon;
    switch (assignment.status) {
      case 'Pending':
        statusColor = const Color(0xFFE5A100);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Assigned':
      case 'Accepted':
      case 'Open':
        statusColor = const Color(0xFF4A90D9);
        statusIcon = Icons.check_circle_outline;
        break;
      case 'In_Progress':
      case 'In Progress':
        statusColor = const Color(0xFF9B59B6);
        statusIcon = Icons.sync;
        break;
      case 'Completed':
      case 'Fixed':
      case 'Verified':
      case 'Resolved':
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.task_alt;
        break;
      case 'Declined':
      case 'Closed':
        statusColor = const Color(0xFFE74C3C);
        statusIcon = Icons.cancel_outlined;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    Color priorityColor;
    switch (ticket.priority) {
      case 'High':
        priorityColor = const Color(0xFFE74C3C);
        break;
      case 'Medium':
        priorityColor = const Color(0xFFF39C12);
        break;
      default:
        priorityColor = const Color(0xFF2ECC71);
    }

    // Format dates
    String assignedDate = '';
    try {
      final dt = DateTime.parse(assignment.assignedAt);
      assignedDate = DateFormat('MMM dd, yyyy – HH:mm').format(dt);
    } catch (_) {
      assignedDate = assignment.assignedAt;
    }

    String createdDate = '';
    try {
      final dt = DateTime.parse(ticket.createdAt);
      createdDate = DateFormat('MMM dd, yyyy – HH:mm').format(dt);
    } catch (_) {
      createdDate = ticket.createdAt;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F7),
      body: BlocListener<AssignmentCubit, AssignmentState>(
        listener: (context, state) {
          if (state is AssignmentActionSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFF2ECC71),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
            );
            Navigator.pop(context);
          } else if (state is AssignmentActionError) {
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
        child: CustomScrollView(
          slivers: [
            // ─── APP BAR ───
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              backgroundColor: const Color(0xFF0D2137),
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  ticket.title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF0D2137), Color(0xFF1A3A5C)],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: statusColor, size: 40),
                    ),
                  ),
                ),
              ),
            ),

            // ─── CONTENT ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── STATUS & BADGES ──
                    Row(
                      children: [
                        _buildBadge(
                            assignment.displayStatus, statusColor, statusIcon),
                        const SizedBox(width: 8),
                        _buildBadge(ticket.priority, priorityColor, null),
                        if (ticket.emergencyFlag) ...[
                          const SizedBox(width: 8),
                          _buildBadge('Emergency', const Color(0xFFE74C3C),
                              Icons.warning_amber_rounded),
                        ],
                        if (assignment.aiVerified) ...[
                          const SizedBox(width: 8),
                          _buildBadge('AI Verified', const Color(0xFF4A90D9),
                              Icons.verified_outlined),
                        ],
                      ],
                    ),
                    const SizedBox(height: 20),

                    // ── TICKET INFO ──
                    _buildSectionCard(
                      title: 'Ticket Details',
                      icon: Icons.description_outlined,
                      children: [
                        _buildInfoRow('Title', ticket.title),
                        _buildInfoRow('Description', ticket.description),
                        _buildInfoRow('Category', ticket.category.name),
                        _buildInfoRow('Area / Zone', ticket.area.name),
                        _buildInfoRow('Created', createdDate),
                        _buildInfoRow(
                            'Confirmed', '${ticket.confirmedCount} times'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── ASSIGNMENT INFO ──
                    _buildSectionCard(
                      title: 'Assignment Info',
                      icon: Icons.assignment_outlined,
                      children: [
                        _buildInfoRow('Assignment ID', '#${assignment.id}'),
                        _buildInfoRow('Assigned At', assignedDate),
                        _buildInfoRow('Status', assignment.displayStatus),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── LOCATION ──
                    _buildSectionCard(
                      title: 'Location',
                      icon: Icons.location_on_outlined,
                      children: [
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              final lat = ticket.lat;
                              final lng = ticket.lng;
                              final url = Uri.parse(
                                  'https://www.google.com/maps/search/?api=1&query=$lat,$lng');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url,
                                    mode: LaunchMode.externalApplication);
                              }
                            },
                            icon: const Icon(Icons.map_outlined, size: 20),
                            label: const Text(
                              'Open in Google Maps',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0D3B66),
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── IMAGES / MEDIA ──
                    _buildMediaSection(ticket.media),
                    const SizedBox(height: 24),

                    // ── ACTION BUTTONS ──
                    _buildActionButtons(assignment),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color, IconData? icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D3B66).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF0D3B66), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1D26),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(List<TicketMediaModel>? media) {
    final hasMedia = media != null && media.isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF9B59B6).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: Color(0xFF9B59B6), size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'Images & Media',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1D26),
                ),
              ),
              const Spacer(),
              if (hasMedia)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B59B6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${media!.length} items',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF9B59B6),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (!hasMedia)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 40, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(
                      'No images attached',
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey.shade400),
                    ),
                  ],
                ),
              ),
            )
          else if (_loadingMedia && _signedUrls.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: CircularProgressIndicator(),
              ),
            )
          else
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: media!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final m = media[index];
                  final url = _signedUrls[m.id];

                  return GestureDetector(
                    onTap: () {
                      if (url != null) _showFullscreenImage(context, url, m);
                    },
                    child: Container(
                      width: 160,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (url != null)
                              Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder:
                                    (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress
                                                  .expectedTotalBytes !=
                                              null
                                          ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                              loadingProgress
                                                  .expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.broken_image_outlined,
                                          size: 32,
                                          color: Colors.grey.shade400),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Load failed',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.grey.shade400),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            else
                              Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.grey.shade400,
                                ),
                              ),

                            // Before/After label
                            if (m.beforeAfter != null)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    m.beforeAfter!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showFullscreenImage(
      BuildContext context, String url, TicketMediaModel media) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: Text(
              media.beforeAfter != null
                  ? '${media.beforeAfter} Image'
                  : 'Image',
              style: const TextStyle(fontSize: 16),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              minScale: 0.5,
              maxScale: 4.0,
              child: Image.network(
                url,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                },
                errorBuilder: (_, __, ___) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 64, color: Colors.white54),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(AssignmentModel assignment) {
    if (assignment.status == 'Pending') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                _showConfirmDialog(
                  'Decline Assignment',
                  'Are you sure you want to decline this assignment?',
                  () => context
                      .read<AssignmentCubit>()
                      .declineAssignment(assignment.id),
                );
              },
              icon: const Icon(Icons.close, size: 18),
              label: const Text('Decline',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE74C3C),
                side: const BorderSide(color: Color(0xFFE74C3C)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context
                    .read<AssignmentCubit>()
                    .acceptAssignment(assignment.id);
              },
              icon: const Icon(Icons.check, size: 18),
              label: const Text('Accept',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2ECC71),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
    }

    if (assignment.status == 'In_Progress' ||
        assignment.status == 'In Progress' ||
        assignment.status == 'Completed' ||
        assignment.status == 'Fixed' ||
        assignment.status == 'Resolved' ||
        assignment.status == 'Verified') {
      return Column(
        children: [
          if (assignment.status == 'In_Progress' || assignment.status == 'In Progress') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showConfirmDialog(
                    'Mark as Completed',
                    'Are you sure this assignment is completed?',
                    () => context
                        .read<AssignmentCubit>()
                        .updateAssignmentStatus(assignment.id, 'Completed'),
                  );
                },
                icon: const Icon(Icons.check_circle, size: 20),
                label: const Text('Mark as Completed',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D3B66),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _pickAndUploadImage(context, assignment),
              icon: const Icon(Icons.add_a_photo_outlined, size: 20),
              label: const Text('Upload Work Image',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0D3B66),
                side: const BorderSide(color: Color(0xFF0D3B66), width: 1.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      );
    }

    // Default for other statuses
    return const SizedBox.shrink();
  }

  Future<void> _pickAndUploadImage(BuildContext context, AssignmentModel assignment) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null && context.mounted) {
        context.read<AssignmentCubit>().uploadMedia(
              assignment.ticket.id,
              image.path,
              beforeAfter: 'After',
            );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
    }
  }

  void _showConfirmDialog(
      String title, String message, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title,
            style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        content: Text(message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel',
                style: TextStyle(color: Colors.grey.shade500)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              onConfirm();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D3B66),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
