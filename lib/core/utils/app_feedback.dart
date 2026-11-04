import 'package:flutter/material.dart';

import '../theme/wish_colors.dart';

void showAppSnackBar(
  BuildContext context,
  String message, {
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final messenger = ScaffoldMessenger.of(context);
  messenger.hideCurrentSnackBar();
  messenger.showSnackBar(
    SnackBar(
      content: Text(message),
      action: actionLabel == null
          ? null
          : SnackBarAction(label: actionLabel, onPressed: onAction ?? () {}),
      duration: const Duration(seconds: 3),
    ),
  );
}

Future<bool> showConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Batal',
  String confirmLabel = 'Hapus',
  IconData icon = Icons.delete_outline_rounded,
  bool destructive = true,
}) async {
  final colors = context.colors;
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        icon: Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: destructive ? colors.tierSSoft : colors.surfaceMuted,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            icon,
            color: destructive ? colors.danger : colors.ink,
            size: 24,
          ),
        ),
        title: Text(title, textAlign: TextAlign.center),
        content: Text(message, textAlign: TextAlign.center),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: destructive
                ? FilledButton.styleFrom(
                    backgroundColor: colors.danger,
                    foregroundColor: Colors.white,
                  )
                : null,
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return result ?? false;
}
