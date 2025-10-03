import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/task/task_state.dart';
import 'package:taskify/bloc/theme/theme_bloc.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/task/task_event.dart';
import 'package:taskify/config/constants.dart';
import 'package:taskify/data/model/create_task_model.dart';
import 'package:taskify/data/model/task/task_model.dart';
import 'package:taskify/routes/routes.dart';
import 'package:taskify/screens/notes/widgets/notes_shimmer_widget.dart';
import 'package:taskify/screens/task/widget/status_field.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:taskify/utils/widgets/my_theme.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:taskify/utils/widgets/user_client_row_detail_page.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:taskify/screens/dash_board/dashboard.dart';
import 'package:taskify/screens/widgets/detail_page_menu.dart';
import 'package:taskify/screens/widgets/html_widget.dart';
import 'package:taskify/screens/widgets/side_bar.dart';
import 'package:taskify/screens/widgets/user_client_box.dart';
import 'package:taskify/screens/widgets/custom_container.dart';
import 'package:taskify/utils/widgets/status_priority_row.dart';

class TaskDetailScreen extends StatefulWidget {
  final bool? fromNoti;
  final String? from;
  final Tasks? task;

  const TaskDetailScreen({
    super.key,
    this.fromNoti,
    this.from,
    this.task,
  });

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _key = GlobalKey<ExpandableFabState>();
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
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
  String? role;

  @override
  void initState() {
    super.initState();
    _getRole();
    if (widget.task != null) {
      title = widget.task!.title;
      status = widget.task!.status;
      priority = widget.task!.priority;
      users = widget.task!.users;
      clients = widget.task!.clients;
      project = widget.task!.project;
      startDate = widget.task!.startDate;
      dueDate = widget.task!.dueDate;
      description = widget.task!.description;
      note = widget.task!.note;
      createdAt = widget.task!.createdAt;
      updatedAt = widget.task!.updatedAt;
      priorityId = widget.task!.priorityId;
      userId = widget.task!.userId;
      statusId = widget.task!.statusId;
      projectId = widget.task!.projectId;

      // Log raw date strings for debugging
      print('Raw createdAt: $createdAt');
      print('Raw updatedAt: $updatedAt');
      print('Raw startDate: $startDate');
      print('Raw dueDate: $dueDate');

      // Assign raw date strings directly
      if (createdAt != null && createdAt!.isNotEmpty) {
        dateCreated = createdAt!;
      }
      if (updatedAt != null && updatedAt!.isNotEmpty) {
        dateUpdated = updatedAt!;
      }
      if (startDate != null && startDate!.isNotEmpty) {
        dateStart = startDate!;
      }
      if (dueDate != null && dueDate!.isNotEmpty) {
        dateEnd = dueDate!;
      }

      print('Assigned dateCreated: $dateCreated');
      print('Assigned dateUpdated: $dateUpdated');
      print('Assigned dateStart: $dateStart');
      print('Assigned dateEnd: $dateEnd');
    }
    print("rjghnnkj ${widget.from}");
  }

  Future<void> _getRole() async {
    try {
      final Box box = await Hive.openBox('userBox');
      role = box.get('role') ?? 'member';
      setState(() {});
    } catch (e) {
      print('Error fetching role: $e');  
      role = 'member';
      setState(() {});
    }
  }

  String formatDateFromApi(String dateString, BuildContext context) {
    try {
      DateTime parsedDate;
      try {
        parsedDate = DateTime.parse(dateString);
      } catch (e) {
        final DateFormat fallbackFormatter = DateFormat('yyyy-MM-dd');
        parsedDate = fallbackFormatter.parse(dateString);
      }
      final DateFormat formatter = DateFormat('dd MMM yyyy', Localizations.localeOf(context).languageCode);
      return formatter.format(parsedDate);
    } catch (e) {
      print('Error parsing date: $dateString, Error: $e');
      return 'Invalid Date';
    }
  }

  void _onDeleteTask(int? taskId) {
    if (taskId == null) {
      flutterToastCustom(msg: 'Invalid task ID', color: AppColors.red);
      return;
    }
    final setting = context.read<TaskBloc>();
    BlocProvider.of<TaskBloc>(context).add(DeleteTask(taskId));
    setting.stream.listen((state) {
      if (state is TaskDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) => route is! MaterialPageRoute ||
                route.settings.name != 'taskdetail',
          );
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.deletedsuccessfully,
            color: AppColors.primary,
          );
        }
      }
      if (state is TaskDeleteError || state is TaskError) {
        if (mounted) {
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
            (route) => route is! MaterialPageRoute ||
                route.settings.name != 'taskdetail',
          );
          flutterToastCustom(
            msg: state is TaskDeleteError
                ? state.errorMessage
                : (state as TaskError).errorMessage,
            color: AppColors.red,
          );
        }
      }
    });
  }

  void _showStatusEditDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
        backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
        title: Text(AppLocalizations.of(context)!.update),
        contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h), // Reduced padding
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: 70.h, // Constrain height to fit StatusField
          child: StatusField1(
            isRequired: true,
            status: statusId,
            isCreate: false,
            name: status ?? "",
            index: 0,
          //  enabled: true,
            onSelected: (newStatus, newStatusId) {
              setState(() {
                status = newStatus;
                statusId = newStatusId;
              });
            },
          ),
        ),
        actionsPadding: EdgeInsets.only(bottom: 10.h), // Optimize action padding
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () {
              if (statusId != null) {
                context.read<TaskBloc>().add(UpdateTask(
                  id: widget.task!.id!,
                  title: title ?? "",
                  statusId: statusId!,
                 // priorityId: priorityId ?? 0,
                  startDate: startDate ?? "",
                  dueDate: dueDate ?? "",
                  desc: description ?? "",
                  userId: userId ?? [],
                  note: note ?? "",
                ));
                context.read<TaskBloc>().stream.listen((event) {
                  if (event is TaskEditSuccess) {
                    flutterToastCustom(
                      msg: AppLocalizations.of(context)!.updatedsuccessfully,
                      color: AppColors.primary,
                    );
                    Navigator.of(context).pop();
                  } else if (event is TaskEditError) {
                    // flutterToastCustom(
                    //   msg: event.errorMessage,
                    //   color: AppColors.red,
                    // );
                     Navigator.of(context).pop();
                  }
                });
              } else {
                // flutterToastCustom(
                //   msg: AppLocalizations.of(context)!.pleaseselect,
                //   color: AppColors.red,
                // );
              }
            },
            child: Text(AppLocalizations.of(context)!.done),
          ),
        ],
      );
    },
  );
}
  
  Future<void> _onRefresh() async {
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
    return Future.delayed(const Duration(milliseconds: 500));
  }

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
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
       floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: role == 'admin'
    ? detailMenu(
        isEdit: true,
        isDelete: true,
        key: _key,
        context: context,
        onpressEdit: () {
          _key.currentState?.toggle();
          List<String> username = [];
          List<int> ids = [];
          if (users != null) {
            for (var names in users!) {
              username.add(names.firstName ?? 'Unknown');
              ids.add(names.id ?? 0);
            }
          }
          router.push(
            '/createtask',
            extra: {
              "id": widget.task?.id ?? 0,
              "isCreate": false,
              "fromDetail": true,
              "title": title ?? '',
              "users": username,
              "desc": description ?? '',
              "start": startDate ?? '',
              "end": dueDate ?? '',
              "priority": priority ?? '',
              "priorityId": priorityId ?? 0,
              "usersid": ids,
              "statusId": statusId ?? 0,
              "note": note ?? '',
              "project": project ?? '',
              "userList": users ?? [],
              "projectId": projectId ?? 0,
              "status": status ?? '',
              "req": <CreateTaskModel>[],
            },
          );
        },
        onpressDelete: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r),
                ),
                backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                title: Text(AppLocalizations.of(context)!.confirmDelete),
                content: Text(AppLocalizations.of(context)!.areyousure),
                actions: [
                  TextButton(
                    onPressed: () {
                      _onDeleteTask(widget.task?.id);
                      Navigator.of(context).pop();
                    },
                    child: const Text('Delete'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
            extra: {
              "isDetail": true,
              "id": widget.task?.id ?? 0,
            },
          );
        },
      )
    : role == 'member'
        ? FloatingActionButton(
            backgroundColor: AppColors.primary,
            onPressed: () {
              _showStatusEditDialog(context);
            },
            child: const Icon(Icons.edit, color: Colors.white),
          )
        : const SizedBox.shrink(),
        
        body: SideBar(
          context: context,
          controller: sideBarController,
          underWidget: RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            onRefresh: _onRefresh,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 0.w),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: _appbar(isLightTheme),
                    ),
                    const SizedBox(height: 20),
                    if (widget.task == null)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 150.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 150.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 50.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 120.h),
                            const SizedBox(height: 20),
                            shimmerDetails(isLightTheme, context, 120.h),
                            const SizedBox(height: 20),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: _taskCard(),
                          ),
                          SizedBox(height: 20.h),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 18.w),
                            child: _dateCard(dateStart, dateEnd, dateCreated, dateUpdated),
                          ),
                          SizedBox(height: 20.h),
                          note != null
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                                  child: _noteCard(),
                                )
                              : const SizedBox(),
                          note != null ? SizedBox(height: 20.h) : const SizedBox(),
                          users != null && users!.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                                  child: _usersCard(),
                                )
                              : const SizedBox.shrink(),
                          clients != null && clients!.isNotEmpty
                              ? SizedBox(height: 20.h)
                              : const SizedBox(),
                          clients != null && clients!.isNotEmpty
                              ? Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 18.w),
                                  child: _clientsCard(),
                                )
                              : const SizedBox.shrink(),
                          SizedBox(height: 60.h),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ... rest of the methods (_appbar, _taskCard, _dateCard, _noteCard, _usersCard, _clientsCard) remain unchanged ...


  Widget _appbar(bool isLightTheme) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
        ],
      ),
      child: BackArrow(
        onTap: () {
          if (widget.from == "subtask") {
            BlocProvider.of<TaskBloc>(context)
                .add(AllTaskListOnTask(id: widget.task?.id));
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
      ),
    );
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
            SizedBox(height: 10.h),
            ExpandableHtmlWidget(
              text: description ?? "",
              context: context,
              width: 290.w,
            ),
            SizedBox(height: 10.h),
            SizedBox(
              child: statusClientRow(status ?? "", priority ?? "", context, true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(String dateStart, String dateEnd, String dateCreated, String dateUpdated) {
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            startDate != null && startDate!.isNotEmpty
                ? SizedBox(height: 10.h)
                : const SizedBox.shrink(),
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            dueDate != null && dueDate!.isNotEmpty
                ? SizedBox(height: 10.h)
                : const SizedBox(),
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            createdAt != null && createdAt!.isNotEmpty
                ? SizedBox(height: 10.h)
                : const SizedBox.shrink(),
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
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ],
        ),
      ),
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
            SizedBox(height: 10.w),
            CustomText(
              text: note ?? "",
              size: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.textClrChange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _usersCard() {
    return InkWell(
      onTap: () {
        userClientDialog(
          from: 'user',
          context: context,
          title: AppLocalizations.of(context)!.allusers,
          list: users ?? [],
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
            list: users ?? [],
            title: AppLocalizations.of(context)!.users,
          ),
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
          list: clients ?? [],
        );
      },
      child: customContainer(
        width: double.infinity,
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 15.w),
          child: UserClientRowDetailPage(
            list: clients ?? [],
            title: AppLocalizations.of(context)!.clients,
          ),
        ),
      ),
    );
  }
}











  // Widget _project() {
  //   return InkWell(
  //     onTap: () {
  //       router.push('/projectdetails', extra: {
  //         "id": projectId ?? 0,
  //       });
  //     },
  //     child: customContainer(
  //       width: double.infinity,
  //       context: context,
  //       addWidget: Padding(
  //         padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 15.w),
  //         child: Column(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             project != null
  //                 ? Row(
  //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Expanded(
  //                         flex: 3,
  //                         child: CustomText(
  //                           text: "${AppLocalizations.of(context)!.project}   ",
  //                           size: 18.sp,
  //                           fontWeight: FontWeight.w800,
  //                           color: Theme.of(context).colorScheme.textClrChange,
  //                         ),
  //                       ),
  //                       Expanded(
  //                         flex: 7,
  //                         child: CustomText(
  //                           text: project ?? "",
  //                           size: 14.sp,
  //                           maxLines: 2,
  //                           overflow: TextOverflow.ellipsis,
  //                           fontWeight: FontWeight.w500,
  //                           color: Theme.of(context).colorScheme.textClrChange,
  //                         ),
  //                       ),
  //                     ],
  //                   )
  //                 : const SizedBox.shrink(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
