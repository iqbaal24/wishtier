import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/wish_tier.dart';
import '../../core/theme/wish_colors.dart';
import '../../core/utils/app_feedback.dart';
import '../../core/utils/formatters.dart';
import '../../core/utils/image_storage.dart';
import '../../core/widgets/app_icon_button.dart';
import '../../core/widgets/tier_badge.dart';
import '../../data/models/wish_item.dart';
import '../../providers/wish_providers.dart';

enum ItemFormResult { saved, deleted }

Future<ItemFormResult?> showItemFormSheet(
  BuildContext context, {
  WishItem? item,
  WishTier? initialTier,
}) {
  return showModalBottomSheet<ItemFormResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    constraints: const BoxConstraints(maxWidth: 620),
    builder: (context) {
      return ItemFormSheet(item: item, initialTier: initialTier);
    },
  );
}

Future<void> openWishItemForm(
  BuildContext context, {
  WishItem? item,
  WishTier? initialTier,
}) async {
  final result = await showItemFormSheet(
    context,
    item: item,
    initialTier: initialTier,
  );
  if (!context.mounted || result == null) return;

  final message = switch (result) {
    ItemFormResult.saved =>
      item == null
          ? 'Keinginan ditambahkan ke wishlist.'
          : 'Perubahan berhasil disimpan.',
    ItemFormResult.deleted => 'Keinginan dihapus dari wishlist.',
  };
  showAppSnackBar(context, message);
}

class ItemFormSheet extends ConsumerStatefulWidget {
  const ItemFormSheet({super.key, this.item, this.initialTier});

  final WishItem? item;
  final WishTier? initialTier;

  @override
  ConsumerState<ItemFormSheet> createState() => _ItemFormSheetState();
}

class _ItemFormSheetState extends ConsumerState<ItemFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  final _linkController = TextEditingController();
  final _nameFocus = FocusNode();

  late WishTier _selectedTier;
  late String? _photoPath;
  late final String? _originalPhotoPath;
  String? _pickedPhotoPath;
  bool _pickingPhoto = false;
  bool _saving = false;
  bool _completed = false;

  bool get _isEditing => widget.item != null;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _selectedTier = item?.tier ?? widget.initialTier ?? WishTier.a;
    _nameController.text = item?.name ?? '';
    _priceController.text = item != null && item.price > 0
        ? formatNumber(item.price)
        : '';
    _noteController.text = item?.note ?? '';
    _linkController.text = item?.link ?? '';
    _photoPath = item?.photoPath;
    _originalPhotoPath = item?.photoPath;
  }

  @override
  void dispose() {
    if (!_completed && _pickedPhotoPath != null) {
      unawaited(ImageStorage.deleteIfExists(_pickedPhotoPath));
    }
    _nameController.dispose();
    _priceController.dispose();
    _noteController.dispose();
    _linkController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    if (_pickingPhoto) return;
    setState(() => _pickingPhoto = true);
    try {
      final path = await ImageStorage.pickFromGallery();
      if (!mounted) return;
      if (path != null) {
        if (_pickedPhotoPath != null &&
            _pickedPhotoPath != _originalPhotoPath) {
          unawaited(ImageStorage.deleteIfExists(_pickedPhotoPath));
        }
        setState(() {
          _pickedPhotoPath = path;
          _photoPath = path;
        });
      }
    } on Object {
      if (mounted) {
        showAppSnackBar(context, 'Foto tidak bisa diambil. Coba lagi ya.');
      }
    } finally {
      if (mounted) setState(() => _pickingPhoto = false);
    }
  }

  void _removePhoto() {
    if (_pickedPhotoPath != null && _pickedPhotoPath != _originalPhotoPath) {
      unawaited(ImageStorage.deleteIfExists(_pickedPhotoPath));
    }
    setState(() {
      _pickedPhotoPath = null;
      _photoPath = null;
    });
  }

  String? _normalizedLink() {
    var value = _linkController.text.trim();
    if (value.isEmpty) return null;
    if (!RegExp(r'^https?://', caseSensitive: false).hasMatch(value)) {
      value = 'https://$value';
    }
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return null;
    return value;
  }

  Future<void> _openLink() async {
    final link = _normalizedLink();
    final uri = link == null ? null : Uri.tryParse(link);
    if (uri == null) {
      showAppSnackBar(context, 'Tautan belum valid.');
      return;
    }
    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched && mounted) {
        showAppSnackBar(context, 'Tautan tidak bisa dibuka.');
      }
    } on Object {
      if (mounted) {
        showAppSnackBar(context, 'Tautan tidak bisa dibuka.');
      }
    }
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) {
      _nameFocus.requestFocus();
      return;
    }

    setState(() => _saving = true);

    final item = WishItem(
      id: widget.item?.id ?? const Uuid().v4(),
      name: _nameController.text.trim(),
      price: parsePrice(_priceController.text) ?? 0,
      tier: _selectedTier,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      link: _normalizedLink(),
      photoPath: _photoPath,
      isPurchased: widget.item?.isPurchased ?? false,
      purchasedAt: widget.item?.purchasedAt,
      createdAt: widget.item?.createdAt ?? DateTime.now(),
      sortOrder: widget.item?.sortOrder ?? 0,
    );

    final notifier = ref.read(wishListProvider.notifier);
    if (_isEditing) {
      await notifier.update(item);
    } else {
      await notifier.add(item);
    }

    if (_originalPhotoPath != null && _originalPhotoPath != _photoPath) {
      await ImageStorage.deleteIfExists(_originalPhotoPath);
    }

    if (!mounted) return;
    _completed = true;
    Navigator.of(context).pop(ItemFormResult.saved);
  }

  Future<void> _delete() async {
    final item = widget.item;
    if (item == null) return;

    final confirmed = await showConfirmDialog(
      context,
      title: 'Hapus keinginan?',
      message: '“${item.name}” akan dihapus permanen dari wishlist kamu.',
    );
    if (!confirmed || !mounted) return;

    if (_pickedPhotoPath != null && _pickedPhotoPath != _originalPhotoPath) {
      await ImageStorage.deleteIfExists(_pickedPhotoPath);
    }
    await ref.read(wishListProvider.notifier).delete(item.id);
    await ImageStorage.deleteIfExists(_originalPhotoPath);

    if (!mounted) return;
    _completed = true;
    Navigator.of(context).pop(ItemFormResult.deleted);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final media = MediaQuery.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: media.size.height * 0.92),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 12, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isEditing ? 'Edit keinginan' : 'Tambah keinginan',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isEditing
                              ? 'Perbarui detail atau pindahkan prioritasnya.'
                              : 'Catat keinginan dan tentukan seberapa penting.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: colors.inkSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    tooltip: 'Tutup',
                    onPressed: () => Navigator.of(context).pop(),
                    size: 44,
                    background: colors.surfaceMuted,
                    borderColor: Colors.transparent,
                  ),
                ],
              ),
            ),
            Divider(color: colors.border, height: 1),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        focusNode: _nameFocus,
                        autofocus: !_isEditing,
                        textInputAction: TextInputAction.next,
                        textCapitalization: TextCapitalization.sentences,
                        maxLength: 80,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Nama keinginan',
                          hintText: 'Contoh: Laptop untuk kuliah',
                          counterText: '',
                          fillColor: colors.background,
                          prefixIcon: const Icon(
                            Icons.bookmark_border_rounded,
                            size: 20,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama keinginan wajib diisi.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(
                        title: 'Prioritas',
                        hint: _selectedTier.label,
                      ),
                      const SizedBox(height: 10),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final itemWidth = (constraints.maxWidth - 9) / 2;
                          return Wrap(
                            spacing: 9,
                            runSpacing: 9,
                            children: [
                              for (final tier in WishTier.values)
                                SizedBox(
                                  width: itemWidth,
                                  child: _TierOption(
                                    tier: tier,
                                    selected: _selectedTier == tier,
                                    onTap: () =>
                                        setState(() => _selectedTier = tier),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [ThousandsInputFormatter()],
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.ink,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Perkiraan harga',
                          hintText: '0',
                          helperText:
                              'Opsional, isi kalau sudah ada perkiraan.',
                          fillColor: colors.background,
                          prefixText: 'Rp ',
                          prefixStyle: TextStyle(
                            fontFamily: 'Rubik',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: colors.inkSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _noteController,
                        minLines: 2,
                        maxLines: 4,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.ink,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Catatan',
                          hintText:
                              'Kenapa ingin ini? Detail yang perlu diingat...',
                          helperText: 'Opsional',
                          fillColor: colors.background,
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _linkController,
                        keyboardType: TextInputType.url,
                        autocorrect: false,
                        textInputAction: TextInputAction.done,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: colors.ink,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Tautan produk',
                          hintText: 'https://...',
                          helperText: 'Opsional',
                          fillColor: colors.background,
                          prefixIcon: const Icon(Icons.link_rounded, size: 20),
                          suffixIcon: IconButton(
                            tooltip: 'Buka tautan',
                            onPressed: _openLink,
                            icon: const Icon(
                              Icons.open_in_new_rounded,
                              size: 19,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      _FieldLabel(
                        title: 'Foto',
                        hint: _photoPath == null ? 'Opsional' : 'Terlampir',
                      ),
                      const SizedBox(height: 10),
                      _PhotoPicker(
                        photoPath: _photoPath,
                        picking: _pickingPhoto,
                        onPick: _pickPhoto,
                        onRemove: _removePhoto,
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: colors.surface,
                border: Border(top: BorderSide(color: colors.border)),
              ),
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                  child: Row(
                    children: [
                      if (_isEditing) ...[
                        AppIconButton(
                          icon: Icons.delete_outline_rounded,
                          tooltip: 'Hapus keinginan',
                          onPressed: _saving ? null : _delete,
                          size: 54,
                          iconSize: 22,
                          foreground: colors.danger,
                          background: colors.tierSSoft,
                          borderColor: colors.danger.withValues(alpha: 0.18),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Expanded(
                        child: FilledButton(
                          onPressed: _saving ? null : _save,
                          child: _saving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    color: colors.onAccent,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (!_isEditing) ...[
                                      const Icon(Icons.add_rounded, size: 19),
                                      const SizedBox(width: 7),
                                    ],
                                    Text(
                                      _isEditing
                                          ? 'Simpan perubahan'
                                          : 'Tambah ke wishlist',
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.title, required this.hint});

  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall
              ?.copyWith(fontSize: 13.5, color: colors.ink),
        ),
        const SizedBox(width: 7),
        Text(
          '· $hint',
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(fontSize: 11.5, color: colors.inkTertiary),
        ),
      ],
    );
  }
}

class _TierOption extends StatelessWidget {
  const _TierOption({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final WishTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = colors.tier(tier);

    return Semantics(
      button: true,
      selected: selected,
      label: 'Tier ${tier.letter}, ${tier.label}, ${tier.tagline}',
      child: ExcludeSemantics(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              curve: Curves.easeOut,
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: selected ? colors.tierSoft(tier) : colors.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: selected ? color : colors.border,
                  width: selected ? 1.6 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      TierBadge(tier: tier, size: 30),
                      const Spacer(),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 120),
                        opacity: selected ? 1 : 0,
                        child: Icon(
                          Icons.check_circle_rounded,
                          size: 18,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tier ${tier.letter}',
                    style: TextStyle(
                      fontFamily: 'Rubik',
                      fontSize: 13,
                      height: 1.2,
                      fontWeight: FontWeight.w700,
                      color: selected ? color : colors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    tier.tagline,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 10.5,
                      height: 1.2,
                      fontWeight: FontWeight.w500,
                      color: colors.inkSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  const _PhotoPicker({
    required this.photoPath,
    required this.picking,
    required this.onPick,
    required this.onRemove,
  });

  final String? photoPath;
  final bool picking;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final theme = Theme.of(context);
    final hasPhoto = photoPath != null && File(photoPath!).existsSync();

    if (picking) {
      return Container(
        height: 76,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colors.inkSecondary,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Membuka galeri...',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.inkSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (!hasPhoto) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPick,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colors.background,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: colors.border),
                  ),
                  child: Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 21,
                    color: colors.inkSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tambah foto',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13.5,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Bantu kamu mengenali barangnya',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: colors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colors.inkTertiary,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(photoPath!),
              width: 64,
              height: 64,
              fit: BoxFit.cover,
              cacheWidth: 192,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 64,
                  height: 64,
                  color: colors.surfaceMuted,
                  alignment: Alignment.center,
                  child: Icon(Icons.image_outlined, color: colors.inkTertiary),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onPick,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Foto terlampir',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13.5,
                          color: colors.ink,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ketuk untuk mengganti',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 11.5,
                          color: colors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          AppIconButton(
            icon: Icons.close_rounded,
            tooltip: 'Hapus foto',
            onPressed: onRemove,
            size: 44,
            iconSize: 18,
            foreground: colors.danger,
            background: colors.tierSSoft,
            borderColor: Colors.transparent,
          ),
        ],
      ),
    );
  }
}
