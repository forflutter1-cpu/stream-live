import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Widget/appBarrWidget.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/api/api_controller/api_controller.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/model/contact_model.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/app_helper.dart';
import 'package:iptv/Screen/SplashScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with ApiHelper, AppHelper {
  HomeGetxController homeGetxController = Get.find();


  ContactModel? contactModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBar_Widget(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                height: 15,
              ),
              Text(
                'المعلومات الشخصية',
                style: AppStyles().font20(fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 15,
              ),
              SizedBox(
                height: Get.height * 0.35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'اسم المستخدم: ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              SharedPrefController().name,
                              style: AppStyles()
                                  .font14(color: AppColors.primryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'حالة الحساب : ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              padding: const EdgeInsetsDirectional.symmetric(
                                  vertical: 5, horizontal: 20),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  color:
                                      SharedPrefController().status == 'Active'
                                          ? AppColors.greenColor
                                          : AppColors.redColor),
                              child: Text(
                                SharedPrefController().status == 'Active'
                                    ? 'مفعل'
                                    : SharedPrefController().status,
                                style: AppStyles()
                                    .font14(color: AppColors.whiteColor),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'نوع الاشتراك : ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              SharedPrefController().isTrial == '1'
                                  ? 'مجاني  '
                                  : 'مدفوع  ',
                              style: AppStyles()
                                  .font14(color: AppColors.primryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: Get.height * 0.35,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تاريخ انتهاء الاشتراك : ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              SharedPrefController().expDate != null
                                  ? timeStam(SharedPrefController().expDate!)
                                  : 'غير محدد',
                              style: AppStyles()
                                  .font14(color: AppColors.primryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'عدد الأجهزة النشطة الآن : ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '${SharedPrefController().activeCons} / ${SharedPrefController().maxConnections}',
                              style: AppStyles()
                                  .font14(color: AppColors.primryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        // height: 120,
                        // width: 230,
                        padding: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20, vertical: 20),
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 8, vertical: 15),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: AppColors.whiteColor,
                            boxShadow: const [
                              BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.black12,
                                  offset: Offset(0, 3))
                            ]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'تاريخ إنشاء الحساب : ',
                              style: AppStyles()
                                  .font16(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              SharedPrefController().createdAt != null
                                  ? timeStam(SharedPrefController().createdAt!)
                                  : 'غير محدد',
                              style: AppStyles()
                                  .font14(color: AppColors.primryColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Row(
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     Container(
              //       height: 120,
              //       width: 230,
              //       padding: const EdgeInsetsDirectional.symmetric(
              //           horizontal: 20, vertical: 20),
              //       margin: const EdgeInsetsDirectional.symmetric(
              //           horizontal: 10, vertical: 15),
              //       decoration: BoxDecoration(
              //           borderRadius: BorderRadius.circular(10),
              //           color: AppColors.whiteColor,
              //           boxShadow: const [
              //             BoxShadow(
              //                 blurRadius: 6,
              //                 color: Colors.black12,
              //                 offset: Offset(0, 3))
              //           ]),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         mainAxisAlignment: MainAxisAlignment.center,
              //         children: [
              //           Text(
              //             'عدد الأجهزة الأقصى : ',
              //             style: AppStyles().font16(fontWeight: FontWeight.bold),
              //           ),
              //           const SizedBox(
              //             height: 10,
              //           ),
              //           Text(
              //             '1',
              //             style: AppStyles().font14(),
              //           ),
              //         ],
              //       ),
              //     ),
              //   ],
              // ),

              SizedBox(
                height: Get.height * 0.35,
                width: Get.width,
                child: Container(
                  padding: const EdgeInsetsDirectional.symmetric(
                      horizontal: 20, vertical: 20),
                  margin: const EdgeInsetsDirectional.symmetric(
                      horizontal: 8, vertical: 15),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.whiteColor,
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 6,
                            color: Colors.black12,
                            offset: Offset(0, 3))
                      ]),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'رابط السيرفر :  ',
                        style: AppStyles().font16(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SelectableText(
                        SharedPrefController().url,
                        style: AppStyles().font14(color: AppColors.primryColor),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Get.defaultDialog(
                    title: "حذف الحساب",
                    middleText: "هل أنت متأكد من رغبتك في حذف الحساب نهائياً؟ لا يمكن التراجع عن هذا الإجراء.",
                    textConfirm: "حذف",
                    textCancel: "إلغاء",
                    confirmTextColor: Colors.white,
                    buttonColor: Colors.red,
                    onConfirm: () async {
                      Get.back(); // close dialog
                      bool success = await ApiController().deleteAccount();
                      if (success) {
                        await SharedPrefController().clear();
                        Get.offAll(() => const SplashScreen()); // redirect to Splash / Login
                      }
                    },
                  );
                },
                child: Text(
                  'حذف الحساب نهائياً',
                  style: AppStyles().font16(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
