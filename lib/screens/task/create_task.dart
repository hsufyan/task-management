import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/task_id/taskid_bloc.dart';
import '../../bloc/task_id/taskid_event.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../config/constants.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/toast_widget.dart';

import '../Project/widgets/project_field.dart';
import '../dash_board/dashboard.dart';
import '../style/design_config.dart';
import '../widgets/custom_date.dart';
import '../widgets/custom_cancel_create_button.dart';
import '../widgets/custom_textfields/custom_textfield.dart';
import 'Widget/priority_all_field.dart';
import 'Widget/users_field.dart';
import 'Widget/status_field.dart';

class CreateTask extends StatefulWidget {
  final bool? isCreate;
  final bool? fromDetail;
  final String? title;
  final String? project;
  final String? user;
  final String? status;
  final String? priority;
  final int? priorityId;
  final int? statusId;
  final int? id;
  final int? projectID;
  final String? desc;
  final String? note;
  final String? start;
  final String? end;
  final List<Tasks>? taskcreate;
  final List<TaskUsers>? userList;
  final List<String>? users;
  final List<int>? usersid;
  final int? index;
  final Tasks? tasks;

  const CreateTask(
      {super.key,
      this.isCreate,
      this.fromDetail,
      this.project,
      this.userList,
      this.tasks,
      this.title,
      this.usersid,
      this.priority,
      this.priorityId,
      this.projectID,
      this.users,
      this.id,
      this.statusId,
      this.user,
      this.status,
      this.desc,
      this.note,
      this.start,
      this.end,
      this.taskcreate,
      this.index});

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController projectController = TextEditingController();
  TextEditingController userController = TextEditingController();
  TextEditingController statusController = TextEditingController();
  TextEditingController priorityController = TextEditingController();
  TextEditingController descController = TextEditingController();
  TextEditingController noteController = TextEditingController();
  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  String? fromdate;
  String? todate;
  String? selectedCategory;
  List<String>? usersName;
  List<int>? selectedusersNameId;
  String? selectedStatus;
  int? selectedStatusId;
  bool? isLoading;
  int? selectedPriorityId;
  String? selectedPriority;
  int? selectedID;

  String selectedProject = '';

  String selectedUser = '';
  // String selectedStatus = '';

  String? formattedStartDate;
  String? formattedEndDate;
  int? idStatus;
  int? idPriority;

  void _handleProjectSelected(String category, int catID) {
    setState(() {
      selectedCategory = category;
      selectedID = catID;
    });
  }

  void _handlePrioritySelected(String category, int catId) {
    setState(() {
      selectedPriority = category;
      selectedPriorityId = catId;
    });
  }

  void _handleStatusSelected(String category, int catId) {
    setState(() {
      selectedStatus = category;
      selectedStatusId = catId;
    });

  }

 void _onCreate() {
  if (titleController.text.isNotEmpty && selectedStatusId != null) {
    context.read<TaskBloc>().add(TaskCreated(
      title: titleController.text,
      statusId: selectedStatusId ?? 0,
      startDate: fromdate ?? "",
      dueDate: todate ?? "",
      desc: descController.text,
      userId: selectedusersNameId ?? [],
      note: noteController.text,
    ));
    isLoading = true;
    context.read<TaskBloc>().stream.listen((event) {
      if (event is TaskCreateSuccess) {
        if (mounted) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const DashBoard(initialIndex: 2),
            ),
          );
          isLoading = false;
          flutterToastCustom(
            msg: AppLocalizations.of(context)!.createdsuccessfully,
            color: AppColors.primary,
          );
        }
      } else if (event is TaskCreateError) {
        flutterToastCustom(msg: event.errorMessage);
      }
    });
  } else {
    flutterToastCustom(
      msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
    );
  }
}
  void _onUpdateTask() {
    isLoading = true;
    context.read<TaskBloc>().add(UpdateTask(
          id: widget.id!,
          title: titleController.text,
          statusId:
              selectedStatusId == null ? widget.statusId! : selectedStatusId!,
          priorityId: selectedPriorityId == null
              ? widget.priorityId!
              : selectedPriorityId!,
          startDate: fromdate ?? widget.start!,
          desc: descController.text,
          userId: selectedusersNameId!,
          note: noteController.text,
          dueDate: todate ?? widget.end!,
        ));
    context.read<TaskBloc>().stream.listen((event) {

      if (event is TaskEditSuccess) {
        if (mounted) {
          isLoading = false;
          if (widget.fromDetail == true) {

            BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
            router.pop(context);
          } else {
            context.read<TaskBloc>().add(AllTaskList());
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    const DashBoard(initialIndex: 2), // Navigate to index 1
              ),
            );
          }

          flutterToastCustom(
              msg: AppLocalizations.of(context)!.updatedsuccessfully,
              color: AppColors.primary);
        }
      } else if (event is TaskEditError) {
        if (mounted) {
          flutterToastCustom(msg: event.errorMessage);
          context.read<TaskBloc>().add(AllTaskList());
        }
      }
    });

    //   return;
    // }
    // context.read<TaskBloc>().add(AllTaskList());
    // Navigator.pop(context);
    // CustomToast(message: "Fill all the fields");
  }

  FocusNode? titleFocus,
      budgetFocus,
      descFocus,
      startsFocus,
      endFocus = FocusNode();
  List tags = [
    "development",
    "E-Commerce",
    "Marketing",
    "Marketing",
    "Marketing"
  ];

  void _handleUsersSelected(List<String> category, List<int> catId) {
    setState(() {
      usersName = category;
      selectedusersNameId = catId;
    });

  }

  bool? token;
  @override
  void initState() {
    if (widget.isCreate == false) {
      String? formattedstart;
      String? formattedend;

      selectedusersNameId = widget.usersid;
      if (widget.start != null &&
          widget.start!.isNotEmpty &&
          widget.start != "") {
        DateTime parsedDate = parseDateStringFromApi(widget.start!);
        formattedstart = dateFormatConfirmed(parsedDate, context);
        selectedDateStarts = parseDateStringFromApi(widget.start!);
      }
      if (widget.end != null && widget.end!.isNotEmpty && widget.end != "") {
        DateTime parsedDateEnd = parseDateStringFromApi(widget.end!);
        formattedend = dateFormatConfirmed(parsedDateEnd, context);
        selectedDateEnds = parsedDateEnd;
      }

      titleController = TextEditingController(text: widget.title);
      projectController = TextEditingController(text: widget.project);
      selectedCategory = widget.project;
      selectedPriority = widget.priority;
      selectedStatus = widget.status;
      usersName = widget.users;
      startsController = TextEditingController(text: formattedstart);
      endController = TextEditingController(text: formattedend);
      descController =
          TextEditingController(text: removeHtmlTags(widget.desc!));
      noteController = TextEditingController(text: widget.note);
    } else {
      titleController = TextEditingController();
      selectedStatus = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    for (var i in widget.userList!) {
      selectedusersNameId!.add(i.id!);
    }
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (!didPop) {
            if (widget.fromDetail == true && widget.isCreate == false) {
              BlocProvider.of<TaskidBloc>(context).add(TaskIdListId(widget.id));
              router.pop();
            } else {
              router.pop();
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.backGroundColor,
          body: SingleChildScrollView(
            child: Column(
              children: [
                _createEditAppbar(isLightTheme),
                SizedBox(height: 30.h),
                _taskBody(isLightTheme)
              ],
            ),
          ),
        ));
  }

  Widget _taskBody(isLightTheme) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
          if (state is TaskLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is TaskCreateSuccessLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is TaskEditSuccessLoading) {
            return _form([], isLightTheme, false);
          }
          if (state is AllTaskSuccess) {
            return _form([], isLightTheme, false);
          } else if (state is TaskPaginated) {
            List<int> id = [];
            if (widget.isCreate == false) {
              for (var task in state.task) {
                for (var ids in task.users!) {
                  id.add(ids.id!);
                }
              }
            }

            return _form(state.task, isLightTheme, true);
          }
          return Container();
        }),
      ),
    );
  }

  Widget _createEditAppbar(isLightTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
            padding: EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h),
            child: Column(
              children: [
                Container(
                    decoration: BoxDecoration(boxShadow: [
                      isLightTheme
                          ? MyThemes.lightThemeShadow
                          : MyThemes.darkThemeShadow,
                    ]),
                    // color: Colors.red,
                    // width: 300.w,
                    child: InkWell(
                      onTap: () {
                        if (widget.fromDetail == true && widget.isCreate == false) {
                          BlocProvider.of<TaskidBloc>(context)
                              .add(TaskIdListId(widget.id));
                          router.pop();
                        } else {
                          context.read<TaskBloc>().add(AllTaskList());
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DashBoard(
                                  initialIndex: 2), // Navigate to index 1
                            ),
                          );
                        }
                      },
                      child: BackArrow(
                        title: widget.isCreate == false
                            ? AppLocalizations.of(context)!.edittask
                            : AppLocalizations.of(context)!.createtask,
                      ),
                    )),
              ],
            ))
      ],
    );
  }

  Widget _form(tasks, isLightTheme, isPaginatedState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          title: AppLocalizations.of(context)!.title,
          hinttext: AppLocalizations.of(context)!.pleaseentertitle,
          controller: titleController,
          onSaved: (value) {},
          onFieldSubmitted: (value) {},
          isLightTheme: isLightTheme,
          isRequired: true,
        ),

        SizedBox(
          height: 15.h,
        ),
        UsersField(
            isCreate: widget.isCreate!,
            usersname: usersName ?? [],
            project: const [],
            usersid: widget.usersid!,
            onSelected: _handleUsersSelected),
        SizedBox(
          height: 15.h,
        ),
        StatusField(
          isRequired: true,
          status: widget.statusId,
          isCreate: widget.isCreate!,
          name: selectedStatus ?? "",
          index: widget.index!,
          onSelected: _handleStatusSelected,
        ),
        // StatusField(isLightTheme, Statusname, idStatus),
        // SizedBox(
        //   height: 15.h,
        // ),
        // PriorityAllField(
        //     priority: widget.priorityId,
        //     isCreate: widget.isCreate!,
        //     name: selectedPriority ?? "",
        //     index: widget.index,
        //     onSelected: _handlePrioritySelected),
        // SizedBox(
        //   height: 15.h,
        // ),
        // ProjectField(
        //   isRequired: true,
        //   isCreate: widget.isCreate!,
        //   project: widget.projectID != null ? widget.projectID! : 0,
        //   name: selectedCategory ?? "",
        //   index: widget.index!,
        //   onSelected: _handleProjectSelected,
        // ),

        // PriorityField(isLightTheme, Priorityname,idPriority),
        SizedBox(
          height: 15.h,
        ),
        CustomTextField(
            height: 112.h,
            keyboardType: TextInputType.multiline,
            title: AppLocalizations.of(context)!.description,
            hinttext: AppLocalizations.of(context)!.pleaseenterdescription,
            controller: descController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: false),

        SizedBox(
          height: 15.h,
        ),

        CustomTextField(
            keyboardType: TextInputType.multiline,
            height: 112.h,
            title: AppLocalizations.of(context)!.note,
            hinttext: AppLocalizations.of(context)!.pleaseenternotes,
            controller: noteController,
            onSaved: (value) {},
            onFieldSubmitted: (value) {},
            isLightTheme: isLightTheme,
            isRequired: false),
        SizedBox(
          height: 15.h,
        ),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: DatePickerWidget(
            dateController: startsController, // Use only one controller
            title: AppLocalizations.of(context)!.date,
            titlestartend: AppLocalizations.of(context)!.selectstartenddate,
            onTap: () {
              showCustomDateRangePicker(
                context,
                dismissible: true,
                minimumDate: DateTime(1900),
                maximumDate: DateTime(9999),
                endDate: selectedDateEnds,
                startDate: selectedDateStarts,
                backgroundColor: Theme.of(context).colorScheme.containerDark,
                primaryColor: AppColors.primary,
                onApplyClick: (start, end) {
                  setState(() {
                    selectedDateEnds = end;
                    selectedDateStarts = start;

                    // Show both start and end dates in the same controller
                    startsController.text =
                    "${dateFormatConfirmed(selectedDateStarts, context)}  -  ${dateFormatConfirmed(selectedDateEnds!, context)}";
                    fromdate = dateFormatConfirmedToApi(start);
                    todate = dateFormatConfirmedToApi(end);
                    // Assign values for API submission

                  });
                },
                onCancelClick: () {
                  setState(() {
                    // Handle cancellation if needed
                  });
                },
              );
            },
            isLightTheme: isLightTheme,
          ),
        ),

        SizedBox(
          height: 15.h,
        ),

        // endsField(isLightTheme),
        SizedBox(
          height: 15.h,
        ),
        CreateCancelButtom(
          isLoading: isLoading,
          isCreate: widget.isCreate,
          onpressCancel: () {
            Navigator.pop(context);
          },
          onpressCreate: widget.isCreate == true
              ? () async {
                print('tapped on create');
                  isPaginatedState == true ? _onCreate() : null;
                  // Navigator.pop(context);
                }
              : () {
                  isPaginatedState == true ? _onUpdateTask() : null;

                },
        ),
        SizedBox(
          height: 25.h,
        )
      ],
    );
  }
}
