import 'package:flutter/material.dart';
import 'package:recycleorigindriver/core/theme/theme_context.dart';

class MainItemButton extends StatelessWidget {
  const MainItemButton({
    required this.title,
    required this.itemPaddingF,
    this.imageSizeFactor = 0.35,
    this.isMonoColor = true,
    required this.selectedItem,
    required this.icon,
  });

  final String title;
  final double itemPaddingF;
  final double imageSizeFactor;
  final bool isMonoColor;
  final int selectedItem;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final scheme = Theme.of(context).colorScheme;
    final selected = selectedItem == 1;

    return LayoutBuilder(
      builder: (_, constraint) => Padding(
        padding: EdgeInsets.all(deviceWidth * itemPaddingF),
        child: Container(
          decoration: BoxDecoration(
              color: selected ? context.brandPrimary : scheme.surface,
              boxShadow: [
                BoxShadow(
                  color: context.brandPrimary.withValues(alpha: 0.08),
                  blurRadius: 10.10,
                  spreadRadius: 10.510,
                  offset: Offset(
                    0,
                    0,
                  ),
                )
              ],
              borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                  bottom: 10,
                  top: 16,
                ),
                child: Container(
                  height: constraint.maxHeight * 0.25,
                  child: icon,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 10, right: 10, bottom: 8, top: 10),
                child: FittedBox(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          selected ? scheme.onPrimary : scheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                      fontSize: textScaleFactor * 12.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
