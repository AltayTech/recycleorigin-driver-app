import 'package:flutter/material.dart';

class Badge extends StatelessWidget {
  const Badge({
    required this.child,
    required this.value,
    required this.color,
    required this.textColor,
  }) ;

  final Widget child;
  final String value;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        child,
        Positioned(
          right: 8,
          top: 8,
          child: Container(
            padding: EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10.0),
              border: Border.all(color: Colors.grey, width: 0.3),
              color: color != null
                  ? color
                  : Theme.of(context).colorScheme.secondary,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text(
              value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: textColor,
              ),
            ),
          ),
        )
      ],
    );
  }
}
