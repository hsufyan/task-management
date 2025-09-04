import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/screens/widgets/custom_container.dart';

import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:taskify/utils/widgets/status_priority_row.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/task_id/taskid_bloc.dart';
import '../../bloc/task_id/taskid_event.dart';
import '../../bloc/task_id/taskid_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/constants.dart';
import '../../data/model/create_task_model.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/user_client_row_detail_page.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';

import '../dash_board/dashboard.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/detail_page_menu.dart';
import '../widgets/html_widget.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';

class TaskDetailScreen extends StatefulWidget {
  final bool? fromNoti;
  final String? from;
  final int? id;
  const TaskDetailScreen({
    super.key,
    this.fromNoti,
    this.from,
    this.id,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();

  String selectedCategory = '';
  final _key = GlobalKey<ExpandableFabState>();
  List<Tasks> task = [];
  List<String> username = [];

  int? id;
  int? workspaceId;
  String? title;
  String? status;
  int? statusId;
  String? priority;
  int? priorityId;
  List<TaskUsers>? users;
  List<int>? userId;
  List<TaskClients>? clients;
  String? startDate;
  String? dueDate;
  String? project;
  int? projectId;
  String? description;
  String? note;
  String? createdAt;
  String? updatedAt;
  String dateCreated = '';
  String dateUpdated = '';
  String dateStart = '';
  String dateEnd = '';
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void initState() {
    BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
    print("rjghnnkj ${widget.from}");
    super.initState();
  }

  void _onDeleteTask(taskId) {
    final setting = context.read<TaskBloc>();
    BlocProvider.of<TaskBloc>(context).add(DeleteTask(taskId));
    setting.stream.listen((state) {
      if (state is TaskDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is TaskDeleteError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );
          flutterToastCustom(msg: state.errorMessage);
        }
      }
      if (state is TaskError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) {
              return route is! MaterialPageRoute ||
                  route.settings.name != 'taskdetail';
            },
          );
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
        if (!didPop) {
          router.pop();
        }
      },
      child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          floatingActionButtonLocation: ExpandableFab.location,
          floatingActionButton:
              context.read<PermissionsBloc>().isdeleteTask == true ||
                      context.read<PermissionsBloc>().iseditTask == true
                  ? detailMenu(
                      isDiscuss: true,
                      isEdit: context.read<PermissionsBloc>().iseditTask,
                      isDelete: context.read<PermissionsBloc>().isdeleteTask,
                      key: _key,
                      context: context,
                      onpressEdit: () {
                        _key.currentState?.toggle();
                        List<String> username = [];
                        for (var names in users!) {
                          username.add(names.firstName!);
                        }
                        List<int>? ids = [];
                        for (var i in users!) {
                          ids.add(i.id!);
                        }
                        router.push(
                          '/createtask',
                          extra: {
                            "id": widget.id,
                            "isCreate": false,
                            "fromDetail": true,
                            "title": title,
                            "users": username,
                            "desc": description,
                            "start": startDate,
                            "end": dueDate,
                            // "user":task.users,
                            'priority': priority,
                            // or true, depending on your needs
                            'priorityId': priorityId,
                            "usersid": ids,
                            // or true, depending on your needs
                            'statusId': statusId,
                            // or true, depending on your needs
                            'note': note,
                            // or true, depending on your needs
                            'project': project,
                            "userList": users,
                            // "users": username,
                            // or true, depending on your needs
                            'projectId': projectId,
                            // or true, depending on your needs
                            'status': status,
                            // or true, depending on your needs
                            'req': <CreateTaskModel>[],
                            // your list of LeaveRequests
                          },
                        );
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
                                    _onDeleteTask(widget.id);
                                  },
                                  child: const Text('Delete'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(false); // Cancel deletion
                                  },
                                  child: const Text('Cancel'),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      onpressdiscuss: () {
                        _key.currentState?.toggle();
                        router.push(
                          "/taskdiscussionTabs",
                          extra: {"isDetail": true, "id": widget.id},
                        );
                      })
                  : SizedBox.shrink(),
          body: SideBar(
              context: context,
              controller: sideBarController,
              underWidget: RefreshIndicator(
                  color: AppColors.primary, // Spinner color
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  onRefresh: _onRefresh,
                  child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0.w),
                      child: SingleChildScrollView(
                        physics:
                            const AlwaysScrollableScrollPhysics(), // Ensure always scrollable

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 18.w),
                              child: _appbar(isLightTheme),
                            ),
                            // SizedBox(height: 30.h),
                            const SizedBox(
                              height: 20,
                            ),
                            BlocConsumer<TaskidBloc, TaskidState>(
                                listener: (context, state) {
                              if (state is TaskidWithId) {
                                dateCreated = '';
                                dateUpdated = '';
                                dateStart = '';
                                dateEnd = '';
                                for (var item in state.task) {
                                  title = item.title;
                                  status = item.status;
                                  priority = item.priority;
                                  users = item.users;
                                  clients = item.clients;
                                  project = item.project;
                                  startDate = item.startDate;
                                  dueDate = item.dueDate;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                  priorityId = item.priorityId;
                                  userId = item.userId;
                                  users = item.users;
                                  statusId = item.statusId;
                                  projectId = item.projectId;

                                  if (createdAt != null) {
                                    dateCreated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (createdAt != null) {
                                    dateUpdated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (dueDate != null) {
                                    dateEnd =
                                        formatDateFromApi(dueDate!, context);
                                  }

                                  // clientIds = item.c;
                                }
                              }
                            }, builder: (context, state) {
                              if (state is TaskidWithId) {
                                dateCreated = '';
                                dateUpdated = '';
                                dateStart = '';
                                dateEnd = '';
                                for (var item in state.task) {
                                  title = item.title;
                                  status = item.status;
                                  priority = item.priority;
                                  users = item.users;
                                  clients = item.clients;
                                  project = item.project;
                                  startDate = item.startDate;
                                  dueDate = item.dueDate;
                                  description = item.description;
                                  note = item.note;
                                  createdAt = item.createdAt;
                                  updatedAt = item.updatedAt;
                                  priorityId = item.priorityId;
                                  userId = item.userId;
                                  users = item.users;
                                  statusId = item.statusId;
                                  projectId = item.projectId;

                                  if (createdAt != null) {
                                    dateCreated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (createdAt != null) {
                                    dateUpdated =
                                        formatDateFromApi(createdAt!, context);
                                  }
                                  if (startDate != null) {
                                    dateStart =
                                        formatDateFromApi(startDate!, context);
                                  }
                                  if (dueDate != null) {
                                    dateEnd =
                                        formatDateFromApi(dueDate!, context);
                                  }

                                  // clientIds = item.c;
                                }

                                return Column(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _taskCard(),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _dateCard(dateStart, dateEnd,
                                          dateCreated, dateUpdated),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 18.w),
                                      child: _project(),
                                    ),
                                    SizedBox(
                                      height: 20.h,
                                    ),
                                    note != null
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _noteCard(),
                                          )
                                        : SizedBox(),
                                    note != null
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox(),
                                    users != null && users!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _usersCard(),
                                          )
                                        : SizedBox.shrink(),
                                    clients != null && clients!.isNotEmpty
                                        ? SizedBox(
                                            height: 20.h,
                                          )
                                        : SizedBox(),
                                    clients != null && clients!.isNotEmpty
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.w),
                                            child: _clientsCard(),
                                          )
                                        : SizedBox.shrink(),
                                    SizedBox(
                                      height: 60.h,
                                    ),
                                  ],
                                );
                              }
                              if (state is TaskLoading) {
                                return Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 18.w),
                                  child: Column(
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
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
                                    const SizedBox(
                                      height: 20,
                                    ),
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
                          ],
                        ),
                      ))))),
    );
  }

  Widget _appbar(isLightTheme) {
    return Container(
        decoration: BoxDecoration(boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ]),
        // color: Colors.red,
        // width: 300.w,
        child: BackArrow(
          onTap: () {
            if (widget.from == "subtask") {
              BlocProvider.of<TaskBloc>(context)
                  .add(AllTaskListOnTask(id: widget.id));
              router.pop();
            } else if (widget.from == "dashboard") {
              BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
              router.pop();
            }
          },
          isAdd: false,
          isDetailPage: true,
          isEditFromDetail: context.read<PermissionsBloc>().iseditTask,
          isDeleteFromDetail: context.read<PermissionsBloc>().isdeleteTask,
          isEditCreate: true,
          fromNoti: "task",
          title: AppLocalizations.of(context)!.taskdetail,
        ));
  }

  Widget _taskCard() {
    return customContainer(
      width: double.infinity,
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
            SizedBox(
              height: 10.h,
            ),
            ExpandableHtmlWidget(
              text: description ?? "",
              context: context,
              width: 290.w,
            ),
            SizedBox(
              height: 10.h,
            ),
            SizedBox(
                // color: Colors.red,
                // width: 240.w,
                child: statusClientRow(status, priority, context, true)),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(dateStart, dateEnd, dateCreated, dateUpdated) {
    return customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
          child: Column(
            children: [
              startDate != null && startDate!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.startdate} : ",
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
              startDate != null && startDate!.isNotEmpty
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox.shrink(),
              dueDate != null && dueDate!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.duedate} :",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: " $dateEnd",
                          size: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.textClrChange,
                        )
                      ],
                    )
                  : const SizedBox.shrink(),
              dueDate != null && dueDate!.isNotEmpty
                  ? SizedBox(
                      height: 10.h,
                    )
                  : SizedBox(),
              createdAt != null && createdAt!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.createdat} : ",
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
              SizedBox(
                height: 10.h,
              ),
              updatedAt != null && updatedAt!.isNotEmpty
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "${AppLocalizations.of(context)!.updatedAt} :",
                          size: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        CustomText(
                          text: " $dateUpdated",
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

  Widget _project() {
    return InkWell(
      onTap: () {
        router.push('/projectdetails', extra: {
          "id": projectId,
        });
      },
      child: customContainer(
          width: double.infinity,
          context: context,
          addWidget: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                project != null
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 3,
                            child: CustomText(
                              text:
                                  "${AppLocalizations.of(context)!.project}   ",
                              size: 18.sp,
                              fontWeight: FontWeight.w800,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          ),
                          // SizedBox(width: 50.w,),
                          Expanded(
                            flex: 7,
                            child: CustomText(
                              text: "$project",
                              size: 14.sp,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.w500,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                          )
                        ],
                      )
                    : SizedBox.shrink(),
              ],
            ),
          )),
    );
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

  Widget _usersCard() {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: 'user',
          context: context,
          title: AppLocalizations.of(context)!.allusers,
          list: users!.isEmpty ? [] : users,
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: users!, title: AppLocalizations.of(context)!.users),
        ),
      ),
    );
  }

  Widget _clientsCard() {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: 'client',
          context: context,
          title: AppLocalizations.of(context)!.allclients,
          list: clients!.isEmpty ? [] : clients!,
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
              list: clients!, title: AppLocalizations.of(context)!.clients),
        ),
      ),
    );
  }
}
