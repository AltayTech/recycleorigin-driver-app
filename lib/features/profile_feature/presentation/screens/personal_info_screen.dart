import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/core/theme/app_theme.dart';
import 'package:recycleorigindriver/core/widgets/drawer_or_back_leading.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_state.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/screens/edit_personal_info_screen.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/utils/driver_display.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_hero.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_info_row.dart';
import 'package:recycleorigindriver/features/profile_feature/presentation/widgets/profile_section_card.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

/// Read-only driver personal information with sectioned cards.
class PersonalInfoScreen extends StatefulWidget {
  static const routeName = '/personal_info';

  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<CustomerInfoBloc>().getCustomer();
    });
  }

  Future<void> _refresh() async {
    await context.read<CustomerInfoBloc>().getCustomer();
  }

  void _openEdit(BuildContext context) {
    Navigator.of(context).pushNamed(EditPersonalInfoScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        leading: const DrawerOrBackLeading(),
        centerTitle: true,
        backgroundColor: AppTheme.appBarColor,
        iconTheme: const IconThemeData(color: AppTheme.appBarIconColor),
        title: Text(
          l10n.personalInfoLabel,
          style: const TextStyle(
            color: AppTheme.appBarIconColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      drawer: mainDrawerIfRootRoute(context),
      body: BlocBuilder<CustomerInfoBloc, CustomerInfoState>(
        buildWhen: (prev, cur) => prev.driver != cur.driver,
        builder: (context, state) {
          final driver = state.driver;
          final data = driver.driver_data;
          final bottomInset = MediaQuery.paddingOf(context).bottom;

          return RefreshIndicator(
            color: Theme.of(context).colorScheme.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: ProfileHero(
                    driver: driver,
                    compact: true,
                    showStats: false,
                    onEditPressed: () => _openEdit(context),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(16, 8, 16, 24 + bottomInset),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate(
                      <Widget>[
                        Text(
                          l10n.personalInfoSubtitle,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: AppTheme.grey,
                                height: 1.45,
                              ),
                        ),
                        const SizedBox(height: 16),
                        ProfileSectionCard(
                          title: l10n.basicInfoSectionTitle,
                          trailing: _EditChip(
                            onPressed: () => _openEdit(context),
                          ),
                          children: <Widget>[
                            ProfileInfoRow(
                              label: l10n.firstNameLabel,
                              value: data.fname,
                            ),
                            ProfileInfoRow(
                              label: l10n.lastNameLabel,
                              value: data.lname,
                            ),
                            ProfileInfoRow(
                              label: l10n.userTypeLabel,
                              value: DriverDisplay.userTypeLabel(driver, l10n),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProfileSectionCard(
                          title: l10n.contactSectionTitle,
                          trailing: _EditChip(
                            onPressed: () => _openEdit(context),
                          ),
                          children: <Widget>[
                            ProfileInfoRow(
                              label: l10n.emailLabel,
                              value: data.email,
                              copyable: true,
                            ),
                            ProfileInfoRow(
                              label: l10n.mobileLabel,
                              value: data.mobile.isNotEmpty
                                  ? data.mobile
                                  : data.phone,
                              copyable: true,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ProfileSectionCard(
                          title: l10n.addressSectionTitle,
                          trailing: _EditChip(
                            onPressed: () => _openEdit(context),
                          ),
                          children: <Widget>[
                            ProfileInfoRow(
                              label: l10n.provinceLabel,
                              value: data.ostan,
                            ),
                            ProfileInfoRow(
                              label: l10n.cityLabel,
                              value: data.city,
                            ),
                            ProfileInfoRow(
                              label: l10n.postalCodeLabel,
                              value: data.postcode,
                            ),
                          ],
                        ),
                      ],
                    ),
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

class _EditChip extends StatelessWidget {
  const _EditChip({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.edit_outlined, size: 18),
      label: Text(l10n.editProfileLabel),
      style: TextButton.styleFrom(
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.symmetric(horizontal: 8),
      ),
    );
  }
}
