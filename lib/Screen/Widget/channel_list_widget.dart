import 'package:flutter/material.dart';
import 'package:iptv/app_material/app_colors.dart';
import 'package:iptv/app_material/app_styles.dart';

class ChannelList extends StatelessWidget {
  const ChannelList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      margin: const EdgeInsets.only(left: 10, right: 10, top: 10),
      height: double.infinity,
      width: 250,
      decoration: const BoxDecoration(color: AppColors.primryColor),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.whiteColor,
                    size: 15,
                  )),
              Text('الكل',
                  style: AppStyles().font12(
                    color: AppColors.whiteColor,
                    fontWeight: FontWeight.w300,
                  )),
              IconButton(
                  onPressed: () {},
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    size: 15,
                    color: AppColors.whiteColor,
                  )),
            ],
          ),
          const Divider(),
          SizedBox(
            height: 230,
            child: ListView.builder(
                // physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: 8,
                padding: const EdgeInsets.symmetric(vertical: 3),
                itemBuilder: (context, index) {
                  return InkWell(
                    onTap: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text('122',
                                style: AppStyles().font12(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w300,
                                )),
                            const SizedBox(
                              width: 10,
                            ),
                            //صورة ابقناة
                            Image.asset(
                              'images/new_logo.jpg',
                              color: Colors.white,
                              width: 40,
                              height: 40,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('لا يوجد برنامج ',
                                style: AppStyles().font12(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w300,
                                )),
                            const SizedBox(
                              width: 20,
                            ),
                            Text('اسم القناة',
                                style: AppStyles().font12(
                                  color: AppColors.whiteColor,
                                  fontWeight: FontWeight.w300,
                                )),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    );
  }
}
