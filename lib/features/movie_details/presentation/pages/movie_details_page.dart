import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:route_movie_app/core/components/reusable_components/Container_movie.dart';
import 'package:route_movie_app/core/components/reusable_components/movie_list_widget.dart';
import 'package:route_movie_app/core/firebase/firebase_functions.dart';
import 'package:route_movie_app/core/utils/app_colors.dart';
import 'package:route_movie_app/features/movie_details/data/data_sources/remote/more_like_remote_ds_impl.dart';
import 'package:route_movie_app/features/movie_details/data/data_sources/remote/movie_details_remote_ds_impl.dart';
import 'package:route_movie_app/features/movie_details/data/repositories/more_like_repo_impl.dart';
import 'package:route_movie_app/features/movie_details/data/repositories/movie_details_repo_impl.dart';
import 'package:route_movie_app/features/movie_details/domain/use_cases/more_like_use_case.dart';
import 'package:route_movie_app/features/movie_details/domain/use_cases/movie_details_use_case.dart';
import 'package:route_movie_app/features/movie_details/presentation/widgets/container_genre_widget.dart';
import 'package:route_movie_app/features/movie_details/presentation/widgets/custom_stack_widget.dart';
import 'package:route_movie_app/features/movie_details/presentation/widgets/poster_widget.dart';
import 'package:route_movie_app/features/movie_details/presentation/widgets/vote_widget.dart';
import 'package:route_movie_app/features/watchList_tab/data/models/watch_list_model.dart';
import '../../../../core/components/reusable_components/custom_show_dialog.dart';
import '../../../../core/components/reusable_components/isWatchList_widget.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/styles.dart';
import '../../../home_tab/data/models/PopularFilmModel.dart';
import '../bloc/movie_details_bloc.dart';

class MovieDetailsPage extends StatefulWidget {
  const MovieDetailsPage({
    super.key,
  });

  @override
  State<MovieDetailsPage> createState() => _MovieDetailsPageState();
}

class _MovieDetailsPageState extends State<MovieDetailsPage> {
  WatchListModel? watchListModel;
  bool isInWatchList = false;

  @override
  void initState() {
    super.initState();
    checkIfInWatchList();
  }

  void checkIfInWatchList() async {
    bool exists =
        await FirebaseFunctions.checkIfFilmExists(watchListModel?.id ?? '');
    setState(() {
      isInWatchList = exists;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    var movieId = args['filmId'] as int;
    bool isWatchList = args['isWatchList'] ?? false;
    return BlocProvider(
      create: (context) => MovieDetailsBloc(
        MovieDetailsUseCase(
          MovieDetailsRepoImplement(
            MovieDetailsRemoteDSImpl(),
          ),
        ),
        MoreLikeUseCase(
          MoreLikeRepoImplement(
            MoreLikeRemoteDsImplement(),
          ),
        ),
      )
        ..add(
          GetMovieDetailsEvent(movieId),
        )
        ..add(
          MoreLikeMovieEvent(movieId),
        ),
      child: BlocConsumer<MovieDetailsBloc, MovieDetailsState>(
        listener: (context, state) {
          /* if (state.status == ScreenStatus.loading) {
            showDialog(
              context: context,
              builder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            );
          }*/
          if (state.status == ScreenStatus.failure) {
            showDialog(
              context: context,
              builder: (context) => Center(
                child: AlertDialog(
                  title: const Text(AppStrings.error),
                  content: Text(
                    state.failures?.message ?? AppStrings.wrong,
                  ),
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          WatchListModel model = WatchListModel(
            id: '${state.movieDetailsModel?.id ?? 0}',
            title: state.movieDetailsModel?.title ?? "",
            image:
                '${Constants.imagePath}${state.movieDetailsModel?.backdropPath ?? ""}',
            description: state.movieDetailsModel?.overview ?? "",
            releaseDate: state.movieDetailsModel?.releaseDate ?? "",
            movieId: state.movieDetailsModel?.id ?? 0,
            isWatchList: true,
          );
          return Scaffold(
            appBar: AppBar(
              title: Text(
                state.movieDetailsModel?.title ?? "",
                style: AppStyles.titleAppBar,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomStackWidget(
                  imageUrl:
                      '${Constants.imagePath}${state.movieDetailsModel?.backdropPath ?? ""}',
                ),
                Padding(
                  padding: EdgeInsets.only(left: 18.w, top: 13.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.movieDetailsModel?.title ?? "",
                        style: AppStyles.bodyMedium.copyWith(
                          fontSize: 18,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        state.movieDetailsModel?.releaseDate ?? "",
                        style: AppStyles.dateSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          PosterWidget(
                            posterUrl:
                                '${Constants.imagePath}${state.movieDetailsModel?.posterPath ?? ""}',
                            onTap: () async {
                              setState(() {
                                isWatchList = !isWatchList;
                                isInWatchList = !isInWatchList;
                              });
                              if (isWatchList || isInWatchList) {
                                await FirebaseFunctions.addWatchlist(
                                    watchListModel: model,
                                    onException: (e) {
                                      showDialog(
                                        context: context,
                                        builder: (context) => CustomShowDialog(
                                          dialogContent: e,
                                        ),
                                      );
                                    });
                              }
                            },
                            child: IsWatchList(
                              isWatchList: isInWatchList || isWatchList,
                            ),
                          ),
                          SizedBox(width: 11.w),
                          Expanded(
                            child: SizedBox(
                              width: 250.w,
                              height: 220.h,
                              child: Padding(
                                padding: EdgeInsets.only(right: 8.w),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: GridView.builder(
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 9.w,
                                          mainAxisSpacing: 7.h,
                                          childAspectRatio: 3,
                                        ),
                                        itemCount: state.movieDetailsModel
                                                ?.genres?.length ??
                                            0,
                                        itemBuilder: (context, index) {
                                          return ContainerGenreWidget(
                                            genreName: state.movieDetailsModel
                                                    ?.genres?[index].name ??
                                                "",
                                          );
                                        },
                                      ),
                                    ),
                                    SizedBox(
                                      height: 8.h,
                                    ),
                                    SizedBox(
                                      height: 120.h,
                                      child: SingleChildScrollView(
                                        child: Text(
                                          state.movieDetailsModel?.overview ??
                                              "",
                                          style: AppStyles.bodySmall.copyWith(
                                              color: AppColor.genreTextColor,
                                              height: 1.5),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 3.h,
                                    ),
                                    VoteWidget(
                                      voteAverage:
                                          "${state.movieDetailsModel?.voteAverage ?? 0.toStringAsFixed(2)}",
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 18.h,
                ),
                Expanded(
                  child: ContainerMovie(
                    text: "More Like This",
                    child: ListView.separated(
                      itemCount: state.moreLikeModel?.results?.length ?? 0,
                      scrollDirection: Axis.horizontal,
                      itemBuilder: (context, index) {
                        bool isInWatchListM = watchlistMovieIds.contains(
                            state.moreLikeModel?.results?[index].id ?? 0);

                        return MovieListWidget(

                          onClicked: () async {
                            setState(() {
                              isInWatchListM = !isInWatchListM;
                            });
                            toggleWatchlistStatus(
                                state.moreLikeModel?.results?[index].id ?? 0);
                            WatchListModel model = WatchListModel(
                                isWatchList: true,
                                id:
                                    '${state.moreLikeModel?.results?[index].id ?? 0}',
                                title: state
                                        .moreLikeModel?.results?[index].title ??
                                    '',
                                image:
                                    '${Constants.imagePath}${state.moreLikeModel?.results?[index].backdropPath ?? ''} ',
                                description: state.moreLikeModel
                                        ?.results?[index].overview ??
                                    '',
                                releaseDate: state.moreLikeModel
                                        ?.results?[index].releaseDate ??
                                    '',
                                movieId:
                                    state.moreLikeModel?.results?[index].id ??
                                        0);
                            if (isInWatchListM) {
                              await FirebaseFunctions.addWatchlist(
                                watchListModel: model,
                                onException: (e) {
                                  showDialog(
                                    context: context,
                                    builder: (context) => CustomShowDialog(
                                      dialogContent: e,
                                    ),
                                  );
                                },
                              );
                            }
                          }, movie: state.moreLikeModel?.results?[index]??Results(),
                          isWatchList: isInWatchListM,

                        );
                      },
                      separatorBuilder: (context, index) {
                        return SizedBox(
                          width: 14.w,
                        );
                      },
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
