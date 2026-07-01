import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  final String title;
  final Widget body;

  final List<Widget>? actions;

  final Widget? floatingActionButton;

  final Widget? bottomNavigationBar;

  final bool showAppBar;

  final bool centerTitle;

  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.showAppBar = true,
    this.centerTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: showAppBar
          ? AppBar(
              title: Text(title),
              centerTitle: centerTitle,
              actions: actions,
            )
          : null,

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: body,
        ),
      ),

      floatingActionButton: floatingActionButton,

      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
