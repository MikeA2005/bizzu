import 'dart:convert';

import 'package:flutter/material.dart';

// Convierte imágenes Base64 del teléfono o URLs remotas en un widget Flutter.
class ProductImage extends StatelessWidget {
  final String imageSource;
  final double? width;
  final double? height;
  final BoxFit fit;

  const ProductImage({
    super.key,
    required this.imageSource,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    if (imageSource.isEmpty) {
      return _fallbackIcon();
    }

    // Si es una imagen guardada en Base64 desde el teléfono
    if (imageSource.startsWith('data:image')) {
      try {
        final base64String = imageSource.split(',').last;
        final bytes = base64Decode(base64String);
        return Image.memory(
          bytes,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, _, _) => _fallbackIcon(),
        );
      } catch (_) {
        return _fallbackIcon();
      }
    }

    // Si es una URL de internet (compatibilidad con registros anteriores)
    return Image.network(
      imageSource,
      width: width,
      height: height,
      fit: fit,
      errorBuilder: (_, _, _) => _fallbackIcon(),
    );
  }

  Widget _fallbackIcon() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.image_not_supported,
        size: 48,
        color: Colors.grey,
      ),
    );
  }
}
