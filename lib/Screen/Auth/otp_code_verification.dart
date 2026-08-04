import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Profile/update_profile_screen.dart';
import 'package:iptv/Widget/button_widget.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';

class OtpVerificationScreen extends StatefulWidget {
  final bool isEmail;

  const OtpVerificationScreen({super.key, required this.isEmail});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen>
    with AppHelper {
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());

  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    resendCode();
    _focusNodes[0].requestFocus();
  }

  @override
  void dispose() {
    for (var f in _focusNodes) {
      f.dispose();
    }
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // شعار أو أيقونة
                const SizedBox(height: 30),
                const Icon(
                  Icons.verified_user,
                  size: 80,
                  color: AppColors.primryColor,
                ),
                const SizedBox(height: 20),

                // نص توضيحي
                const Text(
                  "تحقق من رقم الهاتف",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "أدخل رمز التحقق الذي أرسلناه إلى",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // رقم الهاتف مع زر تعديل
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        widget.isEmail
                            ? SharedPrefController().email
                            : SharedPrefController().phone,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    TextButton(
                      onPressed: editPhoneNumber,
                      child: const Text(
                        "تعديل",
                        style: TextStyle(fontSize: 16, color: Colors.blue),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // 6 خانات OTP
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(6, (index) {
                      return Container(
                        width: 50,
                        height: 60,
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: "",
                            contentPadding: EdgeInsets.zero,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(
                                  color: Colors.grey, width: 1.5),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide(
                                  color: Theme.of(context).primaryColor,
                                  width: 2),
                            ),
                            filled: true,
                            fillColor: Colors.grey[100],
                          ),
                          onChanged: (value) {
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index + 1]);
                            }
                            if (value.isEmpty && index > 0) {
                              FocusScope.of(context)
                                  .requestFocus(_focusNodes[index - 1]);
                            }

                            // if (index == 5 && value.isNotEmpty) {
                            //   _onSubmit();
                            // }
                          },
                          onEditingComplete: onSubmit,
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),

                // إمكانية إعادة إرسال الرمز
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("لم تستلم الرمز؟"),
                    TextButton(
                      onPressed: resendCode,
                      child: const Text(
                        "إعادة الإرسال",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primryColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // زر تأكيد
                Visibility(
                  visible: !isClicked,
                  replacement: const Center(child: CircularProgressIndicator()),
                  child: ButtonWidget(
                    height: 40,
                    onPressed: onSubmit,
                    child: const Text(
                      "تأكيد",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSubmit() async {
    setState(() {
      isClicked = true;
    });
    String otpCode = _controllers.map((c) => c.text).join();
    if (otpCode.length == 6) {
      FocusScope.of(context).unfocus();
      await ApiController().checkVerify(code: otpCode, isEmail: widget.isEmail);
    } else {
      showMeesage(title: "الرجاء إدخال الكود كاملاً", isError: true);
    }
    setState(() {
      isClicked = false;
    });
  }

  void resendCode() async {
    await ApiController().sendVerify(isEmail: widget.isEmail);
  }

  void editPhoneNumber() {
    Get.off(() => const UpdateProfileScreen());
  }
}
