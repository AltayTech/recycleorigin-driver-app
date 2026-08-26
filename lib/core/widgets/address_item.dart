import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:recycleorigindriver/features/auth_feature/presentation/bloc/auth_bloc.dart';
import 'package:recycleorigindriver/core/models/request/address.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

class AddressItem extends StatefulWidget {
  final Address addressItem;
  final bool isSelected;

  const AddressItem({
    super.key,
    required this.addressItem,
    required this.isSelected,
  });

  @override
  State<AddressItem> createState() => _AddressItemState();
}

class _AddressItemState extends State<AddressItem> {
  bool _isInit = true;

  var _isLoading = true;

  late bool isLogin;

  List<Address> addressList = [];

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _isLoading = false;
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> removeItem() async {
    setState(() {
      _isLoading = true;
    });
    await context.read<AuthBloc>().getAddresses();
    if (!mounted) {
      return;
    }
    addressList = context.read<AuthBloc>().state.addressItems;

    addressList.remove(
      addressList.firstWhere((prod) => prod.name == widget.addressItem.name),
    );
    await context.read<AuthBloc>().updateAddress(addressList);
    if (!mounted) {
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.textScalerOf(context).scale(1);

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        height: deviceWidth * 0.24,
        width: deviceWidth,
        decoration: BoxDecoration(
          color: widget.isSelected
              ? context.brandPrimary.withValues(alpha: 0.1)
              : scheme.surface,
          border: Border.all(color: scheme.outlineVariant, width: 0.3),
          borderRadius: BorderRadius.circular(5),
        ),
        child: LayoutBuilder(
          builder: (_, constraints) => Stack(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top: deviceWidth * 0.05),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Icon(
                          Icons.place,
                          color: Colors.indigo,
                          size: 30,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                widget.addressItem.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: context.primaryText,
                                  fontSize: textScaleFactor * 18,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Text(
                              widget.addressItem.address,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                color: context.secondaryText,
                                fontSize: textScaleFactor * 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 2,
                left: 2,
                child: SizedBox(
                  height: deviceWidth * 0.10,
                  width: deviceWidth * 0.1,
                  child: InkWell(
                    onTap: () {
                      removeItem();
                    },
                    child: Icon(Icons.close, size: 20, color: Colors.black54),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: 0,
                right: 0,
                child: Align(
                  alignment: Alignment.center,
                  child: _isLoading
                      ? SpinKitFadingCircle(
                          itemBuilder: (BuildContext context, int index) {
                            return DecoratedBox(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: index.isEven ? Colors.grey : Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
