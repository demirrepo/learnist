import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_theme.dart';

/// Maps Markdown tags onto the app's type scale.
///
/// `google_fonts` bakes the weight into the registered font family, so an
/// inherited `fontWeight` alone would not pick up the bold face: `strong`
/// and the headings need their own full `GoogleFonts.manrope` style.
MarkdownStyleSheet aiMarkdownStyleSheet(BuildContext context) {
  final body = GoogleFonts.manrope(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );
  final bold = GoogleFonts.manrope(
    fontSize: 14,
    height: 1.5,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
  );

  return MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
    p: body,
    strong: bold,
    em: body.copyWith(fontStyle: FontStyle.italic),
    listBullet: body,
    a: body.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    ),
    // Headings sized down so they don't tower over the card.
    h1: bold.copyWith(fontSize: 17),
    h2: bold.copyWith(fontSize: 16),
    h3: bold.copyWith(fontSize: 15),
    h4: bold,
    h5: bold,
    h6: bold,
    code: GoogleFonts.robotoMono(
      fontSize: 13,
      height: 1.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textPrimary,
    ),
    codeblockDecoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    blockquoteDecoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
    ),
    blockSpacing: 10,
    // The surrounding panel pads the content; drop the theme's outer margins.
    h1Padding: EdgeInsets.zero,
    h2Padding: EdgeInsets.zero,
    h3Padding: EdgeInsets.zero,
    pPadding: EdgeInsets.zero,
  );
}
