import 'package:flutter/material.dart';

class AppColors {
  // --- 100% MONOCHROMATIC BASE PALETTE ---
  
  // --- LIGHT THEME (Pristine White & High Contrast Monochrome) ---
  static const Color lightBackground = Color(0xFFFFFFFF); // Pure pristine white
  static const Color lightSurface = Color(0xFFF7F7F8); // Very light grey surface
  static const Color lightSurfaceHighlight = Color(0xFFEFEFF1); // Hover/Pressed/Subtle
  
  static const Color lightTextPrimary = Color(0xFF09090B); // Stark black
  static const Color lightTextSecondary = Color(0xFF71717A); // Mid-tone gray
  static const Color lightTextTertiary = Color(0xFFA1A1AA); // Muted gray
  
  static const Color lightBorder = Color(0xFFE4E4E7);
  static const Color lightDivider = Color(0xFFF4F4F5);
  
  static const Color lightIcon = Color(0xFF71717A);
  static const Color lightIconActive = Color(0xFF09090B);

  // --- DARK THEME (True AMOLED Deep Black & Crisp Monochrome) ---
  static const Color darkBackground = Color(0xFF000000); // True AMOLED Pure Black
  static const Color darkSurface = Color(0xFF0E0E10); // Deep dark surface
  static const Color darkSurfaceHighlight = Color(0xFF18181B); // Raised surface / hover
  
  static const Color darkTextPrimary = Color(0xFFFAFAFA); // Crisp off-white
  static const Color darkTextSecondary = Color(0xFFA1A1AA); // Mid-tone gray
  static const Color darkTextTertiary = Color(0xFF71717A); // Muted gray
  
  static const Color darkBorder = Color(0xFF27272A);
  static const Color darkDivider = Color(0xFF18181B);
  
  // Icons
  static const Color darkIcon = Color(0xFFA1A1AA);
  static const Color darkIconActive = Color(0xFFFAFAFA);

  // --- MONOCHROMATIC BRAND & ACTION ACCENTS ---
  static const Color primary = Color(0xFFFAFAFA); // Stark Crisp Monochrome Accent
  static const Color accentBlue = Color(0xFF44A5EA); // Subtle low-key accent substitute
  static const Color accentCompress = Color(0xFF44A5EA);
  static const Color accentUpscale = Color(0xFFA1A1AA);
  static const Color accentDownload = Color(0xFFFAFAFA);
  static const Color accentDelete = Color(0xFFEF4444); // Functional delete alert only
  static const Color accentWarning = Color(0xFFF59E0B);
  
  // Backward compatibility alias for status colors
  static const Color success = Color(0xFFFAFAFA);
  static const Color warning = accentWarning;
  static const Color error = accentDelete;
  static const Color info = Color(0xFFFAFAFA);
}
