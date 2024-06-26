import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:route_movie_app/core/firebase/firebase_functions.dart';
import 'package:route_movie_app/core/utils/app_colors.dart';
import 'package:route_movie_app/core/utils/app_images.dart';
import 'package:route_movie_app/core/utils/app_strings.dart';
import 'package:route_movie_app/core/utils/styles.dart';
import 'package:route_movie_app/features/watchList_tab/data/models/watch_list_model.dart';
import 'package:route_movie_app/features/watchList_tab/presentation/widgets/watchlist_item.dart';

class WatchListTab extends StatelessWidget {
  const WatchListTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0.w, vertical: 15.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 25.h),
            Text(
              'Watchlist',
              style: AppStyles.bodyLarge,
              textAlign: TextAlign.start,
            ),
            SizedBox(height: 10.h),
            StreamBuilder<QuerySnapshot<WatchListModel>>(
              stream: FirebaseFunctions.getWatchList(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColor.primaryColor,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text(AppStrings.error),
                  );
                }
                var films =
                    snapshot.data?.docs.map((e) => e.data()).toList() ?? [];
                if (films.isEmpty) {
                  return Column(
                    children: [
                      SizedBox(height: 250.h),
                      Image.asset(AppImages.noMovies),
                      SizedBox(height: 10.h),
                       Center(
                        child: Text(
                          AppStrings.noMovieWatchList,
                          style: AppStyles.bodyMedium,

                        ),
                      ),
                    ],
                  );
                }
                return Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return WatchListItem(watchListModel: films[index]);
                    },
                    itemCount: films.length,
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
