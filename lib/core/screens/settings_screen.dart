import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/notifications/notification_preferences_controller.dart';
import 'package:recycleorigindriver/l10n/app_localizations.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

import '../app_locale_controller.dart';
import '../theme/app_theme.dart';
import '../utils/app_info_service.dart';
import '../widgets/drawer_or_back_leading.dart';

/// Application settings: language, notifications, and app metadata.
class SettingsScreen extends StatelessWidget {
  static const routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        elevation: 0,
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: ValueListenableBuilder<Locale>(
        valueListenable: AppLocaleController.instance.localeNotifier,
        builder: (context, locale, _) {
          final bottomInset = MediaQuery.paddingOf(context).bottom;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.settingsScreenIntro,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.grey,
                        height: 1.45,
                      ),
                ),
                const SizedBox(height: 20),
                _SettingsSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: l10n.languageTitle,
                        icon: Icons.translate_rounded,
                        iconColor: AppTheme.primary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.applicationLanguageLabel,
                        style: const TextStyle(
                          color: AppTheme.h1,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Semantics(
                        label: l10n.applicationLanguageLabel,
                        child: Column(
                          children: [
                            _LanguageOptionTile(
                              selected: locale.languageCode == 'en',
                              title: l10n.englishLabel,
                              onTap: () => AppLocaleController.instance
                                  .setLocaleCode('en'),
                            ),
                            const Divider(height: 1, color: AppTheme.secondary),
                            _LanguageOptionTile(
                              selected: locale.languageCode == 'tr',
                              title: l10n.turkishLabel,
                              onTap: () => AppLocaleController.instance
                                  .setLocaleCode('tr'),
                            ),
                            const Divider(height: 1, color: AppTheme.secondary),
                            _LanguageOptionTile(
                              selected: locale.languageCode == 'ar',
                              title: l10n.arabicLabel,
                              onTap: () => AppLocaleController.instance
                                  .setLocaleCode('ar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const _NotificationPreferencesSection(),
                const SizedBox(height: 16),
                _SettingsSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: l10n.appInformationSectionTitle,
                        icon: Icons.info_outline_rounded,
                        iconColor: AppTheme.primary,
                      ),
                      const SizedBox(height: 16),
                      _AppMetaBlock(l10n: l10n),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SettingsSectionCard extends StatelessWidget {
  const _SettingsSectionCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppTheme.white,
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: AppTheme.h1,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _LanguageOptionTile extends StatelessWidget {
  const _LanguageOptionTile({
    required this.selected,
    required this.title,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Semantics(
        button: true,
        selected: selected,
        label: title,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            child: Row(
              children: [
                Icon(
                  selected
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: selected ? AppTheme.primary : AppTheme.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.h1,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationPreferencesSection extends StatefulWidget {
  const _NotificationPreferencesSection();

  @override
  State<_NotificationPreferencesSection> createState() =>
      _NotificationPreferencesSectionState();
}

class _NotificationPreferencesSectionState
    extends State<_NotificationPreferencesSection> {
  late final NotificationPreferencesController _controller;

  @override
  void initState() {
    super.initState();
    _controller = NotificationPreferencesController();
    _controller.load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _categoryLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'transactional':
        return l10n.notificationCategoryTransactional;
      case 'marketing':
        return l10n.notificationCategoryMarketing;
      default:
        return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        return _SettingsSectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SectionHeader(
                      title: l10n.notificationsSectionTitle,
                      icon: Icons.notifications_active_outlined,
                      iconColor: AppTheme.primary,
                    ),
                  ),
                  if (_controller.saving)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else if (_controller.savedFlash)
                    Icon(
                      Icons.check_circle_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n.notificationsSectionDescription,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.grey,
                      height: 1.45,
                    ),
              ),
              if (_controller.loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_controller.error == 'load')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: <Widget>[
                      Text(
                        l10n.notificationPrefsLoadErrorMessage,
                        style: TextStyle(color: AppTheme.grey),
                      ),
                      const SizedBox(height: 12),
                      TextButton.icon(
                        onPressed: _controller.load,
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text(l10n.retryLabel),
                      ),
                    ],
                  ),
                )
              else ...<Widget>[
                if (_controller.error == 'save')
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Text(
                      l10n.connectionRetryMessage,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                  ),
                if (_controller.saving)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      l10n.notificationPrefsSavingLabel,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.grey,
                          ),
                    ),
                  ),
                for (final cat in _controller.prefs.keys) ...<Widget>[
                  const SizedBox(height: 12),
                  Text(
                    _categoryLabel(l10n, cat),
                    style: const TextStyle(
                      color: AppTheme.h1,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notificationChannelPush),
                    value: _controller.prefs[cat]!['push'] ?? true,
                    onChanged: (bool v) {
                      _controller.setEnabled(cat, 'push', v);
                    },
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(l10n.notificationChannelInApp),
                    value: _controller.prefs[cat]!['inapp'] ?? true,
                    onChanged: (bool v) {
                      _controller.setEnabled(cat, 'inapp', v);
                    },
                  ),
                  if (cat != _controller.prefs.keys.last)
                    const Divider(height: 1, color: AppTheme.secondary),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _AppMetaBlock extends StatelessWidget {
  const _AppMetaBlock({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final info = AppInfoService.instance;
    final name = info.appName;
    final versionLine = '${l10n.version} ${info.fullVersion}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          name,
          style: const TextStyle(
            color: AppTheme.h1,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          versionLine,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.grey,
              ),
        ),
      ],
    );
  }
}
