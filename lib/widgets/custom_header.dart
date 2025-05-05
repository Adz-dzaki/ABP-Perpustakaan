import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final VoidCallback onMenuTap;
  final VoidCallback onLogoutTap;

  const CustomHeader({
    super.key,
    required this.onMenuTap,
    required this.onLogoutTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.menu),
          onPressed: onMenuTap,
        ),
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.red),
          onPressed: onLogoutTap,
        ),
      ],
    );
  }
}
