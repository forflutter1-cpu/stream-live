import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/model/profile_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';

class PublicScreen extends StatefulWidget {
  const PublicScreen({super.key});

  @override
  State<PublicScreen> createState() => _PublicScreenState();
}

class _PublicScreenState extends State<PublicScreen> with AppHelper {
  late TextEditingController userName;
  late TextEditingController password;
  late TextEditingController serverDomain;
  late TextEditingController name;
  //  operatorModel!.data??  operatorModel!.data?;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    // getOperator();
    userName = TextEditingController();
    password = TextEditingController();
    serverDomain = TextEditingController();
    name = TextEditingController();
  }

  @override
  void dispose() {
    userName.dispose();
    password.dispose();
    serverDomain.dispose();
    name.dispose();
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
                              height: 120,
                              width: 120,
                            ),
                          ),
                        ),
                      )))),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    operatorModel?.data?.title ?? 'تسجيل دخول يدوي',
                    style: AppStyles().font20(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Text(operatorModel?.data?.description ??
                      'أدخل بيانات السيرفر وبيانات الدخول للمتابعة.'),
                  Wrap(
                    children: [
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.email.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.email);
                            },
                            icon: const Icon(
                              Icons.email,
                              //  color: baseColor,
                            )),
                      ),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.phone.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.phone);
                            },
                            icon: const Icon(
                              Icons.call,
                              color: Colors.green,
                            )),
                      ),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.facebook.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.facebook);
                            },
                            icon: SvgPicture.asset(
                              'images/facebook.svg',
                              height: 20,
                              width: 20,
                            )),
                      ),
                      Visibility(
                          visible: operatorModel?.data != null &&
                              operatorModel!.data!.instagram.isNotEmpty,
                          child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.instagram);
                            },
                            icon: SvgPicture.asset(
                              'images/Instagram.svg',
                              height: 20,
                              width: 20,
                            ),
                          )),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.twitter.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.twitter);
                            },
                            icon: SvgPicture.asset(
                              'images/T.svg',
                              height: 20,
                              width: 20,
                            )),
                      ),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.telegram.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.telegram);
                            },
                            icon: SvgPicture.asset(
                              'images/telegram.svg',
                              height: 20,
                              width: 20,
                            )),
                      ),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.whatsapp.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.whatsapp);
                            },
                            icon: SvgPicture.asset(
                              'images/w.svg',
                              height: 20,
                              width: 20,
                            )),
                      ),
                      Visibility(
                        visible: operatorModel?.data != null &&
                            operatorModel!.data!.website.isNotEmpty,
                        child: IconButton(
                            onPressed: () {
                              launch(url: operatorModel!.data!.website);
                            },
                            icon: const Icon(
                              Icons.language_sharp,
                            )),
                      ),
                    ],
                  )
                ],
              ),
            ),

            //
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFiled_Widget(
                    hintText: 'الاسم',
                    controller: name,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFiled_Widget(
                    hintText: 'رابط السيرفر',
                    controller: serverDomain,
                    textInputType: TextInputType.url,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFiled_Widget(
                    hintText: 'اسم المستخدم',
                    controller: userName,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  TextFiled_Widget(
                    hintText: 'كلمة المرور',
                    controller: password,
                    textInputType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    iconVi: true,
                    onEditingComplete: login,
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
                        onPressed: login,
                        child: Text(
                          'تسجيل دخول',
                          style: AppStyles().font16(
                            color: AppColors.whiteColor,
                            fontWeight: FontWeight.w400,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 30,
                  ),

                  // InkWell(
                  //   onTap: () {
                  //     Get.to(() => const RegisterScreen());
                  //   },
                  //   child: Text.rich(TextSpan(children: [
                  //     const TextSpan(text: ' اذا كان ليس لديك حساب بامكانك '),
                  //     TextSpan(
                  //         text: 'انشاء حساب بالضغط هنا',
                  //         style:
                  //             AppStyles().font14(color: AppColors.primryColor)),
                  //   ])),
                  // ),
                ],
              ),
            ),
          ],
        ),
      ),
    ));
  }

  bool checkData() {
    if (name.text.isNotEmpty &&
        serverDomain.text.isNotEmpty &&
        password.text.isNotEmpty &&
        userName.text.isNotEmpty) {
      if (serverDomain.text.replaceAll(' ', '').isURL) {
        return true;
      } else {
        showMeesage(
          title: 'رابط السيرفر غير صحيح',
          // subTitle: 'رابط السيرفر يجب انو يكون رابط',
          isError: true,
        );
        return false;
      }
    }
    showMeesage(
      title: 'جميع الحقول مطلوبة',
      // subTitle: 'يجب عليك اضافة كل الحقول',
      isError: true,
    );
    return false;
  }

  void login() async {
    if (checkData()) {
      setState(() {
        isClicked = true;
      });
      await SharedPrefController()
          .updateBaseUrl(baseUrl: serverDomain.text.replaceAll(' ', ''));

      ProfileModel? profileModel = await ApiController().login(
        userName: userName.text,
        password: password.text,
      );

      if (profileModel != null) {
        await SharedPrefController()
            .saveUserData(profileModel: profileModel, isLogined: true);

        Get.offAll(() => const HomeScreen());
      }
      setState(() {
        isClicked = false;
      });
    }
  }
}
