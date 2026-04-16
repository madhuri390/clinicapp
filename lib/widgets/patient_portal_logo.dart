import 'package:flutter/material.dart';

/// Prodontics brand mark (PNG with transparent background).
class PatientPortalLogo extends StatelessWidget {
  const PatientPortalLogo({
    super.key,
    this.height = 52,
    this.width,
  });

  final double height;
  final double? width;

  static const assetPath = 'assets/images/prodontics_logo.png';

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      assetPath,
      height: height,
      width: width,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      errorBuilder: (context, error, stackTrace) => Icon(
        Icons.medical_services_outlined,
        size: height * 0.75,
        color: Colors.white,
      ),
    );
  }
}
