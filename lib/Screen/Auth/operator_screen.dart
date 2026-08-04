import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Auth/LoginScreen.dart';
import 'package:iptv/Screen/Auth/public_screen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';

class OperatorScreen extends StatefulWidget {
  const OperatorScreen({super.key});

  @override
  State<OperatorScreen> createState() => _OperatorScreenState();
}

class _OperatorScreenState extends State<OperatorScreen> {
  late TextEditingController operatorController;

  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    operatorController = TextEditingController(
        text: SharedPrefController().operator != null
            ? (SharedPrefController().operator!.isNotEmpty
                ? SharedPrefController().operator
                : '1')
            : '1');
  }

  @override
  void dispose() {
    operatorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Expanded(
              child: Column(
                children: [
                  AnimationConfiguration.synchronized(
                      duration: const Duration(milliseconds: 357),
                      child: ScaleAnimation(
                          child: FadeInAnimation(
                              child: Center(
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.asset(
                              'images/new_logo.jpg',
                              height: 250,
                              width: 250,
                            ),
                          ),
                        ),
                      )))),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),

            //
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Text('رقم السيرفر')),
                  const SizedBox(
                    height: 15,
                  ),
                  TextFiled_Widget(
                    hintText: 'رقم السيرفر',
                    controller: operatorController,
                    textInputType: TextInputType.text,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Visibility(
                    visible: !isClicked,
                    replacement: const Center(
                      child: CircularProgressIndicator(),
                    ),
                    child: ButtonWidget(
                        color: AppColors.primryColor,
                        height: 50,
                        elevation: 2,
                        onPressed: operator,
                        child: Text(
                          'اضافة',
                          style: AppStyles().font16(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  void operator() async {
    setState(() {
      isClicked = true;
    });
    operatorModel = await ApiController().getOperator(
      code: operatorController.text,
    );

    if (operatorModel != null &&
        operatorModel!.data != null &&
        operatorModel!.data!.url != null &&
        operatorModel!.data!.url!.isNotEmpty) {
      SharedPrefController().updateBaseUrl(baseUrl: operatorModel!.data!.url!);
      SharedPrefController().updateOperator(operator: operatorController.text);
      Get.to(() => const LoginScreen());
    } else {
      if (operatorModel!.type != 'operator') {
        Get.to(() => operatorModel!.type == 'private'
            ? const LoginScreen()
            : const PublicScreen());
      }
    }
    setState(() {
      isClicked = false;
    });
  }
}
