import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:iptv/Screen/Auth/operator_screen.dart';
import 'package:iptv/Screen/Auth/public_screen.dart';
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/Screen/Auth/RegisterScreen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/model/profile_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/utils/deep_link_redirect.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with AppHelper {
  late TextEditingController userName;
  late TextEditingController password;
  //  operatorModel!.data??  operatorModel!.data?;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    getContact();
    // getOperator();
    userName = TextEditingController();
    password = TextEditingController();
  }

  @override
  void dispose() {
    userName.dispose();
    password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 700;
            final horizontalPadding = compact ? 22.0 : 30.0;
            final contentWidth =
                compact ? double.infinity : constraints.maxWidth;

            final contactPanel = ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: compact ? 360 : 420,
              ),
              child: _buildContactPanel(compact: compact),
            );
            final loginPanel = ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: compact ? 360 : 520,
              ),
              child: _buildLoginPanel(compact: compact),
            );

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: compact ? 26 : 40,
                ),
                child: SizedBox(
                  width: contentWidth,
                  child: compact
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              contactPanel,
                              const SizedBox(height: 28),
                              loginPanel,
                            ],
                          ),
                        )
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(child: Center(child: contactPanel)),
                            const SizedBox(width: 48),
                            Expanded(child: Center(child: loginPanel)),
                          ],
                        ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildContactPanel({required bool compact}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (operatorModel?.type == 'operator')
          Center(
            child: InkWell(
              onTap: () {
                Get.to(() => const OperatorScreen());
              },
              child: Text.rich(TextSpan(children: [
                TextSpan(
                    text: 'تغيير السيرفر',
                    style: AppStyles().font14(color: AppColors.primryColor)),
              ])),
            ),
          ),
        SizedBox(height: compact ? 10 : 20),
        AnimationConfiguration.synchronized(
            duration: const Duration(milliseconds: 357),
            child: ScaleAnimation(
                child: FadeInAnimation(
                    child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'images/new_logo.jpg',
                    height: compact ? 104 : 120,
                    width: compact ? 104 : 120,
                  ),
                ),
              ),
            )))),
        SizedBox(height: compact ? 12 : 20),
        Text(
          operatorModel!.data?.title ?? '',
          textAlign: TextAlign.center,
          style: AppStyles().font20(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          operatorModel!.data?.description ?? '',
          textAlign: TextAlign.center,
        ),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 2,
          runSpacing: 2,
          children: [
            Visibility(
              visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
                visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
              visible: operatorModel!.data != null &&
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
    );
  }

  Widget _buildLoginPanel({required bool compact}) {
    final socialButtonWidth = compact ? 96.0 : Get.width * 0.20;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextFiled_Widget(
          hintText: 'اسم المستخدم أو الايميل أو رقم الهاتف',
          controller: userName,
          textInputType: TextInputType.text,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 16),
        TextFiled_Widget(
          hintText: 'كلمة المرور',
          controller: password,
          textInputType: TextInputType.text,
          iconVi: true,
          textInputAction: TextInputAction.done,
          onEditingComplete: login,
        ),
        const SizedBox(height: 24),
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
        const SizedBox(height: 20),
        operatorModel?.type == 'operator'
            ? Column(
                children: [
                  Visibility(
                    visible: SharedPrefController().operator == '1',
                    child: Column(
                      children: [
                        Center(
                          child: InkWell(
                            onTap: () {
                              Get.to(() => const RegisterScreen());
                            },
                            child: Text.rich(
                              TextSpan(children: [
                                const TextSpan(
                                    text:
                                        ' اذا كان ليس لديك حساب بامكانك '),
                                TextSpan(
                                    text: 'انشاء حساب بالضغط هنا',
                                    style: AppStyles().font14(
                                        color: AppColors.primryColor)),
                              ]),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 15,
                          child: Divider(
                            color:
                                AppColors.blackColor.withValues(alpha: 0.1),
                          ),
                        ),
                        const Text('او قم بتسجيل الدخول عبر'),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () async {
                                signInWithGoogle();
                              },
                              child: Container(
                                width: socialButtonWidth,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.deepOrange,
                                ),
                                child: SvgPicture.asset(
                                  'images/google.svg',
                                  height: 30,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Visibility(
                              visible: true,
                              child: Container(
                                width: socialButtonWidth,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.black,
                                ),
                                child: InkWell(
                                  onTap: () async {
                                    await ApiController().appleLogin();
                                  },
                                  child: SvgPicture.asset(
                                    'images/apple.svg',
                                    height: 30,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ],
              )
            : Center(
                child: InkWell(
                  onTap: () {
                    Get.to(() => const RegisterScreen());
                  },
                  child: Text.rich(
                    TextSpan(children: [
                      const TextSpan(text: ' اذا كان ليس لديك حساب بامكانك '),
                      TextSpan(
                          text: 'انشاء حساب بالضغط هنا',
                          style: AppStyles()
                              .font14(color: AppColors.primryColor)),
                    ]),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
        const SizedBox(height: 8),
        Center(
          child: InkWell(
            onTap: () {
              Get.to(() => const PublicScreen());
            },
            child: const Text('تجربة سيرفر اخر ؟'),
          ),
        ),
      ],
    );
  }

  bool checkData() {
    if (password.text.isNotEmpty && userName.text.isNotEmpty) {
      return true;
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
      ProfileModel? profileModel = await ApiController().login(
        userName: userName.text,
        password: password.text,
      );

      if (profileModel != null) {
        await SharedPrefController()
            .saveUserData(profileModel: profileModel, isLogined: true);

        await openPendingRouteOrHome();
      }
      setState(() {
        isClicked = false;
      });
    }
  }

  void getContact() async {
    contactModel = await ApiController().getContact();
    setState(() {});
  }

  void signInWithGoogle() async {
    try {
      GoogleSignInAccount? googleSignInAccount = await GoogleSignIn().signIn();

      setState(() {
        isClicked = true;
      });
      GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount!.authentication;
      String accessToken = googleSignInAuthentication.accessToken!;
      String? errorMessage =
          await ApiController().googleLogin(token: accessToken);
      if (errorMessage != null) {
        // SOMETHING WENT WRONG - THE ( errorMessage ) THE MESSAGE TO SHOW IN THE TOAST
        showMeesage(title: errorMessage, isError: true);
        setState(() {
          isClicked = false;
        });
      } else {
        // THE OPERATION DONE SUCCSfully
        // myAwesomeDialog(context,
        //     title: 'Seccses', subTitle: 'you are logined now', isError: false);

        // SharedPrefController().role == 'Customer'
        //     ? Get.offAll(
        //         () => const HomeScreen(),
        //         transition: Transition.size,
        //         duration: const Duration(milliseconds: 1500),
        //         curve: Curves.easeIn,
        //       )
        //     : Get.offAll(
        //         () => const OrdersScreen(),
        //         transition: Transition.size,
        //         duration: const Duration(milliseconds: 1500),
        //         curve: Curves.easeIn,
        //       );
      }
    } catch (error) {
      setState(() {
        isClicked = false;
      });
      return;
    }
  }

  // void getOperator() async {
  //   operatorModel = await ApiController().getOperator();
  //   setState(() {});
  // }
}
