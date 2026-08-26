import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:recycleorigindriver/features/customer_feature/presentation/bloc/customer_info_bloc.dart';
import 'package:recycleorigindriver/core/models/request/waste_ref.dart';

import 'package:recycleorigindriver/l10n/l10n.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

class CustomDialogSendDelivery extends StatefulWidget {
  final int totalWallet;
  final Function function;

  const CustomDialogSendDelivery({
    super.key,
    required this.totalWallet,
    required this.function,
  });

  @override
  State<CustomDialogSendDelivery> createState() =>
      _CustomDialogSendDeliveryState();
}

class _CustomDialogSendDeliveryState extends State<CustomDialogSendDelivery> {
  String? storeValue;
  List<String> storeValueList = [];
  List<WasteRef> storeList = [];
  late WasteRef selectedStore;

  @override
  void didChangeDependencies() {
    storeList = context.watch<CustomerInfoBloc>().state.driver.stores;

    for (int i = 0; i < storeList.length; i++) {
      storeValueList.add(storeList[i].post_title);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Consts.padding),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  LayoutBuilder dialogContent(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);
    final scheme = Theme.of(context).colorScheme;

    return LayoutBuilder(
      builder: (_, constraints) => Padding(
        padding: EdgeInsets.only(
          top: Consts.avatarRadius + Consts.padding,
          bottom: Consts.padding,
          left: Consts.padding,
          right: Consts.padding,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.pageBackground,
            shape: BoxShape.rectangle,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 5.0,
                offset: const Offset(0.0, 10.0),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: SizedBox(
                    width: deviceWidth * 0.78,
                    child: Text(
                      context.l10n.selectWarehouseLabel,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: context.primaryText,
                        fontSize: textScaleFactor * 16.0,
                      ),
                    ),
                  ),
                ),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      width: deviceWidth * 0.78,
                      height: deviceHeight * 0.05,
                      alignment: Alignment.centerRight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: scheme.surface,
                        border: Border.all(color: scheme.outline, width: 0.6),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(
                          right: 8.0,
                          left: 8,
                          top: 6,
                        ),
                        child: DropdownButton<String>(
                          hint: Text(
                            context.l10n.selectWarehouseMessage,
                            style: TextStyle(
                              color: context.secondaryText,
                              fontSize: textScaleFactor * 13.0,
                            ),
                          ),
                          value: storeValue,
                          icon: Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Icon(
                              Icons.arrow_drop_down,
                              color: scheme.onSurface,
                              size: 20,
                            ),
                          ),
                          dropdownColor: scheme.surface,
                          style: TextStyle(
                            color: scheme.onSurface,
                            fontSize: textScaleFactor * 13.0,
                          ),
                          isDense: true,
                          onChanged: (newValue) {
                            setState(() {
                              storeValue = newValue;
                              selectedStore =
                                  storeList[storeValueList.lastIndexOf(
                                    newValue!,
                                  )];
                            });
                          },
                          items: storeValueList.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 3.0),
                                  child: Text(
                                    value,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: scheme.onSurface,
                                      fontSize: textScaleFactor * 13.0,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40.0),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Builder(
                    builder: (context) => ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: InkWell(
                        onTap: () {
                          widget.function(selectedStore.id);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: constraints.maxHeight * 0.06,
                          width: constraints.maxWidth * 0.8,
                          decoration: BoxDecoration(
                            color: context.brandPrimary,
                          ),
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                context.l10n.confirmLabel,
                                style: TextStyle(
                                  color: scheme.onPrimary,
                                  fontSize: textScaleFactor * 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
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

class Consts {
  Consts._();

  static const double padding = 5.0;
  static const double avatarRadius = 3;
}
