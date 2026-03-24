import 'package:flutter/material.dart';

/// Centralized color palette for the CityNex design system.
abstract class AppColors {
  // ─── PRIMARY ───
  static const Color primary = Color(0xFF0A2D4F);
  static const Color primaryLight = Color(0xFF1565C0);
  static const Color primarySoft = Color(0xFF4A90D9);

  // ─── SECONDARY / ACCENT ───
  static const Color accent = Color(0xFF00BFA6);
  static const Color accentLight = Color(0xFFB2DFDB);

  // ─── BACKGROUND ───
  static const Color scaffoldBg = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF0F2F5);

  // ─── TEXT ───
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);

  // ─── DIVIDER / BORDER ───
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ─── STATUS ───
  static const Color pending = Color(0xFFE5A100);
  static const Color open = Color(0xFF4A90D9);
  static const Color inProgress = Color(0xFF9B59B6);
  static const Color resolved = Color(0xFF2ECC71);
  static const Color error = Color(0xFFEF4444);
  static const Color declined = Color(0xFFE74C3C);

  // ─── PRIORITY ───
  static const Color critical = Color(0xFFDC2626);
  static const Color high = Color(0xFFF97316);
  static const Color medium = Color(0xFFF59E0B);
  static const Color low = Color(0xFF22C55E);

  // ─── BOTTOM NAV ───
  static const Color navBar = Color(0xFF0D2137);

  // ─── GRADIENTS ───
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2D4F), Color(0xFF1565C0)],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF00BFA6), Color(0xFF00897B)],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A2D4F), Color(0xFF1A4A7A)],
  );

  // ─── HELPERS ───

  /// Returns status color for a given status string.
  static Color statusColor(String status) {
    return switch (status) {
      'Pending' => pending,
      'Open' || 'Assigned' || 'Accepted' => open,
      'In_Progress' || 'In Progress' => inProgress,
      'Resolved' || 'Fixed' || 'Verified' || 'Completed' => resolved,
      'Declined' || 'Closed' => declined,
      _ => textSecondary,
    };
  }

  /// Returns priority color for a given priority string.
  static Color priorityColor(String priority) {
    return switch (priority) {
      'Critical' => critical,
      'High' => high,
      'Medium' => medium,
      'Low' => low,
      _ => textSecondary,
    };
  }

  /// Returns status icon for a given status string.
  static IconData statusIcon(String status) {
    return switch (status) {
      'Pending' => Icons.hourglass_empty,
      'Open' || 'Assigned' || 'Accepted' => Icons.folder_open_outlined,
      'In_Progress' || 'In Progress' => Icons.sync,
      'Resolved' || 'Fixed' || 'Verified' || 'Completed' =>
        Icons.check_circle_outline,
      'Declined' || 'Closed' => Icons.cancel_outlined,
      _ => Icons.info_outline,
    };
  }

  /// Returns category icon for a given category name.
  static IconData categoryIcon(String categoryName) {
    return switch (categoryName.toLowerCase()) {
      'road damage' || 'road' => Icons.warning_rounded,
      'public safety' => Icons.shield_outlined,
      'water' => Icons.water_drop_outlined,
      'electricity' => Icons.electric_bolt_outlined,
      'waste' => Icons.delete_outline,
      _ => Icons.report_outlined,
    };
  }
}
