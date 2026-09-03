import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/contact_feature/presentation/contact_with_us_screen.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_info_row.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_section_card.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Read-only vehicle details for the driver.
class VehicleInfoScreen extends StatelessWidget {
  static const routeName = '/vehicle_info';

  const VehicleInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        title: Text(
          l10n.myVehicleLabel,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
        buildWhen: (prev, cur) => prev.driver != cur.driver,
        builder: (context, state) {
          final driver = state.driver;
          final plate = driver.car_number.trim();
          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + bottomInset),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                if (plate.isNotEmpty)
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.directions_car_filled_rounded,
                            size: 40,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.plateNumberLabel,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: context.secondaryText),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            plate,
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 2,
                                  color: context.primaryText,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                ProfileSectionCard(
                  title: l10n.vehicleSectionTitle,
                  children: <Widget>[
                    ProfileInfoRow(
                      label: l10n.vehicleTypeLabel,
                      value: driver.car.name,
                    ),
                    ProfileInfoRow(
                      label: l10n.vehicleColorLabel,
                      value: driver.car_color.name,
                    ),
                    ProfileInfoRow(
                      label: l10n.plateNumberLabel,
                      value: driver.car_number,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  color: scheme.surfaceContainerHighest,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.vehicleContactSupportHint,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: context.primaryText,
                                  height: 1.45,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushNamed(ContactWithUs.routeName);
                  },
                  icon: const Icon(Icons.support_agent_outlined),
                  label: Text(l10n.contactUsLabel),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
