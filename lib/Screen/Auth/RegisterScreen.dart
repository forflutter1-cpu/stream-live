import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/HomeScreen.dart';
import 'package:iptv/Screen/Auth/LoginScreen.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/model/profile_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import '../../Widget/button_widget.dart';
import '../../Widget/textFiled_widget.dart';
import 'package:country_code_picker/country_code_picker.dart'; // أضف هذه السطر

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with AppHelper {
  late TextEditingController firstName;
  late TextEditingController emailAddress;
  late TextEditingController phoneNumber;
  late TextEditingController password;
  late TextEditingController passwordConfirm;
  bool iconVi = true;
  bool isClicked = false;
  String selectedCountryCode = '+970'; // رمز افتراضي للأردن

  @override
  void initState() {
    super.initState();
    firstName = TextEditingController();
    emailAddress = TextEditingController();
    phoneNumber = TextEditingController();
    password = TextEditingController();
    passwordConfirm = TextEditingController();
  }

  @override
  void dispose() {
    firstName.dispose();
    emailAddress.dispose();
    phoneNumber.dispose();
    password.dispose();
    passwordConfirm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leadingWidth: 250,
          toolbarHeight: 50,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                RichText(
                    text: TextSpan(children: [
                  TextSpan(
                      text: 'Stream ',
                      style: AppStyles().font20(
                        color: AppColors.primryColor,
                        fontWeight: FontWeight.bold,
                      )),
                  TextSpan(
                      text: 'Live',
                      style: AppStyles().font18(
                        color: AppColors.deepPurpleColor,
                      )),
                ])),
                const SizedBox(
                  width: 5,
                ),
                const Icon(
                  Icons.play_circle_outline_outlined,
                  color: AppColors.deepPurpleColor,
                ),
              ],
            ),
          ),
          title: Text(
            'انشاء حساب',
            style: AppStyles().font16(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w400,
            ),
          ),
          centerTitle: true,
          actions: [
            InkWell(
              onTap: () {
                try {
                  Get.closeAllSnackbars();
                } catch (_) {}
                Get.to(() => const LoginScreen());
              },
              child: Text(
                'تسجيل الدخول ',
                style: AppStyles().font12(
                  color: AppColors.primryColor,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(
              width: 20,
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'اسم المستخدم',
                                style: AppStyles().font16(
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFiled_Widget(
                                hintText: 'ادخل اسمك بالكامل',
                                controller: firstName,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9@.]')),
                                ],
                                textInputType: TextInputType.name,
                                suffix: const Icon(
                                  Icons.person,
                                  color: Color(0xffAEAEAE),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'الايميل',
                                style: AppStyles().font16(
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFiled_Widget(
                                hintText: 'ادخل الايميل الخاص بك',
                                textInputType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(
                                      RegExp(r'[a-zA-Z0-9@.]')),
                                ],
                                controller: emailAddress,
                                suffix: const Icon(
                                  Icons.email_outlined,
                                  color: Color(0xffAEAEAE),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 15,
                    ),

                    //
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                ' رقم الهاتف',
                                style: AppStyles().font16(
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  // مُختار رمز الدولة

                                  Expanded(
                                    child: TextFiled_Widget(
                                      hintText: 'ادخل رقم الهاتف',
                                      controller: phoneNumber,
                                      textInputAction: TextInputAction.next,
                                      textInputType: TextInputType.phone,
                                      suffix: const Icon(
                                        Icons.phone_android,
                                        color: Color(0xffAEAEAE),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Directionality(
                                    textDirection: TextDirection.ltr,
                                    child: Container(
                                      height: 50,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.grey),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: CountryCodePicker(
                                        onChanged: (CountryCode countryCode) {
                                          setState(() {
                                            selectedCountryCode =
                                                countryCode.dialCode!;
                                          });
                                        },
                                        initialSelection: 'PS',
                                        favorite: const ['+970', 'PS'],
                                        showCountryOnly: false,
                                        showOnlyCountryWhenClosed: false,
                                        alignLeft: false,
                                        textStyle: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.blackColor,
                                        ),
                                        padding: EdgeInsets.zero,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                'كلمة المرور',
                                style: AppStyles().font16(
                                  color: AppColors.blackColor,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFiled_Widget(
                                hintText: 'ادخل كلمة المرور',
                                controller: password,
                                textInputType: TextInputType.text,
                                onEditingComplete: register,
                                iconVi: iconVi,
                                suffix: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      iconVi = !iconVi;
                                    });
                                  },
                                  icon: iconVi
                                      ? const Icon(Icons.visibility_off)
                                      : const Icon(Icons.visibility),
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    //

                    const SizedBox(
                      height: 20,
                    ),
                    //
                    Visibility(
                      visible: !isClicked,
                      replacement: const Center(
                        child: CircularProgressIndicator(),
                      ),
                      child: ButtonWidget(
                          color: AppColors.primryColor,
                          height: 50,
                          elevation: 2,
                          onPressed: register,
                          child: Text(
                            'تسجيل',
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
              ],
            ),
          ),
        ));
  }

  bool checkData() {
    if (password.text.isNotEmpty &&
        firstName.text.isNotEmpty &&
        emailAddress.text.isNotEmpty &&
        phoneNumber.text.isNotEmpty) {
      return true;
    }
    showMeesage(
      title: 'جميع الحقول مطلوبة',
      isError: true,
    );
    return false;
  }

  void register() async {
    if (checkData()) {
      setState(() {
        isClicked = true;
      });

      // دمج رمز الدولة مع رقم الهاتف
      String fullPhoneNumber = '$selectedCountryCode ${phoneNumber.text}';
      ProfileModel? profileModel = await ApiController().register(
        userName: firstName.text,
        password: password.text,
        mobile: fullPhoneNumber, // استخدام الرقم الكامل مع رمز الدولة
        email: emailAddress.text,
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
