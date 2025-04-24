import 'package:flutter/material.dart';

class SlideTransition1 extends PageRouteBuilder {
  final Widget page;
  SlideTransition1(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 900),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn);

            return SlideTransition(
              position:
                  Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
                      .animate(animation),
              child: page,
            );
          },
        );
}

class SlideTransition2 extends PageRouteBuilder {
  final Widget page;
  SlideTransition2(this.page)
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 900),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn);

            return SlideTransition(
              position:
                  Tween(begin: const Offset(1, 0), end: const Offset(0, 0))
                      .animate(animation),
              textDirection: TextDirection.rtl,
              child: page,
            );
          },
        );
}

class CustomSizeTransition extends PageRouteBuilder {
  final Widget page;
  final AlignmentGeometry alignment;

  CustomSizeTransition(this.page, {required this.alignment})
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn);

            return Align(
              alignment: alignment,
              child: SizeTransition(
                sizeFactor: animation,
                axis: Axis.horizontal,
                axisAlignment: 0,
                child: page,
              ),
            );
          },
        );
}

class CustomScaleTransition extends PageRouteBuilder {
  final Widget page;
  final Alignment alignment;

  CustomScaleTransition(this.page, {required this.alignment})
      : super(
          pageBuilder: (context, animation, anotherAnimation) => page,
          transitionDuration: const Duration(milliseconds: 1000),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, anotherAnimation, child) {
            animation = CurvedAnimation(
                parent: animation,
                curve: Curves.fastLinearToSlowEaseIn,
                reverseCurve: Curves.fastOutSlowIn);

            return ScaleTransition(
              alignment: alignment,
              scale: animation,
              child: child,
            );
          },
        );
}
