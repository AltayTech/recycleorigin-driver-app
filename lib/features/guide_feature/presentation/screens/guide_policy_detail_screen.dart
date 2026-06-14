import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';

import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';

/// Full-screen CMS policy or FAQ content.
class GuidePolicyDetailScreen extends StatelessWidget {
  const GuidePolicyDetailScreen({
    super.key,
    required this.title,
    required this.html,
  });

  final String title;
  final String html;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textScaler = MediaQuery.textScalerOf(context);

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        title: Text(title),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        child: HtmlWidget(
          html,
          textStyle: TextStyle(
            color: scheme.onSurface,
            fontSize: textScaler.scale(14),
            height: 1.45,
          ),
        ),
      ),
    );
  }
}
