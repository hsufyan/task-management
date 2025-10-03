import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:hive/hive.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/activity_log/activity_log_bloc.dart';
import 'package:taskify/bloc/activity_log/activity_log_event.dart';
import 'package:taskify/bloc/auth/auth_bloc.dart';
import 'package:taskify/bloc/auth/auth_event.dart';
import 'package:taskify/bloc/birthday/birthday_bloc.dart';
import 'package:taskify/bloc/birthday/birthday_event.dart';
import 'package:taskify/bloc/dashboard_stats/dash_board_stats_bloc.dart';
import 'package:taskify/bloc/dashboard_stats/dash_board_stats_event.dart';
import 'package:taskify/bloc/languages/language_switcher_bloc.dart';
import 'package:taskify/bloc/languages/language_switcher_event.dart';
import 'package:taskify/bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import 'package:taskify/bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import 'package:taskify/bloc/leave_request/leave_request_bloc.dart';
import 'package:taskify/bloc/leave_request/leave_request_event.dart';
import 'package:taskify/bloc/meeting/meeting_bloc.dart';
import 'package:taskify/bloc/meeting/meeting_event.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:taskify/bloc/notes/notes_event.dart';
import 'package:taskify/bloc/notifications/system_notification/notification_bloc.dart';
import 'package:taskify/bloc/notifications/system_notification/notification_event.dart';
import 'package:taskify/bloc/notifications/system_notification/notification_state.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/permissions/permissions_state.dart';
import 'package:taskify/bloc/project/project_bloc.dart';
import 'package:taskify/bloc/project/project_event.dart';
import 'package:taskify/bloc/project_filter/project_filter_bloc.dart';
import 'package:taskify/bloc/project_filter/project_filter_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/bloc/setting/settings_event.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/task/task_state.dart';
import 'package:taskify/bloc/todos/todos_bloc.dart';
import 'package:taskify/bloc/todos/todos_event.dart';
import 'package:taskify/bloc/user_profile/user_profile_bloc.dart';
import 'package:taskify/bloc/user_profile/user_profile_event.dart';
import 'package:taskify/bloc/user_profile/user_profile_state.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_bloc.dart';
import 'package:taskify/bloc/work_anniveresary/work_anniversary_event.dart';
import 'package:taskify/bloc/workspace/workspace_bloc.dart';
import 'package:taskify/bloc/workspace/workspace_event.dart';
import 'package:taskify/bloc/workspace/workspace_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/create_task_model.dart';
import 'package:taskify/data/repositories/Task/task_repo.dart';
import 'package:taskify/screens/dash_board/dashboard.dart';
import 'package:taskify/screens/home_screen/widgets/workspace_dialog.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../../bloc/priority_multi/priority_multi_bloc.dart';
import '../../bloc/priority_multi/priority_multi_event.dart';
import '../../bloc/priority_multi/priority_multi_state.dart';
import '../../bloc/project_multi/project_multi_bloc.dart';
import '../../bloc/project_multi/project_multi_event.dart';
import '../../bloc/project_multi/project_multi_state.dart';
import '../../bloc/status/status_bloc.dart';
import '../../bloc/status/status_event.dart';
import '../../bloc/status_multi/status_multi_bloc.dart';
import '../../bloc/status_multi/status_multi_event.dart';
import '../../bloc/status_multi/status_multi_state.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task_filter/task_filter_bloc.dart';
import '../../bloc/task_filter/task_filter_event.dart';
import '../../bloc/task_filter/task_filter_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../config/constants.dart';
import '../../data/localStorage/hive.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import 'dart:async';
import '../../bloc/priority/priority_state.dart';

import '../../bloc/user/user_state.dart';
import 'package:intl/intl.dart';

import '../widgets/custom_date.dart';
import '../widgets/html_widget.dart';
import '../widgets/search_field.dart';
import '../widgets/user_client_box.dart';

class AllTaskScreen extends StatefulWidget {
  const AllTaskScreen({super.key});

  @override
  State<AllTaskScreen> createState() => _AllTaskScreenState();
}

class _AllTaskScreenState extends State<AllTaskScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey globalKeyOne = GlobalKey();
  final GlobalKey globalKeyTwo = GlobalKey();
  final GlobalKey globalKeyThree = GlobalKey();

  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  late final AnimationController _controller = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
  late final AnimationController _pinnedcController = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Clients');
  String filterName = 'Clients';
  bool isLoading = true;
  bool isFirst = false;
  String searchword = "";
  String? searchValue = "";
  List<int> userSelectedId = [];
  List<int> userSelectedIdS = [];
  List<String> userSelectedname = [];
  List<int> clientSelectedIdS = [];
  List<String> clientSelectedname = [];
  List<int> prioritySelectedIdS = [];
  List<String> prioritySelectedname = [];
  List<int> projectSelectedIdS = [];
  List<String> projectSelectedname = [];
  List<int> statusSelectedIdS = [];
  List<String> statusSelectedname = [];
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _statusSearchController = TextEditingController();
  final TextEditingController _prioritySearchController =
      TextEditingController();
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _projectSearchController =
      TextEditingController();
  String? fromDate;
  String? toDate;

  bool isListening = false;
  bool dialogShown = false;
  bool clientSelected = false;
  bool clientDisSelected = false;
  bool priorityDisSelected = false;
  bool userDisSelected = false;
  bool projectDisSelected = false;
  bool statusDisSelected = false;
  bool dateDisSelected = false;
  bool userSelected = false;
  bool statusSelected = false;
  bool prioritySelected = false;
  bool projectSelected = false;
  bool dateSelected = false;

  int filterSelectedId = 0;
  int filterCount = 0;
  String filterSelectedNmae = "";

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  double level = 0.0;
  final List<String> filter = [
    'Clients',
    'Users',
    'Status',
    'Priorities',
    'Projects',
    'Date'
  ];

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  int? statusPending;

  String? role;
  String? photoWidget;
  String? email;
  String? roleInUser;
  String? firstNameUser;
  String? lastNameUSer;
  String? workSpaceTitle;
  bool projectChart = false;
  bool taskChart = false;
  bool isExpand = false;
  bool? isConnectedToInternet;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _todayTask();
    _initSpeech();
    _getRole();
    _initializeBlocs();
    getIsFirst();
  }

  void _initializeBlocs() {
   // context.read<FilterCountBloc>().add(ProjectResetFilterCount());
     context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());
      photoWidget = context.read<UserProfileBloc>().profilePic;
    context.read<UserProfileBloc>().add(ProfileListGet());
    // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    // BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    // statusPending = context.read<LeaveRequestBloc>().statusPending;
    // context.read<DashBoardStatsBloc>().totalTodos.toString();
    // context.read<DashBoardStatsBloc>().totalProject.toString();
    // context.read<DashBoardStatsBloc>().totalTask.toString();
    // context.read<DashBoardStatsBloc>().totaluser.toString();
    // context.read<DashBoardStatsBloc>().totalClient.toString();
    // context.read<DashBoardStatsBloc>().totalMeeting.toString();
    // BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    // BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    // BlocProvider.of<NotificationBloc>(context).add(UnreadNotificationCount());
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed && mounted) {
      BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    _pinnedcController.dispose();
    startsController.dispose();
    endController.dispose();
    searchController.dispose();
    _clientSearchController.dispose();
    _statusSearchController.dispose();
    _prioritySearchController.dispose();
    _userSearchController.dispose();
    _projectSearchController.dispose();
    sideBarController.dispose();
    super.dispose();
  }

  void _todayTask() {
    DateTime now = DateTime.now();
    fromDate = DateFormat('yyyy-MM-dd').format(now);
    DateTime oneWeekFromNow = now.add(const Duration(days: 7));
    toDate = DateFormat('yyyy-MM-dd').format(oneWeekFromNow);
  }

  void handleIsProjectChart(bool status) {
    setState(() {
      projectChart = status;
    });
  }

  void handleIsTaskChart(bool status) {
    setState(() {
      taskChart = status;
    });
  }

  void toggleDrawer(bool expanded) {
    setState(() {
      isExpand = expanded;
    });
  }

  Future<void> _getRole() async {
    role = await HiveStorage.getRole();
    setState(() {
      if (role == 'Client') {
        // Handle client-specific logic
      } else {
        BlocProvider.of<WorkAnniversaryBloc>(context)
            .add(WeekWorkAnniversaryList([], [], 7));
        BlocProvider.of<BirthdayBloc>(context).add(WeekBirthdayList(7, [], []));
        BlocProvider.of<LeaveReqDashboardBloc>(context)
            .add(WeekLeaveReqListDashboard([], 7));
      }
    });
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
      if (_lastWords.isEmpty) {
        dialogShown = false;
      }
    });
  }

  void _onDialogDismissed() {
    setState(() {
      dialogShown = false;
    });
  }

  void _startListening() async {
    if (!_speechToText.isListening && !dialogShown) {
      setState(() {
        dialogShown = true;
      });
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const SearchPopUp();
        },
      ).then((_) {
        _onDialogDismissed();
      });
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_En",
        pauseFor: const Duration(seconds: 3),
        onSoundLevelChange: soundLevelListener,
      );
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      searchController.text = _lastWords;
      if (_lastWords.isNotEmpty && dialogShown) {
        Navigator.pop(context);
        dialogShown = false;
      }
    });
    context.read<TaskBloc>().add(SearchTasks(_lastWords));
  }

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter;
    });
  }

  getIsFirst() async {
    isFirst = await HiveStorage.isFirstTime();
    setState(() {});
  }

  String? photo;

  void onDeleteTask(Tasks task) {
    print("[DEBUG] Triggering DeleteTask for task ID: ${task.id}");
    context.read<TaskBloc>().add(DeleteTask(task.id!));
  }

 
 
  Future<void> _onRefresh() async {
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
    return Future.delayed(const Duration(milliseconds: 500));
  }

 Widget _listOfProject(Tasks task, bool isLightTheme, String? date,
    List<Tasks> statetask, int index) {
  print(
      "[DEBUG] Rendering task ID: ${task.id}, title: ${task.title}, users: ${task.users}, clients: ${task.clients}, pinned: ${task.pinned}, favorite: ${task.favorite}, statusId: ${task.statusId}");
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 10.h),
    child: DismissibleCard(
      direction: role == 'admin'
          ? DismissDirection.horizontal
          : DismissDirection.none,
      title: task.id.toString(),
      confirmDismiss: (DismissDirection direction) async {
        print(
            "[DEBUG] Dismiss direction: $direction for task ID: ${task.id}");
        if (direction == DismissDirection.endToStart && role == 'admin') {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r)),
                backgroundColor:
                    Theme.of(context).colorScheme.alertBoxBackGroundColor,
                title: Text(AppLocalizations.of(context)!.confirmDelete),
                content: Text(AppLocalizations.of(context)!.areyousure),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text(AppLocalizations.of(context)!.delete),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(AppLocalizations.of(context)!.cancel),
                  ),
                ],
              );
            },
          );
          return result ?? false;
        } else if (direction == DismissDirection.startToEnd &&
            role == 'admin') {
          onEditTask(task);
          return false;
        }
        return false;
      },
      onDismissed: (DismissDirection direction) {
        print(
            "[DEBUG] onDismissed triggered for task ${task.id}, direction: $direction");
        if (direction == DismissDirection.endToStart && role == 'admin') {
          print("[DEBUG] Deleting task ${task.id}");
          onDeleteTask(task);
        }
      },
      dismissWidget: InkWell(
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        onTap: () {
          print(
              "[DEBUG] onTap triggered for task ID: ${task.id}, title: ${task.title}");
          print("[DEBUG] Router: $router, Context: $context");
          router.push(
            '/taskdetail',
            extra: {
              "task": task, // Pass the entire Tasks object
              "from": "dashboard",
            },
          ).then((_) {
            print("[DEBUG] Navigation to /taskdetail completed");
          }).catchError((error) {
            print("[DEBUG] Navigation error: $error");
          });
        },
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                text: "#${task.id.toString()}",
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
                          CustomText(
                            text: task.title ?? 'Untitled',
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            size: 24.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                            fontWeight: FontWeight.w600,
                          ),
                          task.description != null
                              ? SizedBox(height: 8.h)
                              : const SizedBox.shrink(),
                          task.description != null
                              ? SizedBox(
                                  width: double.infinity,
                                  child: htmlWidget(
                                      task.description!, context,
                                      width: 290.w, height: 36.h),
                                )
                              : const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                child: statusClientRow(
                    task.status ?? 'Unknown', task.priority, context, isLightTheme),
              ),
              (task.users?.isEmpty ?? true) && (task.clients?.isEmpty ?? true)
                  ? const SizedBox.shrink()
                  : Padding(
                      padding:
                          EdgeInsets.only(top: 10.h, left: 18.w, right: 18.w),
                      child: SizedBox(
                        height: 60.h,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  print(
                                      "[DEBUG] Showing user dialog for task ${task.id}");
                                  userClientDialog(
                                    from: "user",
                                    context: context,
                                    title: AppLocalizations.of(context)!.allusers,
                                    list: task.users ?? [],
                                  );
                                },
                                child: RowDashboard(
                                    list: task.users ?? [], title: "user"),
                              ),
                            ),
                            task.users?.isEmpty ?? true
                                ? const SizedBox.shrink()
                                : SizedBox(width: 20.w),
                            task.clients?.isEmpty ?? true
                                ? const SizedBox.shrink()
                                : Expanded(
                                    child: InkWell(
                                      onTap: () {
                                        print(
                                            "[DEBUG] Showing client dialog for task ${task.id}");
                                        userClientDialog(
                                          from: 'client',
                                          context: context,
                                          title: task.clients?.isNotEmpty ?? false
                                              ? AppLocalizations.of(context)!
                                                  .allclients
                                              : AppLocalizations.of(context)!
                                                  .allclients,
                                          list: task.clients ?? [],
                                        );
                                      },
                                      child: RowDashboard(
                                          list: task.clients ?? [],
                                          title: "client"),
                                    ),
                                  ),
                          ],
                        ),
                      ),
                    ),
              Divider(color: Theme.of(context).colorScheme.dividerClrChange),
              Padding(
                padding:
                    EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const HeroIcon(HeroIcons.calendar,
                            style: HeroIconStyle.solid,
                            color: AppColors.blueColor),
                        SizedBox(width: 20.w),
                        CustomText(
                            text: date ?? "",
                            color: AppColors.greyColor,
                            size: 12,
                            fontWeight: FontWeight.w500),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
   @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return Scaffold(
      key: _scaffoldKey,
      drawer: isExpand ? _drawerIn() : _expandedDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h),
        child: AppBar(
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: isLightTheme ? Colors.transparent : Colors.black,
            statusBarIconBrightness:
                isLightTheme ? Brightness.dark : Brightness.light,
            statusBarBrightness:
                isLightTheme ? Brightness.light : Brightness.dark,
          ),
          backgroundColor: Colors.transparent,
          leadingWidth: 50.w,
          leading: Padding(
            padding: EdgeInsets.symmetric(horizontal: 0.w),
            child: GestureDetector(
              onTap: () => _scaffoldKey.currentState?.openDrawer(),
              child: SizedBox(
                width: 50.w,
                height: 30.h,
                child: HeroIcon(
                  HeroIcons.bars3BottomLeft,
                  style: HeroIconStyle.outline,
                  size: 20.sp,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
              ),
            ),
          ),
          // actions: [
          //   Padding(
          //     padding: EdgeInsets.symmetric(horizontal: 18.w),
          //     child: Row(
          //       children: [
          //         Stack(
          //           children: [
          //             GestureDetector(
          //               onTap: () => router.push("/notification"),
          //               child: SizedBox(
          //                 height: 50.h,
          //                 child: Padding(
          //                   padding: EdgeInsets.only(left: 5.w, right: 10.w),
          //                   child: HeroIcon(
          //                     HeroIcons.bell,
          //                     style: HeroIconStyle.outline,
          //                     size: 20.sp,
          //                     color:
          //                         Theme.of(context).colorScheme.textClrChange,
          //                   ),
          //                 ),
          //               ),
          //             ),
          //             Positioned(
          //               right: 5.w,
          //               top: 2.h,
          //               child:
          //                   BlocConsumer<NotificationBloc, NotificationsState>(
          //                 listener: (context, state) {
          //                   if (state is NotificationPaginated) {}
          //                 },
          //                 builder: (context, state) {
          //                   print(
          //                       "[DEBUG] Notification state: $state, totalUnreadCount: ${context.read<NotificationBloc>().totalUnreadCount}");
          //                   if (state is UnreadNotification) {
          //                     return state.total == 0
          //                         ? const SizedBox()
          //                         : Container(
          //                             height: 15.sp,
          //                             width: 15.sp,
          //                             decoration: BoxDecoration(
          //                                 shape: BoxShape.circle,
          //                                 color: Colors.yellow.shade800),
          //                             child: Center(
          //                               child: CustomText(
          //                                 size: 10,
          //                                 fontWeight: FontWeight.w600,
          //                                 text: state.total.toString(),
          //                                 color: AppColors.pureWhiteColor,
          //                               ),
          //                             ),
          //                           );
          //                   }
          //                   return const SizedBox();
          //                 },
          //               ),
          //             ),
          //           ],
          //         ),
          //         GestureDetector(
          //           onTap: () => _showLanguageDialog(context),
          //           child: SizedBox(
          //             height: 50.h,
          //             child: Padding(
          //               padding: EdgeInsets.only(left: 5.w, right: 5.w),
          //               child: HeroIcon(
          //                 HeroIcons.language,
          //                 style: HeroIconStyle.outline,
          //                 size: 20.sp,
          //                 color: Theme.of(context).colorScheme.textClrChange,
          //               ),
          //             ),
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ],
      
        ),
      ),
      floatingActionButton: role == 'admin'
          ? Padding(
              padding: EdgeInsets.only(bottom: 60.h),
              child: FloatingActionButton(
                isExtended: true,
                onPressed: () {
                  print("[DEBUG] FAB tapped, navigating to /createtask");
                  BlocProvider.of<UserBloc>(context).add(UserList());
                  BlocProvider.of<StatusBloc>(context).add(StatusList());
                  router.push('/createtask', extra: {
                    "id": 0,
                    "isCreate": true,
                    "title": "",
                    "desc": "",
                    "start": "",
                    "end": "",
                    "users": <String>[], // Empty list of usernames
                    "usersid": <int>[], // Empty list of user IDs
                    "priorityId": 0,
                    "statusId": 0,
                    "note": "",
                    "project": "",
                    "userList": <dynamic>[], // Empty list for user objects
                    "status": "",
                    "req":
                        <CreateTaskModel>[], // Placeholder, assumed to be defined
                  });
                },
                backgroundColor: AppColors.primary,
                child: const Icon(Icons.add, color: AppColors.whiteColor),
              ),
            )
          : const SizedBox(),
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Column(
        children: [
          SizedBox(height: 20.h),
          CustomSearchField(
            isLightTheme: isLightTheme,
            controller: searchController,
            suffixIcon: SizedBox(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (searchController.text.isNotEmpty)
                    SizedBox(
                      width: 20.w,
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
                          context.read<TaskBloc>().add(SearchTasks(""));
                        },
                      ),
                    ),
                  // SizedBox(
                  //   width: 30.w,
                  //   child: IconButton(
                  //     icon: Icon(
                  //       _speechToText.isNotListening
                  //           ? Icons.mic_off
                  //           : Icons.mic,
                  //       size: 20.sp,
                  //       color: Theme.of(context).colorScheme.textFieldColor,
                  //     ),
                  //     onPressed: () {
                  //       if (_speechToText.isNotListening) {
                  //         _startListening();
                  //       } else {
                  //         _stopListening();
                  //       }
                  //     },
                  //   ),
                  // ),
         
                  // BlocBuilder<TaskFilterCountBloc, TaskFilterCountState>(
                  //   builder: (context, state) {
                  //     return SizedBox(
                  //       width: 35.w,
                  //       child: Stack(
                  //         children: [
                  //           IconButton(
                  //             icon: HeroIcon(
                  //               HeroIcons.adjustmentsHorizontal,
                  //               style: HeroIconStyle.solid,
                  //               color: Theme.of(context)
                  //                   .colorScheme
                  //                   .textFieldColor,
                  //               size: 30.sp,
                  //             ),
                  //             onPressed: () {
                  //               BlocProvider.of<ClientBloc>(context)
                  //                   .add(ClientList());
                  //               BlocProvider.of<StatusMultiBloc>(context)
                  //                   .add(StatusMultiList());
                  //               BlocProvider.of<PriorityMultiBloc>(context)
                  //                   .add(PriorityMultiList());
                  //               BlocProvider.of<ProjectMultiBloc>(context)
                  //                   .add(ProjectMultiList());
                  //               BlocProvider.of<UserBloc>(context)
                  //                   .add(UserList());
                  //               _filterDialog(context, isLightTheme);
                  //             },
                  //           ),
                  //           if (state.count > 0)
                  //             Positioned(
                  //               right: 5.w,
                  //               top: 7.h,
                  //               child: Container(
                  //                 padding: EdgeInsets.zero,
                  //                 alignment: Alignment.center,
                  //                 height: 12.h,
                  //                 width: 10.w,
                  //                 decoration: const BoxDecoration(
                  //                   color: AppColors.primary,
                  //                   shape: BoxShape.circle,
                  //                 ),
                  //                 child: CustomText(
                  //                   text: state.count.toString(),
                  //                   color: Colors.white,
                  //                   size: 6,
                  //                   textAlign: TextAlign.center,
                  //                   fontWeight: FontWeight.bold,
                  //                 ),
                  //               ),
                  //             ),
                  //         ],
                  //       ),
                  //     );
                  //   },
                  // ),
                
                ],
              ),
            ),
            onChanged: (value) {
              searchword = value;
              context.read<TaskBloc>().add(SearchTasks(value));
            },
          ),
          SizedBox(height: 20.h),
          _taskBlocList(isLightTheme),
          SizedBox(height: 60.h),
        ],
      ),
    );
  }

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    setState(() {
      this.level = level;
    });
  }


 void onEditTask(Tasks task) {
    List<String> username = [];
    List<int> ids = [];
    if (task.users != null) {
      for (var names in task.users!) {
        username.add(names.firstName ?? 'Unknown');
        ids.add(names.id ?? 0);
      }
    }
    print(
        "[DEBUG] Navigating to edit task: ${task.id}, username: $username, ids: $ids, statusId: ${task.statusId}");
    router.push(
      '/createtask',
      extra: {
        "id": task.id ?? 0,
        "isCreate": false,
        "title": task.title ?? '',
        "users": username,
        "desc": task.description ?? '',
        "start": task.startDate ?? '',
        "end": task.dueDate ?? '',
        "usersid": ids,
        "statusId": task.statusId ?? 0,
        "note": task.note ?? '',
        "project": task.project ?? '',
        "userList": task.users ?? [],
        "status": task.status ?? '',
        "req": <CreateTaskModel>[],
      },
    );
  }


 void _showLanguageDialog(BuildContext context) {
    String? selectedLanguage =
        context.read<LanguageBloc>().state.locale.languageCode;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
          contentPadding: EdgeInsets.only(right: 10.w, bottom: 30.h),
          actionsPadding: EdgeInsets.only(right: 10.w, bottom: 30.h),
          title: Text(AppLocalizations.of(context)!.chooseLang),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 50.w,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('English',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'en',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('हिन्दी',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'hi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('عربي',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'ar',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('한국인',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'ko',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('베트남 사람',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'vi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                      RadioListTile<String>(
                        visualDensity: const VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: const Text('포르투갈 인',
                            style: TextStyle(
                                fontSize: 17, fontFamily: "Poppins-Bold")),
                        value: 'pt',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) =>
                            setState(() => selectedLanguage = value),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontFamily: "Poppins-Bold")),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.ok,
                  style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 16,
                      fontFamily: "Poppins-Bold")),
              onPressed: () {
                if (selectedLanguage != null) {
                  //   context.read<LanguageBloc>().add(ChangeLanguage(languageCode: selectedLanguage));
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


   Widget _taskBlocList(bool isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: BlocConsumer<TaskBloc, TaskState>(
          listener: (context, state) {
            print("[DEBUG] TaskBloc state: $state");
            if (state is TaskPaginated) {
              print(
                  "[DEBUG] TaskPaginated: ${state.task.length} tasks, hasReachedMax: ${state.hasReachedMax}");
            }
            if (state is TaskDeleteSuccess) {
              if (mounted) {
                flutterToastCustom(
                    msg: AppLocalizations.of(context)!.deletedsuccessfully,
                    color: AppColors.primary);
                BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
              }
            }
            if (state is TaskDeleteError) {
              if (mounted) {
                flutterToastCustom(msg: state.errorMessage);
              }
            }
          },
          builder: (context, state) {
            print("[DEBUG] Building with state: $state");
            if (state is TaskLoading) {
              print("[DEBUG] Showing NotesShimmer for TaskLoading");
              return const NotesShimmer();
            } else if (state is TaskPaginated) {
              return NotificationListener<ScrollNotification>(
                onNotification: (scrollInfo) {
                  print(
                      "[DEBUG] ScrollNotification: pixels=${scrollInfo.metrics.pixels}, maxScrollExtent=${scrollInfo.metrics.maxScrollExtent}");
                  if (scrollInfo is ScrollStartNotification) {
                    print("[DEBUG] Scroll started, dismissing keyboard");
                    FocusScope.of(context).unfocus();
                  }
                  if (!state.hasReachedMax &&
                      scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                    print("[DEBUG] Triggering LoadMore event");
                    print(
                        "[DEBUG] LoadMore params: searchValue=$searchValue, projectId=$projectSelectedIdS, clientId=$clientSelectedIdS, userId=$userSelectedIdS, statusId=$statusSelectedIdS, fromDate=$fromDate, toDate=$toDate");
                    context.read<TaskBloc>().add(LoadMore(
                          searchQuery: searchValue ?? '',
                          userId: userSelectedIdS,
                          statusId: statusSelectedIdS,
                          fromDate: fromDate,
                          toDate: toDate,
                        ));
                  }
                  return false;
                },
                child: state.task.isNotEmpty
                    ? ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        itemCount: state.hasReachedMax
                            ? state.task.length
                            : state.task.length + 1,
                        itemBuilder: (context, index) {
                          if (index < state.task.length) {
                            Tasks task = state.task[index];
                            String? date;
                            if (task.createdAt != null) {
                              print(
                                  "[DEBUG] Parsing date for task ${task.id}: ${task.createdAt}");
                              var dateCreated =
                                  parseDateStringFromApi(task.createdAt!);
                              date = dateFormatConfirmed(dateCreated, context);
                            } else {
                              print(
                                  "[DEBUG] task.createdAt is null for task ${task.id}");
                            }
                            return index == 0
                                ? ShakeWidget(
                                    child: _listOfProject(task, isLightTheme,
                                        date, state.task, index))
                                : _listOfProject(task, isLightTheme, date,
                                    state.task, index);
                          } else {
                            print(
                                "[DEBUG] Showing loading indicator for index $index");
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary, size: 40.0),
                              ),
                            );
                          }
                        },
                      )
                    : const NoData(isImage: true),
              );
            }
            print("[DEBUG] Returning empty Text for unhandled state: $state");
            return const Text("");
          },
        ),
      ),
    );
  }



  void _filterDialog(BuildContext context, isLightTheme) {
    showModalBottomSheet(
      backgroundColor: Theme.of(context).colorScheme.containerDark,
      context: context,
      isScrollControlled:
          true, // Allows the bottom sheet to take the full height
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize:
                MainAxisSize.min, // Minimize the size of the bottom sheet
            children: <Widget>[
              SizedBox(height: 10),
              // Title
              CustomText(
                text: AppLocalizations.of(context)!.selectfilter,
                color: AppColors.primary,
                size: 30.sp,
                fontWeight: FontWeight.bold,
              ),
              SizedBox(height: 20), // Spacing

              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      // color: Colors.red,
                      height: 600.h, // Set a specific height if needed
                      child: ListView.builder(
                        itemCount: filter.length,
                        itemBuilder: (BuildContext context, int index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                filterNameNotifier.value =
                                    filter[index]; // Update the ValueNotifier

                                filterName = filter[index];
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Container(
                                height: 50.h,
                                width: 100.w,
                                decoration: BoxDecoration(
                                  boxShadow: [
                                    isLightTheme
                                        ? MyThemesFilter.lightThemeShadow
                                        : MyThemesFilter.darkThemeShadow,
                                  ],
                                  color: Theme.of(context)
                                      .colorScheme
                                      .containerDark,
                                ),
                                child: Row(
                                  children: [
                                    ValueListenableBuilder<String>(
                                      valueListenable: filterNameNotifier,
                                      builder: (context, filterName, child) {
                                        return filterName == filter[index]
                                            ? Expanded(
                                                flex: 1,
                                                child: Container(
                                                  width: 2,
                                                  color: AppColors.primary,
                                                ),
                                              )
                                            : SizedBox.shrink();
                                      },
                                    ),
                                    Expanded(
                                      flex: 30,
                                      child: Center(
                                        child: Text(
                                          filter[index],
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                            fontSize: 15,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  // Vertical Divider

                  // Second Column (Placeholder for future content)
                  Expanded(
                    flex: 4,
                    child: ValueListenableBuilder<String>(
                      valueListenable: filterNameNotifier,
                      builder: (context, filterName, child) {
                        return _getFilteredWidget(filterName, isLightTheme);
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 5.h), // Spacing between content and buttons

              // Actions (Buttons)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
                child: SizedBox(
                  // color: Colors.red,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      InkWell(
                          onTap: () {
                            // Calculate and update filter count based on selections
                            if (clientSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'clients',
                                        isSelected: true),
                                  );
                            }
                            if (userSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'users', isSelected: true),
                                  );
                            }
                            if (statusSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'status', isSelected: true),
                                  );
                            }
                            if (prioritySelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'priorities',
                                        isSelected: true),
                                  );
                            }
                            if (projectSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'projects',
                                        isSelected: true),
                                  );
                            }
                            if (fromDate != null || toDate != null) {
                              context.read<TaskFilterCountBloc>().add(
                                    UpdateFilterCount(
                                        filterType: 'date', isSelected: true),
                                  );
                            }

                            // Apply filters to project dashboard
                            BlocProvider.of<TaskBloc>(context).add(
                                AllTaskListOnTask(
                                    projectId: projectSelectedIdS,
                                    clientId: clientSelectedIdS,
                                    userId: userSelectedIdS,
                                    statusId: statusSelectedIdS,
                                    priorityId: prioritySelectedIdS,
                                    fromDate: fromDate,
                                    toDate: toDate));

                            // Clear search controllers
                            _clientSearchController.clear();
                            _statusSearchController.clear();
                            _prioritySearchController.clear();
                            _userSearchController.clear();
                            _projectSearchController.clear();

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 35.h,
                            // width: 100.w,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.apply,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )),
                      SizedBox(
                        width: 20.w,
                      ),
                      InkWell(
                          onTap: () {
                            context
                                .read<TaskFilterCountBloc>()
                                .add(TaskResetFilterCount());
                            BlocProvider.of<TaskBloc>(context)
                                .add(AllTaskListOnTask());
                            projectSelectedIdS.clear();
                            clientSelectedIdS.clear();
                            userSelectedIdS.clear();
                            statusSelectedIdS.clear();
                            prioritySelectedIdS.clear();
                            searchController.text = '';
                            fromDate = "";
                            toDate = "";
                            _clientSearchController.clear();
                            _statusSearchController.clear();
                            _prioritySearchController.clear();
                            _userSearchController.clear();
                            _projectSearchController.clear();
                            filterCount = 0;
                            filterNameNotifier.value = 'Clients';

                            Navigator.of(context).pop();
                          },
                          child: Container(
                            height: 35.h,
                            // width: 100.w,
                            decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(15)),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 3.h),
                              child: Center(
                                child: CustomText(
                                  text: AppLocalizations.of(context)!.clear,
                                  size: 12.sp,
                                  color: AppColors.pureWhiteColor,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

//  Widget _taskBlocList(bool isLightTheme) {
//   return Expanded(
//     child: RefreshIndicator(
//       color: AppColors.primary, // Spinner color
//       backgroundColor: Theme.of(context).colorScheme.backGroundColor,
//       onRefresh: _onRefresh,
//       child: (context.read<PermissionsBloc>().isManageTask == true)
//           ? FutureBuilder(
//               future: Future.delayed(Duration(seconds: 1)), // Delay by 1 second
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState != ConnectionState.done) {
//                   print("[DEBUG] FutureBuilder: Waiting for delay");
//                   return const NotesShimmer(); // Show loading indicator
//                 }
//                 return BlocConsumer<TaskBloc, TaskState>(
//                   listener: (context, state) {
//                     print("[DEBUG] TaskBloc state: $state");
//                     if (state is TaskPaginated) {
//                       print("[DEBUG] TaskPaginated: ${state.task.length} tasks, hasReachedMax: ${state.hasReachedMax}");
//                     }
//                   },
//                   builder: (context, state) {
//                     print("[DEBUG] Building with state: $state");

//                     if (state is TaskLoading) {
//                       print("[DEBUG] Showing NotesShimmer for TaskLoading");
//                       return const NotesShimmer();
//                     } else if (state is TaskPaginated) {
//                       return NotificationListener<ScrollNotification>(
//                         onNotification: (scrollInfo) {
//                           print("[DEBUG] ScrollNotification: pixels=${scrollInfo.metrics.pixels}, maxScrollExtent=${scrollInfo.metrics.maxScrollExtent}");
//                           if (scrollInfo is ScrollStartNotification) {
//                             print("[DEBUG] Scroll started, dismissing keyboard");
//                             FocusScope.of(context).unfocus(); // Dismiss keyboard
//                           }
//                           if (!state.hasReachedMax &&
//                               scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
//                             print("[DEBUG] Triggering LoadMore event");
//                             print("[DEBUG] LoadMore params: searchValue=$searchValue, projectId=$projectSelectedIdS, clientId=$clientSelectedIdS, userId=$userSelectedIdS, statusId=$statusSelectedIdS, fromDate=$fromDate, toDate=$toDate");
//                             // Safely handle nullable searchValue
//                             context.read<TaskBloc>().add(LoadMore(
//                               searchQuery: searchValue ?? '', // Fallback to empty string
//                              // projectId: projectSelectedIdS,
//                             //  clientId: clientSelectedIdS,
//                               userId: userSelectedIdS,
//                               statusId: statusSelectedIdS,
//                               fromDate: fromDate,
//                               toDate: toDate,
//                             ));
//                           }
//                           return false;
//                         },
//                         child: state.task.isNotEmpty
//                             ? ListView.builder(
//                                 padding: EdgeInsets.symmetric(horizontal: 18.w),
//                                 itemCount: state.hasReachedMax
//                                     ? state.task.length
//                                     : state.task.length + 1,
//                                 itemBuilder: (context, index) {
//                                   if (index < state.task.length) {
//                                     Tasks task = state.task[index];
//                                     String? date;
//                                     if (task.createdAt != null) {
//                                       print("[DEBUG] Parsing date for task ${task.id}: ${task.createdAt}");
//                                       var dateCreated = parseDateStringFromApi(task.createdAt!);
//                                       date = dateFormatConfirmed(dateCreated, context);
//                                     } else {
//                                       print("[DEBUG] task.createdAt is null for task ${task.id}");
//                                     }
//                                     return index == 0
//                                         ? ShakeWidget(
//                                             child: _listOfProject(
//                                               task,
//                                               isLightTheme,
//                                               date,
//                                               state.task,
//                                               index,
//                                             ),
//                                           )
//                                         : _listOfProject(
//                                             task,
//                                             isLightTheme,
//                                             date,
//                                             state.task,
//                                             index,
//                                           );
//                                   } else {
//                                     print("[DEBUG] Showing loading indicator for index $index");
//                                     return Padding(
//                                       padding: const EdgeInsets.symmetric(vertical: 0),
//                                       child: Center(
//                                         child: state.hasReachedMax
//                                             ? const Text('')
//                                             : const SpinKitFadingCircle(
//                                                 color: AppColors.primary,
//                                                 size: 40.0,
//                                               ),
//                                       ),
//                                     );
//                                   }
//                                 },
//                               )
//                             : const NoData(isImage: true),
//                       );
//                     }

//                     print("[DEBUG] Returning empty Text for unhandled state: $state");
//                     return const Text("");
//                   },
//                 );
//               },
//             )
//           : const NoPermission(),
//     ),
//   );
// }

  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName.toLowerCase()) {
      case 'clients':
        return _clientLists(); // Show ClientList if filterName is "client"
      case 'users':
        return _userLists(); // Show UserList if filterName is "user"
      case 'projects':
        return _projectsLists();
      case 'status':
        return _statusLists();
      case 'priorities':
        return _priorityLists();
      case 'date':
        return _dateList(isLightTheme); // Show TagsList if filterName is "tags"
      default:
        return _clientLists(); // Default view
    }
  }

  Widget _dateList(isLightTheme) {
    return SizedBox(
      width: 200.w,
      height: 400.h,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DatePickerWidget(
              dateController: startsController,
              title: AppLocalizations.of(context)!.starts,
              onTap: () {
                showCustomDateRangePicker(
                  context,
                  dismissible: true,
                  minimumDate: DateTime(1900, 1, 1), // Very early date
                  maximumDate: DateTime(2100, 12, 31),
                  endDate: selectedDateEnds,
                  startDate: selectedDateStarts,
                  backgroundColor: Theme.of(context).colorScheme.containerDark,
                  primaryColor: AppColors.primary,
                  onApplyClick: (start, end) {
                    setState(() {
                      // If the end date is not selected or is null, set it to the start date
                      if (end.isBefore(start) || selectedDateEnds == null) {
                        end =
                            start; // Set the end date to the start date if not selected
                      }
                      selectedDateEnds = end;
                      selectedDateStarts = start;

                      startsController.text = DateFormat('MMMM dd, yyyy')
                          .format(selectedDateStarts);
                      endController.text =
                          DateFormat('MMMM dd, yyyy').format(selectedDateEnds!);
                      fromDate = DateFormat('yyyy-MM-dd').format(start);
                      toDate = DateFormat('yyyy-MM-dd').format(end);
                    });
                  },
                  onCancelClick: () {
                    setState(() {
                      // Handle cancellation if necessary
                    });
                  },
                );
              },
              isLightTheme: isLightTheme,
            ),
          ),
          SizedBox(
            height: 10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            child: DatePickerWidget(
              dateController: endController,
              title: AppLocalizations.of(context)!.ends,
              isLightTheme: isLightTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchFieldFilter(controller, onChanged) {
    return TextField(
      cursorColor: AppColors.greyForgetColor,
      cursorWidth: 1,
      // controller: _clientSearchController,
      controller: controller,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(
          vertical: (35.h - 30.sp) / 2,
          horizontal: 10.w,
        ),
        hintText: AppLocalizations.of(context)!.searchhere,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: AppColors.greyForgetColor, // Set your desired color here
            width: 1.0, // Set the border width if needed
          ),
          borderRadius:
              BorderRadius.circular(20.r), // Optional: adjust the border radius
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20.r),
          borderSide: BorderSide(
            color: AppColors.purple, // Border color when TextField is focused
            width: 1.0,
          ),
        ),
      ),
      onChanged: onChanged,
    );
  }

  Widget _clientLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
              height: 35.h,
              child: _searchFieldFilter(
                _clientSearchController,
                (value) {
                  context.read<ClientBloc>().add(SearchClients(value));
                },
              )),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<ClientBloc, ClientState>(builder: (context, state) {
          if (state is ClientLoading || state is ClientInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is ClientPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<ClientBloc>(context)
                      .add(ClientLoadMore(searchword));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.client.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.client.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.client.length) {
                            final isSelected = clientSelectedIdS
                                .contains(state.client[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    clientSelectedIdS
                                        .remove(state.client[index].id!);
                                    clientSelectedname
                                        .remove(state.client[index].firstName!);
                                    // If no clients are selected anymore, update filter count
                                    if (clientSelectedIdS.isEmpty) {
                                      context.read<TaskFilterCountBloc>().add(
                                            UpdateFilterCount(
                                              filterType: 'clients',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    if (!clientSelectedIdS
                                        .contains(state.client[index].id!)) {
                                      clientSelectedIdS
                                          .add(state.client[index].id!);
                                      clientSelectedname
                                          .add(state.client[index].firstName!);
                                      // Update filter count when first client is selected
                                      if (clientSelectedIdS.length == 1) {
                                        context.read<TaskFilterCountBloc>().add(
                                              UpdateFilterCount(
                                                filterType: 'clients',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                  }

                                  _onFilterSelected('client');
                                });
                                BlocProvider.of<ClientBloc>(context).add(
                                    SelectedClient(
                                        index, state.client[index].firstName!));
                                BlocProvider.of<ClientBloc>(context).add(
                                    ToggleClientSelection(
                                        state.client[index].id!,
                                        state.client[index].firstName!));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.w, vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 55.h,
                                  child: Center(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 0.w,
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            CircleAvatar(
                                              radius: 20,
                                              backgroundImage: NetworkImage(
                                                  state.client[index].profile!),
                                            ),
                                            SizedBox(
                                              width: 5.w,
                                            ), // Column takes up maximum available space
                                            Expanded(
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal: 0.w),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Flexible(
                                                          child: CustomText(
                                                            text: state
                                                                .client[index]
                                                                .firstName!,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            size: 18.sp,
                                                            color: isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                          ),
                                                        ),
                                                        SizedBox(width: 5.w),
                                                        Flexible(
                                                          child: CustomText(
                                                            text: state
                                                                .client[index]
                                                                .lastName!,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            size: 18.sp,
                                                            color: isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        Flexible(
                                                          child: CustomText(
                                                            text: state
                                                                .client[index]
                                                                .email!,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            maxLines: 1,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            size: 14.sp,
                                                            color: isSelected
                                                                ? AppColors
                                                                    .primary
                                                                : Theme.of(
                                                                        context)
                                                                    .colorScheme
                                                                    .textClrChange,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            // Spacer to push the icon to the far right
                                            if (isSelected) ...[
                                              SizedBox(
                                                  width: 8
                                                      .w), // Optional spacing between text and icon
                                              HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
                                            ]
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _statusLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
              height: 35.h,
              child: _searchFieldFilter(
                _statusSearchController,
                (value) {
                  context
                      .read<StatusMultiBloc>()
                      .add(SearchStatusMultis(value));
                },
              )),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<StatusMultiBloc, StatusMultiState>(
            builder: (context, state) {
          if (state is StatusMultiLoading || state is StatusMultiInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is StatusMultiPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<StatusMultiBloc>(context)
                      .add(StatusMultiLoadMore());
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.statusMulti.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.statusMulti.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.statusMulti.length) {
                            final isSelected = statusSelectedIdS
                                .contains(state.statusMulti[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                // userSelectedname.clear();
                                // userSelectedIdS.clear();
                                setState(() {
                                  if (isSelected) {
                                    statusDisSelected = true;
                                    statusSelectedIdS
                                        .remove(state.statusMulti[index].id!);
                                    statusSelectedname.remove(
                                        state.statusMulti[index].title!);
                                    // If no clients are selected anymore, update filter count
                                    if (statusSelectedIdS.isEmpty) {
                                      context.read<TaskFilterCountBloc>().add(
                                            UpdateFilterCount(
                                              filterType: 'status',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    if (!statusSelectedIdS.contains(
                                        state.statusMulti[index].id!)) {
                                      statusSelectedIdS
                                          .add(state.statusMulti[index].id!);
                                      statusSelectedname
                                          .add(state.statusMulti[index].title!);
                                      // Update filter count when first client is selected
                                      if (statusSelectedIdS.length == 1) {
                                        context.read<TaskFilterCountBloc>().add(
                                              UpdateFilterCount(
                                                filterType: 'status',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                  }

                                  _onFilterSelected('status');
                                });
                                BlocProvider.of<StatusMultiBloc>(context).add(
                                    SelectedStatusMulti(index,
                                        state.statusMulti[index].title!));
                                BlocProvider.of<StatusMultiBloc>(context).add(
                                    ToggleStatusMultiSelection(
                                        state.statusMulti[index].id!,
                                        state.statusMulti[index].title!));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 35.h,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 110.w,
                                            child: CustomText(
                                              text: state
                                                  .statusMulti[index].title!,
                                              fontWeight: FontWeight.w500,
                                              size: 18.sp,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          isSelected
                                              ? const HeroIcon(
                                                  HeroIcons.checkCircle,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.primary)
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _priorityLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: SizedBox(
              height: 35.h,
              child: _searchFieldFilter(
                _prioritySearchController,
                (value) {
                  context
                      .read<PriorityMultiBloc>()
                      .add(SearchPriorityMultis(value));
                },
              )),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<PriorityMultiBloc, PriorityMultiState>(
            builder: (context, state) {
          if (state is PriorityLoading || state is PriorityInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is PriorityMultiPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  BlocProvider.of<PriorityMultiBloc>(context)
                      .add(PriorityMultiLoadMore());
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.priorityMulti.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.priorityMulti.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.priorityMulti.length) {
                            final isSelected = prioritySelectedIdS
                                .contains(state.priorityMulti[index].id!);
                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    priorityDisSelected = true;
                                    prioritySelectedIdS
                                        .remove(state.priorityMulti[index].id!);
                                    prioritySelectedname.remove(
                                        state.priorityMulti[index].title!);
                                    userSelected = false;

                                    // If no users are selected anymore, update filter count
                                    if (prioritySelectedIdS.isEmpty) {
                                      context.read<TaskFilterCountBloc>().add(
                                            UpdateFilterCount(
                                              filterType: 'priorities',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    priorityDisSelected = false;
                                    if (!prioritySelectedIdS.contains(
                                        state.priorityMulti[index].id!)) {
                                      prioritySelectedIdS
                                          .add(state.priorityMulti[index].id!);
                                      prioritySelectedname.add(
                                          state.priorityMulti[index].title!);

                                      // Update filter count when first user is selected
                                      if (prioritySelectedIdS.length == 1) {
                                        context.read<TaskFilterCountBloc>().add(
                                              UpdateFilterCount(
                                                filterType: 'priorities',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId =
                                        state.priorityMulti[index].id!;
                                    filterSelectedNmae = "priorities";
                                  }
                                  // if (isSelected) {
                                  //   priorityDisSelected = true;
                                  //   prioritySelectedIdS.remove(state.priorityMulti[index].id!);
                                  //   prioritySelectedname.remove(state.priorityMulti[index].title!);
                                  //   prioritySelected=false;
                                  // }
                                  // else {
                                  //   priorityDisSelected = false;
                                  //   if (!prioritySelectedIdS
                                  //       .contains(state.priorityMulti[index].id!)) {
                                  //     prioritySelectedIdS
                                  //         .add(state.priorityMulti[index].id!);
                                  //     prioritySelectedname
                                  //         .add(state.priorityMulti[index].title!);
                                  //   }
                                  //   filterSelectedId = state.priorityMulti[index].id!;
                                  //   filterSelectedName = "priority";
                                  // }
                                  _onFilterSelected('priority');
                                });
                                BlocProvider.of<StatusMultiBloc>(context).add(
                                    SelectedStatusMulti(index,
                                        state.priorityMulti[index].title!));
                                BlocProvider.of<StatusMultiBloc>(context).add(
                                    ToggleStatusMultiSelection(
                                        state.priorityMulti[index].id!,
                                        state.priorityMulti[index].title!));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 35.h,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 110.w,
                                            child: CustomText(
                                              text: state
                                                  .priorityMulti[index].title!,
                                              fontWeight: FontWeight.w500,
                                              size: 18.sp,
                                              maxLines: 1,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          isSelected
                                              ? const HeroIcon(
                                                  HeroIcons.checkCircle,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.primary)
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.sp,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _projectsLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
              height: 35.h,
              child: _searchFieldFilter(
                _projectSearchController,
                (value) {
                  context
                      .read<ProjectMultiBloc>()
                      .add(SearchProjectMultis(value));
                },
              )),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<ProjectMultiBloc, ProjectMultiState>(
            builder: (context, state) {
          if (state is ProjectMultiLoading || state is ProjectMultiInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is ProjectMultiPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  BlocProvider.of<ProjectMultiBloc>(context)
                      .add(ProjectMultiLoadMore());
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.projectMulti.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.projectMulti.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.projectMulti.length) {
                            final isSelected = projectSelectedIdS
                                .contains(state.projectMulti[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                // userSelectedname.clear();
                                // userSelectedIdS.clear();

                                //
                                //
                                // if (isSelected) {
                                //   projectDisSelected = true;
                                //   projectSelectedIdS
                                //       .remove(state.projectMulti[index].id!);
                                //   projectSelectedname
                                //       .remove(state.projectMulti[index].title!);
                                // }
                                // else {
                                //   if (!projectSelectedIdS
                                //       .contains(state.projectMulti[index].id!)) {
                                //     projectSelectedIdS
                                //         .add(state.projectMulti[index].id!);
                                //     projectSelectedname
                                //         .add(state.projectMulti[index].title!);
                                //   }
                                //   filterSelectedId = state.projectMulti[index].id!;
                                //   filterSelectedNmae = "project";
                                // }
                                setState(() {
                                  if (isSelected) {
                                    userDisSelected = true;
                                    userSelectedIdS
                                        .remove(state.projectMulti[index].id!);
                                    userSelectedname.remove(
                                        state.projectMulti[index].title!);
                                    userSelected = false;

                                    // If no users are selected anymore, update filter count
                                    if (userSelectedIdS.isEmpty) {
                                      context.read<TaskFilterCountBloc>().add(
                                            UpdateFilterCount(
                                              filterType: 'projects',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    userDisSelected = false;
                                    if (!userSelectedIdS.contains(
                                        state.projectMulti[index].id!)) {
                                      userSelectedIdS
                                          .add(state.projectMulti[index].id!);
                                      userSelectedname.add(
                                          state.projectMulti[index].title!);

                                      // Update filter count when first user is selected
                                      if (userSelectedIdS.length == 1) {
                                        context.read<TaskFilterCountBloc>().add(
                                              UpdateFilterCount(
                                                filterType: 'projects',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId =
                                        state.projectMulti[index].id!;
                                    filterSelectedNmae = "users";
                                  }

                                  _onFilterSelected('project');
                                });
                                BlocProvider.of<ProjectMultiBloc>(context).add(
                                    SelectedProjectMulti(index,
                                        state.projectMulti[index].title!));
                                BlocProvider.of<ProjectMultiBloc>(context).add(
                                    ToggleProjectMultiSelection(
                                        state.projectMulti[index].id!,
                                        state.projectMulti[index].title!));
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 35.h,
                                  child: Center(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 10.w),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: 110.w,
                                            child: CustomText(
                                              text: state
                                                  .projectMulti[index].title!,
                                              fontWeight: FontWeight.w500,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              size: 18.sp,
                                              color: isSelected
                                                  ? AppColors.primary
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                            ),
                                          ),
                                          isSelected
                                              ? const HeroIcon(
                                                  HeroIcons.checkCircle,
                                                  style: HeroIconStyle.solid,
                                                  color: AppColors.primary)
                                              : const SizedBox.shrink(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _userLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
              height: 35.h,
              child: _searchFieldFilter(
                _userSearchController,
                (value) {
                  setState(() {
                    searchword = value;
                  });
                  context.read<UserBloc>().add(SearchUsers(value));
                },
              )),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<UserBloc, UserState>(builder: (context, state) {
          print("gxfcgcfhbv $state");
          if (state is UserLoading || state is UserInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is UserPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<UserBloc>(context)
                      .add(UserLoadMore(searchword));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.user.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.user.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.user.length) {
                            final isSelected =
                                userSelectedIdS.contains(state.user[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    userDisSelected = true;
                                    userSelectedIdS
                                        .remove(state.user[index].id!);
                                    userSelectedname
                                        .remove(state.user[index].firstName!);
                                    userSelected = false;

                                    // If no users are selected anymore, update filter count
                                    if (userSelectedIdS.isEmpty) {
                                      context.read<TaskFilterCountBloc>().add(
                                            UpdateFilterCount(
                                              filterType: 'users',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    userDisSelected = false;
                                    if (!userSelectedIdS
                                        .contains(state.user[index].id!)) {
                                      userSelectedIdS
                                          .add(state.user[index].id!);
                                      userSelectedname
                                          .add(state.user[index].firstName!);

                                      // Update filter count when first user is selected
                                      if (userSelectedIdS.length == 1) {
                                        context.read<TaskFilterCountBloc>().add(
                                              UpdateFilterCount(
                                                filterType: 'users',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId = state.user[index].id!;
                                    filterSelectedNmae = "users";
                                  }

                                  _onFilterSelected('users');
                                });
                                BlocProvider.of<UserBloc>(context).add(
                                    SelectedUser(
                                        index, state.user[index].firstName!));
                                BlocProvider.of<UserBloc>(context).add(
                                    ToggleUserSelection(state.user[index].id!,
                                        state.user[index].firstName!));
                                // context.read<ProjectBloc>().add(SearchProject("", filterSelectedId, filterSelectedNmae));
                                // Future.delayed(Duration(seconds: 1), () {
                                //   Navigator.pop(context);
                                // });

                                // userSelectedIdS.clear();
                                // userSelectedname.clear();
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 0.w, vertical: 2.h),
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppColors.purpleShade
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: isSelected
                                              ? AppColors.primary
                                              : Colors.transparent)),
                                  width: double.infinity,
                                  height: 55.h,
                                  child: Center(
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 0.w),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            // Column takes up maximum available space
                                            Expanded(
                                              child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 0.w),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      CircleAvatar(
                                                        radius: 20,
                                                        backgroundImage:
                                                            NetworkImage(state
                                                                .user[index]
                                                                .profile!),
                                                      ),
                                                      SizedBox(
                                                        width: 5.w,
                                                      ), // Column takes up maximum available space
                                                      Expanded(
                                                        child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      0.w),
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .firstName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                      width:
                                                                          5.w),
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .lastName!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          18.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              Row(
                                                                children: [
                                                                  Flexible(
                                                                    child:
                                                                        CustomText(
                                                                      text: state
                                                                          .user[
                                                                              index]
                                                                          .email!,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      size:
                                                                          14.sp,
                                                                      color: isSelected
                                                                          ? AppColors
                                                                              .primary
                                                                          : Theme.of(context)
                                                                              .colorScheme
                                                                              .textClrChange,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Spacer to push the icon to the far right
                                                    ],
                                                  )),
                                            ),
                                            // Spacer to push the icon to the far right
                                            if (isSelected) ...[
                                              SizedBox(
                                                  width: 8
                                                      .w), // Optional spacing between text and icon
                                              HeroIcon(
                                                HeroIcons.checkCircle,
                                                style: HeroIconStyle.solid,
                                                color: AppColors.purple,
                                              ),
                                            ]
                                          ],
                                        )),
                                  ),
                                ),
                              ),
                            );
                          } else {
                            // Show a loading indicator when more notes are being loaded
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 0),
                              child: Center(
                                child: state.hasReachedMax
                                    ? const Text('')
                                    : const SpinKitFadingCircle(
                                        color: AppColors.primary,
                                        size: 40.0,
                                      ),
                              ),
                            );
                          }
                        },
                      )
                    : NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _drawerIn() {
    return ClipRRect(
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(20.0),
          bottomRight: Radius.circular(20.0),
        ),
        child: Container(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          height: 680.h,
          child: Drawer(
            elevation: 0,
            // shadowColor: Colors.red,
            width: 62.w,
            // width: width * 0.63,
            backgroundColor: Theme.of(context).colorScheme.bgColorChange,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  BlocConsumer<WorkspaceBloc, WorkspaceState>(
                    listener: (context, state) {
                      if (state is WorkspacePaginated) {}
                    },
                    builder: (context, state) {
                      if (state is WorkspacePaginated) {
                        return InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return WorkSpaceDialog(work: state.workspace);
                              },
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.only(top: 20.h),
                            child: HeroIcon(
                              HeroIcons.square3Stack3d,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                              size: 20.sp,
                            ),
                          ),
                        );
                      }
                      return Padding(
                        padding: EdgeInsets.only(top: 30.h),
                        child: SizedBox(
                          child: HeroIcon(
                            HeroIcons.square3Stack3d,
                            style: HeroIconStyle.outline,
                            color: AppColors.greyColor,
                            size: 20.sp,
                          ),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  SizedBox(
                    height: 0.h,
                  ),
                  BlocConsumer<UserProfileBloc, UserProfileState>(
                      listener: (context, state) {
                    if (state is UserProfileSuccess) {
                      for (var data in state.profile) {
                        firstNameUser = data.firstName ?? "First Name";
                        lastNameUSer = data.lastName ?? "LastName";
                        email = data.email ?? "Email";

                        roleInUser = data.roleId.toString();
                        photoWidget = data.profile ?? "Photo";
                        role = data.role ?? "Role";
                      }
                    } else if (state is UserProfileError) {}
                  }, builder: (context, state) {
                    if (state is UserProfileSuccess) {
                      firstNameUser =
                          context.read<UserProfileBloc>().firstname ??
                              "First Name";
                      lastNameUSer = context.read<UserProfileBloc>().lastName ??
                          "LastName";
                      email = context.read<UserProfileBloc>().email ?? "Email";
                      // addressWidget = context.read<UserProfileBloc>().address ?? "Address";
                      // cityINWidget = context.read<UserProfileBloc>().city ?? "City";
                      roleInUser =
                          context.read<UserProfileBloc>().roleId.toString();
                      photoWidget =
                          context.read<UserProfileBloc>().profilePic ?? "Photo";
                      role = context.read<UserProfileBloc>().role ?? "Role";

                      return photoWidget == null
                          ? Padding(
                              padding: const EdgeInsets.only(top: 68),
                              child: SizedBox(
                                width: 30.w,
                                // alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 21.r,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  child: CircleAvatar(
                                    radius: 20.r, // Size of the profile image
                                    backgroundColor: Colors.grey[
                                        200], // Replace with your image URL
                                  ),
                                ),
                              ),
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 0.h),
                              child: SizedBox(
                                width: 30.w,
                                // alignment: Alignment.center,
                                child: CircleAvatar(
                                  radius: 25.r,
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  child: photoWidget != null
                                      ? CircleAvatar(
                                          radius:
                                              20.r, // Size of the profile image
                                          backgroundImage: photo != null ||
                                                  photoWidget != null
                                              ? NetworkImage(photoWidget!)
                                              : NetworkImage(photo!),
                                          backgroundColor: Colors.grey[
                                              200], // Replace with your image URL
                                        )
                                      : CircleAvatar(
                                          radius: 20.r,
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .backGroundColor,
                                          child: CircleAvatar(
                                            radius: 20
                                                .r, // Size of the profile image
                                            backgroundColor: Colors.grey[200],
                                            child: Icon(
                                              Icons.person,
                                              size: 20.sp,
                                              color: Colors.grey,
                                            ), // Replace with your image URL
                                          ),
                                        ),
                                ),
                              ),
                            );
                    }
                    // if (state is UserProfileLoading) {
                    //   return Positioned(
                    //       top: 200.h, left: 40.w, right: 40.w, child: const ProfileShimmer());
                    // }
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: SizedBox(
                        width: 50.w,
                        // alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor:
                              Theme.of(context).colorScheme.backGroundColor,
                          child: CircleAvatar(
                            radius: 25.r, // Size of the profile image
                            backgroundColor:
                                Colors.grey[200], // Replace with your image URL
                          ),
                        ),
                      ),
                    );
                  }),
                  SizedBox(
                    height: 15.h,
                  ),
                  BlocConsumer<PermissionsBloc, PermissionsState>(
                      listener: (context, state) {
                    // Handle side effects based on state changes here
                    if (state is PermissionsSuccess) {}
                  }, builder: (context, state) {
                    return Column(
                      children: [
                        context.read<PermissionsBloc>().isManageProject == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const DashBoard(
                                          initialIndex:
                                              1), // Navigate to index 1
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.wallet,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageTask == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const DashBoard(
                                          initialIndex:
                                              2), // Navigate to index 1
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    size: 26,
                                    HeroIcons.documentCheck,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageWorkspace ==
                                true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  // router.push('/notes');
                                  router.push('/workspaces',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.squares2x2,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context
                                    .read<PermissionsBloc>()
                                    .isManageSystemNotification ==
                                true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push("/notification");
                                  context
                                      .read<NotificationBloc>()
                                      .add(NotificationList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.bellAlert,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            context.read<TodosBloc>().add(const TodosList());
                            router.push("/todos");
                            router.pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.barsArrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                        context.read<PermissionsBloc>().isManageClient == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push("/client");
                                  BlocProvider.of<ClientBloc>(context)
                                      .add(ClientList());
                                  router.pop();
                                  // GoRouter.of(context).push('/client', extra: 'Client');
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.userGroup,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageUser == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push('/user');
                                  BlocProvider.of<UserBloc>(context)
                                      .add(UserList());
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.users,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            context.read<NotesBloc>().add(const NotesList());
                            router.push('/notes');
                            router.pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: const HeroIcon(
                              HeroIcons.newspaper,
                              style: HeroIconStyle.outline,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ),
                        role == "Client"
                            ? const SizedBox.shrink()
                            : InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push('/leaverequest',
                                      extra: {"fromNoti": false});
                                  // context.read<LeaveRequestBloc>().add(const LeaveRequestList("",0,[]));
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.arrowRightEndOnRectangle,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ),
                        context.read<PermissionsBloc>().isManageMeeting == true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  context
                                      .read<MeetingBloc>()
                                      .add(const MeetingLists());

                                  router.push('/meetings',
                                      extra: {"fromNoti": false});
                                  router.pop();
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.camera,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        context.read<PermissionsBloc>().isManageActivityLog ==
                                true
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push("/activitylog");
                                  BlocProvider.of<ActivityLogBloc>(context)
                                      .add(AllActivityLogList());
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.chartBar,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                        role == "admin"
                            ? InkWell(
                                splashColor: Colors.transparent,
                                onTap: () {
                                  router.push("/settings");
                                  BlocProvider.of<SettingsBloc>(context)
                                      .add(SettingsList('general_settings'));
                                  Navigator.pop(context);
                                },
                                child: Padding(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  child: const HeroIcon(
                                    HeroIcons.cog6Tooth,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    );
                  }),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      BlocProvider.of<AuthBloc>(context).add(LoggedOut(
                        context: context,
                      ));
                      router.pop();
                    },
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      child: const HeroIcon(
                        HeroIcons.arrowLeftStartOnRectangle,
                        style: HeroIconStyle.outline,
                        color: AppColors.greyColor,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20.h,
                  ),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        isExpand = !isExpand;
                      });
                    },
                    child: isExpand
                        ? Container(
                            height: 30.h,
                            width: 30.w,
                            decoration: const BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: AppColors.primary),
                            child: const HeroIcon(
                              size: 15,
                              HeroIcons.arrowRight,
                              style: HeroIconStyle.solid,
                              color: AppColors.pureWhiteColor,
                            ))
                        : Container(),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ));
  }

  Future<String?> getRole() async {
    Box box = await Hive.openBox('userBox');
    return box.get('role') as String? ??
        'member'; // Default to 'member' if null
  }

  Widget _expandedDrawer() {
    // Trigger LeaveRequestBloc to fetch pending leave requests
    BlocProvider.of<LeaveRequestBloc>(context)
        .add(const GetPendingLeaveRequest());
    statusPending = context.read<LeaveRequestBloc>().statusPending;

    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topRight: Radius.circular(20.0),
        bottomRight: Radius.circular(20.0),
      ),
      child: Drawer(
        elevation: 0,
        width: 250,
        backgroundColor: Theme.of(context).colorScheme.bgColorChange,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h),
                BlocConsumer<UserProfileBloc, UserProfileState>(
                  listener: (context, state) {
                    if (state is UserProfileSuccess) {
                      for (var data in state.profile) {
                        setState(() {
                          isLoading = true;
                          firstNameUser = data.firstName ?? "First Name";
                          lastNameUSer = data.lastName ?? "Last Name";
                          email = data.email ?? "Email";
                          roleInUser = data.roleId.toString();
                          photoWidget = data.profile;
                          role = data.role ?? "Role";
                        });
                      }
                    } else if (state is UserProfileError) {
                      // Handle error if needed
                    }
                  },
                  builder: (context, state) {
                    if (state is UserProfileSuccess) {
                      firstNameUser =
                          context.read<UserProfileBloc>().firstname ??
                              "First Name";
                      lastNameUSer = context.read<UserProfileBloc>().lastName ??
                          "Last Name";
                      email = context.read<UserProfileBloc>().email ?? "Email";
                      roleInUser =
                          context.read<UserProfileBloc>().roleId.toString();
                      photoWidget = context.read<UserProfileBloc>().profilePic;
                      role = context.read<UserProfileBloc>().role ?? "Role";

                      return Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 30.h),
                          state.profile.isNotEmpty
                              ? Row(
                                  children: [
                                    SizedBox(
                                      width: 60.w,
                                      child: CircleAvatar(
                                        radius: 25.r,
                                        backgroundImage: photoWidget != null
                                            ? NetworkImage(photoWidget!)
                                            : NetworkImage(photo!),
                                        backgroundColor: Colors.grey[200],
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(
                                  width: 60.w,
                                  child: CircleAvatar(
                                    radius: 26.r,
                                    backgroundColor: Colors.transparent,
                                    child: photoWidget != null
                                        ? CircleAvatar(
                                            radius: 25.r,
                                            backgroundImage:
                                                NetworkImage(photoWidget!),
                                            backgroundColor: Colors.grey[200],
                                          )
                                        : CircleAvatar(
                                            radius: 25.r,
                                            backgroundColor: Colors.grey[200],
                                            child: const Icon(
                                              Icons.person,
                                              color: Colors.grey,
                                            ),
                                          ),
                                  ),
                                ),
                          SizedBox(height: 10.h),
                          if (firstNameUser != null)
                            CustomText(
                              text: "$firstNameUser $lastNameUSer",
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          if (email != null)
                            CustomText(
                              text: email!,
                              size: 12,
                              color: AppColors.greyColor,
                            ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 60),
                      child: SizedBox(
                        width: 50.w,
                        child: CircleAvatar(
                          radius: 26.r,
                          backgroundColor:
                              Theme.of(context).colorScheme.backGroundColor,
                          child: CircleAvatar(
                            radius: 25.r,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                SizedBox(height: 12.h),
                FutureBuilder<String?>(
                  future: getRole(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return const Center(child: Text('Error loading role'));
                    }
                    final isAdmin = snapshot.data == 'admin';
                    final role = snapshot.data ??
                        'member'; // Use Hive role for leave requests

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Projects
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/dashboard',
                                  extra: {'initialIndex': 1});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.wallet,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.projects,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Tasks
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/dashboard',
                                  extra: {'initialIndex': 2});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    size: 26,
                                    HeroIcons.documentCheck,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .tasksFromDrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Statuses
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/Status");
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    size: 26,
                                    HeroIcons.square2Stack,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.statuses,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Priorities
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/priorities");
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    size: 26,
                                    HeroIcons.arrowUp,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .priorities,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Workspaces
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/workspaces',
                                  extra: {"fromNoti": false});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.squares2x2,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .workspaceFromDrawer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.red.shade300,
                                    ),
                                    child: Center(
                                      child: CustomText(
                                        size: 10,
                                        fontWeight: FontWeight.w600,
                                        text:
                                            "${context.read<WorkspaceBloc>().totalWorkspace ?? 0}",
                                        color: AppColors.pureWhiteColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Clients
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/clients");
                              context.read<ClientBloc>().add(ClientList());
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.userGroup,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .clientsFordrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Users
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/users");
                              context.read<UserBloc>().add(UserList());
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.users,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .usersFordrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Meetings
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              context
                                  .read<MeetingBloc>()
                                  .add(const MeetingLists());
                              router.push('/meetings',
                                  extra: {"fromNoti": false});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.camera,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.meetings,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Notifications
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            toggleDrawer(false);
                            router.push("/notification");
                            context
                                .read<NotificationBloc>()
                                .add(NotificationList());
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const HeroIcon(
                                      HeroIcons.bellAlert,
                                      style: HeroIconStyle.outline,
                                      color: AppColors.greyColor,
                                    ),
                                    SizedBox(width: 20.w),
                                    CustomText(
                                      text: AppLocalizations.of(context)!
                                          .notifications,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                    ),
                                  ],
                                ),
                                BlocConsumer<NotificationBloc,
                                    NotificationsState>(
                                  listener: (context, state) {
                                    if (state is NotificationPaginated) {}
                                  },
                                  builder: (context, state) {
                                    if (state is UnreadNotification) {
                                      return Container(
                                        height: 20,
                                        width: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.yellow.shade800,
                                        ),
                                        child: Center(
                                          child: CustomText(
                                            size: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            text: "${state.total}",
                                            color: AppColors.pureWhiteColor,
                                          ),
                                        ),
                                      );
                                    }
                                    return const SizedBox();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Todos
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            toggleDrawer(false);
                            context.read<TodosBloc>().add(const TodosList());
                            router.push("/todos");
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              children: [
                                const HeroIcon(
                                  HeroIcons.barsArrowUp,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.greyColor,
                                ),
                                SizedBox(width: 20.w),
                                CustomText(
                                  text: AppLocalizations.of(context)!.todos,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Notes
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            toggleDrawer(false);
                            context.read<NotesBloc>().add(const NotesList());
                            router.push('/notes');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              children: [
                                const HeroIcon(
                                  HeroIcons.newspaper,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.greyColor,
                                ),
                                SizedBox(width: 20.w),
                                CustomText(
                                  text: AppLocalizations.of(context)!.notes,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Leave Requests
                        if (role !=
                            "Client") // Using UserProfileBloc role for consistency with original code
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/leaverequest',
                                  extra: {"fromNoti": false});
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const HeroIcon(
                                        HeroIcons.arrowRightEndOnRectangle,
                                        style: HeroIconStyle.outline,
                                        color: AppColors.greyColor,
                                      ),
                                      SizedBox(width: 20.w),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .leaverequestsDrawer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: 20,
                                    width: 20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow.shade800,
                                    ),
                                    child: Center(
                                      child: CustomText(
                                        size: 10,
                                        fontWeight: FontWeight.w600,
                                        text: "${statusPending ?? 0}",
                                        color: AppColors.pureWhiteColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Activity Log
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/activitylog");
                              context
                                  .read<ActivityLogBloc>()
                                  .add(AllActivityLogList());
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.chartBar,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .activitylogs,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Settings
                        if (isAdmin)
                          InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/settings");
                              context
                                  .read<SettingsBloc>()
                                  .add(SettingsList("general_settings"));
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 10.h),
                              child: Row(
                                children: [
                                  const HeroIcon(
                                    HeroIcons.cog6Tooth,
                                    style: HeroIconStyle.outline,
                                    color: AppColors.greyColor,
                                  ),
                                  SizedBox(width: 20.w),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.settings,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Logout
                        InkWell(
                          splashColor: Colors.transparent,
                          onTap: () {
                            toggleDrawer(false);
                            context
                                .read<AuthBloc>()
                                .add(LoggedOut(context: context));
                            router.replace('/login');
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 10.h),
                            child: Row(
                              children: [
                                const HeroIcon(
                                  HeroIcons.arrowLeftStartOnRectangle,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.greyColor,
                                ),
                                SizedBox(width: 20.w),
                                CustomText(
                                  text: AppLocalizations.of(context)!.logout,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 15.h),
                        InkWell(
                          onTap: () {
                            setState(() {
                              isExpand = !isExpand;
                            });
                          },
                          child: !isExpand
                              ? Container(
                                  height: 30.h,
                                  width: 30.w,
                                  decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(20)),
                                    color: AppColors.primary,
                                  ),
                                  child: const HeroIcon(
                                    size: 15,
                                    HeroIcons.arrowLeft,
                                    style: HeroIconStyle.solid,
                                    color: AppColors.whiteColor,
                                  ),
                                )
                              : Container(),
                        ),
                        const SizedBox(height: 100),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

// Widget _listOfProject(Tasks task, bool isLightTheme, String? date, List<Tasks> statetask, int index) {
//   print("[DEBUG] Rendering task ID: ${task.id}, title: ${task.title}, users: ${task.users}, clients: ${task.clients}, pinned: ${task.pinned}, favorite: ${task.favorite}, statusId: ${task.statusId}");

//   return Padding(
//     padding: EdgeInsets.symmetric(vertical: 10.h),
//     child: DismissibleCard(
//       direction: context.read<PermissionsBloc>().isdeleteTask == true &&
//               context.read<PermissionsBloc>().iseditTask == true
//           ? DismissDirection.horizontal // Allow both directions
//           : context.read<PermissionsBloc>().isdeleteTask == true
//               ? DismissDirection.endToStart // Allow delete
//               : context.read<PermissionsBloc>().iseditTask == true
//                   ? DismissDirection.startToEnd // Allow edit
//                   : DismissDirection.none,
//       title: task.id.toString(),
//       confirmDismiss: (DismissDirection direction) async {
//         print("[DEBUG] Dismiss direction: $direction for task ID: ${task.id}");
//         if (direction == DismissDirection.endToStart) {
//           // Right to left swipe (Delete action)
//           final result = await showDialog<bool>(
//             context: context,
//             builder: (context) {
//               return AlertDialog(
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
//                 title: Text(AppLocalizations.of(context)!.confirmDelete),
//                 content: Text(AppLocalizations.of(context)!.areyousure),
//                 actions: [
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(true), // Confirm deletion
//                     child: Text(AppLocalizations.of(context)!.delete),
//                   ),
//                   TextButton(
//                     onPressed: () => Navigator.of(context).pop(false), // Cancel deletion
//                     child: Text(AppLocalizations.of(context)!.cancel),
//                   ),
//                 ],
//               );
//             },
//           );
//           return result ?? false; // Return false if dialog is dismissed
//         } else if (direction == DismissDirection.startToEnd) {
//           // Edit action
//           List<String> username = [];
//           List<int> ids = [];
//           if (task.users != null) {
//             for (var names in task.users!) {
//               username.add(names.firstName ?? 'Unknown');
//               ids.add(names.id ?? 0);
//             }
//           }
//           print("[DEBUG] Navigating to edit task: ${task.id}, username: $username, ids: $ids, statusId: ${task.statusId}");
//           router.push(
//             '/createtask',
//             extra: {
//               "id": task.id,
//               "isCreate": false,
//               "title": task.title ?? '',
//               "users": username,
//               "desc": task.description ?? '',
//               "start": task.startDate,
//               "end": task.dueDate,
//               "usersid": ids,
//               "statusId": task.statusId ?? 0, // Fallback for null statusId
//               "note": task.note ?? '',
//               "project": task.project,
//               "userList": task.users ?? [],
//               "tasks": statetask[index],
//               "status": task.status,
//               "req": <CreateTaskModel>[],
//             },
//           );
//           BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
//           return false; // Prevent dismiss
//         }
//         return false; // Default case
//       },
//       dismissWidget: InkWell(
//         highlightColor: Colors.transparent,
//         splashColor: Colors.transparent,
//         onTap: () {
//           List<String> username = [];
//           if (task.users != null) {
//             for (var names in task.users!) {
//               username.add(names.firstName ?? 'Unknown');
//             }
//           }
//           print("[DEBUG] Navigating to task detail: ${task.id}, username: $username");
//           router.push(
//             '/taskdetail',
//             extra: {
//               "id": task.id,
//               "from": "dashboard",
//             },
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             boxShadow: [
//               isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
//             ],
//             color: Theme.of(context).colorScheme.containerDark,
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               CustomText(
//                                 text: "#${task.id.toString()}",
//                                 size: 14.sp,
//                                 color: Theme.of(context).colorScheme.textClrChange,
//                                 fontWeight: FontWeight.w700,
//                                 maxLines: 1,
//                                 overflow: TextOverflow.ellipsis,
//                               ),
//                               Row(
//                                 children: [
//                                   InkWell(
//                                     onTap: () {
//                                       setState(() {
//                                         task.pinned = task.pinned == 1 ? 0 : 1;
//                                         print("[DEBUG] Updating pinned status for task ${task.id}: ${task.pinned}");
//                                         TaskRepo().updateTaskPinned(
//                                           id: statetask[index].id!,
//                                           isPinned: task.pinned ?? 0, // Fallback for null pinned
//                                         );
//                                       });
//                                       _pinnedcController.reverse().then(
//                                           (value) => _pinnedcController.forward());
//                                     },
//                                     child: Container(
//                                       width: 40.w,
//                                       height: 30.h,
//                                       decoration: BoxDecoration(
//                                         boxShadow: [
//                                           isLightTheme
//                                               ? MyThemes.lightThemeShadow
//                                               : MyThemes.darkThemeShadow,
//                                         ],
//                                         color: Theme.of(context).colorScheme.backGroundColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: ScaleTransition(
//                                         scale: Tween(begin: 0.7, end: 1.0).animate(
//                                           CurvedAnimation(
//                                             parent: _pinnedcController,
//                                             curve: Curves.easeOut,
//                                           ),
//                                         ),
//                                         child: Icon(
//                                           task.pinned == 1
//                                               ? Icons.push_pin
//                                               : Icons.push_pin_outlined,
//                                           size: 20,
//                                           color: task.pinned == 1 ? Colors.blue : Colors.blue,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   InkWell(
//                                     splashColor: Colors.transparent,
//                                     highlightColor: Colors.transparent,
//                                     onTap: () {
//                                       setState(() {
//                                         task.favorite = task.favorite == 1 ? 0 : 1;
//                                         print("[DEBUG] Updating favorite status for task ${task.id}: ${task.favorite}");
//                                         TaskRepo().updateTaskFavorite(
//                                           id: task.id!,
//                                           isFavorite: task.favorite ?? 0, // Fallback for null favorite
//                                         );
//                                       });
//                                       _controller.reverse().then(
//                                           (value) => _controller.forward());
//                                     },
//                                     child: Container(
//                                       width: 40.w,
//                                       height: 30.h,
//                                       decoration: BoxDecoration(
//                                         boxShadow: [
//                                           isLightTheme
//                                               ? MyThemes.lightThemeShadow
//                                               : MyThemes.darkThemeShadow,
//                                         ],
//                                         color: Theme.of(context).colorScheme.backGroundColor,
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: ScaleTransition(
//                                         scale: Tween(begin: 0.7, end: 1.0).animate(
//                                           CurvedAnimation(
//                                             parent: _controller,
//                                             curve: Curves.easeOut,
//                                           ),
//                                         ),
//                                         child: Icon(
//                                           task.favorite == 1
//                                               ? Icons.favorite
//                                               : Icons.favorite_border,
//                                           size: 20,
//                                           color: task.favorite == 1 ? Colors.red : Colors.red,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           CustomText(
//                             text: task.title ?? 'Untitled',
//                             overflow: TextOverflow.ellipsis,
//                             maxLines: 1,
//                             size: 24.sp,
//                             color: Theme.of(context).colorScheme.textClrChange,
//                             fontWeight: FontWeight.w600,
//                           ),
//                           task.description != null
//                               ? SizedBox(height: 8.h)
//                               : SizedBox.shrink(),
//                           task.description != null
//                               ? SizedBox(
//                                   width: double.infinity,
//                                   child: htmlWidget(
//                                     task.description!,
//                                     context,
//                                     width: 290.w,
//                                     height: 36.h,
//                                   ),
//                                 )
//                               : SizedBox.shrink(),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 10.h),
//               Padding(
//                 padding: EdgeInsets.symmetric(horizontal: 20.h),
//                 child: statusClientRow(
//                   task.status ?? 'Unknown',
//                   task.priority,
//                   context,
//                   false,
//                 ),
//               ),
//               (task.users?.isEmpty ?? true) && (task.clients?.isEmpty ?? true)
//                   ? SizedBox.shrink()
//                   : Padding(
//                       padding: EdgeInsets.only(top: 10.h, left: 18.w, right: 18.w),
//                       child: SizedBox(
//                         height: 60.h,
//                         child: Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Expanded(
//                               child: InkWell(
//                                 onTap: () {
//                                   print("[DEBUG] Showing user dialog for task ${task.id}");
//                                   userClientDialog(
//                                     from: "user",
//                                     context: context,
//                                     title: AppLocalizations.of(context)!.allusers,
//                                     list: task.users ?? [],
//                                   );
//                                 },
//                                 child: RowDashboard(
//                                   list: task.users ?? [],
//                                   title: "user",
//                                 ),
//                               ),
//                             ),
//                             task.users?.isEmpty ?? true
//                                 ? const SizedBox.shrink()
//                                 : SizedBox(width: 20.w),
//                             task.clients?.isEmpty ?? true
//                                 ? const SizedBox.shrink()
//                                 : Expanded(
//                                     child: InkWell(
//                                       onTap: () {
//                                         print("[DEBUG] Showing client dialog for task ${task.id}");
//                                         userClientDialog(
//                                           from: 'client',
//                                           context: context,
//                                           title: task.clients?.isNotEmpty ?? false
//                                               ? AppLocalizations.of(context)!.allclients
//                                               : AppLocalizations.of(context)!.allclients,
//                                           list: task.clients ?? [],
//                                         );
//                                       },
//                                       child: RowDashboard(
//                                         list: task.clients ?? [],
//                                         title: "client",
//                                       ),
//                                     ),
//                                   ),
//                           ],
//                         ),
//                       ),
//                     ),
//               Divider(color: Theme.of(context).colorScheme.dividerClrChange),
//               Padding(
//                 padding: EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Row(
//                       children: [
//                         const HeroIcon(
//                           HeroIcons.calendar,
//                           style: HeroIconStyle.solid,
//                           color: AppColors.blueColor,
//                         ),
//                         SizedBox(width: 20.w),
//                         CustomText(
//                           text: date ?? "",
//                           color: AppColors.greyColor,
//                           size: 12,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//       onDismissed: (DismissDirection direction) async {
//         print("[DEBUG] onDismissed triggered for task ${task.id}, direction: $direction");
//         if (direction == DismissDirection.endToStart &&
//             context.read<PermissionsBloc>().isdeleteTask == true) {
//           setState(() {
//             statetask.removeAt(index);
//             print("[DEBUG] Deleting task ${task.id}");
//           //  onDeleteTask(task.id!);
//           });
//         } else if (direction == DismissDirection.startToEnd &&
//             context.read<PermissionsBloc>().iseditTask == true) {
//           print("[DEBUG] Edit action for task ${task.id} (not dismissing)");
//         }
//       },
//     ),
//   );
// }}
}
