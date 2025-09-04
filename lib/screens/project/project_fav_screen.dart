import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';

import '../../bloc/project/project_bloc.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../config/internet_connectivity.dart';
import '../../data/model/Project/all_project.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../../utils/widgets/shake_widget.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/no_permission_screen.dart';
import '../widgets/search_field.dart';
import '../widgets/speech_to_text.dart';
import '../widgets/user_client_box.dart';


class FavouriteScreen extends StatefulWidget {
  const FavouriteScreen({super.key});

  @override
  State<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends State<FavouriteScreen> with TickerProviderStateMixin{
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  late SpeechToTextHelper speechHelper;
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
  late final AnimationController _pinnedcController = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
  String searchWord = "";
  bool? isLoading = false;
  bool isLoadingMore = false;

  String? currency;
  String? currencyPosition;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  void _initializeApp() {
    searchController.addListener(() {
      setState(() {});
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          // context.read<ActivityLogBloc>().add(SearchActivityLog(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();


    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));
  }
  void _onDeleteProject({required int id}) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(id));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));
  }
  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        setState(() {
          _connectionStatus = results;
        });
        _initializeApp();
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results != "ConnectivityResult.none") {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
          _initializeApp();
        });
      }
    });
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
          // context.read<ActivityLogBloc>().add(SearchActivityLog(result));
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    super.initState();
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }
  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;


    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
      if (!didPop) {
        router.pop();
        BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());

      }
    },
    child:Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Container(
        color: Theme.of(context).colorScheme.backGroundColor,
        child: Column(
            children: [
        Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: BackArrow(
          onTap: (){
            print('fgdhgfdhfghf');
            router.pop();
            BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());

          },
          // iSBackArrow: true,
          fromDash: false,
          title: AppLocalizations.of(context)!.favProject,
        ),
              ),

        SizedBox(height: 20.h),
        CustomSearchField(
          isLightTheme: isLightTheme,
          controller: searchController,
          suffixIcon: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (searchController.text.isNotEmpty)
                SizedBox(
                  width: 20.w,
                  // color: AppColors.red,
                  child: IconButton(
                    highlightColor: Colors.transparent,
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.clear,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.textFieldColor,
                    ),
                    onPressed: () {
                      searchController.clear();
                      // context
                      //     .read<ProjectBloc>()
                      //     .add(SearchProject('', [], []));
                    },
                  ),
                ),
              IconButton(
                icon: Icon(
                  !speechHelper.isListening
                      ? Icons.mic_off
                      : Icons.mic,
                  size: 20.sp,
                  color:
                  Theme.of(context).colorScheme.textFieldColor,
                ),
                onPressed: () {
                  if (speechHelper.isListening) {
                    speechHelper.stopListening();
                  } else {
                    speechHelper.startListening(context, searchController, SearchPopUp());
                  }
                },
              ),
            ],
          ),
          onChanged: (value) {
            searchWord = value;
            // context.read<ProjectBloc>().add(SearchProject(value, [], []));
          },
        ),
              SizedBox(height: 20.h),
              Expanded(
                child: RefreshIndicator(
                    color: AppColors.primary, // Spinner color
                    backgroundColor:
                    Theme.of(context).colorScheme.backGroundColor,
                    onRefresh: _onRefresh,
                    child: context.read<PermissionsBloc>().isManageProject ==
                        true
                        ? BlocConsumer<ProjectBloc, ProjectState>(
                      listener: (context, state) {
                        if (state is ProjectPaginated) {
                          isLoadingMore = false;
                          setState(() {});
                        }
                      },
                      builder: (context, state) {
                        print("dgfxgcjnvm $state");
                        if (state is ProjectLoading) {
                          return const NotesShimmer();
                        } else if (state is ProjectFavPaginated) {
                          // Show notes list with pagination
                          return NotificationListener<ScrollNotification>(
                            onNotification: (scrollInfo) {
                              if (scrollInfo is ScrollStartNotification) {
                                FocusScope.of(context)
                                    .unfocus(); // Dismiss keyboard
                              }
                              // Check if the user has scrolled to the end and load more notes if needed
                              if (!state.hasReachedMax &&
                                  scrollInfo.metrics.pixels ==
                                      scrollInfo
                                          .metrics.maxScrollExtent &&
                                  isLoadingMore == false) {
                                isLoadingMore = true;
                                setState(() {});
                                context.read<ProjectBloc>().add(
                                    ProjectLoadMore(searchWord, [], []));
                              }
                              return false;
                            },
                            child: context
                                .read<PermissionsBloc>()
                                .isManageProject ==
                                true
                                ? state.project.isNotEmpty
                                ? isLoading == true ?NotesShimmer():ListView.builder(
                                padding: EdgeInsets.only(
                                    left: 18.w,
                                    right: 18.w,
                                    bottom: 70.h),
                                // physics: NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount: state.hasReachedMax
                                    ? state.project.length
                                    : state.project.length + 1,
                                itemBuilder: (context, index) {
                                  if (index <
                                      state.project.length) {
                                    ProjectModel project =
                                    state.project[index];
                                    String? date;

                                    if (project.startDate !=
                                        null) {
                                      date = formatDateFromApi(
                                          project.startDate!,
                                          context);
                                    }
                                    return index == 0
                                        ? ShakeWidget(
                                      child:projectList(
                                          state.project,
                                          index,
                                          project,
                                          date,
                                          isLightTheme))

                                        : projectList(
                                        state.project,
                                        index,
                                        project,
                                        date,
                                        isLightTheme);



                                  } else {
                                    // Show a loading indicator when more notes are being loaded
                                    return Padding(
                                      padding: const EdgeInsets
                                          .symmetric(vertical: 0),
                                      child: Center(
                                        child: state.hasReachedMax
                                            ? const Text('')
                                            : const SpinKitFadingCircle(
                                          color: AppColors
                                              .primary,
                                          size: 40.0,
                                        ),
                                      ),
                                    );
                                  }
                                })
                                : NoData(
                              isImage: true,
                            )
                                : NoPermission(),
                          );
                        } else if (state is ProjectError) {
                          // Show error message
                          return const NotesShimmer();
                        } else if (state is ProjectDeleteSuccess) {
                          if (mounted) {
                            flutterToastCustom(
                                msg: AppLocalizations.of(context)!.deletedsuccessfully,
                                color: AppColors.primary);
                            BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));

                          }
                        } else if (state is ProjectDeleteError) {
                          if (mounted) {
                            flutterToastCustom(
                                msg:state.errorMessage,
                                color: AppColors.primary);
                          }
                          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));

                        }
                        // Handle other states
                        return Container();
                      },
                    )
                        : const NoPermission()),
              ),
   
   
    ]),
    )));
  }
  Widget projectList(stateProject, index, project, date, isLightTheme) {
    return Padding(
      padding: EdgeInsets.only(top: 18.h),
      child: InkWell(
        onTap: () {
          router.push('/projectdetails',
              extra: {"id": stateProject[index].id, "from": "dashboard"});
        },
        child: Container(
          // height: 250.h,
          decoration: BoxDecoration(
              boxShadow: [
                isLightTheme
                    ? MyThemes.lightThemeShadow
                    : MyThemes.darkThemeShadow,
              ],
              color: Theme.of(context).colorScheme.containerDark,
              borderRadius: BorderRadius.circular(12)),
          width: double.infinity,
          // color: Colors.yellow,
          child: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      text: "#${project.id.toString()}",
                      size: 14.sp,
                      color: Theme.of(context).colorScheme.textClrChange,
                      fontWeight: FontWeight.w700,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              project.pinned =
                              project.pinned == 1 ? 0 : 1;
                              ProjectRepo().updateProjectPinned(
                                id: stateProject[index].id,
                                isPinned: project.pinned,
                              );
                            });
                            _pinnedcController.reverse().then(
                                    (value) => _pinnedcController.forward());
                          },
                          child: Container(
                              width: 40.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .backGroundColor,
                                  shape: BoxShape.circle),
                              child: ScaleTransition(
                                scale: Tween(begin: 0.7, end: 1.0)
                                    .animate(CurvedAnimation(
                                    parent: _pinnedcController,
                                    curve: Curves.easeOut)),
                                child: Icon(
                                  project.pinned == 1
                                      ? Icons.push_pin
                                      : Icons.push_pin_outlined,
                                  size: 20,
                                  color: project.pinned == 1
                                      ? Colors.blue
                                      : Colors.blue,
                                ),
                              )),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              project.favorite =
                              project.favorite == 1 ? 0 : 1;
                              ProjectRepo().updateProjectFavorite(
                                id: stateProject[index].id,
                                isFavorite: project.favorite,
                              );
                            });
                            _controller
                                .reverse()
                                .then((value) => _controller.forward());
                          },
                          child: Container(
                              width: 40.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                                  ],
                                  color: Theme.of(context)
                                      .colorScheme
                                      .backGroundColor,
                                  shape: BoxShape.circle),
                              child: ScaleTransition(
                                scale: Tween(begin: 0.7, end: 1.0)
                                    .animate(CurvedAnimation(
                                    parent: _controller,
                                    curve: Curves.easeOut)),
                                child: Icon(
                                  project.favorite == 1
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 20,
                                  color: project.favorite == 1
                                      ? Colors.red
                                      : Colors.red,
                                ),
                              )),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        HeroIcon(
                          HeroIcons.clipboardDocumentList,
                          style: HeroIconStyle.outline,
                          color: AppColors.primary,
                        ),
                        project.taskCount != null && project.taskCount > 1
                            ? CustomText(
                          text:
                          " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.tasksFromDrawer}",
                          size: 14.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : project.taskCount == 1
                            ? CustomText(
                          text:
                          " ${project.taskCount} ${AppLocalizations.of(context)!.task}",
                          size: 14.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        )
                            : CustomText(
                          text:
                          " 0 ${AppLocalizations.of(context)!.task}",
                          size: 14.sp,
                          color: Theme.of(context)
                              .colorScheme
                              .textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    project.budget != null && project.budget!.isNotEmpty
                        ? Row(
                      children: [
                        // CircleAvatar(
                        //   backgroundColor: Colors.transparent,
                        //   radius: 10.0,
                        //   child: Image.asset(
                        //     AppImages.budgetImage,
                        //     height: 50,
                        //   ),
                        // ),
                        Container(
                          alignment: Alignment.centerRight,
                          // color: Colors.teal,
                          // width: 100.w,
                          height: 40.h,
                          child: CustomText(
                            text:
                            " ${currency != null ? "$currency" : ""}${project.budget}",
                            size: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                        : SizedBox.shrink(),
                  ],
                ),
                Padding(
                  padding: EdgeInsets.only(top: 0.h),
                  child: SizedBox(
                    width: 300.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          alignment: Alignment.centerLeft,
                          // color: Colors.teal,
                          width: 200.w,
                          height: 40.h,
                          child: CustomText(
                            text: project.title!,
                            size: 24,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                            fontWeight: FontWeight.w700,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                project.description == null || project.description == ""
                    ? const SizedBox.shrink()
                    : SizedBox(
                  height: 5.h,
                ),
                project.description == null || project.description == ""
                    ? SizedBox()
                    : htmlWidget(project.description!, context,
                    height: 38.h),
                SizedBox(height: 5.h),
                SizedBox(
                  // color: Colors.red,
                  width: 300.w,
                  child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 0.h),
                      child: statusClientRow(project.status,
                          project.priority, context, false)),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 10.h),
                    child: SizedBox(
                      // color: Colors.tealAccent,
                      height: 60.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  userClientDialog(
                                      context: context,
                                      from: "user",
                                      isFrom: "homescreen",
                                      title: AppLocalizations.of(context)!
                                          .allusers,
                                      list: project.users.isEmpty
                                          ? []
                                          : project.users);
                                },
                                child: RowDashboard(
                                    list: project.users!, title: "user")),
                          ),
                          project.users!.isEmpty
                              ? const SizedBox.shrink()
                              : SizedBox(
                            width: 40.w,
                          ),
                          Expanded(
                            child: InkWell(
                                onTap: () {
                                  userClientDialog(
                                    context: context,
                                    from: "client",
                                    title: project.clients.isNotEmpty
                                        ? AppLocalizations.of(context)!
                                        .allclients
                                        : AppLocalizations.of(context)!
                                        .allclients,
                                    list: project.clients.isEmpty
                                        ? []
                                        : project.clients,
                                  );
                                },
                                child: RowDashboard(
                                    list: project.clients!,
                                    title: "client")),
                          )
                        ],
                      ),
                    )),
                date != null
                    ? Padding(
                  padding: EdgeInsets.only(top: 5.h),
                  child: Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 15.w,
                            // color: Colors.yellow,
                            child: const HeroIcon(
                              HeroIcons.calendar,
                              style: HeroIconStyle.outline,
                              // color: colors.blueColor,
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                          CustomText(
                            text: date,
                            size: 12.26,
                            fontWeight: FontWeight.w300,
                            color: Theme.of(context)
                                .colorScheme
                                .textClrChange,
                          ),
                        ],
                      ),
                    ],
                  ),
                )
                    : SizedBox.shrink(),
              ],
            ),
          ),
        ),
      ),
    );
    // return Stack(
    //     children: [
    //       Padding(
    //           padding: EdgeInsets.symmetric(vertical: 10.h),
    //           child: DismissibleCard(
    //             direction:
    //             context.read<PermissionsBloc>().isdeleteProject == true &&
    //                 context.read<PermissionsBloc>().iseditProject == true
    //                 ? DismissDirection.horizontal // Allow both directions
    //                 : context.read<PermissionsBloc>().isdeleteProject == true
    //                 ? DismissDirection.endToStart // Allow delete
    //                 : context.read<PermissionsBloc>().iseditProject == true
    //                 ? DismissDirection.startToEnd // Allow edit
    //                 : DismissDirection.none,
    //             title: stateProject[index].id.toString(),
    //             confirmDismiss: (DismissDirection direction) async {
    //               if (direction == DismissDirection.startToEnd) {
    //                 if (context.read<PermissionsBloc>().iseditProject == true) {
    //                   // Navigate to the edit page
    //                   List<String>? userList = [];
    //                   List<String>? clientList = [];
    //                   List<String>? tagList = [];
    //
    //                   if (project.users != null) {
    //                     for (var user in project.users!) {
    //                       userList.add(user.firstName!);
    //                     }
    //                   }
    //
    //                   if (project.clients != null) {
    //                     for (var client in project.clients!) {
    //                       clientList.add(client.firstName!);
    //                     }
    //                   }
    //
    //                   if (project.tags != null) {
    //                     for (var tag in project.tags!) {
    //                       tagList.add(tag.title!);
    //                     }
    //                   }
    //
    //                   router.push(
    //                     '/createproject',
    //                     extra: {
    //                       "id": project.id,
    //                       "isCreate": false,
    //                       "title": project.title,
    //                       "desc": project.description,
    //                       "start": project.startDate ?? "",
    //                       "end": project.endDate ?? "",
    //                       "budget": project.budget,
    //                       'priority': project.priority,
    //                       'priorityId': project.priorityId,
    //                       'statusId': project.statusId,
    //                       'note': project.note,
    //                       "clientNames": clientList,
    //                       "userNames": userList,
    //                       "tagNames": tagList,
    //                       "userId": project.userId,
    //                       "tagId": project.tagIds,
    //                       "canClientDiscuss": project.clientCanDiscuss,
    //                       "clientId": project.clientId,
    //                       "access": project.taskAccessibility,
    //                       'status': project.status,
    //                     },
    //                   );
    //
    //                   // Prevent the widget from being dismissed
    //                   return false;
    //                 } else {
    //                   // No edit permission, prevent swipe
    //                   return false;
    //                 }
    //               }
    //
    //               // Handle deletion confirmation
    //               if (direction == DismissDirection.endToStart) {
    //                 return await showDialog<bool>(
    //                   context: context,
    //                   builder: (context) {
    //                     return AlertDialog(
    //                       title:
    //                       Text(AppLocalizations.of(context)!.confirmDelete),
    //                       content:
    //                       Text(AppLocalizations.of(context)!.areyousure),
    //                       actions: [
    //                         TextButton(
    //                           onPressed: () =>
    //                               Navigator.of(context).pop(true), // Confirm
    //                           child: const Text('Delete'),
    //                         ),
    //                         TextButton(
    //                           onPressed: () =>
    //                               Navigator.of(context).pop(false), // Cancel
    //                           child: const Text('Cancel'),
    //                         ),
    //                       ],
    //                     );
    //                   },
    //                 ) ??
    //                     false; // Default to false if dialog is dismissed without action
    //               }
    //
    //               return false; // Default case for other directions
    //             },
    //             onDismissed: (DismissDirection direction) {
    //               if (direction == DismissDirection.endToStart &&
    //                   context.read<PermissionsBloc>().isdeleteProject == true) {
    //                 setState(() {
    //                   stateProject.removeAt(index);
    //                   _onDeleteProject(id: project.id);
    //                 });
    //               } else if (direction == DismissDirection.startToEnd &&
    //                   context.read<PermissionsBloc>().iseditProject == true) {}
    //             },
    //             dismissWidget: Padding(
    //               padding:  EdgeInsets.only(top: 18.h),
    //               child: InkWell(
    //                 onTap: () {
    //                   router.push('/projectdetails', extra: {
    //                     'from':"fav",
    //                     "id": stateProject[index].id,
    //                   });
    //                 },
    //                 child: Container(
    //                   // height: 250.h,
    //                   decoration: BoxDecoration(
    //                       boxShadow: [
    //                         isLightTheme
    //                             ? MyThemes.lightThemeShadow
    //                             : MyThemes.darkThemeShadow,
    //                       ],
    //                       color: Theme.of(context).colorScheme.containerDark,
    //                       borderRadius: BorderRadius.circular(12)),
    //                   width: double.infinity,
    //                   // color: Colors.yellow,
    //                   child: Padding(
    //                     padding:
    //                     EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
    //                     child: Column(
    //                       mainAxisAlignment: MainAxisAlignment.start,
    //                       crossAxisAlignment: CrossAxisAlignment.start,
    //                       children: [
    //                         Row(
    //                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                           children: [
    //                             CustomText(
    //                               text: "#${project.id.toString()}",
    //                               size: 14.sp,
    //                               color:
    //                               Theme.of(context).colorScheme.textClrChange,
    //                               fontWeight: FontWeight.w700,
    //                               maxLines: 1,
    //                               overflow: TextOverflow.ellipsis,
    //                             ),
    //
    //                             Row(
    //                               children: [
    //                                 HeroIcon(
    //                                   HeroIcons.clipboardDocumentList,
    //                                   style: HeroIconStyle.outline,
    //                                   color: AppColors.primary,
    //                                 ),
    //                                 project.taskCount != null &&
    //                                     project.taskCount > 1
    //                                     ? CustomText(
    //                                   text:
    //                                   " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.tasksFromDrawer}",
    //                                   size: 14.sp,
    //                                   color: Theme.of(context)
    //                                       .colorScheme
    //                                       .textClrChange,
    //                                   fontWeight: FontWeight.w700,
    //                                   maxLines: 1,
    //                                   overflow: TextOverflow.ellipsis,
    //                                 )
    //                                     : project.taskCount == 1
    //                                     ? CustomText(
    //                                   text:
    //                                   " ${project.taskCount} ${AppLocalizations.of(context)!.task}",
    //                                   size: 14.sp,
    //                                   color: Theme.of(context)
    //                                       .colorScheme
    //                                       .textClrChange,
    //                                   fontWeight: FontWeight.w700,
    //                                   maxLines: 1,
    //                                   overflow: TextOverflow.ellipsis,
    //                                 )
    //                                     : CustomText(
    //                                   text:
    //                                   " 0 ${AppLocalizations.of(context)!.task}",
    //                                   size: 14.sp,
    //                                   color: Theme.of(context)
    //                                       .colorScheme
    //                                       .textClrChange,
    //                                   fontWeight: FontWeight.w700,
    //                                   maxLines: 1,
    //                                   overflow: TextOverflow.ellipsis,
    //                                 ),
    //                               ],
    //                             ),
    //                           ],
    //                         ),
    //                         Padding(
    //                           padding: EdgeInsets.only(top: 0.h),
    //                           child: SizedBox(
    //                             width: 300.w,
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                               children: [
    //                                 Container(
    //                                   alignment: Alignment.centerLeft,
    //                                   // color: Colors.teal,
    //                                   width: 200.w,
    //                                   height: 40.h,
    //                                   child: CustomText(
    //                                     text: project.title!,
    //                                     size: 24,
    //                                     color: Theme.of(context)
    //                                         .colorScheme
    //                                         .textClrChange,
    //                                     fontWeight: FontWeight.w700,
    //                                     maxLines: 1,
    //                                     overflow: TextOverflow.ellipsis,
    //                                   ),
    //                                 ),
    //                                 project.budget != null &&
    //                                     project.budget!.isNotEmpty
    //                                     ? Container(
    //                                   alignment: Alignment.centerRight,
    //                                   // color: Colors.teal,
    //                                   width: 100.w,
    //                                   height: 40.h,
    //                                   child: CustomText(
    //                                     text:
    //                                     "${currency != null ? "$currency" : ""}${project.budget}",
    //                                     size: 14,
    //                                     color: Theme.of(context)
    //                                         .colorScheme
    //                                         .textClrChange,
    //                                     fontWeight: FontWeight.w700,
    //                                     maxLines: 1,
    //                                     overflow: TextOverflow.ellipsis,
    //                                   ),
    //                                 )
    //                                     : SizedBox.shrink(),
    //                               ],
    //                             ),
    //                           ),
    //                         ),
    //                         project.description == null || project.description == ""
    //                             ? const SizedBox.shrink()
    //                             : SizedBox(
    //                           height: 5.h,
    //                         ),
    //                         project.description == null || project.description == ""
    //                             ? SizedBox()
    //                             : htmlWidget(project.description!, context,
    //                             height: 38.h),
    //                         SizedBox(height: 5.h),
    //                         SizedBox(
    //                           // color: Colors.red,
    //                           width: 300.w,
    //                           child: Padding(
    //                               padding: EdgeInsets.symmetric(vertical: 0.h),
    //                               child: statusClientRow(project.status,
    //                                   project.priority, context, false)),
    //                         ),
    //                         Padding(
    //                             padding: EdgeInsets.only(top: 10.h),
    //                             child: SizedBox(
    //                               // color: Colors.tealAccent,
    //                               height: 60.h,
    //                               child: Row(
    //                                 mainAxisAlignment:
    //                                 MainAxisAlignment.spaceBetween,
    //                                 crossAxisAlignment: CrossAxisAlignment.start,
    //                                 children: [
    //                                   Expanded(
    //                                     child: InkWell(
    //                                         onTap: () {
    //                                           userClientDialog(
    //                                               context: context,
    //                                               from: "user",
    //                                               isFrom: "homescreen",
    //                                               title:
    //                                               AppLocalizations.of(context)!
    //                                                   .allusers,
    //                                               list: project.users.isEmpty
    //                                                   ? []
    //                                                   : project.users);
    //                                         },
    //                                         child: RowDashboard(
    //                                             list: project.users!,
    //                                             title: "user")),
    //                                   ),
    //                                   project.users!.isEmpty
    //                                       ? const SizedBox.shrink()
    //                                       : SizedBox(
    //                                     width: 40.w,
    //                                   ),
    //                                   Expanded(
    //                                     child: InkWell(
    //                                         onTap: () {
    //                                           userClientDialog(
    //                                             context: context,
    //                                             from: "client",
    //                                             title: project.clients.isNotEmpty
    //                                                 ? AppLocalizations.of(context)!
    //                                                 .allclients
    //                                                 : AppLocalizations.of(context)!
    //                                                 .allclients,
    //                                             list: project.clients.isEmpty
    //                                                 ? []
    //                                                 : project.clients,
    //                                           );
    //                                         },
    //                                         child: RowDashboard(
    //                                             list: project.clients!,
    //                                             title: "client")),
    //                                   )
    //                                 ],
    //                               ),
    //                             )),
    //                         date != null
    //                             ? Padding(
    //                           padding: EdgeInsets.only(top: 5.h),
    //                           child: Row(
    //                             children: [
    //                               SizedBox(
    //                                 width: 15.w,
    //                                 // color: Colors.yellow,
    //                                 child: const HeroIcon(
    //                                   HeroIcons.calendar,
    //                                   style: HeroIconStyle.outline,
    //                                   // color: colors.blueColor,
    //                                 ),
    //                               ),
    //                               SizedBox(
    //                                 width: 5.w,
    //                               ),
    //                               CustomText(
    //                                 text: date,
    //                                 size: 12.26,
    //                                 fontWeight: FontWeight.w300,
    //                                 color: Theme.of(context)
    //                                     .colorScheme
    //                                     .textClrChange,
    //                               )
    //                             ],
    //                           ),
    //                         )
    //                             : SizedBox.shrink(),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //               ),
    //             ),
    //           )),
    //       Positioned(
    //         right: 3.w,
    //         top: 5.h,
    //         child: Row(
    //           children: [
    //             GlowContainer(
    //                 shape: BoxShape.circle,
    //                 glowColor:
    //                 Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
    //
    //                 child: InkWell(
    //                   onTap: () {
    //                     setState(() {
    //                       project.pinned = project.pinned == 1 ? 0 : 1;
    //                       ProjectRepo().updateProjectPinned( id:stateProject.id, isPinned: project.pinned,);
    //                     });
    //                     _pinnedcController.reverse().then((value) => _pinnedcController.forward());
    //                   },
    //                   child: Container(
    //                       width: 40.w,
    //                       height: 30.h,
    //                       decoration: BoxDecoration(
    //                           color: Theme.of(context).colorScheme.backGroundColor,
    //                           shape: BoxShape.circle),
    //                       child: ScaleTransition(
    //                         scale: Tween(begin: 0.7, end: 1.0).animate(
    //                             CurvedAnimation(
    //                                 parent: _pinnedcController, curve: Curves.easeOut)),
    //                         child: Icon(
    //                           project.pinned == 1
    //                               ? Icons.push_pin
    //                               : Icons.push_pin_outlined,
    //                           size: 20,
    //                           color: project.pinned == 1 ? Colors.red : Colors.grey,
    //                         ),
    //                       )),
    //                 )),
    //             GlowContainer(
    //                 shape: BoxShape.circle,
    //                 glowColor:
    //                 Theme.of(context).colorScheme.primary.withValues(alpha: 0.6),
    //
    //                 child: InkWell(
    //                   onTap: () {
    //                     setState(() {
    //                       project.favorite = project.favorite == 1 ? 0 : 1;
    //                       ProjectRepo().updateProjectFavorite( id:stateProject[index].id, isFavorite: project.favorite,);
    //
    //                     });
    //                     _controller.reverse().then((value) => _controller.forward());
    //                     isLoading = true;
    //                     BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardFavList(isFav: 1));
    //                     isLoading = false;
    //
    //                   },
    //                   child: Container(
    //                       width: 40.w,
    //                       height: 30.h,
    //                       decoration: BoxDecoration(
    //                           color: Theme.of(context).colorScheme.backGroundColor,
    //                           shape: BoxShape.circle),
    //                       child: ScaleTransition(
    //                         scale: Tween(begin: 0.7, end: 1.0).animate(
    //                             CurvedAnimation(
    //                                 parent: _controller, curve: Curves.easeOut)),
    //                         child: Icon(
    //                           project.favorite == 1
    //                               ? Icons.favorite
    //                               : Icons.favorite_border,
    //                           size: 20,
    //                           color: project.favorite == 1 ? Colors.red : Colors.grey,
    //                         ),
    //                       )),
    //                 )),
    //           ],
    //         ),
    //       )]);
  }
}
