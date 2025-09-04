import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';

import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/constants.dart';
import '../../config/internet_connectivity.dart';
import '../../data/model/task/task_model.dart';
import '../../data/repositories/Task/Task_repo.dart';
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

class TaskFavouriteScreen extends StatefulWidget {
  const TaskFavouriteScreen({super.key});

  @override
  State<TaskFavouriteScreen> createState() => _TaskFavouriteScreenState();
}

class _TaskFavouriteScreenState extends State<TaskFavouriteScreen>
    with TickerProviderStateMixin {
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

    BlocProvider.of<TaskBloc>(context).add(TaskDashBoardFavList(isFav: 1));
  }



  void _onDeleteTask(task) {
    context.read<TaskBloc>().add(DeleteTask(task));

    BlocProvider.of<TaskBloc>(context).add(AllTaskList());
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
    BlocProvider.of<TaskBloc>(context).add(TaskDashBoardFavList(isFav: 1));
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
        BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());

      }
    },
    child:Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: Container(
          color: Theme.of(context).colorScheme.backGroundColor,
          child: Column(children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: BackArrow(
                onTap: () {
                  print('fgdhgfdhfghf');
                  router.pop();
                  BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
                },
                // iSBackArrow: true,
                fromDash: false,
                title: AppLocalizations.of(context)!.favTask,
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
                      !speechHelper.isListening ? Icons.mic_off : Icons.mic,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.textFieldColor,
                    ),
                    onPressed: () {
                      if (speechHelper.isListening) {
                        speechHelper.stopListening();
                      } else {
                        speechHelper.startListening(
                            context, searchController, SearchPopUp());
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
                  child: context.read<PermissionsBloc>().isManageTask == true
                      ? BlocConsumer<TaskBloc, TaskState>(
                          listener: (context, state) {
                            if (state is TaskFavPaginated) {
                              isLoadingMore = false;
                              setState(() {});
                            }
                          },
                          builder: (context, state) {
                            print("dgfxgcjnvm $state");
                            if (state is TaskLoading) {
                              return const NotesShimmer();
                            } else if (state is TaskFavPaginated) {
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
                                          scrollInfo.metrics.maxScrollExtent &&
                                      isLoadingMore == false) {
                                    isLoadingMore = true;
                                    setState(() {});
                                    context.read<TaskBloc>().add(LoadMore(
                                        searchQuery: searchWord,
                                        projectId: [],
                                        clientId: [],
                                        userId: [],
                                        statusId: [],
                                     //   priorityId: [],
                                        fromDate: "",
                                        toDate: "",
                                        isFav: 1));
                                  }
                                  return false;
                                },
                                child: context
                                            .read<PermissionsBloc>()
                                            .isManageTask ==
                                        true
                                    ? state.task.isNotEmpty
                                        ? isLoading == true
                                            ? NotesShimmer()
                                            : ListView.builder(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 18.w),
                                                itemCount: state.hasReachedMax
                                                    ? state.task.length
                                                    : state.task.length + 1,
                                                itemBuilder: (context, index) {
                                                  if (index <
                                                      state.task.length) {
                                                    Tasks task =
                                                        state.task[index];
                                                    String? date;
                                                    if (task.createdAt !=
                                                        null) {
                                                      var dateCreated =
                                                          parseDateStringFromApi(
                                                              task.createdAt!);
                                                      date =
                                                          dateFormatConfirmed(
                                                              dateCreated,
                                                              context);
                                                    }
                                                    return index == 0
                                                        ? ShakeWidget(
                                                            child:
                                                                _listOfProject(
                                                                    task,
                                                                    isLightTheme,
                                                                    date,
                                                                    state.task,
                                                                    index))
                                                        : _listOfProject(
                                                            task,
                                                            isLightTheme,
                                                            date,
                                                            state.task,
                                                            index);
                                                  } else {
                                                    // Show a loading indicator when more notes are being loaded
                                                    return Padding(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          vertical: 0),
                                                      child: Center(
                                                        child: state
                                                                .hasReachedMax
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
                            } else if (state is TaskDeleteSuccess) {
                              if (mounted) {
                                flutterToastCustom(
                                    msg: AppLocalizations.of(context)!
                                        .deletedsuccessfully,
                                    color: AppColors.primary);
                              }
                              BlocProvider.of<TaskBloc>(context).add(TaskDashBoardFavList(isFav: 1));

                            } else if (state is TaskDeleteError) {
                              if (mounted) {
                                // flutterToastCustom(
                                //     msg:state.errorMessage,
                                //     color: AppColors.primary);
                              }
                              BlocProvider.of<TaskBloc>(context).add(TaskDashBoardFavList(isFav: 1));

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

  Widget _listOfProject(task, isLightTheme, date, statetask, index) {
    return Padding(
      padding:  EdgeInsets.symmetric(vertical: 10.h),
      child: InkWell(
        highlightColor: Colors.transparent, // No highlight on tap
        splashColor: Colors.transparent,
        onTap: () {
          List<String> username = [];
          for (var names in task.users!) {
            username.add(names.firstName!);
          }
          router.push(
            '/taskdetail',
            extra: {
              "id": task.id,
              // your list of LeaveRequests
            },
          );
        },
        child: Container(
            decoration: BoxDecoration(
                boxShadow: [
                  isLightTheme
                      ? MyThemes.lightThemeShadow
                      : MyThemes.darkThemeShadow,
                ],
                color: Theme.of(context).colorScheme.containerDark,
                borderRadius: BorderRadius.circular(12)),
            // height: 140.h,
            child:  Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(  // Replace Container(width: double.infinity)
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,

                              children: [
                                CustomText(
                                  text: "#${task.id.toString()}",
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
                                          task.pinned = task.pinned == 1 ? 0 : 1;
                                          TaskRepo().updateTaskPinned( id:statetask[index].id, isPinned: task.pinned,);
                                        });
                                        _pinnedcController.reverse().then((value) => _pinnedcController.forward());
                                      },
                                      child: Container(
                                          width: 40.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                                              ],
                                              color: Theme.of(context).colorScheme.backGroundColor,
                                              shape: BoxShape.circle),
                                          child: ScaleTransition(
                                            scale: Tween(begin: 0.7, end: 1.0).animate(
                                                CurvedAnimation(
                                                    parent: _pinnedcController, curve: Curves.easeOut)),
                                            child: Icon(
                                              task.pinned == 1
                                                  ? Icons.push_pin
                                                  : Icons.push_pin_outlined,
                                              size: 20,
                                              color: task.pinned == 1 ? Colors.blue : Colors.blue,
                                            ),
                                          )),
                                    ),
                                    InkWell(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onTap: () {
                                        setState(() {
                                          task.favorite = task.favorite == 1 ? 0 : 1;
                                          TaskRepo().updateTaskFavorite( id:task.id, isFavorite: task.favorite,);
                                        });
                                        _controller.reverse().then((value) => _controller.forward());
                                      },
                                      child: Container(
                                          width: 40.w,
                                          height: 30.h,
                                          decoration: BoxDecoration(
                                              boxShadow: [
                                                isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                                              ],
                                              color: Theme.of(context).colorScheme.backGroundColor,
                                              shape: BoxShape.circle),
                                          child: ScaleTransition(
                                            scale: Tween(begin: 0.7, end: 1.0).animate(
                                                CurvedAnimation(
                                                    parent: _controller, curve: Curves.easeOut)),
                                            child: Icon(
                                                task.favorite == 1
                                                    ? Icons.favorite
                                                    : Icons.favorite_border,
                                                size: 20,
                                                color: task.favorite == 1 ? Colors.red : Colors.red
                                            ),
                                          )),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            CustomText(
                              text: task.title!,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              size: 24.sp,
                              color: Theme.of(context).colorScheme.textClrChange,
                              fontWeight: FontWeight.w600,
                            ),
                            task.description != null
                                ? SizedBox(height: 8.h)
                                : SizedBox.shrink(),
                            task.description != null
                                ? SizedBox(
                              // height: 40.h,
                                width: double.infinity,
                                child: htmlWidget(task.description!,context,width:290.w,height: 36.h)
                            )
                                : SizedBox.shrink(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h,),
                Padding(  // Replace SizedBox with width: 300.w
                  padding: EdgeInsets.symmetric(horizontal: 20.h),
                  child: statusClientRow(task.status, task.priority, context, false),
                ),
                task.users!.isEmpty && task.clients!.isEmpty
                    ? SizedBox.shrink()
                    : Padding(
                  padding: EdgeInsets.only(top: 10.h, left: 18.w, right: 18.w),
                  child: SizedBox(
                    height: 60.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {

                              userClientDialog(
                                from: "user",
                                context: context,
                                title: AppLocalizations.of(context)!.allusers,
                                list: task.users!.isEmpty ? [] : task.users,
                              );
                            },
                            child: RowDashboard(list: task.users!, title: "user"),
                          ),
                        ),
                        task.users!.isEmpty
                            ? const SizedBox.shrink()
                            : SizedBox(width: 20.w),  // Reduced from 40.w to 20.w for better spacing
                        task.clients!.isEmpty
                            ? const SizedBox.shrink()
                            : Expanded(
                          child: InkWell(
                            onTap: () {
                              userClientDialog(
                                from: 'client',
                                context: context,
                                title: task.clients.isNotEmpty
                                    ? AppLocalizations.of(context)!
                                    .allclients
                                    : AppLocalizations.of(context)!
                                    .allclients,
                                list: task.clients.isEmpty ? [] : task.clients,
                              );
                            },
                            child: RowDashboard(
                              list: task.clients!,
                              title: "client",
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Divider(color: Theme.of(context).colorScheme.dividerClrChange),
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const HeroIcon(
                            HeroIcons.calendar,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor,
                          ),
                          SizedBox(width: 20.w),
                          CustomText(
                            text: date ?? "",
                            color: AppColors.greyColor,
                            size: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }
}
