import 'package:flutter/material.dart';

import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/config/config.dart';
import 'package:iptv/model/operator_model.dart';
import 'package:iptv/utils/app_helper.dart';

OperatorModel? operatorModel;

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

DateTime dateTime = DateTime.now();

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin, AppHelper {
  AnimationController? controller;
  Animation<double>? scaleAnimation;

  @override
  void initState() {
    super.initState();
    screen = 'splash_screen';

    controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    scaleAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: controller!,
        curve: Curves.easeInOut,
      ),
    );

    // Start the animation in reverse
    controller!.repeat(reverse: true); // Repeat the animation

    getOperator();
  }

  @override
  void dispose() {
    controller?.dispose();
    screen = '';
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var dateTime = DateTime.now();

    return Scaffold(
      backgroundColor: AppColors.primryColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 80),
              decoration: BoxDecoration(
                  color: AppColors.primryColor,
                  borderRadius: BorderRadius.circular(10)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: scaleAnimation!,
                    child: Column(
                      children: [
                        const Icon(
                          Icons.play_circle_outline_outlined,
                          color: AppColors.whiteColor,
                          size: 100,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(' Live ',
                                style: AppStyles().font18(
                                  color: AppColors.whiteColor,
                                )),
                            Text('Stream ',
                                style: AppStyles().font20(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.bold,
                                )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'جميع الحقوق محفوظة',
                style: AppStyles().font12(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                color: Colors.transparent,
              ),
              Text(
                ' Alkmal ${dateTime.year.toString()}',
                style: AppStyles().font12(
                  color: AppColors.whiteColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
