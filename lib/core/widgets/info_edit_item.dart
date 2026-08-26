import 'package:flutter/material.dart';

import 'package:recycleorigindriver/core/theme/theme_context.dart';
import 'package:recycleorigindriver/l10n/l10n.dart';

class InfoEditItem extends StatelessWidget {
  const InfoEditItem({super.key, 
    required this.title,
    required this.controller,
    required this.keybordType,
    required this.bgColor,
    required this.iconColor,
    required this.thisFocusNode,
    required this.newFocusNode,
    this.maxLine = 1,
    required this.fieldHeight,
  });

  final String title;
  final TextEditingController controller;
  final TextInputType keybordType;
  final int maxLine;
  final Color bgColor;
  final Color iconColor;
  final double fieldHeight;
  final FocusNode newFocusNode;
  final FocusNode thisFocusNode;

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    double deviceWidth = MediaQuery.of(context).size.width;
    var textScaleFactor = MediaQuery.of(context).textScaleFactor;

    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        width: deviceWidth * 0.8,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  '$title : ',
                  style: TextStyle(
                    color: context.primaryText,
                    fontSize: textScaleFactor * 14.0,
                  ),
                ),
              ),
              Container(
                color: scheme.surface,
                height: fieldHeight,
                child: Form(
                  child: TextFormField(
                    maxLines: maxLine,
                    keyboardType: keybordType,
                    onEditingComplete: () {},
                    validator: (value) {
                      if (value!.isEmpty) {
                        return context.l10n.fieldRequiredValidation;
                      }
                      return null;
                    },
                    style: TextStyle(
                      color: context.primaryText,
                      fontSize: textScaleFactor * 14.0,
                    ),
                    onFieldSubmitted: (_) =>
                        FocusScope.of(context).requestFocus(newFocusNode),
                    focusNode: thisFocusNode,
                    textInputAction: TextInputAction.go,
                    controller: controller,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5),
                        borderSide: BorderSide(
                          width: 0,
                          color: scheme.surface,
                        ),
                      ),
                      labelStyle: TextStyle(
                        color: Colors.blue,
                        fontSize: textScaleFactor * 10.0,
                      ),
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
