import 'package:flutter/material.dart';

import '../theme/patient_portal_theme.dart';
import 'ui_kit.dart';

/// Bright, airy patient header: a large display title with an optional
/// gradient accent word, sitting transparently over the gradient canvas.
class PatientPortalShellHeader extends StatelessWidget {
  const PatientPortalShellHeader({
    super.key,
    required this.title,
    this.accentWord,
    this.subtitle,
    this.trailing,
  });

  final String title;

  /// Optional word rendered with the brand gradient after [title]
  /// (e.g. title "Your", accent "Smile").
  final String? accentWord;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnimatedEntrance(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, top + 18, 20, 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(title, style: PatientPortalTheme.displayLarge(context)),
                      if (accentWord != null && accentWord!.trim().isNotEmpty) ...[
                        Text(' ', style: PatientPortalTheme.displayLarge(context)),
                        GradientText(
                          accentWord!,
                          style: PatientPortalTheme.displayAccent(context),
                        ),
                      ],
                    ],
                  ),
                  if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      subtitle!,
                      style: PatientPortalTheme.body(context),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
