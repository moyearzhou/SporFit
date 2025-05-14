import 'package:flutter/material.dart';

extension ImageExt on Image {
  Image copy({
    required Key key,
    required ImageProvider image,
    required ImageFrameBuilder frameBuilder,
    required ImageLoadingBuilder loadingBuilder,
    required ImageErrorWidgetBuilder errorBuilder,
    required String semanticLabel,
    required bool excludeFromSemantics,
    required double width,
    required double height,
    required Color color,
    required BlendMode colorBlendMode,
    required BoxFit fit,
    required AlignmentGeometry alignment,
    required ImageRepeat repeat,
    required Rect centerSlice,
    required bool matchTextDirection,
    required bool gaplessPlayback,
    required FilterQuality filterQuality,
  }) {
    return Image(
        key: key ?? this.key,
        image: image ?? this.image,
        frameBuilder: frameBuilder ?? this.frameBuilder,
        loadingBuilder: loadingBuilder ?? this.loadingBuilder,
        errorBuilder: errorBuilder ?? this.errorBuilder,
        semanticLabel: semanticLabel ?? this.semanticLabel,
        excludeFromSemantics: excludeFromSemantics ?? this.excludeFromSemantics,
        width: width ?? this.width,
        height: height ?? this.height,
        color: color,
        colorBlendMode: colorBlendMode ?? this.colorBlendMode,
        fit: fit ?? this.fit,
        alignment: alignment ?? this.alignment,
        repeat: repeat ?? this.repeat,
        centerSlice: centerSlice ?? this.centerSlice,
        matchTextDirection: matchTextDirection ?? this.matchTextDirection,
        gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
        filterQuality: filterQuality ?? this.filterQuality);
  }
}
