import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/models/driver.dart';
import 'package:recycleorigindriver/core/ui/top_bar.dart';
import 'package:recycleorigindriver/core/widgets/star_rating_widget.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/utils/driver_display.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_avatar.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_stats_card.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

const Color _heroGradientEnd = Color(0xFF1F8B61);

/// Profile header with gradient, avatar, and optional stats card.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.driver,
    this.compact = false,
    this.onEditPressed,
    this.showStats = true,
  });

  final Driver driver;
  final bool compact;
  final VoidCallback? onEditPressed;
  final bool showStats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colorScheme = Theme.of(context).colorScheme;
    final displayName = DriverDisplay.name(driver, l10n);
    final subtitle = DriverDisplay.subtitle(driver);
    final heroHeight = compact ? 140.0 : 200.0;
    final avatarRadius = compact ? 28.0 : 32.0;

    return Column(
      children: <Widget>[
        SizedBox(
          height: heroHeight,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: <Widget>[
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: <Color>[
                      colorScheme.primary,
                      _heroGradientEnd,
                    ],
                  ),
                ),
              ),
              if (!compact) const TopBar(height: 200),
              if (onEditPressed != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    tooltip: l10n.editProfileLabel,
                    onPressed: onEditPressed,
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                    ),
                  ),
                ),
              Positioned(
                left: 20,
                right: 20,
                bottom: compact ? 20 : 52,
                child: Row(
                  children: <Widget>[
                    ProfileAvatar(
                      imageUrl: DriverDisplay.imageUrl(
                        driver.driver_data.driver_image,
                      ),
                      initials: DriverDisplay.initials(displayName),
                      radius: avatarRadius,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            displayName,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: compact ? 18 : null,
                                ),
                          ),
                          if (subtitle.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 4),
                            Text(
                              subtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontSize: 13,
                              ),
                            ),
                          ],
                          if (!compact) ...<Widget>[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: <Widget>[
                                Chip(
                                  label: Text(
                                    l10n.driverRoleLabel,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                  backgroundColor:
                                      Colors.white.withValues(alpha: 0.22),
                                  labelStyle:
                                      const TextStyle(color: Colors.white),
                                  side: BorderSide.none,
                                  padding: EdgeInsets.zero,
                                ),
                                if (driver.averageRating != null)
                                  StarRatingDisplay(
                                    value: driver.averageRating!,
                                    size: 16,
                                    color: Colors.amber.shade300,
                                  )
                                else
                                  Text(
                                    l10n.noRatingLabel,
                                    style: TextStyle(
                                      color:
                                          Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (showStats && !compact)
          Transform.translate(
            offset: const Offset(0, -28),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProfileStatsCard(driver: driver),
            ),
          ),
        if (showStats && !compact) const SizedBox(height: 4),
      ],
    );
  }
}
