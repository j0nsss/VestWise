import 'package:flutter/material.dart';

/// Consistent app bar across feature screens (plan P1-T6). Wraps [AppBar] so
/// styling stays centralized in the theme.
class VWAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VWAppBar({
    required this.title,
    this.actions,
    this.leading,
    this.bottom,
    this.automaticallyImplyLeading = true,
    super.key,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      leading: leading,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));
}
