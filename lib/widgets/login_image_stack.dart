import 'package:flutter/material.dart';

/// Image configuration for the login screen.
///
/// **Location:** `lib/widgets/login_image_stack.dart` — class `LoginImageAssets`
///
/// Images are loaded from local assets. To change them, replace the files in
/// `assets/images/` or update the paths below.
class LoginImageAssets {
  static const String dentalClinicTreatment =
      'assets/images/filip-rankovic-grobgaard-rm7Mgu33tHU-unsplash.jpg';
  static const String happyDentalPatient =
      'assets/images/atikah-akhtar-XJptUS8nbhs-unsplash.jpg';
  static const String dentistConsultation =
      'assets/images/caroline-lm--m-4tYmtLlI-unsplash.jpg';
}

/// Overlapping stacked layout of 3 rounded dental/clinic images from assets.
class LoginImageStackSection extends StatelessWidget {
  const LoginImageStackSection({super.key});

  static const double _borderRadius = 28;
  static const double _imageWidth = 140;
  static const double _imageHeight = 160;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 360;

    return SizedBox(
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Bottom-right (back)
          Positioned(
            right: isNarrow ? 8 : 24,
            bottom: 12,
            child: _StackImage(
              assetPath: LoginImageAssets.dentistConsultation,
              width: _imageWidth,
              height: _imageHeight,
              borderRadius: _borderRadius,
              rotation: -0.08,
            ),
          ),
          // Mid-left
          Positioned(
            left: isNarrow ? 12 : 28,
            top: 24,
            child: _StackImage(
              assetPath: LoginImageAssets.happyDentalPatient,
              width: _imageWidth,
              height: _imageHeight,
              borderRadius: _borderRadius,
              rotation: 0.06,
            ),
          ),
          // Top-right (front)
          Positioned(
            right: isNarrow ? 28 : 48,
            top: 8,
            child: _StackImage(
              assetPath: LoginImageAssets.dentalClinicTreatment,
              width: _imageWidth,
              height: _imageHeight,
              borderRadius: _borderRadius,
              rotation: -0.05,
            ),
          ),
        ],
      ),
    );
  }
}

class _StackImage extends StatelessWidget {
  const _StackImage({
    required this.assetPath,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.rotation = 0,
  });

  final String assetPath;
  final double width;
  final double height;
  final double borderRadius;
  final double rotation;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          assetPath,
          width: width,
          height: height,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      ),
    );
  }
}
