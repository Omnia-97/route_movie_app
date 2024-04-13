import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:route_movie_app/core/utils/styles.dart';
import 'package:route_movie_app/features/browse_tab/data/remote/models/category_model.dart';
import '../../../../core/utils/app_colors.dart';
import '../../data/remote/models/MovieListModel.dart';

class BrowseCategoryItem extends StatelessWidget {
  const BrowseCategoryItem({
    super.key,
    required this.genres,
    required this.text,
    required this.onTap,
    required this.categoryModel,
  });
  final Genres? genres;
  final String text;
  final VoidCallback onTap;
  final CategoryModel categoryModel;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTap();
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: CachedNetworkImage(
              imageUrl: categoryModel.imageUrl,
              fit: BoxFit.fill,
              width: 158.w,
              height: 90.h,
              progressIndicatorBuilder: (context, url, downloadProgress) =>
                  Center(
                    child: CircularProgressIndicator(
                      value: downloadProgress.progress,
                      color: AppColor.primaryColor,
                    ),
                  ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
          Container(
            alignment: Alignment.center,
            width: 158,
            height: 90,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4.r),
              color: AppColor.movieItemBgColor.withOpacity(0.37),
              boxShadow: [
                BoxShadow(
                  color: AppColor.blackColor.withOpacity(0.16),
                  spreadRadius: 0,
                  blurRadius: 3,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Text(
              text,
              style: AppStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
