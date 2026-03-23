import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/ticket_model.dart';
import '../../core/models/ticket_media_model.dart';
import 'package:intl/intl.dart';
import '../../core/utils/cache_helper.dart';
import 'logic/ticket_cubit.dart';
import 'logic/ticket_state.dart';

class ReportDetailsScreen extends StatefulWidget {
  const ReportDetailsScreen({super.key});

  @override
  State<ReportDetailsScreen> createState() => _ReportDetailsScreenState();
}

class _ReportDetailsScreenState extends State<ReportDetailsScreen> {
  late TicketModel _report;
  bool _didFetchDetails = false;
  int _currentImageIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didFetchDetails) {
      _report = ModalRoute.of(context)!.settings.arguments as TicketModel;
      // Fetch ticket details with media
      TicketCubit.get(context).getTicketDetails(_report.id);
      _didFetchDetails = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    IconData statusIcon;
    switch (_report.status) {
      case 'Pending':
        statusColor = const Color(0xFFE5A100);
        statusIcon = Icons.hourglass_empty;
        break;
      case 'Open':
        statusColor = const Color(0xFF4A90D9);
        statusIcon = Icons.folder_open_outlined;
        break;
      case 'In_Progress':
      case 'In Progress':
        statusColor = const Color(0xFF9B59B6);
        statusIcon = Icons.groups_outlined;
        break;
      case 'Fixed':
      case 'Verified':
      case 'Resolved':
        statusColor = const Color(0xFF2ECC71);
        statusIcon = Icons.check_circle_outline;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.info_outline;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: BlocListener<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketDeleteMediaSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.green.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
            // reset image index cautiously
            setState(() => _currentImageIndex = 0);
          } else if (state is TicketDeleteMediaError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.error}'),
                backgroundColor: Colors.red.shade600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            );
          }
        },
        child: CustomScrollView(
          slivers: [
            // Image app bar with media
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: BlocBuilder<TicketCubit, TicketState>(
                buildWhen: (prev, curr) =>
                    curr is TicketDetailLoading ||
                    curr is TicketDetailLoaded ||
                    curr is TicketDetailError,
                builder: (context, state) {
                  if (state is TicketDetailLoading) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1A237E),
                        ),
                      ),
                    );
                  }

                  if (state is TicketDetailLoaded &&
                      state.signedUrls.isNotEmpty) {
                    return _buildImageCarousel(state.signedUrls, state.media);
                  }

                  // Fallback placeholder
                  return Container(
                    color: Colors.grey.shade300,
                    child:
                        const Icon(Icons.image, size: 64, color: Colors.grey),
                  );
                },
              ),
            ),
          ),

          // We also need a bloc listener wrapper around the sliver list, but we can't wrap Slivers
          // in BlocListener directly easily unless it's the Scaffold. Let's add it to the body.

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    _report.title,
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
                              _report.category?.name ?? 'General',
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
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              statusIcon,
                              size: 16,
                              color: statusColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _report.status,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: statusColor,
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
                      _report.description,
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
                      'Lat: ${_report.lat.toStringAsFixed(6)}\nLng: ${_report.lng.toStringAsFixed(6)}\nArea: ${_report.area.name}',
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
                      _report.createdAt != null && _report.createdAt.isNotEmpty
                        ? DateFormat('EEEE, MMMM d, yyyy – hh:mm a').format(DateTime.parse(_report.createdAt!))
                        : 'Unknown',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Vote / Admin actions
                  _buildActions(context, _report),
                ],
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildImageCarousel(List<String> imageUrls, List<TicketMediaModel> mediaItems) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentImageIndex = index);
          },
          itemBuilder: (context, index) {
            final mediaId = index < mediaItems.length ? mediaItems[index].id : null;
            return Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: imageUrls[index],
                  fit: BoxFit.cover,
                  progressIndicatorBuilder: (context, url, progress) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: progress.progress,
                          color: const Color(0xFF1A237E),
                        ),
                      ),
                    );
                  },
                  errorWidget: (context, url, error) {
                    return Container(
                      color: Colors.grey.shade300,
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.broken_image, size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Failed to load image',
                              style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    );
                  },
                ),
                // Delete button for this specific image overlay
                if (mediaId != null)
                  Positioned(
                    top: 40, // Below status bar
                    right: 16,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () {
                        _showDeleteMediaDialog(context, mediaId);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
        // Page indicator dots
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return Container(
                  width: _currentImageIndex == index ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: _currentImageIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.4),
                  ),
                );
              }),
            ),
          ),
        // Image counter badge, adjusted top padding to avoid overlap with Delete button
        if (imageUrls.length > 1)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_currentImageIndex + 1}/${imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
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

  Widget _buildActions(BuildContext context, TicketModel report) {
    final role = (CacheHelper.getData(key: 'user_role') ?? 'citizen').toString().toLowerCase();

    if (role == 'admin') {
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
    } else {
      // Citizen role: Vote / Confirm action
      return SizedBox(
        width: double.infinity,
        height: 52,
        child: BlocConsumer<TicketCubit, TicketState>(
          listener: (context, state) {
            if (state is TicketActionSuccess && state.message.contains('confirm')) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('✅ Ticket confirmed successfully!'),
                  backgroundColor: Colors.green.shade400,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              Navigator.pop(context); // Optional: Pop back to list
            } else if (state is TicketActionError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${state.error}'),
                  backgroundColor: Colors.red.shade600,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state is TicketActionLoading;
            return ElevatedButton.icon(
              onPressed: isLoading ? null : () {
                if (report.id != null) {
                  TicketCubit.get(context).confirmTicket(report.id!);
                }
              },
              icon: isLoading ? const SizedBox() : const Icon(Icons.thumb_up_alt_outlined),
              label: isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Confirm / Vote (${report.confirmedCount ?? 0})',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A237E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  void _showChangeStatusDialog(BuildContext context, TicketModel report) {
    String selectedStatus = report.status ?? 'Open';
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

  void _showDeleteDialog(BuildContext context, TicketModel report) {
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

  void _showDeleteMediaDialog(BuildContext context, int mediaId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Delete Photo',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
          ),
          content: const Text('Are you sure you want to delete this photo from the report?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                TicketCubit.get(context).deleteTicketMedia(
                  ticketId: _report.id!,
                  mediaId: mediaId,
                );
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
