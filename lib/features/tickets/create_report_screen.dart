import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'logic/ticket_cubit.dart';
import 'logic/ticket_state.dart';
import '../../services/location_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/shared_widgets.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = 'Road';
  bool _hasLocation = false;
  bool _isLoading = false;
  double? _lat;
  double? _lng;

  final ImagePicker _picker = ImagePicker();
  File? _selectedImage;

  final List<String> _categories = ['Road', 'Water', 'Electricity', 'Waste', 'Other'];

  final Map<String, IconData> _categoryIcons = {
    'Road': Icons.edit_road,
    'Water': Icons.water_drop,
    'Electricity': Icons.electric_bolt,
    'Waste': Icons.delete_outline,
    'Other': Icons.more_horiz,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() => _selectedImage = File(pickedFile.path));
      }
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, message: 'Error picking image: $e', isError: true);
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      final loc = await LocationService.getCurrentLocation();
      if (!mounted) return;

      if (loc == null) {
        AppSnackbar.show(context,
            message: 'Unable to get location. Please check permissions.',
            isError: true);
        return;
      }

      setState(() {
        _lat = loc['lat'];
        _lng = loc['lng'];
        _hasLocation = true;
      });

      AppSnackbar.show(context,
          message: '📍 Location captured: ${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
          isSuccess: true);
    } catch (e) {
      if (!mounted) return;
      AppSnackbar.show(context, message: 'Failed to get location: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submitReport() {
    if (!_formKey.currentState!.validate()) return;

    if (!_hasLocation || _lat == null || _lng == null) {
      AppSnackbar.show(context,
          message: 'Please capture location first', isError: true);
      return;
    }

    int categoryId = _categories.indexOf(_selectedCategory) + 1;

    TicketCubit.get(context).createTicket(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      categoryId: categoryId.clamp(1, 5),
      areaId: 1,
      lat: _lat!,
      lng: _lng!,
      priority: 'Medium',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'New Report',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              AppTextField(
                controller: _titleController,
                label: 'Report Title',
                hint: 'e.g. Broken street light',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a title';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe the issue in detail...',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter a description';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category selector — visual grid
              _buildSectionLabel('Category'),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCategory = cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.cardBg,
                        borderRadius: AppDimensions.borderRadiusMd,
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.border,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _categoryIcons[cat],
                            size: 20,
                            color: isSelected ? AppColors.primary : AppColors.textSecondary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Image section
              _buildSectionLabel('Photo'),
              const SizedBox(height: 8),
              if (_selectedImage != null) ...[
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: AppDimensions.borderRadiusMd,
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImage = null),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.close, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () => _pickImage(ImageSource.gallery),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () => _pickImage(ImageSource.camera),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Location section
              _buildSectionLabel('Location'),
              const SizedBox(height: 8),
              if (_isLoading && !_hasLocation)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                )
              else
                _buildLocationCard(),
              const SizedBox(height: 32),

              // Submit button
              BlocConsumer<TicketCubit, TicketState>(
                listener: (context, state) async {
                  if (state is TicketActionSuccess) {
                    if (state.message.contains('created') &&
                        _selectedImage != null &&
                        state.ticket != null) {
                      AppSnackbar.show(context,
                          message: 'Report created! Uploading image...');
                      TicketCubit.get(context).uploadTicketMedia(
                        ticketId: state.ticket!.id,
                        filePath: _selectedImage!.path,
                      );
                    } else {
                      AppSnackbar.show(context,
                          message: '✅ Report submitted successfully!',
                          isSuccess: true);
                      if (mounted) Navigator.pop(context);
                    }
                  } else if (state is TicketActionError) {
                    AppSnackbar.show(context,
                        message: 'Error: ${state.error}', isError: true);
                  }
                },
                builder: (context, state) {
                  final isSubmitting = state is TicketActionLoading;
                  return GradientButton(
                    label: 'Submit Report',
                    icon: Icons.send,
                    isLoading: isSubmitting,
                    onPressed: _submitReport,
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildLocationCard() {
    return GestureDetector(
      onTap: _getCurrentLocation,
      child: AppCard(
        margin: EdgeInsets.zero,
        borderColor: _hasLocation ? AppColors.resolved : null,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (_hasLocation ? AppColors.resolved : AppColors.primary)
                    .withOpacity(0.1),
                borderRadius: AppDimensions.borderRadiusSm,
              ),
              child: Icon(
                _hasLocation
                    ? Icons.location_on_rounded
                    : Icons.my_location_rounded,
                color: _hasLocation ? AppColors.resolved : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _hasLocation ? 'Location Captured' : 'Get Current Location',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _hasLocation
                          ? AppColors.resolved
                          : AppColors.textPrimary,
                    ),
                  ),
                  if (_hasLocation && _lat != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${_lat!.toStringAsFixed(4)}, ${_lng!.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ] else
                    const Text(
                      'Tap to capture your location',
                      style: TextStyle(fontSize: 12, color: AppColors.textHint),
                    ),
                ],
              ),
            ),
            Icon(
              _hasLocation ? Icons.check_circle : Icons.chevron_right,
              color: _hasLocation ? AppColors.resolved : AppColors.textHint,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Material(
      color: AppColors.cardBg,
      borderRadius: AppDimensions.borderRadiusMd,
      child: InkWell(
        borderRadius: AppDimensions.borderRadiusMd,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusMd,
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
