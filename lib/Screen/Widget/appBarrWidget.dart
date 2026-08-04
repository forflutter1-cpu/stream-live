import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Screen/Auth/LoginScreen.dart';
import 'package:iptv/Screen/Auth/public_screen.dart';
import 'package:iptv/Screen/Profile/ProfileScreen.dart';
import 'package:iptv/Screen/Profile/update_password_screen.dart';
import 'package:iptv/Screen/Profile/update_profile_screen.dart';
import 'package:iptv/Screen/SearchScreen.dart';
import 'package:iptv/Screen/SplashScreen.dart';
import 'package:iptv/Screen/downloaded_screen/downloaded_screen.dart';
import 'package:iptv/Screen/edu/teach_screen.dart';
import 'package:iptv/api/api_helper.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:iptv/database/database_helper.dart';
import 'package:iptv/shared_preferences/shared_pref_controller.dart';
import 'package:iptv/utils/friendly_routes.dart';
import 'package:iptv/utils/app_helper.dart';

class AppBar_Widget extends StatefulWidget implements PreferredSizeWidget {
  @override
  final Size preferredSize;
  final bool showBack;
  final int selectedType;

  const AppBar_Widget({
    this.showBack = true,
    this.selectedType = 0,
    Key? key,
  })  : preferredSize = const Size.fromHeight(50.0),
        super(key: key);

  @override
  State<AppBar_Widget> createState() => _AppBar_WidgetState();
}

class _AppBar_WidgetState extends State<AppBar_Widget>
    with ApiHelper, AppHelper {
  HomeGetxController homeGetxController = Get.put(HomeGetxController());
  // InternetSpeedGetxController internetSpeedGetxController =
  //     Get.put(InternetSpeedGetxController());

  @override
  Widget build(BuildContext context) {
    return AppBar(
      toolbarHeight: 45,
      elevation: 0,
      backgroundColor: Colors.transparent,
      leadingWidth: 250,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            //
            Visibility(
              visible: widget.showBack,
              child: IconButton(
                  onPressed: () {
                    if (Navigator.of(context).canPop()) {
                      Get.back();
                    } else {
                      Get.offAllNamed('/home');
                    }
                  },
                  icon: const Icon(Icons.arrow_back)),
            ),
            const SizedBox(
              width: 5,
            ),
            const Icon(
              Icons.play_circle_outline_outlined,
              color: AppColors.deepPurpleColor,
            ),
            const SizedBox(
              width: 5,
            ),
            RichText(
                text: TextSpan(children: [
              TextSpan(
                  text: 'ستريم ',
                  style: AppStyles().font20(
                    color: AppColors.primryColor,
                    fontWeight: FontWeight.bold,
                  )),
              TextSpan(
                  text: 'لايف',
                  style: AppStyles().font18(
                    color: AppColors.deepPurpleColor,
                  )),
            ])),
          ],
        ),
      ),
      centerTitle: true,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(SharedPrefController().isTrial == '1' ? 'مجاني : ' : 'مدفوع : ',
              style: AppStyles().font14(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w300,
              )),
          InkWell(
            onTap: operatorModel!.type == 'operator' ||
                    operatorModel!.type == 'private'
                ? () {
                    operatorModel != null && operatorModel!.data != null
                        ? contactDialog()
                        : soonDialog();
                  }
                : null,
            child: Text(
                SharedPrefController().status == 'Active'
                    ? 'مفعل'
                    : SharedPrefController().status,
                style: AppStyles().font14(
                  color: SharedPrefController().status == 'Active'
                      ? AppColors.greenColor
                      : AppColors.redColor,
                  fontWeight: FontWeight.w300,
                )),
          ),
          const SizedBox(
            width: 10,
            height: 20,
            child: VerticalDivider(),
          ),
          Text(' تاريخ الانتهاء : ',
              style: AppStyles().font14(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w300,
              )),
          Text(
              SharedPrefController().expDate != null
                  ? timeStam(SharedPrefController().expDate!.toString())
                  : 'غير محدد',
              style: AppStyles().font14(
                color: AppColors.primryColor,
                fontWeight: FontWeight.w300,
              )),
        ],
      ),
      actions: [
        TextButton(
          child: const Text('التعليم'),
          onPressed: () => Get.toNamed(educationRoute()),
        ),
        const SizedBox(
          width: 10,
        ),
        // Obx(() {
        //   return Text(
        //     internetSpeedGetxController.downloadSpeed.value,
        //     // style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        //   );
        // }),

        IconButton(
            onPressed: () {
              Get.toNamed('/search/${widget.selectedType}');
              // homeGetxController.searchStreams(search: '');

              // setState(() {
              //   showSearch = !showSearch;
              // });

              // Get.bottomSheet(
              //   Expanded(
              //     // decoration: BoxDecoration(
              //     //     color: AppColors.whiteColor,
              //     //     borderRadius: BorderRadius.circular(8)),
              //     child: Column(
              //       children: [
              //         SizedBox(
              //           height: 50,
              //           child: TextFiled_Widget(
              //             controller: searchController,
              //             hintText: 'بحث',
              //             onChanged: (p0) {
              //               homeGetxController.searchStreams(
              //                   search: searchController.text);
              //             },
              //           ),
              //         ),
              //         const SizedBox(
              //           height: 10,
              //         ),
              //         Expanded(child: Obx(() {
              //           return ListView.separated(
              //             shrinkWrap: true,
              //             itemBuilder: (context, index) {
              //               return Text(homeGetxController
              //                       .searchFilterd[index].name ??
              //                   '');
              //             },
              //             separatorBuilder: (context, index) {
              //               return const Divider();
              //             },
              //             itemCount:
              //                 homeGetxController.searchFilterd.length,
              //           );
              //         }))
              //       ],
              //     ),
              //   ),
              //   backgroundColor: AppColors.whiteColor,
              // );

              // last search
              // showDialog(
              //   context: context,
              //   builder: (BuildContext context) {
              //     return AlertDialog(
              //       title: TextFiled_Widget(
              //         controller: searchController,
              //         textInputType: TextInputType.text,

              //         hintText: 'بحث',

              //         onEditingComplete: () {
              //           // FocusScope.of(context).unfocus();
              //           homeGetxController.searchStreams(
              //             search: searchController.text,
              //           );
              //         },
              //         // onChanged: (p0) {
              //         //   homeGetxController.searchStreams(
              //         //       search: searchController.text);
              //         // },
              //       ),
              //       content: ConstrainedBox(
              //         constraints: BoxConstraints(
              //           maxHeight:
              //               Get.height * 0.6, // تحديد أقصى ارتفاع للـ Dialog
              //         ),
              //         child: SingleChildScrollView(
              //           child: Column(
              //             mainAxisSize: MainAxisSize
              //                 .min, // يجعل الحجم يتناسب مع المحتوى
              //             children: [
              //               Obx(() {
              //                 return Column(
              //                   children: List.generate(
              //                     homeGetxController.searchFilterd.length,
              //                     (index) => Padding(
              //                       padding: const EdgeInsets.all(5.0),
              //                       child: InkWell(
              //                         onTap: () async {
              //                           Get.back();
              //                           homeGetxController
              //                               .changeSelectedStreamName(
              //                                   homeGetxController
              //                                           .streamsFilterd[index]
              //                                           .name ??
              //                                       '');
              //                           String url =
              //                               '${ApiSettings.channelUrl.replaceAll('ThePassword', SharedPrefController().password).replaceAll('theName', SharedPrefController().name).replaceAll('dynamicBaseUrl', '${SharedPrefController().serverProtocol}://${SharedPrefController().url}:${SharedPrefController().serverProtocol == 'http' ? SharedPrefController().port : SharedPrefController().httpsPort}/')}${homeGetxController.streamsFilterd[index].streamId}${homeGetxController.streamsFilterd[index].streamType == 'live' ? '.ts' : '.mp4'}';
              //                           playStream(
              //                               url,
              //                               homeGetxController
              //                                       .streamsFilterd[index]
              //                                       .name ??
              //                                   '');
              //                         },
              //                         child: Text(
              //                           homeGetxController
              //                                   .searchFilterd[index].name ??
              //                               '',
              //                           style: AppStyles().font14(),
              //                         ),
              //                       ),
              //                     ),
              //                   ),
              //                 );
              //               }),
              //             ],
              //           ),
              //         ),
              //       ),
              //       // actions: [
              //       //   TextButton(
              //       //     onPressed: () {
              //       //       Navigator.of(context).pop(); // إغلاق الـ Dialog
              //       //     },
              //       //     child: Text('إغلاق'),
              //       //   ),
              //       // ],
              //     );
              //   },
              // );
            },
            icon: const Icon(Icons.search)),
        // const SizedBox(
        //   width: 10,
        // ),
        // showSearch
        //     ? SizedBox(
        //         width: Get.width * 0.3,
        //         child: TextFiled_Widget(
        //           hintText: 'بحث',
        //           autofocus: true,
        //           onChanged: (p0) {
        //             homeGetxController.searchStreams(
        //               search: p0,
        //             );
        //           },
        //           controller: searchController,
        //         ),
        //       )
        //     : const SizedBox(),
        // IconButton(
        //     onPressed: () async {
        //       SharedPrefController().clear();
        //       await DatabaseHelper.instance.clearDatabase();
        //       controller.dispose();
        //       Get.offAll(() => const LoginScreen());
        //     },
        //     icon: const Icon(Icons.logout)),
        PopupMenuButton<int>(
          onSelected: (value) async {
            switch (value) {
              case 1:
                if (homeGetxController.isLoadingMovieStream.value ||
                    homeGetxController.isLoadingSeriesStream.value ||
                    homeGetxController.isLoadingStream.value) {
                  updateDialog();
                  return;
                }
                await DatabaseHelper.instance.clearWatchProgress();
                homeGetxController.getCategories(clearData: true);
                homeGetxController.getStreams(clearData: true);
                homeGetxController.getCategories(clearData: true);
                await homeGetxController.getStreams(clearData: true);
                homeGetxController.getMovieCategories(clearData: true);
                await homeGetxController.getMovieStreams(clearData: true);
                homeGetxController.getSeriesCategories(clearData: true);
                await homeGetxController.getSeriesStreams(clearData: true);
                SharedPrefController().updateLastDataUpdata(
                    lastDataUpdate: DateTime.now().toString());
                break;

              case 2:
                operatorModel != null && operatorModel!.data != null
                    ? contactDialog()
                    : soonDialog();
                break;

              case 3:
                // التعامل مع خيار تسجيل الخروج
                String operator = SharedPrefController().operator ?? '';
                String typeOperator = SharedPrefController().typeOperator ?? '';

                SharedPrefController().clear();
                await DatabaseHelper.instance.clearDatabase();
                await SharedPrefController().updateOperator(operator: operator);
                await SharedPrefController()
                    .updateTypeOperator(typeOperator: typeOperator);
                // controller.pause();
                // if (controller.state == FijkState.initialized) {
                // Stop the video playback
                // await controller.stop();

                // Dispose of the controller if necessary
                // }

                Get.offAll(() => operatorModel!.type == 'public'
                    ? const PublicScreen()
                    : const LoginScreen());
                // controller.release();
                // if (controller.isBuffering) {
                // controller.dispose();
                // }

                // تعامل مع خيارات أخرى
                break;
              // يمكنك إضافة المزيد من الحالات هنا
              case 4:
                Get.to(() => const ProfileScreen());
                break;

              case 5:
                // upadte profile
                Get.to(() => const UpdateProfileScreen());

                break;
              case 6:
                // password
                Get.to(() => const UpdatePasswordScreen());
              case 7:
                // downloaded videos
                Get.to(() => const DownloadedScreen());

                break;
            }
          },
          icon: const Icon(Icons.more_vert), // أيقونة القائمة
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 4,
              child: Row(
                children: [
                  Icon(Icons.person),
                  SizedBox(width: 8),
                  Text(' الملف الشخصي'),
                ],
              ),
            ),
            if (operatorModel?.type == 'private' ||
                (operatorModel?.type == 'operator' &&
                    SharedPrefController().operator == '1'))
              const PopupMenuItem(
                value: 5,
                child: Row(
                  children: [
                    Icon(Icons.person),
                    SizedBox(width: 8),
                    Text('تحديث البيانات الشخصية'),
                  ],
                ),
              ),
            if (operatorModel?.type == 'private' ||
                (operatorModel?.type == 'operator' &&
                    SharedPrefController().operator == '1'))
              const PopupMenuItem(
                value: 6,
                child: Row(
                  children: [
                    Icon(Icons.lock),
                    SizedBox(width: 8),
                    Text(' تغيير كلمة المرور'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 1,
              child: Row(
                children: [
                  Icon(Icons.update),
                  SizedBox(width: 8),
                  Text('تحديث القنوات'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 7,
              child: Row(
                children: [
                  Icon(Icons.download),
                  SizedBox(width: 8),
                  Text('التحميلات'),
                ],
              ),
            ),
            if (operatorModel!.type == 'operator' ||
                operatorModel!.type == 'private')
              const PopupMenuItem(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.contact_support_outlined),
                    SizedBox(width: 8),
                    Text('تواصل معنا'),
                  ],
                ),
              ),
            const PopupMenuItem(
              value: 3,
              child: Row(
                children: [
                  Icon(Icons.logout),
                  SizedBox(width: 8),
                  Text('تسجيل الخروج'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
