import 'dart:io';

import 'package:flutter/material.dart';

import '../../../core/theme/wish_colors.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/wish_item.dart';

class WishCard extends StatelessWidget {
  const WishCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onPurchased,
  });

  final WishItem item;
  final VoidCallback onTap;
  final VoidCallback onPurchased;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : 320.0;
        final body = _WishCardBody(
          item: item,
          onTap: onTap,
          onPurchased: onPurchased,
        );

        return LongPressDraggable<String>(
          data: item.id,
          delay: const Duration(milliseconds: 240),
          hapticFeedbackOnStart: true,
          feedback: SizedBox(
            width: width,
            child: Transform.rotate(
              angle: -0.012,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: context.colors.shadow.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: ExcludeSemantics(
                  child: IgnorePointer(
                    child: _WishCardBody(
                      item: item,
                      onTap: () {},
                      onPurchased: () {},
                    ),
                  ),
                ),
              ),
            ),
          ),
          childWhenDragging: Opacity(opacity: 0.3, child: body),
          child: body,
        );
      },
    );
  }
}

class _WishCardBody extends StatelessWidget {
  const _WishCardBody({
    required this.item,
    required this.onTap,
    required this.onPurchased,
  });

  final WishItem item;
  final VoidCallback onTap;
  final VoidCallback onPurchased;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final hasPhoto = item.hasPhoto && File(item.photoPath!).existsSync();

    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: colors.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hasPhoto ? 10 : 14, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (hasPhoto) ...[
                _PhotoThumbnail(path: item.photoPath!),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: 15.5,
                        height: 1.25,
                        letterSpacing: -0.1,
                        color: colors.ink,
                      ),
                    ),
                    if (item.hasNote) ...[
                      const SizedBox(height: 3),
                      Text(
                        item.note!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.5,
                          color: colors.inkSecondary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          item.price > 0
                              ? formatRupiah(item.price)
                              : 'Harga belum diisi',
                          style: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: item.price > 0 ? 14 : 12.5,
                            height: 1.2,
                            fontWeight: item.price > 0
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: item.price > 0
                                ? colors.ink
                                : colors.inkTertiary,
                          ),
                        ),
                        if (item.hasLink) ...[
                          const SizedBox(width: 7),
                          Semantics(
                            label: 'Ada tautan produk',
                            child: Icon(
                              Icons.link_rounded,
                              size: 15,
                              color: colors.inkTertiary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: onPurchased,
                    tooltip: 'Tandai sudah dibeli',
                    icon: const Icon(Icons.check_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: colors.success.withValues(alpha: 0.09),
                      foregroundColor: colors.success,
                      minimumSize: const Size.square(44),
                      fixedSize: const Size.square(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 1),
                  Semantics(
                    label: 'Tahan dan geser untuk pindah tier',
                    child: Icon(
                      Icons.drag_indicator_rounded,
                      size: 18,
                      color: colors.inkTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoThumbnail extends StatelessWidget {
  const _PhotoThumbnail({required this.path});

  final String path;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return ClipRRect(
      borderRadius: BorderRadius.circular(13),
      child: Image.file(
        File(path),
        width: 54,
        height: 54,
        fit: BoxFit.cover,
        cacheWidth: 180,
        errorBuilder: (context, error, stackTrace) {
          return _thumbnailFallback(colors);
        },
      ),
    );
  }

  Widget _thumbnailFallback(WishColors colors) {
    return Container(
      width: 54,
      height: 54,
      color: colors.surfaceMuted,
      alignment: Alignment.center,
      child: Icon(Icons.image_outlined, size: 20, color: colors.inkTertiary),
    );
  }
}
