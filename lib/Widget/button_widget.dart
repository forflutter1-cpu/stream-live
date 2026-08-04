import 'package:flutter/material.dart';
import 'package:iptv/app_material/app_colors.dart';

class ButtonWidget extends StatelessWidget {
  const ButtonWidget(
      {Key? key,
      required this.child,
      this.width = double.infinity,
      required this.onPressed,
      required this.height,
      this.elevation = 0,
      this.colorSide = false,
      this.color = AppColors.primryColor})
      : super(key: key);
  final Widget child;
  final double width;
  final double height;
  final Color color;
  final bool colorSide;

  final double elevation;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: child,
      style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          backgroundColor: color,
          minimumSize: Size(width, height),
          elevation: elevation,
          side: BorderSide(
              color: colorSide == true
                  ? AppColors.primryColor
                  : Colors.transparent),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
    );
  }
}
