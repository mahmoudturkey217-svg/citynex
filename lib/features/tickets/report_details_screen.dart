import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/models/ticket_model.dart';
import '../../core/models/ticket_media_model.dart';
import 'package:intl/intl.dart';
import '../../core/utils/cache_helper.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/badges.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/shared_widgets.dart';
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
      TicketCubit.get(context).getTicketDetails(_report.id);
      _didFetchDetails = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      body: BlocListener<TicketCubit, TicketState>(
        listener: (context, state) {
          if (state is TicketDeleteMediaSuccess) {
            AppSnackbar.show(context,
                message: state.message, isSuccess: true);
            setState(() => _currentImageIndex = 0);
          } else if (state is TicketDeleteMediaError) {
            AppSnackbar.show(context,
                message: 'Error: ${state.error}', isError: true);
          }
        },
        child: CustomScrollView(
          slivers: [
            // Image app bar with media
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: AppColors.primary,
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
                        color: AppColors.surfaceLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    }

                    if (state is TicketDetailLoaded &&
                        state.signedUrls.isNotEmpty) {
                      return _buildImageCarousel(
                          state.signedUrls, state.media);
                    }

                    return Container(
                      decoration: const BoxDecoration(
                        gradient: AppColors.primaryGradient,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              size: 48,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'No images provided',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
                      _report.title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Badges row
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                                color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                AppColors.categoryIcon(
                                    _report.category?.name ?? ''),
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _report.category?.name ?? 'General',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusBadge(status: _report.status ?? 'Open', fontSize: 13),
                        PriorityBadge(priority: _report.priority ?? 'Low', fontSize: 13),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Description card
                    _buildInfoCard(
                      icon: Icons.description_outlined,
                      title: 'Description',
                      child: Text(
                        _report.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
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
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Date card
                    _buildInfoCard(
                      icon: Icons.calendar_today_outlined,
                      title: 'Reported On',
                      child: Text(
                        _report.createdAt != null &&
                                _report.createdAt.isNotEmpty
                            ? DateFormat('EEEE, MMMM d, yyyy – hh:mm a')
                                .format(DateTime.parse(_report.createdAt!))
                            : 'Unknown',
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
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

  Widget _buildImageCarousel(
      List<String> imageUrls, List<TicketMediaModel> mediaItems) {
    return Stack(
      fit: StackFit.expand,
      children: [
        PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: (index) =>
              setState(() => _currentImageIndex = index),
          itemBuilder: (context, index) {
            final mediaItem =
                index < mediaItems.length ? mediaItems[index] : null;
            final mediaId = mediaItem?.id;
            final beforeAfter = mediaItem?.beforeAfter;

            return Stack(
              fit: StackFit.expand,
              children: [
                InteractiveViewer(
                  child: CachedNetworkImage(
                    imageUrl: imageUrls[index],
                    fit: BoxFit.cover,
                    progressIndicatorBuilder: (context, url, progress) {
                      return Container(
                        color: AppColors.surfaceLight,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: progress.progress,
                            color: AppColors.primary,
                          ),
                        ),
                      );
                    },
                    errorWidget: (context, url, error) {
                      return Container(
                        color: AppColors.surfaceLight,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.broken_image,
                                size: 48, color: AppColors.textHint),
                            SizedBox(height: 8),
                            Text('Failed to load image',
                                style:
                                    TextStyle(color: AppColors.textHint)),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                
                // BEFORE/AFTER badge
                if (beforeAfter != null && beforeAfter.isNotEmpty)
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: beforeAfter.toLowerCase() == 'before'
                            ? AppColors.error.withOpacity(0.9)
                            : AppColors.resolved.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        beforeAfter.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ),

                // Delete option for admin
                if (mediaId != null)
                  Positioned(
                    top: 40,
                    right: 16,
                    child: IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 20),
                      ),
                      onPressed: () =>
                          _showDeleteMediaDialog(context, mediaId),
                    ),
                  ),
              ],
            );
          },
        ),
        if (imageUrls.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(imageUrls.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
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
        if (imageUrls.length > 1)
          Positioned(
            top: 100,
            right: 16,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    return AppCard(
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 20, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
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
    final role = (CacheHelper.getData(key: 'user_role') ?? 'citizen')
        .toString()
        .toLowerCase();

    if (role == 'admin') {
      return Column(
        children: [
          GradientButton(
            label: 'Change Status',
            icon: Icons.edit_note_rounded,
            onPressed: () => _showChangeStatusDialog(context, report),
          ),
          const SizedBox(height: 12),
          AppOutlineButton(
            label: 'Delete Report',
            icon: Icons.delete_outline,
            color: AppColors.error,
            onPressed: () => _showDeleteDialog(context, report),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
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
                  borderRadius: AppDimensions.borderRadiusLg),
              title: const Text(
                'Change Status',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    title: const Text('Pending'),
                    value: 'Pending',
                    groupValue: selectedStatus,
                    activeColor: AppColors.pending,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Open'),
                    value: 'Open',
                    groupValue: selectedStatus,
                    activeColor: AppColors.open,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('In Progress'),
                    value: 'In Progress',
                    groupValue: selectedStatus,
                    activeColor: AppColors.inProgress,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val!),
                  ),
                  RadioListTile<String>(
                    title: const Text('Resolved'),
                    value: 'Resolved',
                    groupValue: selectedStatus,
                    activeColor: AppColors.resolved,
                    onChanged: (val) =>
                        setDialogState(() => selectedStatus = val!),
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
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
          shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLg),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Delete Report',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text(
              'Are you sure you want to delete this report? This action cannot be undone.',
              style: TextStyle(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
          shape: RoundedRectangleBorder(
              borderRadius: AppDimensions.borderRadiusLg),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_outlined,
                    color: AppColors.error, size: 20),
              ),
              const SizedBox(width: 12),
              const Text('Delete Photo',
                  style: TextStyle(fontSize: 18)),
            ],
          ),
          content: const Text(
              'Are you sure you want to delete this photo from the report?',
              style: TextStyle(color: AppColors.textSecondary)),
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
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
