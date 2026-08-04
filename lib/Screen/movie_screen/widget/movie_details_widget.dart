import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iptv/Widget/main_image_widget.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';
import 'package:iptv/controller/home_getx_controller.dart';
import 'package:shimmer/shimmer.dart';

class MovieDetailsWidget extends StatelessWidget {
  final String name;
  final String? image;
  const MovieDetailsWidget({
    super.key,
    required this.name,
    this.image,
  });

  String _safeText(dynamic value, [String fallback = '']) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppStyles().font16(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _infoText(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(title),
          Text(
            value,
            textAlign: TextAlign.start,
            style: AppStyles().font14(color: AppColors.blacksub4Color),
          ),
        ],
      ),
    );
  }

  Widget _metaPill({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.whiteColor.withValues(alpha: 0.86),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.greysub3Color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.primryColor),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppStyles().font12(fontWeight: FontWeight.bold),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.ellipsis,
              style: AppStyles().font12(color: AppColors.blacksub4Color),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    HomeGetxController homeGetxController = Get.find();

    return Stack(
      children: [
        Obx(() {
          if (homeGetxController.isLoadingMovieDetials.value) {
            return const SizedBox();
          } else if (homeGetxController.movieDetails != null) {
            final backdropPath =
                homeGetxController.movieDetails?.info?.backdropPath;
            return backdropPath != null && backdropPath.isNotEmpty
                ? Opacity(
                    opacity: 0.3,
                    child: MainImageWidget(
                      image: _safeText(backdropPath.first),
                      fit: BoxFit.fill,
                      height: Get.height,
                    ),
                  )
                : const SizedBox();
          } else {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 56),
                child: Text(
                  'تعذر تحميل تفاصيل الفيلم حالياً',
                  textAlign: TextAlign.center,
                  style: AppStyles().font16(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primryColor,
                  ),
                ),
              ),
            );
          }
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                Text(
                  name,
                  style: AppStyles().font20(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primryColor),
                ),
                const SizedBox(
                  height: 15,
                ),
                Obx(() {
                  if (homeGetxController.isLoadingMovieDetials.value) {
                    return Shimmer.fromColors(
                      baseColor: AppColors().baseColor,
                      highlightColor: AppColors().highlightColor,
                      child: Column(
                        children: List.generate(5, (index) {
                          return const SizedBox(
                            height: 35,
                            child: Divider(
                              thickness: 20,
                              endIndent: 20,
                            ),
                          );
                        }),
                      ),
                    );
                  } else if (homeGetxController.movieDetails != null) {
                    final info = homeGetxController.movieDetails?.info;
                    if (info == null) {
                      return _buildBasicDetails();
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _metaPill(
                              icon: Icons.star,
                              label: 'التقييم',
                              value: _safeText(info.rating, 'غير متوفر'),
                            ),
                            _metaPill(
                              icon: Icons.schedule,
                              label: 'المدة',
                              value: _safeText(info.duration, 'غير متوفر'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _infoText(
                          'الحبكة',
                          _safeText(info.plot, 'لا توجد تفاصيل إضافية'),
                        ),
                        _infoText(
                          'الممثلين',
                          _safeText(info.cast, 'غير متوفر'),
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  } else {
                    return _buildBasicDetails();
                  }
                })
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBasicDetails() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MainImageWidget(
              image: image,
              height: 120,
              width: 90,
              fit: BoxFit.cover,
              radius: 8,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              textAlign: TextAlign.center,
              style: AppStyles().font18(
                fontWeight: FontWeight.bold,
                color: AppColors.primryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'التفاصيل الإضافية غير متوفرة حالياً، ويمكنك تشغيل الفيلم من زر التشغيل.',
              textAlign: TextAlign.center,
              style: AppStyles().font14(color: AppColors.greysub3Color),
            ),
          ],
        ),
      ),
    );
  }
}
