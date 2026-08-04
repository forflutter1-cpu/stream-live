import 'package:flutter/material.dart';
import 'package:iptv/app_material/app_colors.dart';

class AppStyles {
  double dPadding = 16;
  TextStyle font10(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 10,
        fontFamily: 'Almarai');
  }

  TextStyle font12({
    Color color = AppColors.blackColor,
    FontWeight fontWeight = FontWeight.w500,
    TextDecoration? decoration,
  }) {
    return TextStyle(
        fontWeight: fontWeight,
        decoration: decoration,
        color: color,
        fontSize: 12,
        fontFamily: 'Almarai');
  }

  TextStyle font14(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 14,
        fontFamily: 'Almarai');
  }

  TextStyle font16(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 16,
        fontFamily: 'Almarai');
  }

  TextStyle font18(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 18,
        fontFamily: 'Almarai');
  }

  TextStyle font20(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 20,
        fontFamily: 'Almarai');
  }

  TextStyle font24(
      {Color color = AppColors.blackColor,
      FontWeight fontWeight = FontWeight.w500}) {
    return TextStyle(
        fontWeight: fontWeight,
        color: color,
        fontSize: 24,
        fontFamily: 'Almarai');
  }
}
