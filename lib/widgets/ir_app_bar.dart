import 'package:flutter/material.dart';

/// Shared AppBar matching the servlet navbar — brand + 4 nav links.
class IRAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const IRAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        _NavBtn('PNR',      '/pnr',      context),
        _NavBtn('Schedule', '/schedule', context),
        _NavBtn('Seats',    '/seats',    context),
        _NavBtn('Fare',     '/fare',     context),
      ],
    );
  }
}

class _NavBtn extends StatelessWidget {
  final String label;
  final String route;
  final BuildContext ctx;
  const _NavBtn(this.label, this.route, this.ctx);

  @override
  Widget build(BuildContext context) {
    return TextButton(
      key: Key('nav_$label'),
      onPressed: () => Navigator.pushNamed(ctx, route),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
    );
  }
}
