import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({super.key});

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  late TextEditingController passwordController,
      newPasswordController,
      confirmController;

  bool isCliked = false;

  @override
  void initState() {
    super.initState();
    passwordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmController = TextEditingController();
  }

  @override
  void dispose() {
    passwordController.dispose();
    newPasswordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تغيير كلمة المرور',
          style: AppStyles().font20(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Row(
            children: [
              Expanded(
                child: AnimationConfiguration.synchronized(
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
                            height: 150,
                            width: 150,
                          ),
                        ),
                      ),
                    )))),
              ),
              Expanded(
                child: Column(
                  children: [
                    // TextFiled_Widget(
                    //   controller: nameController,
                    //   hintText: 'اسم الحساب',
                    //   textInputAction: TextInputAction.next,
                    // ),
                    // const SizedBox(
                    //   height: 15,
                    // ),
                    TextFiled_Widget(
                      controller: passwordController,
                      hintText: 'كلمة المرور القديمة',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFiled_Widget(
                      controller: newPasswordController,
                      hintText: 'كلمة المرور الجديدة',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    TextFiled_Widget(
                      controller: confirmController,
                      hintText: 'تاكيد كلمة المرور',
                      textInputAction: TextInputAction.done,
                      onEditingComplete: updateData,
                    ),
                    const SizedBox(
                      height: 35,
                    ),
                    Visibility(
                      visible: !isCliked,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: ButtonWidget(
                        onPressed: updateData,
                        height: 40,
                        child: Text(
                          'تحديث',
                          style: AppStyles().font14(
                            color: AppColors.whiteColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void updateData() async {
    setState(() {
      isCliked = true;
    });
    await ApiController().changePaswword(
      userName: SharedPrefController().name,
      password: passwordController.text,
      newPassword: newPasswordController.text,
      newPasswordConfirmation: confirmController.text,
    );
    setState(() {
      isCliked = false;
    });
  }
}
