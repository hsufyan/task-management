import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:taskify/bloc/notes/notes_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/bloc/workspace/workspace_state.dart';
import 'package:taskify/screens/home_screen/home_widgets/upcoming_birthday.dart';
import 'package:taskify/screens/home_screen/home_widgets/work_anniversary.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/birthday/birthday_bloc.dart';
import '../../bloc/birthday/birthday_event.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/dashboard_stats/dash_board_stats_event.dart';
import '../../bloc/income_expense/income_expense_bloc.dart';
import '../../bloc/income_expense/income_expense_event.dart';
import '../../bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import '../../bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import '../../bloc/leave_request/leave_request_bloc.dart';
import '../../bloc/leave_request/leave_request_event.dart';
import '../../bloc/meeting/meeting_bloc.dart';
import '../../bloc/meeting/meeting_event.dart';

import '../../bloc/notifications/system_notification/notification_bloc.dart';
import '../../bloc/notifications/system_notification/notification_event.dart';
import '../../bloc/notifications/system_notification/notification_state.dart';
import '../../bloc/permissions/permissions_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/project_filter/project_filter_bloc.dart';
import '../../bloc/project_filter/project_filter_event.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task_filter/task_filter_bloc.dart';
import '../../bloc/task_filter/task_filter_event.dart';
import '../../bloc/todos/todos_bloc.dart';
import '../../bloc/todos/todos_event.dart';
import '../../bloc/workspace/workspace_bloc.dart';
import '../../bloc/workspace/workspace_event.dart';
import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../../bloc/dashboard_stats/dash_board_stats_state.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/languages/language_switcher_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user_profile/user_profile_bloc.dart';
import '../../bloc/user_profile/user_profile_event.dart';
import '../../bloc/user_profile/user_profile_state.dart';
import '../../bloc/work_anniveresary/work_anniversary_bloc.dart';
import '../../bloc/work_anniveresary/work_anniversary_event.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../config/strings.dart';
import '../../data/localStorage/hive.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/toast_widget.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../dash_board/dashboard.dart';
import '../widgets/html_widget.dart';
import '../widgets/user_client_box.dart';
import 'home_widgets/leave_request.dart';
import 'home_widgets/line_chart.dart';
import 'home_widgets/pie_chart.dart';
import 'home_widgets/today_task.dart';
import 'widgets/workspace_dialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

List randomImages = [
  'https://images.unsplash.com/photo-1542909168-82c3e7fdca5c?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8OHx8ZmFjZXxlbnwwfHwwfHw%3D&w=1000&q=80',
  'https://i0.wp.com/post.medicalnewstoday.com/wp-content/uploads/sites/3/2020/03/GettyImages-1092658864_hero-1024x575.jpg?w=1155&h=1528'
];

class _HomeScreenState extends State<HomeScreen> {
  // final Connectivity _connectivity = Connectivity();
  // late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  int? totalProjects = 0;
  int? totalTask = 0;
  int? totalUser = 0;
  int? totalClient = 0;
  int? totalMeeting = 0;
  int? totalTodos = 0;
  String? usersname;
  int? usersId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  List<int> clientSelectedId = [];
  List<String> clientSelectedname = [];

  List<int> userSelectedIdForAnni = [];
  List<String> userSelectednameForAnni = [];

  List<int> userSelectedIdForLeavereq = [];
  List<String> userSelectednameLeavereq = [];
  int upcomingDays = 7;
  int upcomingMonths = 30;
  int days = 0;
  String? weekMonth;

  String? hasGuard;
  String searchWord = "";

  String? languageCode;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isExpand = false;

  void toggleDrawer(bool expanded) {
    setState(() {
      isExpand = expanded;
    });
  }

  void getWorkSpace() async {
    var box = await Hive.openBox(userBox);
    workSpaceTitle = box.get('workspace_title');
  }

  String? fromDate;
  int? statusPending;
  String? toDate;
  bool? isLoading = true;
  String? role;
  bool? isConnectedToInternet;
  StreamSubscription? _internetConnectionStreamSubscription;
  String? photo;

  @override
  void initState() {
    _todayTask();
    context.read<FilterCountBloc>().add(ProjectResetFilterCount());
    context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    context.read<DashBoardStatsBloc>().totalTodos.toString();
    context.read<DashBoardStatsBloc>().totalProject.toString();

    context.read<DashBoardStatsBloc>().totalTask.toString();
    context.read<DashBoardStatsBloc>().totaluser.toString();
    context.read<DashBoardStatsBloc>().totalClient.toString();
    context.read<DashBoardStatsBloc>().totalMeeting.toString();
    BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    BlocProvider.of<NotificationBloc>(context).add(UnreadNotificationCount());

    _getRole();
    super.initState();
  }

  @override
  void dispose() {
    _internetConnectionStreamSubscription?.cancel();
    super.dispose();
  }

  _todayTask() {
    DateTime now = DateTime.now();
    fromDate = DateFormat('yyyy-MM-dd').format(now);

    DateTime oneWeekFromNow = now.add(const Duration(days: 7));
    toDate = DateFormat('yyyy-MM-dd').format(oneWeekFromNow);
  }

  Future<void> _onRefresh() async {
    _todayTask();

    setState(() {
      isLoading = true;
    });
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    context.read<DashBoardStatsBloc>().totalTodos.toString();
    context.read<DashBoardStatsBloc>().totalProject.toString();
    context.read<DashBoardStatsBloc>().totalTask.toString();
    context.read<DashBoardStatsBloc>().totaluser.toString();
    context.read<DashBoardStatsBloc>().totalClient.toString();
    context.read<DashBoardStatsBloc>().totalMeeting.toString();
    BlocProvider.of<ChartBloc>(context)
        .add(FetchChartData(endDate: "", startDate: ""));

    BlocProvider.of<WorkspaceBloc>(context).add(const WorkspaceList());
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    BlocProvider.of<NotificationBloc>(context).add(UnreadNotificationCount());
    BlocProvider.of<TaskBloc>(context).add(TodaysTaskList(fromDate!, toDate!));

    _getRole();
    setState(() {
      isLoading = false;
    });
  }

  String? greetingMessage;
  String? greetingEmoji;
  String? getLanguage;

  String _greeting() {
    int hour = DateTime.now().hour;
    if (hour < 12) {
      greetingMessage = AppLocalizations.of(context)!.morning;

      greetingEmoji = "☀️";
      return AppLocalizations.of(context)!.morning;
    }
    if (hour < 17) {
      // greetingMessage = getTranslated(context, "afternoon");
      greetingMessage = AppLocalizations.of(context)!.afternoon;
      greetingEmoji = "🌞";
      return AppLocalizations.of(context)!.afternoon;
    }
    greetingEmoji = "🌙";
    greetingMessage = AppLocalizations.of(context)!.evening;
    return AppLocalizations.of(context)!.evening;
  }

  Future<void> _getRole() async {
    role = await HiveStorage.getRole();

    // Now that the role is fetched, you can conditionally handle it
    setState(() {
      if (role == 'Client') {
        // Perform any necessary updates for 'Client' role
      } else {
        // Perform other updates for non-'Client' role
        BlocProvider.of<WorkAnniversaryBloc>(context)
            .add(WeekWorkAnniversaryList([], [], 7));
        BlocProvider.of<BirthdayBloc>(context).add(WeekBirthdayList(7, [], []));
        BlocProvider.of<LeaveReqDashboardBloc>(context)
            .add(WeekLeaveReqListDashboard([], 7));
      }
    });
  }

  void _handleUsersName(List<String> userName, List<int> userId) {
    setState(() {
      userSelectedname = userName;
      userSelectedId = userId;
    });
  }

  void _handleUsersNameForAnni(List<String> userName, List<int> userId) {
    setState(() {
      userSelectednameForAnni = userName;
      userSelectedIdForAnni = userId;
    });
  }

  void _handleUsersNameForLeaveReq(List<String> userName, List<int> userId) {
    setState(() {
      userSelectednameLeavereq = userName;
      userSelectedIdForLeavereq = userId;
    });
  }

  String? photoWidget;
  String? email;
  String? roleInUser;
  String? firstNameUser;
  String? lastNameUSer;
  String? workSpaceTitle;
  bool projectChart = false;
  bool taskChart = false;
  void handleIsProjectChart(
    bool status,
  ) {
    setState(() {
      // userId = id;
      projectChart = status;
    });
  }

  void handleIsTaskChart(
    bool status,
  ) {
    setState(() {
      // userId = id;
      taskChart = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    print("hfedfj ${context.read<UserProfileBloc>().role}");
    _todayTask();
    BlocProvider.of<DashBoardStatsBloc>(context).add(StatsList());
    statusPending = context.read<LeaveRequestBloc>().statusPending;
    BlocProvider.of<UserProfileBloc>(context).add(ProfileListGet());
    BlocProvider.of<LeaveRequestBloc>(context).add(GetPendingLeaveRequest());
    _greeting();
    hasGuard = context.read<AuthBloc>().guard;
    context.read<AuthBloc>().guard;
    context.read<AuthBloc>().hasAllDataAccess;
    context.read<AuthBloc>().userId;
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      drawer: isExpand ? _drawerIn() : _expandedDrawer(),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(40.h), // Set your custom height here
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
              onTap: () {
                _scaffoldKey.currentState?.openDrawer();
              },
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
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w),
              child: Row(
                children: [
                  Stack(children: [
                    GestureDetector(
                      onTap: () {
                        router.push("/notification");
                      },
                      child: SizedBox(
                        // color: AppColors.red,
                        height: 50.h,
                        child: Padding(
                          padding: EdgeInsets.only(left: 5.w, right: 10.w),
                          child: HeroIcon(
                            HeroIcons.bell,
                            style: HeroIconStyle.outline,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.textClrChange,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                        right: 5.w,
                        top: 2.h,
                        child:
                            BlocConsumer<NotificationBloc, NotificationsState>(
                                listener: (context, state) {
                          if (state is NotificationPaginated) {}
                        }, builder: (context, state) {
                          print(
                              "eslirkgjxg ${context.read<NotificationBloc>().totalUnreadCount == 0}");
                          if (state is UnreadNotification) {
                            return state.total == 0
                                ? SizedBox()
                                : Container(
                                    height: 15.sp,
                                    width: 15.sp,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.yellow.shade800,
                                    ),
                                    child: Center(
                                        child: CustomText(
                                      size: 10,
                                      fontWeight: FontWeight.w600,
                                      text: state.total.toString(),
                                      color: AppColors.pureWhiteColor,
                                    )),
                                  );
                          }
                          return SizedBox();
                        }))
                  ]),
                  GestureDetector(
                    onTap: () {
                      _showLanguageDialog(context);
                    },
                    child: SizedBox(
                      // color: AppColors.red,
                      height: 50.h,
                      child: Padding(
                        padding: EdgeInsets.only(left: 5.w, right: 5.w),
                        child: HeroIcon(
                          HeroIcons.language,
                          style: HeroIconStyle.outline,
                          size: 20.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
      body: ScrollConfiguration(
        behavior: const ScrollBehavior().copyWith(overscroll: false),
        child: RefreshIndicator(
          color: AppColors.primary, // Spinner color
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          onRefresh: _onRefresh,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10.h,
                ),
                _welcomeCard(isLightTheme),
                SizedBox(
                  height: 15.h,
                ),
                _currentWorkspace(isLightTheme),
                SizedBox(
                  height: 0.h,
                ),
                _totalstats(isLightTheme),
                Row(
                  children: [
                    SizedBox(
                      width: 9.w,
                    ),
                    Expanded(
                        child: DoughnutChart(
                            type: "project",
                            title: AppLocalizations.of(context)!.projectstats,
                            isReverse: false,
                            onChangeForProject: handleIsProjectChart,
                            onChangeForTask: (bool _) {})),
                    // SizedBox(width: 10.w,),
                    Expanded(
                      child: DoughnutChart(
                          type: "task",
                          title: AppLocalizations.of(context)!.taskectstats,
                          isReverse: false,
                          onChangeForTask: handleIsTaskChart,
                          onChangeForProject: (bool _) {}),
                    ),
                    SizedBox(
                      width: 9.w,
                    ),
                  ],
                ),

                SizedBox(
                  height: 15.h,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.w),
                  child: DoughnutChart(
                      title: AppLocalizations.of(context)!.todosoverview,
                      isReverse: true,
                      onChangeForProject: (bool _) {},
                      onChangeForTask: (bool _) {}),
                ),
                SizedBox(
                  height: 15.h,
                ),
                ChartPage(),
                SizedBox(
                  height: 10.h,
                ),
                context.read<PermissionsBloc>().isManageProject == true
                    ? _myProject(context, isLightTheme, languageCode)
                    : SizedBox.shrink(),
                context.read<PermissionsBloc>().isManageTask == true
                    ? TodayTask()
                    : SizedBox.shrink(),

                role == "Client"
                    ? SizedBox()
                    : UpcomingBirthday(
                        onSelected: _handleUsersName,
                      ),
                role == "Client" ? SizedBox() : SizedBox(height: 20.h),
                role == "Client"
                    ? SizedBox()
                    : UpcomingWorkAnniversary(
                        onSelected: _handleUsersNameForAnni),
                // role == "Client" ? SizedBox() : SizedBox(height: 20.h),
                role == "Client"
                    ? SizedBox(height: 20.h)
                    : LeaveRequest(onSelected: _handleUsersNameForLeaveReq),
                SizedBox(
                  height: 60.h,
                ),
              ],
            ),
          ),
        ),
      ),
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
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(10.r), // Set the desired radius here
          ),
          contentPadding: EdgeInsets.only(
            right: 10.w,
            bottom: 30.h,
          ),
          actionsPadding: EdgeInsets.only(
            right: 10.w,
            bottom: 30.h,
          ),
          title: Text(AppLocalizations.of(context)!.chooseLang),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return SingleChildScrollView(
                child: SizedBox(
                  width: 50.w,
                  // height: MediaQueryHelper.screenHeight(context) * 0.2,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'English',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'en',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'हिन्दी',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'hi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          'عربي',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'ar',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ),
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '한국인',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'ko',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Korean
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '베트남 사람',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'vi',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Vietnamese
                      RadioListTile<String>(
                        visualDensity: VisualDensity(horizontal: -4),
                        activeColor: AppColors.primary,
                        title: Text(
                          '포르투갈 인',
                          style: TextStyle(
                            fontSize: 17,
                            fontFamily: "Poppins-Bold",
                          ),
                        ),
                        value: 'pt',
                        groupValue: selectedLanguage,
                        onChanged: (String? value) {
                          setState(() {
                            selectedLanguage = value;
                          });
                        },
                      ), //Portuguese
                    ],
                  ),
                ),
              );
            },
          ),
          actions: [
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.cancel,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text(
                AppLocalizations.of(context)!.ok,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontFamily: "Poppins-Bold",
                ),
              ),
              onPressed: () {
                if (selectedLanguage != null) {
                  // HiveStorage().storeLanguage(selectedLanguage!);

                  context.read<LanguageBloc>().add(
                        ChangeLanguage(languageCode: selectedLanguage!),
                      );
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _welcomeCard(isLightTheme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: Container(
        decoration: BoxDecoration(
            boxShadow: [
              isLightTheme
                  ? MyThemes.lightThemeShadow
                  : MyThemes.darkThemeShadow,
            ],
            color: Theme.of(context).colorScheme.containerDark,
            borderRadius: BorderRadius.circular(12)),
        width: double.infinity,
        height: 100.h,
        // height: 127.h,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocConsumer<UserProfileBloc, UserProfileState>(
                  listener: (context, state) {
                // Handle side effects based on state changes here
                if (state is UserProfileSuccess) {
                  for (var data in state.profile) {
                    isLoading = true;
                    // id = data.id;
                    firstNameUser = data.firstName ?? "First Name";
                    lastNameUSer = data.lastName ?? "LastName";
                    email = data.email ?? "Email";
                    // add = data.address ?? "Address";
                    // cityINWidget = data.city ?? "City";
                    roleInUser = data.roleId.toString();
                    photoWidget = data.profile ?? "Photo";
                    role = data.role ?? "Role";
                  }
                } else if (state is UserProfileError) {
                  // Show error message
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   SnackBar(content: Text('Failed to update profile: ${state.error}')),
                  // );
                }
              }, builder: (context, state) {
                if (state is UserProfileSuccess) {
                  firstNameUser =
                      context.read<UserProfileBloc>().firstname ?? "First Name";
                  lastNameUSer =
                      context.read<UserProfileBloc>().lastName ?? "LastName";
                  email = context.read<UserProfileBloc>().email ?? "Email";
                  // addressWidget = context.read<UserProfileBloc>().address ?? "Address";
                  // cityINWidget = context.read<UserProfileBloc>().city ?? "City";
                  roleInUser =
                      context.read<UserProfileBloc>().roleId.toString();
                  photoWidget =
                      context.read<UserProfileBloc>().profilePic ?? "Photo";
                  role = context.read<UserProfileBloc>().role ?? "Role";

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      state.profile.isNotEmpty
                          ? Row(
                              children: [
                                InkWell(
                                    onTap: () {
                                      router.push("/profile");
                                    },
                                    child: SizedBox(
                                      width: 60.w,
                                      // alignment: Alignment.center,
                                      child: GlowContainer(
                                          shape: BoxShape.circle,
                                          glowColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.3),
                                          blurRadius: 20,
                                          spreadRadius: 10,
                                          child: CircleAvatar(
                                            radius: 25
                                                .r, // Size of the profile image
                                            backgroundImage: photoWidget != null
                                                ? NetworkImage(photoWidget!)
                                                : NetworkImage(photo!),
                                            backgroundColor: Colors.grey[
                                                200], // Replace with your image URL
                                          )),
                                    )),
                                SizedBox(
                                  width: 25.w,
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    CustomText(
                                      text: AppLocalizations.of(context)!.hey,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    CustomText(
                                      text:
                                          "${context.read<UserProfileBloc>().firstname} ${context.read<UserProfileBloc>().lastName} !",
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      size: 12,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ],
                                ),
                              ],
                            )
                          : Padding(
                              padding: EdgeInsets.only(top: 0.h),
                              child: Row(
                                children: [
                                  InkWell(
                                      onTap: () {
                                        router.push("/profile");
                                      },
                                      child: SizedBox(
                                        width: 60.w,
                                        // alignment: Alignment.center,
                                        child: GlowContainer(
                                          shape: BoxShape.circle,
                                          glowColor: Theme.of(context)
                                              .colorScheme
                                              .primary
                                              .withValues(alpha: 0.2),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                          child: CircleAvatar(
                                            backgroundColor: Colors.transparent,

                                            radius: 26.r,
                                            // backgroundColor: Theme.of(context).colorScheme.error,
                                            child: photoWidget != null
                                                ? CircleAvatar(
                                                    radius: 25
                                                        .r, // Size of the profile image
                                                    backgroundImage:
                                                        photoWidget != null
                                                            ? NetworkImage(
                                                                photoWidget!)
                                                            : NetworkImage(
                                                                photo!),
                                                    backgroundColor: Colors
                                                            .grey[
                                                        200], // Replace with your image URL
                                                  )
                                                : CircleAvatar(
                                                    radius: 25.r,
                                                    // Size of the profile image
                                                    backgroundColor:
                                                        Colors.grey[200],
                                                    child: const Icon(
                                                      Icons.person,
                                                      color: Colors.grey,
                                                    ), // Replace with your image URL
                                                  ),
                                          ),
                                        ),
                                      )),
                                  SizedBox(
                                    width: 25.w,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      CustomText(
                                        text: AppLocalizations.of(context)!.hey,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        size: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      CustomText(
                                        text:
                                            "${context.read<UserProfileBloc>().firstname} !",
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        size: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                      firstNameUser != null
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                CustomText(
                                  text: greetingMessage!,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  size: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                CustomText(
                                  text: greetingEmoji!,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  size: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ],
                            )
                          : Shimmer.fromColors(
                              baseColor: isLightTheme == true
                                  ? Colors.grey[100]!
                                  : Colors.grey[600]!,
                              highlightColor: isLightTheme == false
                                  ? Colors.grey[800]!
                                  : Colors.grey[300]!,
                              child: Container(
                                width: 100,
                                height: 10,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Theme.of(context)
                                        .colorScheme
                                        .backGroundColor),
                              ))
                    ],
                  );
                }

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
            ],
          ),
        ),
      ),
    );
  }

  Widget _currentWorkspace(isLightTheme) {
    getWorkSpace();
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: BlocConsumer<WorkspaceBloc, WorkspaceState>(
            listener: (context, state) {
          if (state is WorkspacePaginated) {}
        }, builder: (context, state) {
          print("efhjdbn $state");
          if (state is WorkspacePaginated) {
            return InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return WorkSpaceDialog(
                        work: state.workspace, isDashboard: true);
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
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12)),
                  width: double.infinity,
                  height: 50.h,
                  // height: 127.h,
                  child: Center(
                      child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: workSpaceTitle ??
                              context
                                  .read<AuthBloc>()
                                  .workspaceTitleUpdated
                                  .toString(),
                          color: AppColors.pureWhiteColor,
                          size: 15.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        const HeroIcon(
                          HeroIcons.chevronRight,
                          style: HeroIconStyle.outline,
                          // color: Theme.of(context).colorScheme.textClrChange,
                          color: AppColors.pureWhiteColor,
                        ),
                      ],
                    ),
                  ))),
            );
          }
          if (state is WorkspaceLoading) {
            return Shimmer.fromColors(
                baseColor: isLightTheme == true
                    ? Colors.grey[100]!
                    : Colors.grey[600]!,
                highlightColor: isLightTheme == false
                    ? Colors.grey[800]!
                    : Colors.grey[300]!,
                child: Container(
                  decoration: BoxDecoration(
                      boxShadow: [
                        isLightTheme
                            ? MyThemes.lightThemeShadow
                            : MyThemes.darkThemeShadow,
                      ],
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12)),
                  width: double.infinity,
                  height: 50.h,
                  // height: 127.h,
                ));
          }
          if (state is WorkspaceError) {
            flutterToastCustom(msg: state.errorMessage, color: Colors.red);
          }
          return SizedBox.shrink();
        }));
  }

  Widget _totalstats(isLightTheme) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 15.h),
        child: BlocConsumer<DashBoardStatsBloc, DashBoardStatsState>(
          listener: (context, state) {
            if (state is DashBoardStatsSuccess) {
              totalProjects = state.totalproject;
              totalUser = state.totaluser;
              totalTask = state.totaltask;
              totalClient = state.totalclient;
              totalMeeting = state.totalmeeting;
              totalTodos = state.totaltodos;
              SizedBox(
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        context.read<PermissionsBloc>().isManageProject == true
                            ? _getTotal(
                                index: 1,
                                title:
                                    AppLocalizations.of(context)!.totalProject,
                                isLightTheme: isLightTheme,
                                total: totalProjects.toString(),
                                colors: AppColors.primary,
                                icon: const HeroIcon(
                                  HeroIcons.wallet,
                                  style: HeroIconStyle.outline,
                                  // color: Theme.of(context).colorScheme.textClrChange,
                                  color: AppColors.primary,
                                ),
                                onPress: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const DashBoard(
                                          initialIndex:
                                              1), // Navigate to index 1
                                    ),
                                  );
                                },
                                backroundcolor:
                                    Theme.of(context).colorScheme.containerDark,
                              )
                            : SizedBox.shrink(),
                        SizedBox(
                          width: 10.w,
                        ),
                        context.read<PermissionsBloc>().isManageTask == true
                            ? _getTotal(
                                index: 2,
                                title: AppLocalizations.of(context)!.totalTask,
                                isLightTheme: isLightTheme,
                                total: totalTask.toString(),
                                icon: const HeroIcon(
                                  HeroIcons.documentCheck,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.blueLight,
                                ),
                                onPress: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => const DashBoard(
                                          initialIndex:
                                              2), // Navigate to index 1
                                    ),
                                  );
                                },
                                backroundcolor:
                                    Theme.of(context).colorScheme.containerDark,
                                colors: AppColors.blueLight)
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        context.read<PermissionsBloc>().isManageUser == true
                            ? _getTotal(
                                index: 4,
                                title: AppLocalizations.of(context)!.totalUser,
                                isLightTheme: isLightTheme,
                                total: totalUser.toString(),
                                icon: const HeroIcon(
                                  HeroIcons.userCircle,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.yellow,
                                ),
                                onPress: () {
                                  router.push('/user');
                                },
                                backroundcolor:
                                    Theme.of(context).colorScheme.containerDark,
                                colors: AppColors.yellow)
                            : SizedBox.shrink(),
                        SizedBox(
                          width: 10.w,
                        ),
                        context.read<PermissionsBloc>().isManageClient == true
                            ? _getTotal(
                                index: 3,
                                title:
                                    AppLocalizations.of(context)!.totalClient,
                                total: totalClient.toString(),
                                isLightTheme: isLightTheme,
                                icon: const HeroIcon(
                                  HeroIcons.userGroup,
                                  style: HeroIconStyle.outline,
                                  color: AppColors.orangeYellowishColor,
                                ),
                                onPress: () {
                                  router.push("/client");
                                },
                                backroundcolor:
                                    Theme.of(context).colorScheme.containerDark,
                                colors: AppColors.orangeYellowishColor)
                            : SizedBox.shrink(),
                      ],
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _getTotal(
                            index: 3,
                            title: AppLocalizations.of(context)!.totalMeeting,
                            isLightTheme: isLightTheme,
                            total: totalMeeting.toString(),
                            icon: const HeroIcon(
                              HeroIcons.users,
                              style: HeroIconStyle.outline,
                              color: AppColors.redColor,
                            ),
                            onPress: () {
                              router.push('/meetings',
                                  extra: {"fromNoti": false});
                            },
                            backroundcolor:
                                Theme.of(context).colorScheme.containerDark,
                            colors: AppColors.redColor),
                        SizedBox(
                          width: 10.w,
                        ),
                        _getTotal(
                            index: 2,
                            title: AppLocalizations.of(context)!.totalTodo,
                            isLightTheme: isLightTheme,
                            total: totalTodos.toString(),
                            icon: const HeroIcon(
                              HeroIcons.barsArrowUp,
                              style: HeroIconStyle.outline,
                              color: AppColors.greenColor,
                            ),
                            onPress: () {
                              router.push("/todos");
                            },
                            backroundcolor:
                                Theme.of(context).colorScheme.containerDark,
                            colors: AppColors.greenColor),
                      ],
                    ),
                  ],
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is DashBoardStatsLoading) {
              return const DashBoardStatsShimmer();
            } else if (state is DashBoardStatsSuccess) {
              totalProjects = state.totalproject;
              totalUser = state.totaluser;
              totalTask = state.totaltask;
              totalClient = state.totalclient;
              totalMeeting = state.totalmeeting;
              totalTodos = state.totaltodos;
              final items = [
                {
                  "title": AppLocalizations.of(context)!.totalMeeting,
                  "total": totalClient.toString(),
                  "icon": const HeroIcon(HeroIcons.users,
                      style: HeroIconStyle.outline, color: AppColors.redColor),
                  "onPress": () =>
                      router.push('/meetings', extra: {"fromNoti": false}),
                  "colors": AppColors.orangeYellowishColor,
                  "width": 200.w
                },
                {
                  "title": AppLocalizations.of(context)!.totalTodo,
                  "total": totalTodos.toString(),
                  "icon": const HeroIcon(HeroIcons.barsArrowUp,
                      style: HeroIconStyle.outline, color: AppColors.yellow),
                  "onPress": () => router.push('/todos'),
                  "colors": AppColors.yellow,
                  "width": 130.w
                }
              ];
              return Column(
                children: [
                  MasonryGridView.builder(
                    padding: EdgeInsets.only(bottom: 10.h),
                    gridDelegate:
                        SliverSimpleGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, // Number of columns
                    ),
                    mainAxisSpacing: 10.h,
                    crossAxisSpacing: 10.w,
                    itemCount: 4, // Total number of items
                    shrinkWrap: true, // Prevents unnecessary scrolling issues
                    physics:
                        const NeverScrollableScrollPhysics(), // Disables independent scrolling
                    itemBuilder: (context, index) {
                      final items = [
                        {
                          "title": AppLocalizations.of(context)!.totalProject,
                          "total": totalProjects.toString(),
                          "icon": const HeroIcon(HeroIcons.wallet,
                              style: HeroIconStyle.outline,
                              color: AppColors.primary),
                          "onPress": () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DashBoard(initialIndex: 1))),
                          "colors": AppColors.primary,
                        },
                        {
                          "title": AppLocalizations.of(context)!.totalTask,
                          "total": totalTask.toString(),
                          "icon": const HeroIcon(HeroIcons.documentCheck,
                              style: HeroIconStyle.outline,
                              color: AppColors.blueLight),
                          "onPress": () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (context) =>
                                      const DashBoard(initialIndex: 2))),
                          "colors": AppColors.blueLight,
                        },
                        {
                          "title": AppLocalizations.of(context)!.totalClient,
                          "total": totalClient.toString(),
                          "icon": const HeroIcon(HeroIcons.userGroup,
                              style: HeroIconStyle.outline,
                              color: AppColors.orangeYellowishColor),
                          "onPress": () => router.push("/client"),
                          "colors": AppColors.orangeYellowishColor,
                        },
                        {
                          "title": AppLocalizations.of(context)!.totalUser,
                          "total": totalUser.toString(),
                          "icon": const HeroIcon(HeroIcons.userCircle,
                              style: HeroIconStyle.outline,
                              color: AppColors.yellow),
                          "onPress": () => router.push('/user'),
                          "colors": AppColors.yellow,
                        },
                        {
                          "title": AppLocalizations.of(context)!.totalMeeting,
                          "total": totalClient.toString(),
                          "icon": const HeroIcon(HeroIcons.users,
                              style: HeroIconStyle.outline,
                              color: AppColors.redColor),
                          "onPress": () => router
                              .push('/meetings', extra: {"fromNoti": false}),
                          "colors": AppColors.orangeYellowishColor,
                        },
                        {
                          "title": AppLocalizations.of(context)!.totalUser,
                          "total": totalUser.toString(),
                          "icon": const HeroIcon(HeroIcons.userCircle,
                              style: HeroIconStyle.outline,
                              color: AppColors.yellow),
                          "onPress": () => router.push('/user'),
                          "colors": AppColors.yellow,
                        }
                      ];

                      return _getTotal(
                        index: index +
                            1, // Adjusting index to match your previous logic
                        title: items[index]["title"] as String,
                        isLightTheme: isLightTheme,
                        total: items[index]["total"] as String,
                        icon: items[index]["icon"] as HeroIcon,
                        onPress: items[index]["onPress"] as VoidCallback,
                        backroundcolor:
                            Theme.of(context).colorScheme.containerDark,
                        colors: items[index]["colors"] as Color,
                      );
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _getTotalMeetingTodo(
                        width: items[0]["width"]
                            as double, // Adjusting index to match your previous logic
                        title: items[0]["title"] as String,
                        isLightTheme: isLightTheme,
                        total: items[0]["total"] as String,
                        icon: items[0]["icon"] as HeroIcon,
                        onPress: items[0]["onPress"] as VoidCallback,
                        backroundcolor:
                            Theme.of(context).colorScheme.containerDark,
                        colors: items[0]["colors"] as Color,
                      ),
                      _getTotalMeetingTodo(
                        width: items[1]["width"]
                            as double, // Adjusting index to match your previous logic
                        title: items[1]["title"] as String,
                        isLightTheme: isLightTheme,
                        total: items[1]["total"] as String,
                        icon: items[1]["icon"] as HeroIcon,
                        onPress: items[1]["onPress"] as VoidCallback,
                        backroundcolor:
                            Theme.of(context).colorScheme.containerDark,
                        colors: items[1]["colors"] as Color,
                      ),
                    ],
                  )
                ],
              );
            } else if (state is DashBoardStatsError) {
              // Show error message
              return Center(
                child: Text(
                  state.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }
            // Handle other states
            return const CircularProgressIndicator();
          },
        ));
  }

  Widget _getTotal(
      {required String title,
      required bool isLightTheme,
      required String total,
      required Widget icon,
      required VoidCallback? onPress,
      required Color backroundcolor,
      required int index,
      required Color colors}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        height: index.isOdd ? 200.h : 120.h,
        decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          borderRadius: BorderRadius.circular(10),
          color: backroundcolor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                CustomText(
                  textAlign: TextAlign.center,
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: total,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.viewmore,
                  color: colors,
                  size: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getTotalMeetingTodo(
      {required String title,
      required bool isLightTheme,
      required String total,
      required Widget icon,
      required VoidCallback? onPress,
      required Color backroundcolor,
      required double width,
      required Color colors}) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: width,
        // width: double.infinity, // Let MasonryGrid manage the width
        height: 120.h,
        decoration: BoxDecoration(
          boxShadow: [
            isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
          ],
          borderRadius: BorderRadius.circular(10),
          color: backroundcolor,
        ),
        child: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                icon,
                CustomText(
                  textAlign: TextAlign.center,
                  text: title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
                CustomText(
                  text: total,
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.viewmore,
                  color: colors,
                  size: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
          ),
        ),
      ),
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

  Widget _expandedDrawer() {
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
          // shadowColor: Colors.red,
          width: 250,
          // width: width * 0.63,
          backgroundColor: Theme.of(context).colorScheme.bgColorChange,
          child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 20.h,
                    ),
                    BlocConsumer<UserProfileBloc, UserProfileState>(
                        listener: (context, state) {
                      // Handle side effects based on state changes here
                      if (state is UserProfileSuccess) {
                        for (var data in state.profile) {
                          isLoading = true;
                          // id = data.id;
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
                        lastNameUSer =
                            context.read<UserProfileBloc>().lastName ??
                                "LastName";
                        email =
                            context.read<UserProfileBloc>().email ?? "Email";
                        // addressWidget = context.read<UserProfileBloc>().address ?? "Address";
                        // cityINWidget = context.read<UserProfileBloc>().city ?? "City";
                        roleInUser =
                            context.read<UserProfileBloc>().roleId.toString();
                        photoWidget =
                            context.read<UserProfileBloc>().profilePic ??
                                "Photo";
                        role = context.read<UserProfileBloc>().role ?? "Role";

                        return Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ElevatedButton(
                            //   onPressed: () {},
                            //   child: CustomText(text: "kjsdafd"),
                            //   style: ButtonStyle(),
                            // ),
                            SizedBox(
                              height: 30.h,
                            ),
                            state.profile.isNotEmpty
                                ? Row(
                                    children: [
                                      SizedBox(
                                          width: 60.w,
                                          // alignment: Alignment.center,
                                          child: CircleAvatar(
                                            radius: 25
                                                .r, // Size of the profile image
                                            backgroundImage: photoWidget != null
                                                ? NetworkImage(photoWidget!)
                                                : NetworkImage(photo!),
                                            backgroundColor: Colors.grey[
                                                200], // Replace with your image URL
                                          )),
                                    ],
                                  )
                                : SizedBox(
                                    width: 60.w,
                                    // alignment: Alignment.center,
                                    child: CircleAvatar(
                                      radius: 26.r,
                                      backgroundColor: Colors.transparent,
                                      child: photoWidget != null
                                          ? CircleAvatar(
                                              radius: 25
                                                  .r, // Size of the profile image
                                              backgroundImage: photoWidget !=
                                                      null
                                                  ? NetworkImage(photoWidget!)
                                                  : NetworkImage(photo!),
                                              backgroundColor: Colors.grey[
                                                  200], // Replace with your image URL
                                            )
                                          : CircleAvatar(
                                              radius: 25.r,
                                              // Size of the profile image
                                              backgroundColor: Colors.grey[200],
                                              child: const Icon(
                                                Icons.person,
                                                color: Colors.grey,
                                              ), // Replace with your image URL
                                            ),
                                    ),
                                  ),
                            SizedBox(
                              height: 10.h,
                            ),
                            firstNameUser != null
                                ? CustomText(
                                    text: "$firstNameUser $lastNameUSer",
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                : SizedBox(),
                            email != null
                                ? CustomText(
                                    text: email ?? "",
                                    size: 12,
                                    color: AppColors.greyColor,
                                  )
                                : SizedBox()
                          ],
                        );
                      }
                      // if (state is UserProfileLoading) {
                      //   return Positioned(
                      //       top: 200.h, left: 40.w, right: 40.w, child: const ProfileShimmer());
                      // }
                      return Padding(
                        padding: const EdgeInsets.only(top: 60),
                        child: SizedBox(
                          width: 50.w,
                          // alignment: Alignment.center,
                          child: CircleAvatar(
                            radius: 26.r,
                            backgroundColor:
                                Theme.of(context).colorScheme.backGroundColor,
                            child: CircleAvatar(
                              radius: 25.r, // Size of the profile image
                              backgroundColor: Colors
                                  .grey[200], // Replace with your image URL
                            ),
                          ),
                        ),
                      );
                    }),
                    SizedBox(
                      height: 12.h,
                    ),
                    BlocConsumer<PermissionsBloc, PermissionsState>(
                        listener: (context, state) {
                      // Handle side effects based on state changes here
                      if (state is PermissionsSuccess) {}
                    }, builder: (context, state) {
                      if (state is PermissionsInitial) {}
                      if (state is PermissionsSuccess) {
                        return SingleChildScrollView(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              context.read<PermissionsBloc>().isManageProject ==
                                      true
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        toggleDrawer(false);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const DashBoard(
                                                initialIndex:
                                                    1), // Navigate to index 1
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Row(
                                          children: [
                                            const HeroIcon(
                                              HeroIcons.wallet,
                                              style: HeroIconStyle.outline,
                                              color: AppColors.greyColor,
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .projects,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              // context.read<PermissionsBloc>().isManageProject ==
                              //         true
                              //     ? SizedBox(
                              //         height: 20.h,
                              //       )
                              //     : const SizedBox.shrink(),
                              context.read<PermissionsBloc>().isManageTask ==
                                      true
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        toggleDrawer(false);
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) => const DashBoard(
                                                initialIndex:
                                                    2), // Navigate to index 1
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Row(
                                          children: [
                                            const HeroIcon(
                                              size: 26,
                                              HeroIcons.documentCheck,
                                              style: HeroIconStyle.outline,
                                              color: AppColors.greyColor,
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .tasksFromDrawer,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              context.read<PermissionsBloc>().isManageStatus ==
                                      true
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        toggleDrawer(false);
                                        router.push("/Status");
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Row(
                                          children: [
                                            const HeroIcon(
                                              size: 26,
                                              HeroIcons.square2Stack,
                                              style: HeroIconStyle.outline,
                                              color: AppColors.greyColor,
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .statuses,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              context
                                          .read<PermissionsBloc>()
                                          .isManagePriority ==
                                      true
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        toggleDrawer(false);
                                        router.push("/priorities");
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Row(
                                          children: [
                                            const HeroIcon(
                                              size: 26,
                                              HeroIcons.arrowUp,
                                              style: HeroIconStyle.outline,
                                              color: AppColors.greyColor,
                                            ),
                                            SizedBox(
                                              width: 20.w,
                                            ),
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .priorities,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .textClrChange,
                                            )
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                              context
                                          .read<PermissionsBloc>()
                                          .isManageWorkspace ==
                                      true
                                  ? InkWell(
                                      splashColor: Colors.transparent,
                                      onTap: () {
                                        toggleDrawer(false);
                                        // router.push('/notes');
                                        router.push('/workspaces',
                                            extra: {"fromNoti": false});
                                        router.pop();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
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
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CustomText(
                                                  text: AppLocalizations.of(
                                                          context)!
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
                                              )),
                                            )
                                          ],
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
                                        toggleDrawer(false);
                                        router.push("/notification");
                                        context
                                            .read<NotificationBloc>()
                                            .add(NotificationList());
                                        router.pop();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.h),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                const HeroIcon(
                                                  HeroIcons.bellAlert,
                                                  style: HeroIconStyle.outline,
                                                  color: AppColors.greyColor,
                                                ),
                                                SizedBox(
                                                  width: 20.w,
                                                ),
                                                CustomText(
                                                  text: AppLocalizations.of(
                                                          context)!
                                                      .notifications,
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .textClrChange,
                                                )
                                              ],
                                            ),
                                            BlocConsumer<NotificationBloc,
                                                    NotificationsState>(
                                                listener: (context, state) {
                                              if (state
                                                  is NotificationPaginated) {}
                                            }, builder: (context, state) {
                                              if (state is UnreadNotification) {
                                                return Container(
                                                  height: 20,
                                                  width: 20,
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color:
                                                        Colors.yellow.shade800,
                                                  ),
                                                  child: Center(
                                                      child: CustomText(
                                                    size: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                    text: "${state.total}",
                                                    color: AppColors
                                                        .pureWhiteColor,
                                                  )),
                                                );
                                              }
                                              return SizedBox();
                                            })
                                          ],
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ],
                          
                          ),
                        );
                      }

                      return SizedBox();
                    }),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        toggleDrawer(false);
                        context.read<TodosBloc>().add(const TodosList());
                        router.push("/todos");
                        router.pop();
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
                            SizedBox(
                              width: 20.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.todos,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                          ],
                        ),
                      ),
                    ),
                    context.read<PermissionsBloc>().isManageClient == true
                        ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/client");
                              BlocProvider.of<ClientBloc>(context)
                                  .add(ClientList());
                              router.pop();
                              // GoRouter.of(context).push('/client', extra: 'Client');
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
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .clientsFordrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    context.read<PermissionsBloc>().isManageUser == true
                        ? InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/user');
                              BlocProvider.of<UserBloc>(context)
                                  .add(UserList());
                              router.pop();
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
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .usersFordrawer,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    InkWell(
                      onTap: () {
                        toggleDrawer(false);
                        context.read<NotesBloc>().add(const NotesList());
                        router.push('/notes');
                        router.pop();
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
                            SizedBox(
                              width: 20.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.notes,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                          ],
                        ),
                      ),
                    ),
                    role == "Client"
                        ? SizedBox.shrink()
                        : InkWell(
                            onTap: () {
                              toggleDrawer(false);
                              router.push('/leaverequest',
                                  extra: {"fromNoti": false});
                              // context.read<LeaveRequestBloc>().add(const LeaveRequestList("",0,[]));
                              router.pop();
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
                                      SizedBox(
                                        width: 20.w,
                                      ),
                                      CustomText(
                                        text: AppLocalizations.of(context)!
                                            .leaverequestsDrawer,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),

                                      // SizedBox(
                                      //   width: 15.w,
                                      // ),
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
                                    )),
                                  )
                                ],
                              ),
                            ),
                          ),
                    context.read<PermissionsBloc>().isManageMeeting == true
                        ? InkWell(
                            onTap: () {
                              toggleDrawer(false);
                              context
                                  .read<MeetingBloc>()
                                  .add(const MeetingLists());

                              router.push('/meetings',
                                  extra: {"fromNoti": false});
                              router.pop();
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
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.meetings,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    context.read<PermissionsBloc>().isManageActivityLog == true
                        ? InkWell(
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/activitylog");
                              BlocProvider.of<ActivityLogBloc>(context)
                                  .add(AllActivityLogList());
                              Navigator.pop(context);
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
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text: AppLocalizations.of(context)!
                                        .activitylogs,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    role == "admin"
                        ? InkWell(
                            onTap: () {
                              toggleDrawer(false);
                              router.push("/settings");
                              BlocProvider.of<SettingsBloc>(context)
                                  .add(SettingsList("general_settings"));
                              Navigator.pop(context);
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
                                  SizedBox(
                                    width: 20.w,
                                  ),
                                  CustomText(
                                    text:
                                        AppLocalizations.of(context)!.settings,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .textClrChange,
                                  )
                                ],
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    InkWell(
                      onTap: () {
                        toggleDrawer(false);
                        BlocProvider.of<AuthBloc>(context).add(LoggedOut(
                          context: context,
                        ));
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
                            SizedBox(
                              width: 20.w,
                            ),
                            CustomText(
                              text: AppLocalizations.of(context)!.logout,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 15.h,
                    ),
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
                                  color: AppColors.primary),
                              child: const HeroIcon(
                                size: 15,
                                HeroIcons.arrowLeft,
                                style: HeroIconStyle.solid,
                                color: AppColors.whiteColor,
                              ))
                          : Container(),
                    ),
                    const SizedBox(
                      height: 100,
                    ),
                  ],
                ),
              )),
        ));
  }
}

Widget titleTask(context, title) {
  return SizedBox(
    child: Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: CustomText(
        text: title,
        // text: getTranslated(context, 'myweeklyTask'),
        color: Theme.of(context).colorScheme.textClrChange,
        size: 18,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

Widget _myProject(
  context,
  isLightTheme,
  languageCode,
) {
  return BlocBuilder<ProjectBloc, ProjectState>(
    builder: (context, state) {
      if (state is ProjectLoading) {
        // Show loading indicator when there's no notes
        return Container(
            padding: EdgeInsets.symmetric(horizontal: 18.w),
            height: 270.h,
            // width: 400.w,

            child: const ProjectShimmer());
      } else if (state is ProjectSuccess) {
      } else if (state is ProjectError) {
        // Show error message
      } else if (state is ProjectPaginated) {
        return NotificationListener<ScrollNotification>(
          onNotification: (scrollInfo) {
            if (!state.hasReachedMax &&
                scrollInfo.metrics.pixels ==
                    scrollInfo.metrics.maxScrollExtent) {
              context.read<ProjectBloc>().add(ProjectLoadMore("", [], []));
            }
            return false;
          },
          child: Column(
            children: [
              state.project.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        titleTask(
                          context,
                          AppLocalizations.of(context)!.myproject,
                        ),
                        InkWell(
                          highlightColor: Colors.transparent,
                          splashColor: Colors.transparent,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const DashBoard(
                                    initialIndex: 1), // Navigate to index 1
                              ),
                            );
                          },
                          child: Container(
                            height: 20.h,
                            width: 100.w,
                            alignment: Alignment.centerRight,
                            // color: AppColors.red,
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: CustomText(
                                textAlign: TextAlign.end,
                                text: AppLocalizations.of(context)!.seeall,
                                // text: getTranslated(context, 'myweeklyTask'),
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                size: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox.shrink(),
              state.project.isNotEmpty
                  ? Container(
                      // color: Colors.red,
                      height: 314.h,
                      // width: 400.w
                      alignment: Alignment.centerLeft,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18.w,
                          vertical: 18.w,
                        ),
                        // shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: state.hasReachedMax
                            ? state.project
                                .length // No extra item if all data is loaded
                            : state.project.length +
                                1, // Add 1 for the loading indicator
                        itemBuilder: (context, index) {
                          if (index < state.project.length) {
                            final project = state.project[index];
                            String? date;
                            if (project.startDate != null) {
                              date = formatDateFromApi(
                                  project.startDate!, context);
                            }
                            print("frdnjhkc m ${project.priority}");
                            return Padding(
                                padding: EdgeInsets.only(right: 10.w),
                                child: InkWell(
                                  onTap: () {
                                    router.push('/projectdetails', extra: {
                                      "id": state.project[index].id,
                                    });
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          isLightTheme
                                              ? MyThemes.lightThemeShadow
                                              : MyThemes.darkThemeShadow,
                                        ],
                                        // color: Colors.red,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .containerDark,
                                        // color: colorList[
                                        //     index % colorList.length],
                                        borderRadius:
                                            BorderRadius.circular(12)),
                                    // height: 210.h,
                                    width: 250.w,
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 18.h, horizontal: 18.w),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              // width: 160.w,
                                              alignment: Alignment
                                                  .centerLeft, // Aligns the child to the start (left)
                                              padding: EdgeInsets
                                                  .zero, // Optional: Add some padding to the left if needed
                                              child: CustomText(
                                                text: project.title!,
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .textClrChange,
                                                size: 24.sp,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                fontWeight: FontWeight.w600,
                                                textAlign: TextAlign
                                                    .start, // Aligns the text to start (left)
                                              ),
                                            ),
                                          ),
                                          project.description != null
                                              ? Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 8.h),
                                                  child: htmlWidget(
                                                      project.description!,
                                                      context,
                                                      width: 290.w,
                                                      height: 36.h))
                                              : SizedBox(
                                                  height: 40.h,
                                                  child: Align(
                                                      alignment: Alignment
                                                          .centerLeft, // Horizontally left, vertically centered
                                                      child: CustomText(
                                                        text:
                                                            AppLocalizations.of(
                                                                    context)!
                                                                .nodescription,
                                                        color:
                                                            AppColors.greyColor,
                                                        size: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      )),
                                                ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          project.users!.isEmpty &&
                                                  project.clients!.isEmpty
                                              ? SizedBox.shrink()
                                              : Padding(
                                                  padding:
                                                      EdgeInsets.only(top: 0.h),
                                                  child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Expanded(
                                                          child: InkWell(
                                                              onTap: () {
                                                                userClientDialog(
                                                                  from: 'user',
                                                                  title: AppLocalizations.of(
                                                                          context)!
                                                                      .allusers,
                                                                  list: project
                                                                          .users!
                                                                          .isEmpty
                                                                      ? []
                                                                      : project
                                                                          .users,
                                                                  context:
                                                                      context,
                                                                );
                                                              },
                                                              child:
                                                                  RowDashboard(
                                                                list: project
                                                                    .users!,
                                                                title: "user",
                                                              )),
                                                        ),
                                                        Expanded(
                                                          child: InkWell(
                                                            onTap: () {
                                                              userClientDialog(
                                                                context:
                                                                    context,
                                                                from: "client",
                                                                title: project
                                                                        .clients!
                                                                        .isNotEmpty
                                                                    ? AppLocalizations.of(
                                                                            context)!
                                                                        .allclients
                                                                    : AppLocalizations.of(
                                                                            context)!
                                                                        .allclients,
                                                                list: project
                                                                        .clients!
                                                                        .isEmpty
                                                                    ? []
                                                                    : project
                                                                        .clients,
                                                              );
                                                            },
                                                            child: SizedBox(
                                                                width: 80.w,
                                                                // height: 35,
                                                                //  color: Colors.yellow,
                                                                child:
                                                                    RowDashboard(
                                                                  list: project
                                                                      .clients!,
                                                                  title:
                                                                      "client",
                                                                )),
                                                          ),
                                                        ),
                                                      ])),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          SizedBox(
                                            // color: Colors.orange,
                                            width: 240.w,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                project.status == null &&
                                                        project.status != ""
                                                    ? SizedBox.shrink()
                                                    : Column(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          CustomText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .status,
                                                            size: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .textClrChange,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 25.h,
                                                            // width: 70.w, //
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .blue
                                                                    .shade800), // Set the height of the dropdown
                                                            child: Center(
                                                              child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal: 10
                                                                              .w),
                                                                  child:
                                                                      CustomText(
                                                                    text: project
                                                                            .status ??
                                                                        "",
                                                                    color: AppColors
                                                                        .whiteColor,
                                                                    size: 12.sp,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                project.priority == null &&
                                                        project.priority != ""
                                                    ? SizedBox.shrink()
                                                    : Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .end,
                                                        children: [
                                                          CustomText(
                                                            text: AppLocalizations
                                                                    .of(context)!
                                                                .priority,
                                                            size: 15,
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .textClrChange,
                                                          ),
                                                          Container(
                                                            alignment: Alignment
                                                                .center,
                                                            height: 25.h,
                                                            // width: 70.w, //
                                                            decoration: BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10),
                                                                color: Colors
                                                                    .orange
                                                                    .shade500), // Set the height of the dropdown
                                                            child: Center(
                                                              child: Padding(
                                                                  padding: EdgeInsets
                                                                      .symmetric(
                                                                          horizontal: 10
                                                                              .w),
                                                                  child:
                                                                      CustomText(
                                                                    text: project
                                                                            .priority ??
                                                                        "",
                                                                    color: AppColors
                                                                        .whiteColor,
                                                                    size: 12.sp,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  )),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          date != null
                                              ? Row(
                                                  children: [
                                                    const HeroIcon(
                                                      HeroIcons.calendar,
                                                      style:
                                                          HeroIconStyle.solid,
                                                      color:
                                                          AppColors.blueColor,
                                                    ),
                                                    SizedBox(
                                                      width: 15.w,
                                                    ),
                                                    CustomText(
                                                      text: date,
                                                      color:
                                                          AppColors.greyColor,
                                                      size: 12,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    )
                                                  ],
                                                )
                                              : SizedBox.shrink()
                                        ],
                                      ),
                                    ),
                                  ),
                                ));
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
                      ))
                  : const SizedBox.shrink(),
            ],
          ),
        );
      }
      // Handle other states
      return const Text("");
    },
  );
}
