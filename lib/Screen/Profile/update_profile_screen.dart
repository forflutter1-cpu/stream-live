import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Auth/otp_code_verification.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/Widget/textFiled_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:country_code_picker/country_code_picker.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late TextEditingController nameController, emailController, mobileController;

  bool isCliked = false;
  String selectedCountryCode = '+970'; // فلسطين كافتراضي
  String userPhoneNumber = '';

  @override
  void initState() {
    super.initState();

    // فصل رقم الهاتف إلى رمز الدولة والرقم الفعلي بناءً على المسافة
    String fullPhone = SharedPrefController().phone;
    _parsePhoneNumber(fullPhone);

    nameController = TextEditingController(text: SharedPrefController().name);
    emailController = TextEditingController(text: SharedPrefController().email);
    mobileController = TextEditingController(text: userPhoneNumber);
  }

  // دالة لفصل رقم الهاتف إلى رمز الدولة والرقم بناءً على المسافة
  void _parsePhoneNumber(String fullPhone) {
    if (fullPhone.contains(' ')) {
      // فصل الرقم بناءً على المسافة
      List<String> parts = fullPhone.split(' ');
      if (parts.length >= 2) {
        selectedCountryCode = '+${parts[0]}';
        userPhoneNumber = parts.sublist(1).join('');
      } else {
        selectedCountryCode = '+970';
        userPhoneNumber =
            fullPhone.replaceFirst(selectedCountryCode, '').trim();
      }
    } else {
      // إذا لم تكن هناك مسافة، حاول التعرف على رمز الدولة
      if (fullPhone.startsWith('+970') && fullPhone.length > 4) {
        selectedCountryCode = '+970';
        userPhoneNumber = fullPhone.substring(4);
      } else if (fullPhone.startsWith('+972') && fullPhone.length > 4) {
        selectedCountryCode = '+972';
        userPhoneNumber = fullPhone.substring(4);
      } else if (fullPhone.startsWith('+')) {
        // إذا بدأ بـ + ولكن بدون مسافة، افصل أول 4 أرقام كرمز دولة
        selectedCountryCode =
            fullPhone.length >= 4 ? fullPhone.substring(0, 4) : '+970';
        userPhoneNumber = fullPhone.replaceFirst(selectedCountryCode, '');
      } else {
        // إذا لم يبدأ بـ +، افترض أنه رقم بدون رمز دولة
        selectedCountryCode = '+970';
        userPhoneNumber = fullPhone;
      }
    }

    // تنظيف الرقم من أي مسافات إضافية
    userPhoneNumber = userPhoneNumber.trim();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'تعديل البيانات الشخصية',
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
                    TextFiled_Widget(
                      controller: nameController,
                      hintText: 'اسم الحساب',
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: TextFiled_Widget(
                            controller: emailController,
                            hintText: 'البريد الالكتروني',
                            textInputAction: TextInputAction.next,
                            enabled:
                                SharedPrefController().emailVerifiedAt == null,
                          ),
                        ),
                        if (SharedPrefController().url == 'iptv.alkmal.com' || SharedPrefController().url == 'streams.alkmal.com')
                          Visibility(
                            visible:
                                SharedPrefController().emailVerifiedAt == null,
                            replacement: const Icon(Icons.verified,
                                color: AppColors.greenColor),
                            child: Column(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.error_outline,
                                    color: AppColors.redColor,
                                  ),
                                  onPressed: SharedPrefController()
                                          .email
                                          .isEmpty
                                      ? null
                                      : () {
                                          Get.to(
                                              () => const OtpVerificationScreen(
                                                    isEmail: true,
                                                  ));
                                        },
                                ),
                                Text('تفعيل',
                                    style: AppStyles().font12(
                                      color: AppColors.redColor,
                                    )),
                              ],
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // حقل رقم الهاتف مع مُختار رمز الدولة
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Text(
                        //   'رقم الهاتف',
                        //   style: AppStyles().font14(
                        //     color: AppColors.blackColor,
                        //   ),
                        // ),
                        // const SizedBox(height: 5),
                        Row(
                          children: [
                            // مُختار رمز الدولة

                            Expanded(
                              child: TextFiled_Widget(
                                controller: mobileController,
                                hintText: 'ادخل رقم الهاتف',
                                textInputAction: TextInputAction.done,
                                textInputType: TextInputType.phone,
                                enabled:
                                    SharedPrefController().mobileVerifiedAt ==
                                        null,
                                onEditingComplete: updateData,
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
                                  enabled:
                                      SharedPrefController().mobileVerifiedAt ==
                                          null,
                                  onChanged: (CountryCode countryCode) {
                                    setState(() {
                                      selectedCountryCode =
                                          countryCode.dialCode!;
                                    });
                                  },
                                  initialSelection: selectedCountryCode,
                                  favorite: const ['PS'],
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

                            // Text(
                            //     selectedCountryCode), // مسافة بين المُختار وحقل الرقم

                            if (SharedPrefController().url == 'iptv.alkmal.com' || SharedPrefController().url == 'streams.alkmal.com')
                              Visibility(
                                visible:
                                    SharedPrefController().mobileVerifiedAt ==
                                        null,
                                replacement: const Icon(Icons.verified,
                                    color: AppColors.greenColor),
                                child: Column(
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.error_outline,
                                        color: AppColors.redColor,
                                      ),
                                      onPressed:
                                          SharedPrefController().phone.isEmpty
                                              ? null
                                              : () {
                                                  Get.to(() =>
                                                      const OtpVerificationScreen(
                                                        isEmail: false,
                                                      ));
                                                },
                                    ),
                                    Text('تفعيل',
                                        style: AppStyles().font12(
                                          color: AppColors.redColor,
                                        )),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 35),
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

    String newMobileText = mobileController.text[0] == '0'
        ? mobileController.text.substring(1)
        : mobileController.text;

    // دمج رمز الدولة مع رقم الهاتف مع إضافة مسافة بينهما
    String fullPhoneNumber = '$selectedCountryCode $newMobileText';

    await ApiController().updateProfile(
      userName: nameController.text,
      email: emailController.text,
      mobile: fullPhoneNumber, // إرسال الرقم الكامل مع رمز الدولة ومسافة
    );

    setState(() {
      isCliked = false;
    });
  }
}
