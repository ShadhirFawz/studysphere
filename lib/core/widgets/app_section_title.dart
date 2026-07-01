import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';

class AppSectionTitle extends StatelessWidget {
  final String title;

  const AppSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title, style: AppTextStyles.heading3);
  }
}
