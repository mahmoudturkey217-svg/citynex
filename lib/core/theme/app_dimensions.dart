import 'package:flutter/material.dart';

/// Consistent spacing, radius, and sizing tokens for the CityNex design system.
abstract class AppDimensions {
  // ─── SPACING ───
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;

  // ─── BORDER RADIUS ───
  static const double radiusSm = 8;
  static const double radiusMd = 14;
  static const double radiusLg = 20;
  static const double radiusXl = 28;

  static const BorderRadius borderRadiusSm = BorderRadius.all(Radius.circular(8));
  static const BorderRadius borderRadiusMd = BorderRadius.all(Radius.circular(14));
  static const BorderRadius borderRadiusLg = BorderRadius.all(Radius.circular(20));
  static const BorderRadius borderRadiusXl = BorderRadius.all(Radius.circular(28));

  // ─── ICON SIZES ───
  static const double iconSm = 18;
  static const double iconMd = 22;
  static const double iconLg = 28;

  // ─── COMPONENT HEIGHTS ───
  static const double buttonHeight = 52;
  static const double inputHeight = 50;
  static const double bottomNavHeight = 68;
  static const double filterChipHeight = 38;

  // ─── CONTENT PADDING ───
  static const EdgeInsets screenPadding =
      EdgeInsets.symmetric(horizontal: 20);
  static const EdgeInsets cardPadding = EdgeInsets.all(16);
  static const EdgeInsets formPadding =
      EdgeInsets.symmetric(horizontal: 28);

  // ─── AVATAR ───
  static const double avatarRadius = 44;

  // ─── HEADER ───
  static const BorderRadius headerRadius = BorderRadius.only(
    bottomLeft: Radius.circular(28),
    bottomRight: Radius.circular(28),
  );
}
