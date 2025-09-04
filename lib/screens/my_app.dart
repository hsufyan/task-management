import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:taskify/bloc/notes/notes_bloc.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/auth/auth_bloc.dart';
import 'package:taskify/bloc/user/user_bloc.dart';
import 'package:taskify/routes/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/client_id/clientid_bloc.dart';
import '../bloc/clients/client_event.dart';
import '../bloc/income_expense/income_expense_bloc.dart';
import '../bloc/income_expense/income_expense_event.dart';
import '../bloc/leave_req_dashboard/leave_req_dashboard_bloc.dart';
import '../bloc/leave_req_dashboard/leave_req_dashboard_event.dart';
import '../bloc/meeting/meeting_bloc.dart';
import '../bloc/birthday/birthday_bloc.dart';
import '../bloc/clients/client_bloc.dart';
import '../bloc/leave_request/leave_request_bloc.dart';
import '../bloc/notifications/push_notification/notification_push_bloc.dart';
import '../bloc/notifications/system_notification/notification_bloc.dart';
import '../bloc/priority/priority_bloc.dart';
import '../bloc/priority/priority_event.dart';
import '../bloc/project/project_bloc.dart';
import '../bloc/project_discussion/project_media/project_media_bloc.dart';
import '../bloc/project_discussion/project_milestone/project_milestone_bloc.dart';
import '../bloc/project_discussion/project_milestone/project_milestone_event.dart';
import '../bloc/project_discussion/project_milestone_filter/project_milestone_filter_bloc.dart';
import '../bloc/project_discussion/project_timeline/status_timeline_bloc.dart';
import '../bloc/project_filter/project_filter_bloc.dart';
import '../bloc/project_id/projectid_bloc.dart';

import '../bloc/roles/role_bloc.dart';
import '../bloc/roles_multi/role_multi_bloc.dart';
import '../bloc/setting/settings_bloc.dart';
import '../bloc/tags/tags_bloc.dart';
import '../bloc/tags/tags_event.dart';
import '../bloc/task_discussion/task_media/task_media_bloc.dart';
import '../bloc/task_discussion/task_timeline/task_status_timeline_bloc.dart';
import '../bloc/task_filter/task_filter_bloc.dart';
import '../bloc/task_id/taskid_bloc.dart';
import '../bloc/todos/todos_bloc.dart';
import '../bloc/user/user_event.dart';
import '../bloc/user_id/userid_bloc.dart';
import '../bloc/workspace/workspace_bloc.dart';
import '../bloc/activity_log/activity_log_bloc.dart';
import '../bloc/dashboard_stats/dash_board_stats_bloc.dart';
import '../bloc/languages/language_switcher_bloc.dart';
import '../bloc/languages/language_switcher_state.dart';
import '../bloc/multi_tag/tag_multi_bloc.dart';
import '../bloc/priority_multi/priority_multi_bloc.dart';
import '../bloc/profile_picture/profile_pic_bloc.dart';
import '../bloc/project_multi/project_multi_bloc.dart';
import '../bloc/single_client/single_client_bloc.dart';
import '../bloc/single_select_project/single_select_project_bloc.dart';
import '../bloc/single_select_project/single_select_project_event.dart';
import '../bloc/single_user/single_user_bloc.dart';
import '../bloc/status/status_bloc.dart';
import '../bloc/status/status_event.dart';
import '../bloc/status_multi/status_multi_bloc.dart';
import '../bloc/task/task_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../bloc/user_profile/user_profile_bloc.dart';
import '../bloc/work_anniveresary/work_anniversary_bloc.dart';
import '../bloc/workspace/workspace_event.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class MyApp extends StatefulWidget {
  final bool isDarkTheme;

  const MyApp({super.key, required this.isDarkTheme});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {

  bool initialized = false;
  late final bool isDarkTheme;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String? fcmToken;


  @override
  void initState() {
    super.initState();
    _initializeNotification();
    ThemeBloc.loadTheme().then((value) {
    setState(() {
      isDarkTheme = value;
      initialized = true;
    });
  });
  }

  Future<void> _initializeNotification() async {
    // await NotificationService(context:context).initFirebaseMessaging(context);
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: ThemeBloc.loadTheme(), // Load theme from Hive asynchronously
      builder: (context, snapshot) {
      //  final isDarkTheme = snapshot.data ?? false;
        return MultiProvider(
            providers: [
              BlocProvider(
                create: (context) {
                  final themeBloc = ThemeBloc();
                //  themeBloc.add(InitialThemeEvent(isDarkTheme));
                  return themeBloc;
                },
              ),
              BlocProvider(
                  create: (_) => LanguageBloc.instance), // Add this line
              BlocProvider(create: (_) => AuthBloc()),
              BlocProvider(create: (_) => ProfilePicBloc()),
              BlocProvider(create: (_) => TaskBloc()),
              BlocProvider(create: (_) => UserBloc()..add(UserList())),
              BlocProvider(create: (_) => NotesBloc()),
              BlocProvider(create: (_) => TodosBloc()),
              BlocProvider(create: (_) => ProjectBloc()),
              BlocProvider(create: (_) => SingleClientBloc()),
              BlocProvider(create: (_) => ActivityLogBloc()),
              BlocProvider(create: (_) => WorkAnniversaryBloc()),
              BlocProvider(create: (_) => LeaveRequestBloc()),
              BlocProvider(create: (_) => ClientidBloc()),
              BlocProvider(create: (_) => TaskFilterCountBloc()),
              BlocProvider(create: (_) => TaskidBloc()),
              BlocProvider(create: (context) => ChartBloc()..add(FetchChartData(startDate: "",endDate: ""))),

              BlocProvider(
                  create: (_) => WorkspaceBloc()..add(WorkspaceList())),
              BlocProvider(create: (_) => MeetingBloc()),
              BlocProvider(create: (_) => NotificationBloc()),
              BlocProvider(create: (_) => NotificationPushBloc()),
              BlocProvider(create: (_) => TaskMediaBloc()),
              BlocProvider(create: (_) => TaskStatusTimelineBloc()),
              BlocProvider(create: (_) => UserProfileBloc()),
              BlocProvider(create: (_) => UseridBloc()),
              BlocProvider(create: (_) => ProjectidBloc()),
              BlocProvider<FilterCountBloc>(
                  create: (context) => FilterCountBloc()),
              BlocProvider(
                  create: (_) => LeaveReqDashboardBloc()
                    ..add(WeekLeaveReqListDashboard([], 7))),
              BlocProvider(create: (_) => RoleBloc()),
              BlocProvider(create: (_) => RoleMultiBloc()),
              BlocProvider(create: (_) => TagsBloc()..add(TagsList())),
              BlocProvider(create: (_) => PermissionsBloc()),
              BlocProvider(create: (_) => SingleUserBloc()),
              BlocProvider(create: (_) => ClientBloc()..add(ClientList())),
              BlocProvider(create: (_) => FilterCountOfMilestoneBloc()),
              BlocProvider(create: (_) => BirthdayBloc()),
              BlocProvider(create: (_) => DashBoardStatsBloc()),
              BlocProvider(create: (_) => SingleSelectProjectBloc()),
              BlocProvider(create: (_) => SettingsBloc()),
              BlocProvider(create: (_) => ProjectMilestoneBloc()..add(MileStoneList())),
              BlocProvider(create: (_) => StatusMultiBloc()),
              BlocProvider(create: (_) => PriorityMultiBloc()),
              BlocProvider(create: (_) => TagMultiBloc()),
              BlocProvider(create: (_) => ProjectMultiBloc()),
              BlocProvider(create: (_) => ProjectMediaBloc()),
              BlocProvider(create: (_) => StatusTimelineBloc()),
              BlocProvider(create: (_) => StatusBloc()..add(StatusList())),
              BlocProvider(
                create: (_) => PriorityBloc()..add(PriorityLists()),
              ),
              BlocProvider(
                create: (_) =>
                    SingleSelectProjectBloc()..add(SingleProjectList()),
              ),
            ],
            child: BlocBuilder<ThemeBloc, ThemeState>(
                builder: (context, themeState) {
              // Update the System UI overlay style based on the theme state
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (themeState is DarkThemeState) {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness: Brightness.light,
                    statusBarBrightness: Brightness.dark,
                  ));
                } else {
                  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
                    statusBarColor:
                        Colors.transparent, // Change to the desired color
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light,
                  ));
                }
              });

              return BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, languageState) {
                  return ScreenUtilInit(
                    designSize: const Size(375, 812),
                    minTextAdapt: true,
                    builder: (context, child) {
                      return GestureDetector(
                        onTap: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        child: SafeArea(
                          child: MaterialApp.router(
                            routerConfig: router,
                            locale: languageState.locale,
                            supportedLocales: const [
                              Locale("af"),
                              Locale("am"),
                              Locale("ar"),
                              Locale("az"),
                              Locale("be"),
                              Locale("bg"),
                              Locale("bn"),
                              Locale("bs"),
                              Locale("ca"),
                              Locale("cs"),
                              Locale("da"),
                              Locale("de"),
                              Locale("el"),
                              Locale("en"),
                              Locale("es"),
                              Locale("et"),
                              Locale("fa"),
                              Locale("fi"),
                              Locale("fr"),
                              Locale("gl"),
                              Locale("ha"),
                              Locale("he"),
                              Locale("hi"),
                              Locale("hr"),
                              Locale("hu"),
                              Locale("hy"),
                              Locale("id"),
                              Locale("is"),
                              Locale("it"),
                              Locale("ja"),
                              Locale("ka"),
                              Locale("kk"),
                              Locale("km"),
                              Locale("ko"),
                              Locale("ku"),
                              Locale("ky"),
                              Locale("lt"),
                              Locale("lv"),
                              Locale("mk"),
                              Locale("ml"),
                              Locale("mn"),
                              Locale("ms"),
                              Locale("nb"),
                              Locale("nl"),
                              Locale("nn"),
                              Locale("no"),
                              Locale("pl"),
                              Locale("ps"),
                              Locale("pt"),
                              Locale("ro"),
                              Locale("ru"),
                              Locale("sd"),
                              Locale("sk"),
                              Locale("sl"),
                              Locale("so"),
                              Locale("sq"),
                              Locale("sr"),
                              Locale("sv"),
                              Locale("ta"),
                              Locale("tg"),
                              Locale("th"),
                              Locale("tk"),
                              Locale("tr"),
                              Locale("tt"),
                              Locale("uk"),
                              Locale("ug"),
                              Locale("ur"),
                              Locale("uz"),
                              Locale("vi"),
                              Locale("zh")
                              // Locale('en'),
                              // Locale('hi'),
                              // Locale('ar'),
                              // Locale('ko'),
                              // Locale('pt'),
                              // Locale('vi'),
                            ],
                            localizationsDelegates: [
                              AppLocalizations.delegate,
                              CountryLocalizations.delegate,
                              GlobalMaterialLocalizations.delegate,
                              GlobalWidgetsLocalizations.delegate,
                              GlobalCupertinoLocalizations.delegate,
                            ],
                            debugShowCheckedModeBanner: false,
                            theme: themeState is LightThemeState
                                ? ThemeData.light()
                                : ThemeData.dark(),
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }));
      },
    );
  }
}
