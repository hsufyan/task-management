import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_bloc.dart';
import '../../bloc/project_discussion/project_milestone_filter/project_milestone_filter_event.dart';
import '../../bloc/project_id/projectid_bloc.dart';
import '../../bloc/project_id/projectid_event.dart';
import '../../bloc/project_id/projectid_state.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/status/status_bloc.dart';
import '../../bloc/status/status_event.dart';
import '../../bloc/task_id/taskid_bloc.dart';
import '../../bloc/task_id/taskid_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../config/colors.dart';
import '../../config/constants.dart';
import '../../data/model/Project/all_project.dart';
import '../../data/model/task/task_model.dart';
import '../../data/repositories/Task/task_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/user_client_row_detail_page.dart';
import '../../utils/widgets/users_in_task_details.dart';
import '../dash_board/dashboard.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/custom_container.dart';
import '../widgets/detail_page_menu.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';

class ProjectDetails extends StatefulWidget {
  final int? id;
  final bool? fromNoti;
  final String? from;

  const ProjectDetails({super.key, this.id, this.fromNoti, this.from});

  @override
  State<ProjectDetails> createState() => _ProjectDetailsState();
}

class _ProjectDetailsState extends State<ProjectDetails> {
  // List of items in our dropdown menu

  // Function to handle checkbox state change
  List<int> userId = [];
  List<ProjectUsers>? users;
  List<int>? usersIds = [];
  List<int>? clientIds = [];
  List<Tag>? tags = [];
  List<int>? tagIds = [];
  List<ProjectClients>? clients;
  List<String>? clientList;
  List<String>? userList;
  List<int> clientId = [];
  List<String>? tagList;
  String? statusFrom;
  String? priority;
  String? note;
  String? createdAt;
  String? updatedAt;
  String? taskAccessibility;
  int? priorityId;
  List<int>? tagId;
  int? statusId;
  String? title;
  String? status;
  bool? isLoading = true;
  bool? isLoadingOnRefresh = true;
  String? description;
  List<Tasks> task = [];
  int? statusIds;
  String? currency;
  String? currencyPosition;

  String? budget;
  String? endDate;
  String? hasGuard;
  String? startDate;
  String? taskAccess;
  String dateCreated = '';
  String dateUpdated = '';
  String dateStart = '';
  String dateEnd = '';
  bool isLoadingTask = false;
  List<ProjectModel> project = [];
  final _key = GlobalKey<ExpandableFabState>();

  _getTask() async {
    setState(() {
      isLoadingTask = true;
    });
    Map<String, dynamic> result =
        await TaskRepo().getTask(token: true, projectId: [widget.id!]);
    task = List<Tasks>.from(
        result['data'].map((projectData) => Tasks.fromJson(projectData)));
    setState(() {
      isLoadingTask = false;
    });
  }

  void _onDeleteProject(projectId) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(projectId));
    setting.stream.listen((state) {
      if (state is ProjectDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 1),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'projectdetails';
            },
          );

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 1),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'projectdetails';
            },
          );

          flutterToastCustom(msg: state.errorMessage);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 1),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'projectdetails';
            },
          );

          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  void _onEditProject() {
    _key.currentState?.toggle();
    List<String>? userList = [];

    List<String>? clientList = [];
    List<String>? tagList = [];

    if (users != null) {
      for (var user in users!) {
        userList.add(user.firstName!);
        userId.add(user.id!);
      }
    }
    if (clients != null) {
      for (var client in clients!) {
        clientList.add(client.firstName!);
        clientId.add(client.id!);
      }
    }

    if (tags != null) {
      for (var tag in tags!) {
        tagList.add(tag.title!);
      }
    }
    context.read<PermissionsBloc>().iseditProject == true
        ? router.push(
            '/createproject',
            extra: {
              "id": widget.id,
              "isCreate": false,
              "fromDetail": true,
              "title": title,
              "desc": description,
              "start": startDate ?? "",
              "end": endDate ?? "",
              "budget": budget,
              'priority': priority,
              'priorityId': priorityId,
              'statusId': statusId,
              'note': note,
              "clientNames": clientList,
              "userNames": userList,
              "tagNames": tagList,
              "userId": userId,
              "tagId": tagId,
              "clientId": clientId,
              "access": taskAccessibility,
              'status': status,
            },
          )
        : null;
  }

  @override
  void initState() {
    hasGuard = context.read<AuthBloc>().guard;

    _getTask();

    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;
    context
        .read<FilterCountOfMilestoneBloc>()
        .add(ProjectResetFilterCountOfMilestone());
    BlocProvider.of<ProjectidBloc>(context).add(ProjectIdListId(widget.id));
    super.initState();
  }

  Future<void> _onRefresh() async {
    _getTask();

    BlocProvider.of<ProjectidBloc>(context).add(ProjectIdListId(widget.id));
  }

  final SlidableBarController controller =
      SlidableBarController(initialStatus: false);

  @override
  Widget build(BuildContext context) {
    bool isCreateTask = context.read<PermissionsBloc>().iscreatetask!;
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          print("jkflrgfjgh g");
          print("jkflrgfjgh g${widget.from}");
          if (widget.from == "fav") {
            print("pvgrhjgkfzgh ");
            router.pop();
            BlocProvider.of<ProjectBloc>(context)
                .add(ProjectDashBoardFavList(isFav: 1));
          }
          if (widget.from == "dashboard") {
            router.pop();
            BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
            BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
          }
          if (!didPop) {
            router.pop();
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton: context
                          .read<PermissionsBloc>()
                          .isdeleteProject ==
                      true ||
                  context.read<PermissionsBloc>().iseditProject == true
              ? detailMenu(
            //  isDiscuss:true,
                  isEdit: context.read<PermissionsBloc>().iseditProject,
                  isDelete: context.read<PermissionsBloc>().isdeleteProject,
                  key: _key,
                  context: context,
                  onpressEdit: () {
                    _onEditProject();
                    // Navigator.pop(context);
                  },
                  onpressDelete: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                10.r), // Set the desired radius here
                          ),
                          backgroundColor: Theme.of(context)
                              .colorScheme
                              .alertBoxBackGroundColor,
                          title: Text(
                            AppLocalizations.of(context)!.confirmDelete,
                          ),
                          content: Text(
                            AppLocalizations.of(context)!.areyousure,
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                _onDeleteProject(widget.id);
                              },
                              child: Text(AppLocalizations.of(context)!.delete),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(false); // Cancel deletion
                              },
                              child: Text(AppLocalizations.of(context)!.cancel),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  onpressdiscuss: () {
                    _key.currentState?.toggle();
                    router.push(
                      "/discussionTabs",
                      extra: {"isDetail": true, "id": widget.id},
                    );
                  },
                )
              : SizedBox.shrink(),
          body: Container(
              color: Theme.of(context).colorScheme.backGroundColor,
              child: SideBar(
                  context: context,
                  controller: controller,
                  underWidget: RefreshIndicator(
                    color: AppColors.primary, // Spinner color
                    backgroundColor:
                        Theme.of(context).colorScheme.backGroundColor,
                    onRefresh: _onRefresh,
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: BackArrow(
                                onTap: () {
                                  print("jkflrgfjgh g");
                                  print("jkflrgfjgh g${widget.from}");
                                  if (widget.from == "fav") {
                                    print("pvgrhjgkfzgh ");
                                    router.pop();
                                    BlocProvider.of<ProjectBloc>(context)
                                        .add(ProjectDashBoardFavList(isFav: 1));
                                  }
                                  if (widget.from == "dashboard") {
                                    print("pvgrhjgkfzgh ");
                                    router.pop();
                                    BlocProvider.of<ProjectBloc>(context)
                                        .add(ProjectDashBoardList());
                                  }
                                  router.pop();
                                },
                                fromNoti: "project",
                                title: AppLocalizations.of(context)!
                                    .projectdetails,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            BlocConsumer<ProjectidBloc, ProjectidState>(
                                listener: (context, state) {
                              if (state is ProjectDeleteSuccess) {
                                Navigator.of(context).pushAndRemoveUntil(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const DashBoard(initialIndex: 1),
                                  ),
                                  (route) {
                                    return route is! MaterialPageRoute ||
                                        route.settings.name != 'projectdetails';
                                  },
                                );

                                flutterToastCustom(
                                    msg: AppLocalizations.of(context)!
                                        .deletedsuccessfully,
                                    color: AppColors.primary);
                              }
                              if (state is ProjectidWithId) {
                                for (var item in state.project) {
                                  title = item.title;
                                  status = item.status;
                                  statusIds = item.statusId; //int
                                  priority = item.priority;
                                  priorityId = item.priorityId;
                                  users = item.users;
                                  usersIds = item.userId;
                                  clients = item.clients;
                                  status = item.status;
                                  clientIds = item.clientId;
                                  tags = item.tags; //list int
                                  tagIds = item.tagIds; //list int
                                  startDate = item.startDate;
                                  endDate = item.endDate;
                                  budget = item.budget;
                                  taskAccessibility = item.taskAccessibility;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                  dateCreated =
                                      formatDateFromApi(createdAt!, context);
                                  dateUpdated =
                                      formatDateFromApi(createdAt!, context);
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (endDate != null) {
                                    dateEnd =
                                        formatDateFromApi(endDate!, context);
                                  }
                                  // clientIds = item.c;
                                }
                              }
                            }, builder: (context, state) {
                              if (state is ProjectidWithId) {
                                for (var item in state.project) {
                                  title = item.title;
                                  status = item.status;
                                  statusIds = item.statusId; //int
                                  priority = item.priority;
                                  priorityId = item.priorityId;
                                  users = item.users;
                                  usersIds = item.userId;
                                  clients = item.clients;
                                  status = item.status;
                                  clientIds = item.clientId;
                                  tags = item.tags; //list int
                                  tagIds = item.tagIds; //list int
                                  startDate = item.startDate;
                                  endDate = item.endDate;
                                  budget = item.budget;
                                  taskAccessibility = item.taskAccessibility;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                  dateCreated =
                                      formatDateFromApi(createdAt!, context);
                                  dateUpdated =
                                      formatDateFromApi(createdAt!, context);
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (endDate != null) {
                                    dateEnd =
                                        formatDateFromApi(endDate!, context);
                                  }
                                  // clientIds = item.c;
                                }
                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _projectCard(context),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _budgetAndTaskAccess(context),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _dateCard(context, dateStart,
                                          dateEnd, dateCreated, dateUpdated),
                                    ),
                                    note != null && note!.isNotEmpty
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox.shrink(),
                                    note != null && note!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _noteCard(),
                                          )
                                        : SizedBox.shrink(),
                                    users != null && users!.isNotEmpty
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox.shrink(),
                                    users != null && users!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _usersCard(context, users),
                                          )
                                        : SizedBox.shrink(),
                                    clients != null && clients!.isNotEmpty
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox.shrink(),
                                    clients != null && clients!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child:
                                                _clientsCard(context, clients),
                                          )
                                        : SizedBox.shrink(),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Divider(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .dividerClrChange),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _taskCard(context, task,
                                          isCreateTask, isLoadingTask),
                                    ),
                                    SizedBox(
                                      height: 50.h,
                                    ),
                                  ],
                                );
                              }
                              if (state is ProjectidLoading) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Column(
                                    children: [
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 50.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              if (state is ProjectidInitial) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Column(
                                    children: [
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 150.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 50.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      shimmerDetails(
                                          isLightTheme, context, 120.h),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                );
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: Column(
                                  children: [
                                    shimmerDetails(
                                        isLightTheme, context, 150.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 150.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(isLightTheme, context, 50.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 120.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    shimmerDetails(
                                        isLightTheme, context, 120.h),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(
                              height: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  hasGuard: hasGuard)),
        ));
  }

  Widget _noteCard() {
    return customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                text: "${AppLocalizations.of(context)!.note}  ",
                size: 18.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              SizedBox(
                height: 10.w,
              ),
              CustomText(
                text: "$note",
                size: 14.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.textClrChange,
              )
            ],
          ),
        ));
  }

  Widget _projectCard(context) {
    return customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              CustomText(
                text: title ?? "",
                fontWeight: FontWeight.w700,
                size: 24,
                color: Theme.of(context).colorScheme.textClrChange,
              ),
              description != null
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              description != null
                  ? ExpandableHtmlWidget(
                      text: description ?? "",
                      context: context,
                    )
                  : SizedBox(),
              SizedBox(
                height: 10.h,
              ),
              SizedBox(
                  width: 300.w,
                  child: statusClientRow(status, priority, context, true)),
              SizedBox(
                height: 10.h,
              ),
            ],
          ),
        ));
  }

  Widget _budgetAndTaskAccess(context) {
    return customContainer(
        width: 600.w,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CustomText(
                    text: "${AppLocalizations.of(context)!.budget}:  ",
                    size: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                  // SizedBox(width: 50.w,),
                  budget != null && budget != ""
                      ? currencyPosition == "before"
                          ? CustomText(
                              text: "$currency$budget",
                              size: 14.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                          : CustomText(
                              text: " $budget$currency",
                              size: 14.sp,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            )
                      : CustomText(
                          text: "-",
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                ],
              ),
              taskAccess != null
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              taskAccess != null
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text:
                              "${AppLocalizations.of(context)!.taskaccessibility}  ",
                          size: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        // SizedBox(width: 50.w,),
                        CustomText(
                          text: "$taskAccess",
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : SizedBox.shrink(),

              // users != null && users.isNotEmpty
              //     ? SizedBox(
              //         height: 20.h,
              //       )
              //     : SizedBox.shrink(),
            ],
          ),
        ));
  }

  Widget _dateCard(context, dateStart, dateEnd, dateCreated, dateUpdated) {
    return customContainer(
        width: 600.w,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: Column(
            children: [
              startDate != null
                  ? Row(
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.startdate}: ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateStart,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              endDate != null
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox.shrink(),
              endDate != null
                  ? Row(
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.duedate}: ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateEnd,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              endDate != null
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox.shrink(),
              createdAt != null
                  ? Row(
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.createdat}: ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateCreated,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              updatedAt != null
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox.shrink(),
              updatedAt != null
                  ? Row(
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.updatedAt}: ",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: dateUpdated,
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ));
  }

  Widget _usersCard(context, users) {
    return InkWell(
      onTap: () {
        userClientDialog(
          context: context,
          title: AppLocalizations.of(context)!.allusers,
          list: users!.isEmpty ? [] : users,
          from: 'user',
        );
      },
      child: customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: users!, title: AppLocalizations.of(context)!.users),
        ),
      ),
    );
  }

  Widget _clientsCard(context, clients) {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: "client",
          context: context,
          title: AppLocalizations.of(context)!.allclients,
          list: clients!.isEmpty ? [] : clients,
        );
      },
      child: customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: clients!, title: AppLocalizations.of(context)!.clients),
        ),
      ),
    );
  }

  Widget _taskCard(context, task, isCreateTask, isLoadingTask) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.tasks,
              size: 18.sp,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
            isCreateTask == true
                ? InkWell(
                    highlightColor: Colors.transparent, // No highlight on tap
                    splashColor: Colors.transparent,
                    onTap: () {
                      BlocProvider.of<UserBloc>(context).add(UserList());
                      BlocProvider.of<StatusBloc>(context).add(StatusList());
                      router.push('/createtask', extra: {
                        "id": 0,
                        "isCreate": true,
                        "title": "",
                        "desc": "",
                        "start": "",
                        "end": "",
                        "users": [],
                        'priority': "",
                        'priorityId': 0,
                        'statusId': 0,
                        'note': "",
                        'project': "",
                        'projectId': 0,
                        'status': "",
                        'req': <Tasks>[],
                      });
                    },
                    child: Container(
                      height: 30.h,
                      width: 34.w,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          color: AppColors.primary),
                      child: const HeroIcon(
                        size: 15,
                        HeroIcons.plus,
                        style: HeroIconStyle.outline,
                        color: AppColors.pureWhiteColor,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ],
        ),
        SizedBox(
          height: 10.h,
        ),
        isLoadingTask == false
            ? task.isNotEmpty
                ? InkWell(
                    onTap: () {
                      userClientDialog(
                          from: 'task',
                          context: context,
                          title: AppLocalizations.of(context)!.allusers,
                          list: task.isEmpty ? [] : task);
                    },
                    child: task.isNotEmpty
                        ? SizedBox(
                            // color: Colors.red,
                            width: double.infinity,
                            // height: 300,
                            child: ListView.builder(
                                padding: EdgeInsets.zero,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: task.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return InkWell(
                                    onTap: () {
                                      router.push(
                                        '/taskdetail',
                                        extra: {
                                          "id": task[index].id,
                                          // your list of LeaveRequests
                                        },
                                      );
                                    },
                                    child: TaskListDetails(
                                      id: task[index].id,
                                      startDate: task[index].startDate,
                                      endDate: task[index].dueDate,
                                      clientList: task[index].clients!,
                                      userList: task[index].users!,
                                      title: task[index].title!,
                                    ),
                                  );
                                }))
                        : NoData(
                            isImage: true,
                          ))
                : customContainer(
                    width: 400.w,
                    context: context,
                    addWidget: Padding(
                      padding: EdgeInsets.all(18.w),
                      child: NoData(
                        isImage: true,
                      ),
                    ))
            : const NotesShimmer()
      ],
    );
  }
}
