// lib/utils/font_utils.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// A map of font names for display and their corresponding GoogleFonts text theme functions.
// This makes it easy to add or remove fonts in the future.
final Map<String, TextTheme Function(TextTheme)> availableFonts = {
  'Default (Rosarivo)': GoogleFonts.rosarivoTextTheme,
  'Quattrocento Sans': GoogleFonts.quattrocentoSansTextTheme,
  'Radley': GoogleFonts.radleyTextTheme,
  'Rancho': GoogleFonts.ranchoTextTheme,
  'Ravi Prakash': GoogleFonts.raviPrakashTextTheme,
  'Red Hat Display': GoogleFonts.redHatDisplayTextTheme,
  'Red Rose': GoogleFonts.redRoseTextTheme,
  'Redressed': GoogleFonts.redressedTextTheme,
  'Reem Kufi': GoogleFonts.reemKufiTextTheme,
  'Reenie Beanie': GoogleFonts.reenieBeanieTextTheme,
  'Reggae One': GoogleFonts.reggaeOneTextTheme,
  'Ribeye Marrow': GoogleFonts.ribeyeMarrowTextTheme,
  'Risque': GoogleFonts.risqueTextTheme,
  'Roboto Flex': GoogleFonts.robotoFlexTextTheme,
  'Roboto Serif': GoogleFonts.robotoSerifTextTheme,
  'Rochester': GoogleFonts.rochesterTextTheme,
  'Rock 3D': GoogleFonts.rock3dTextTheme,
  'Rock Salt': GoogleFonts.rockSaltTextTheme,
  'Rokkitt': GoogleFonts.rokkittTextTheme,
};

// A helper function to get the TextTheme function from a font's display name.
TextTheme Function(TextTheme) getFontTheme(String fontName) {
  return availableFonts[fontName] ?? GoogleFonts.rosarivoTextTheme;
}