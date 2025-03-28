import 'package:flutter/material.dart';


//TODO: Add animation
class StrikeThroughContainer extends StatelessWidget{

  final Widget child;
  final Color linecolor;
  final double thickness;
  final double widthFactor;

  const StrikeThroughContainer({
    super.key,
    required this.child,
    required this.linecolor,
    required this.thickness,
    required this.widthFactor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: Center(
              child: Container(
                height: thickness,
                color: linecolor,
              )
            ),
          )
        )
      ],
    );
  }
}