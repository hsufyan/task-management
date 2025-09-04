import 'package:go_router/go_router.dart';
import 'package:taskify/screens/authentication/login_screen.dart';
import 'package:taskify/screens/authentication/sign_up_screen.dart';
import 'package:taskify/screens/email_verification_screen/email_verification.dart';
import 'package:taskify/screens/notification/notification_details.dart';
import 'package:taskify/screens/settings/about_us.dart';
import 'package:taskify/screens/settings/app_settings/company_info_screen.dart';
import 'package:taskify/screens/settings/app_settings/media_storage.dart';
import 'package:taskify/screens/settings/app_settings/roles_and_permisisions.dart';
import 'package:taskify/screens/settings/app_settings/update_permissions.dart';
import 'package:taskify/screens/settings/app_settings/security_screen.dart';
import 'package:taskify/screens/splashScreen/splash_screen.dart';
import '../config/app_images.dart';
import '../data/GlobalVariable/globalvariable.dart';
import '../data/model/clients/all_client_model.dart';
import '../data/model/notification/notification_model.dart';
import '../data/model/project/milestone.dart';
import '../data/model/task/task_model.dart';
import '../data/model/leave_request/leave_req_model.dart';
import '../data/model/user_model.dart';
import '../screens/clients/client_details.dart';
import '../screens/clients/client_screen.dart';
import '../screens/clients/create_edit_client.dart';
import '../screens/home_screen/home_widgets/all_todays_task.dart';
import '../screens/meeting/meeting_screen.dart';
import '../screens/meeting/create_meeting.dart';
import '../screens/notes/notes_screen.dart';
import '../screens/notification/notification_screen.dart';
import '../screens/priorities.dart';
import '../screens/project/discussion_screen/milestone_create_edit_screen.dart';
import '../screens/project/discussion_tabs.dart';
import '../screens/project/project_fav_screen.dart';
import '../screens/project/project_details.dart';
import '../screens/settings/app_settings/general_settings.dart';
import '../screens/settings/app_settings/email.dart';
import '../screens/settings/app_settings/messaging_integration_screen.dart';
import '../screens/settings/privacy_policy_screen.dart';
import '../screens/settings/tems_and_conditions.dart';
import '../screens/settings/setting_screen.dart';
import '../screens/status/status_screen.dart';
import '../screens/task/task_discussion_tabs.dart';
import '../screens/task/task_fav_screen.dart';
import '../screens/todos/todo_screen.dart';
import '../screens/users/create_user.dart';
import '../screens/users/user_details.dart';
import '../screens/users/user_screen.dart';
import '../screens/workspace/workspace_screen.dart';
import '../screens/activity_log/activity_log_screen.dart';
import '../screens/dash_board/dashboard.dart';
import '../screens/home_screen/home_screen.dart';
import '../screens/leave_request/create_leave_request.dart';
import '../screens/leave_request/leave_request_screen.dart';
import '../screens/onboarding_screens/onboarding_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/task/create_task.dart';
import '../screens/task/task_detail.dart';
import '../screens/project/create_project.dart';
import '../screens/project/project_from_dashboard.dart';

final router = GoRouter(
  navigatorKey: navigatorKey,
  initialLocation: '/',
  routes: [
    GoRoute(
        name: 'SplashScreen',
        path: '/',
        builder: (context, state) => SplashScreen(
            navigateAfterSeconds: 5, imageUrl: AppImages.splashLogo)),
    // GoRoute(
    //     name: 'ForgetpasswordScreen',
    //     path: '/forgetpassword',
    //     builder: (context, state) => const ForgetPassword()),
    GoRoute(
        name: 'DashBoardScreen',
        path: '/dashboard',
        builder: (context, state) => const DashBoard()),
    GoRoute(
        name: 'OnboardingScreen',
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen()),
    GoRoute(
      name: 'HomeScreen',
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      name: 'notificationScreen',
      path: '/notification',
      builder: (context, state) => const NotificationScreen(),
    ),
    GoRoute(
      name: 'emailVerification',
      path: '/emailVerification',
      builder: (context, state) => const EmailVerificationScreen(),
    ),
    GoRoute(
      name: 'activitylogscreen',
      path: '/activitylog',
      builder: (context, state) => const ActivityLogScreen(),
    ),
    GoRoute(
      name: 'StatusScreen',
      path: '/Status',
      builder: (context, state) => const StatusScreen(),
    ),
    GoRoute(
      name: 'PrioritiesScreen',
      path: '/priorities',
      builder: (context, state) => const PrioritiesScreen(),
    ),
    // GoRoute(
    //   name: 'activitylogdetailsdcreen',
    //   path: '/activitylogdetails',
    //   builder: (context, state) {
    //     final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
    //     final int index = data['index'] as int? ?? 0;
    //     // final ActivityLog activityLog = data['activityLog'] as ActivityLog;
    //     final List<ActivityLog> activityLog =
    //         (data['activityLog'] as List<dynamic>?)?.map((item) {
    //               if (item is Map<String, dynamic>) {
    //                 return ActivityLog.fromJson(item);
    //               } else if (item is ActivityLog) {
    //                 return item;
    //               } else {
    //                 throw Exception(
    //                     "Unexpected item type in list: ${item.runtimeType}");
    //               }
    //             }).toList() ??
    //             [];
    //
    //     return ActivityLogDetailsScreen(
    //         index: index, activityLogs: activityLog);
    //   },
    // ),
    GoRoute(
      name: 'notificationdetailScreen',
      path: '/notificationdetail',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;

        final int id = data['id'] as int? ?? 0;
        final String title = data['title'] as String? ?? "";
        final String status = data['status'] as String? ?? "";
        final String message = data['message'] as String? ?? "";
        final String createdAt = data['createdAt'] as String? ?? "";
        final String updatedAt = data['updatedAt'] as String? ?? "";

        // Cast req to List<LeaveRequests>
        final List<NotiUsers> users =
            (data['users'] as List<dynamic>?)?.map((item) {
                  if (item is Map<String, dynamic>) {
                    return NotiUsers.fromJson(item);
                  } else if (item is NotiUsers) {
                    return item;
                  } else {
                    throw Exception(
                        "Unexpected item type in list: ${item.runtimeType}");
                  }
                }).toList() ??
                [];
        // final List<Users> users = (data['users'] as List<dynamic>?)
        //     ?.map((item) => Users.fromJson(item as Map<String, dynamic>))
        //     .toList() ?? [];
        final List<NotiClient> clients =
            (data['clients'] as List<dynamic>?)?.map((item) {
                  if (item is Map<String, dynamic>) {
                    return NotiClient.fromJson(item);
                  } else if (item is NotiClient) {
                    return item;
                  } else {
                    throw Exception(
                        "Unexpected item type in list: ${item.runtimeType}");
                  }
                }).toList() ??
                [];

        final int index = data['index'] as int? ?? 0;
        return NotificationDetailScreen(
            id: id,
            title: title,
            status: status,
            users: users,
            clients: clients,
            message: message,
            index: index,
            createdAt: createdAt,
            updatedAt: updatedAt);
      },
    ),
    GoRoute(
        name: 'LoginScreen',
        path: '/login',
        builder: (context, state) => const LoginScreen()),
    GoRoute(
      name: 'SignUpScreen',
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      name: 'WorkSpaceScreen',
      path: '/workspace',
      builder: (context, state) => const ProjectScreen(),
    ),
    GoRoute(
      name: 'settingsScreen',
      path: '/settings',
      builder: (context, state) => const Settingscreen(),
    ),
    GoRoute(
        name: 'milestoneScreen',
        path: '/milestone',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final bool isCreate = data['isCreate'] as bool? ?? true;
          final int projectId = data['projectId'] as int? ?? 0;
          final Milestone? milestone =
              data['milestone'] as Milestone?; // Extract milestone

          return MilestoneCreateEditScreen(
              isCreate: isCreate,
              milestoneModel: milestone!,
              projectId: projectId);
        }),
    GoRoute(
        name: 'discussionTabsScreen',
        path: '/discussionTabs',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final bool isDetail = data['isDetail'] as bool? ?? true;
          final int id = data['id'] as int? ?? 0;
          return DiscussionTabs(
            fromDetail: isDetail,
            id: id,
          );
        }),
    GoRoute(
        name: 'taskdiscussionTabsScreen',
        path: '/taskdiscussionTabs',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final bool isDetail = data['isDetail'] as bool? ?? true;
          final int id = data['id'] as int? ?? 0;
          return TaskDiscussionTabs(
            fromDetail: isDetail,
            id: id,
          );
        }),
    GoRoute(
        name: 'privacyPolicyScreen',
        path: '/privacy',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final String title = data['title'] as String? ?? "";
          return PrivacyPolicyScreen(title: title);
        }),
    GoRoute(
        name: 'aboutusScreen',
        path: '/aboutUs',
        builder: (context, state) {
          return AboutUsScreen();
        }),
    GoRoute(
        name: 'favoriteScreen',
        path: '/favorite',
        builder: (context, state) {
          return FavouriteScreen();
        }),
    GoRoute(
        name: 'taskFavoriteScreen',
        path: '/taskfavorite',
        builder: (context, state) {
          return TaskFavouriteScreen();
        }),
    GoRoute(
        name: 'termsandconditionsScreen',
        path: '/termsconditions',
        builder: (context, state) {
          return TermsAndConditionsScreen();
        }),
    GoRoute(
        name: 'seeAllTaskScreen',
        path: '/seeAllTask',
        builder: (context, state) {
          return SeeAllTask();
        }),
    GoRoute(
      name: 'createprojectScreen',
      path: '/createproject',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final bool isCreate = data['isCreate'] as bool? ?? true;
        final bool fromDetail = data['fromDetail'] as bool? ?? true;
        final int id = data['id'] as int? ?? 0;
        final String title = data['title'] as String? ?? "";
        final String user = data['user'] as String? ?? "";
        final String budget = data['budget'] as String? ?? "";
        final String status = data['status'] as String? ?? "";
        final String priority = data['priority'] as String? ?? "";
        final int priorityId = data['priorityId'] as int? ?? 0;
        final int canClientDiscuss = data['canClientDiscuss'] as int? ?? 0;
        final int statusId = data['statusId'] as int? ?? 0;
        final String desc = data['desc'] as String? ?? "";
        final String note = data['note'] as String? ?? "";
        final String access = data['access'] as String? ?? "";
        final String start = data['start'] as String? ?? "";
        final String end = data['end'] as String? ?? "";
        final List<int> userId = data['userId'] as List<int>? ?? [];

        final List<int> clientId = data['clientId'] as List<int>? ?? [];

        final List<int> tagId = data['tagId'] as List<int>? ?? [];
        final List<String> userNames = data['userNames'] as List<String>? ?? [];
        final List<String> tagNames = data['tagNames'] as List<String>? ?? [];
        final List<String> clientNames =
            data['clientNames'] as List<String>? ?? [];

        // Cast req to List<LeaveRequests>

        final int index = data['index'] as int? ?? 0;
        return CreateProject(
            id: id,
            isCreate: isCreate,
            fromDetail: fromDetail,
            title: title,
            user: user,
            canClientDiscuss: canClientDiscuss,
            budget: budget,
            status: status,
            priority: priority,
            priorityId: priorityId,
            statusId: statusId,
            desc: desc,
            note: note,
            start: start,
            end: end,
            index: index,
            access: access,
            userId: userId,
            clientId: clientId,
            tagId: tagId,
            userNames: userNames,
            tagNames: tagNames,
            clientNames: clientNames);
      },
      // builder: (context, state) => CreateProject(),
    ),
    GoRoute(
        name: 'projectdetailsScreen',
        path: '/projectdetails',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final int id = data['id'] as int? ?? 0;
          final bool fromNoti = data['fromNoti'] as bool? ?? false;
          final String from = data['from'] as String? ?? "";
          return ProjectDetails(
            id: id,
            fromNoti: fromNoti,
            from: from,
          );
        }),

    GoRoute(
      name: 'taskdetailScreen',
      path: '/taskdetail',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;

        final bool fromNoti = data['fromNoti'] as bool? ?? false;
        final String from = data['from'] as String? ?? "";
        final int id = data['id'] as int? ?? 0;

        return TaskDetailScreen(
          fromNoti: fromNoti,
          from: from,
          id: id,
        );
      },
    ),
    GoRoute(
      name: 'createtaskScreen',
      path: '/createtask',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final bool isCreate = data['isCreate'] as bool? ?? true;
        final bool fromDetail = data['fromDetail'] as bool? ?? true;
        final int id = data['id'] as int? ?? 0;
        final String title = data['title'] as String? ?? "";
        final String project = data['project'] as String? ?? "";
        final int projectId = data['projectId'] as int? ?? 0;
        final String user = data['user'] as String? ?? "";
        final String status = data['status'] as String? ?? "";
        final String priority = data['priority'] as String? ?? "";
        final int priorityId = data['priorityId'] as int? ?? 0;
        final int statusId = data['statusId'] as int? ?? 0;
        final String desc = data['desc'] as String? ?? "";
        final String note = data['note'] as String? ?? "";
        final String start = data['start'] as String? ?? "";
        final String end = data['end'] as String? ?? "";
        final List<String> users = data['users'] != null
            ? (List<String>.from(data['users'] as List))
            : [];

        final List<int> usersid =
            data['usersid'] != null ? data['usersid'] as List<int> : [];

        // Cast req to List<LeaveRequests>
        final List<Tasks> req = (data['req'] as List<dynamic>)
            .map((item) => Tasks.fromJson(item as Map<String, dynamic>))
            .toList();
        final Map<String, dynamic> datas = state.extra as Map<String, dynamic>;

        final List<TaskUsers> userList = (data['userList'] as List<dynamic>?)
                ?.where((item) =>
                    item is Map<String, dynamic> ||
                    item is TaskUsers) // Filter valid items first
                .map((item) {
                  if (item is Map<String, dynamic>) {
                    return TaskUsers.fromJson(item);
                  } else if (item is TaskUsers) {
                    return item;
                  } else {
                    // This block should no longer be reached due to the filter above
                    print("Unexpected item type in list: ${item.runtimeType}");
                    return null;
                  }
                })
                .where((item) => item != null) // Filter out null items (if any)
                .cast<TaskUsers>() // Safely cast to List<TaskUsers>
                .toList() ??
            []; // Provide an empty list if the result is null

        final Tasks tasks = Tasks.fromJson(datas);
        final int index = data['index'] as int? ?? 0;
        return CreateTask(
          id: id,
          isCreate: isCreate,
          fromDetail: fromDetail,
          title: title,
          project: project,
          projectID: projectId,
          user: user,
          status: status,
          priority: priority,
          priorityId: priorityId,
          statusId: statusId,
          desc: desc,
          note: note,
          start: start,
          end: end,
          tasks: tasks,
          users: users,
          usersid: usersid,
          userList: userList,
          taskcreate: req,
          index: index,
        );
      },
    ),
    GoRoute(
        name: 'clientScreen',
        path: '/client',
        builder: (context, state) {
          // final title = state.name as String;
          return const ClientScreen();
        }),
    GoRoute(
      name: 'notesScreen',
      path: '/notes',
      builder: (context, state) => const NotesScreen(),
    ),
    GoRoute(
        name: 'leaverequestScreen',
        path: '/leaverequest',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final bool fromNoti = data['fromNoti'] as bool? ?? false;

          return LeaveRequestScreen(fromNoti: fromNoti);
        }),
    GoRoute(
      name: 'workspaceScreen',
      path: '/workspaces',
      builder: (context, state) {
        final Map<String, dynamic>? data = state.extra as Map<String, dynamic>?;
        final bool fromNoti = data?['fromNoti'] as bool? ?? false;
        return WorkspaceScreen(fromNoti: fromNoti);
      },
    ),

    GoRoute(
      name: 'meetingScreen',
      path: '/meetings',
      builder: (context, state) {
        // Provide a default empty map if state.extra is null
        final Map<String, dynamic> data =
            state.extra as Map<String, dynamic>? ?? {};
        final bool fromNoti = data['fromNoti'] as bool? ?? false;
        return MeetingScreen(fromNoti: fromNoti);
      },
    ),

    GoRoute(
      name: 'clientdetailsScreen',
      path: '/clientdetails',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;

// Retrieve the single client directly
        final int id = data['id'] as int? ?? 0;
        final String isClient = data['isClient'] as String? ?? "";

        return ClientDetailsScreen(
            id: id, isClient: isClient); // Pass the client to the screen
      },
    ),
    GoRoute(
      name: 'userScreen',
      path: '/user',
      builder: (context, state) => const UserScreen(),
    ),
    GoRoute(
      name: 'userdetailScreen',
      path: '/userdetail',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final int id = data['id'] as int? ?? 0;
        final String isUser = data['isUser'] as String? ?? "";
        final String from = data['from'] as String? ?? "";

        return UserDetailsScreen(id: id, isUser: isUser, from: from);
      },
    ),
    GoRoute(
      name: 'createuserScreen',
      path: '/createuser',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final bool isCreate = data['isCreate'] as bool? ?? true;
        final bool fromDetail = data['fromDetail'] as bool? ?? true;
        final User? userModel = data['userModel'] as User?;
        // Cast req to List<User>
        final List<User> users = (data['users'] as List<dynamic>?)?.map((item) {
              if (item is Map<String, dynamic>) {
                return User.fromJson(item);
              } else if (item is User) {
                return item;
              } else {
                throw Exception(
                    "Unexpected item type in list: ${item.runtimeType}");
              }
            }).toList() ??
            [];

        // final int index = data['index'] as int? ?? 0;
        return CreateUserScreen(
          isCreate: isCreate,
          fromDetail: fromDetail,
          userModel: userModel,
          user: users,
          // index: index,
        );
      },
    ),
    GoRoute(
      name: 'createeditclientScreen',
      path: '/createclient',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final bool isCreate = data['isCreate'] as bool? ?? true;
        final bool fromDetail = data['fromDetail'] as bool? ?? true;
        final AllClientModel? clientModel =
            data['clientModel'] as AllClientModel?;
        // // Cast req to List<User>
        // final List<AllClientModel> clients =
        //     (data['clients'] as List<dynamic>?)?.map((item) {
        //           if (item is Map<String, dynamic>) {
        //             return AllClientModel.fromJson(item);
        //           } else if (item is AllClientModel) {
        //             return item;
        //           } else {
        //             throw Exception(
        //                 "Unexpected item type in list: ${item.runtimeType}");
        //           }
        //         }).toList() ??
        //         [];

        final int index = data['index'] as int? ?? 0;
        return CreateEditClientScreen(
          isCreate: isCreate,
          clientModel: clientModel,
          fromDetail: fromDetail,
          // client: clients,
          index: index,
        );
      },
    ),
    GoRoute(
      name: 'profileScreen',
      path: '/profile',
      builder: (context, state) => const ProfileScreenn(),
    ),
    GoRoute(
      name: 'messagingIntegrationScreen',
      path: '/messagingintegration',
      builder: (context, state) => const MessagingIntegrationScreen(),
    ),
    GoRoute(
      name: 'updatePermissionScreen',
      path: '/updateRolePermission',
      builder: (context, state) => const UpdatePermissionsScreen(),
    ),
    GoRoute(
      name: 'mediaStorageScreen',
      path: '/mediastorage',
      builder: (context, state) => const MediaStorageScreen(),
    ),
    GoRoute(
        name: 'permissionsScreen',
        path: '/permissions',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final int roleId = data['roleId'] as int? ?? 0;
          final String roleName = data['roleName'] as String? ?? "";
          final bool isCreate = data['isCreate'] as bool? ?? true;
          return PermissionsToRole(
              roleId: roleId, roleName: roleName, isCreate: isCreate);
        }),
    GoRoute(
        name: 'createmeetingScreen',
        path: '/createmeeting',
        builder: (context, state) {
          final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          final bool isCreate = data['isCreate'] as bool? ?? true;
          final int id = data['id'] as int? ?? 0;
          return CreateMeetingScreen(
            isCreate: isCreate,
            id: id,
          );
        }),
    GoRoute(
      name: 'todosScreen',
      path: '/todos',
      builder: (context, state) => const TodosScreen(),
    ),
    GoRoute(
      name: 'appSettingScreen',
      path: '/appSetting',
      builder: (context, state) => const AppSettingScreen(),
    ),
    GoRoute(
      name: 'emailScreen',
      path: '/emailSetting',
      builder: (context, state) => const EmailSettingScreen(),
    ),
    GoRoute(
      name: 'companyInfoScreen',
      path: '/companyInfo',
      builder: (context, state) => const CompanyInfoScreen(),
    ),
    GoRoute(
      name: 'securityScreen',
      path: '/security',
      builder: (context, state) => const SecurityScreen(),
    ),
    GoRoute(
      name: 'createleaveRequestScreen',
      path: '/createleaverequest',
      builder: (context, state) {
        final Map<String, dynamic> data = state.extra as Map<String, dynamic>;
        final bool isCreate = data['isCreate'] as bool? ?? true;

// Cast req to LeaveRequests directly
        final List<LeaveRequests> req = (data['req'] as List<dynamic>)
            .map((item) => LeaveRequests.fromJson(item as Map<String, dynamic>))
            .toList();

        final int index = data['index'] as int? ?? 0;
        return CreateLeaveRequestScreen(
          isCreate: isCreate,
          leaveReq: req, // Pass the single instance here
          index: index,
        );
      },
    )
  ],
);
