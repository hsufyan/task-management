import 'dart:math';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/task/task_bloc.dart';
import 'package:taskify/bloc/task/task_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:taskify/data/model/create_task_model.dart';
import 'package:taskify/data/repositories/Task/task_repo.dart';
import 'package:taskify/screens/widgets/no_data.dart';
import 'package:taskify/screens/widgets/no_permission_screen.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:heroicons/heroicons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'dart:async';
import 'package:intl/intl.dart';

import '../../../bloc/clients/client_bloc.dart';
import '../../../bloc/clients/client_event.dart';
import '../../../bloc/clients/client_state.dart';
import '../../../bloc/permissions/permissions_bloc.dart';
import '../../../bloc/priority/priority_state.dart';
import '../../../bloc/priority_multi/priority_multi_bloc.dart';
import '../../../bloc/priority_multi/priority_multi_event.dart';
import '../../../bloc/priority_multi/priority_multi_state.dart';
import '../../../bloc/project_multi/project_multi_bloc.dart';
import '../../../bloc/project_multi/project_multi_event.dart';
import '../../../bloc/project_multi/project_multi_state.dart';
import '../../../bloc/status_multi/status_multi_bloc.dart';
import '../../../bloc/status_multi/status_multi_event.dart';
import '../../../bloc/status_multi/status_multi_state.dart';
import '../../../bloc/task/task_event.dart';
import '../../../bloc/task_filter/task_filter_bloc.dart';
import '../../../bloc/task_filter/task_filter_event.dart';
import '../../../bloc/task_filter/task_filter_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/constants.dart';
import '../../../data/localStorage/hive.dart';
import '../../../data/model/task/task_model.dart';
import '../../../routes/routes.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../../utils/widgets/row_dashboard.dart';
import '../../../utils/widgets/search_pop_up.dart';
import '../../../utils/widgets/status_priority_row.dart';
import '../../../utils/widgets/toast_widget.dart';
import '../../notes/widgets/notes_shimmer_widget.dart';
import '../../widgets/custom_date.dart';
import '../../widgets/html_widget.dart';
import '../../widgets/search_field.dart';
import '../../widgets/user_client_box.dart';

class SubTaskScreen extends StatefulWidget {
  final int taskId;
  const SubTaskScreen({super.key,required this.taskId});

  @override
  State<SubTaskScreen> createState() => _SubTaskScreenState();
}

class _SubTaskScreenState extends State<SubTaskScreen> with TickerProviderStateMixin{
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
  bool? isLoading = true;
  bool? isFirst = false;
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

  bool isListening =
  false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;
  bool? clientSelected = false;
  bool? clientDisSelected = false;
  bool? priorityDisSelected = false;
  bool? userDisSelected = false;
  bool? projectDisSelected = false;
  bool? statusDisSelected = false;
  bool? dateDisSelected = false;
  bool? userSelected = false;
  bool? statusSelected = false;
  bool? prioritySelected = false;
  bool? projectSelected = false;
  bool? dateSelected = false;

  int filterSelectedId = 0;
  int filterCount = 0;
  String filterSelectedNmae = "";

  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static final bool _onDevice = false;
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

  final options = SpeechListenOptions(
      onDevice: _onDevice,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true);
  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  @override
  void initState() {
print("giruvfjkmcl, ${widget.taskId}");
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(id: widget.taskId,isSubtask: true));
    super.initState();
    getIsFirst();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  void listenForPermissions() async {
    final status = await Permission.microphone.status;
    switch (status) {
      case PermissionStatus.denied:
        requestForPermission();
        break;
      case PermissionStatus.granted:
        break;
      case PermissionStatus.limited:
        break;
      case PermissionStatus.permanentlyDenied:
        break;
      case PermissionStatus.restricted:
        break;
      case PermissionStatus.provisional: // Handle the provisional case
        break;
    }
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
      if (_lastWords.isEmpty) {
        // If no words were recognized, allow reopening the dialog
        dialogShown = false;
      }
    });
  }

  void _onDialogDismissed() {
    setState(() {
      dialogShown = false; // Reset flag when the dialog is dismissed
    });
  }

  void _startListening() async {
    if (!_speechToText.isListening && !dialogShown) {
      setState(() {
        dialogShown = true; // Set the flag to prevent showing multiple dialogs
      });

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return SearchPopUp(); // Call the SearchPopUp widget here
        },
      ).then((_) {
        // This will be called when the dialog is dismissed.
        _onDialogDismissed();
      });

      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        localeId: "en_En",
        pauseFor: Duration(seconds: 3),
        onSoundLevelChange: soundLevelListener,
        listenOptions: options,
      );
      (() {});
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      // Reset the last words on each new result to avoid appending repeatedly
      _lastWords = result.recognizedWords;
      searchController.text = _lastWords;
      if (_lastWords.isNotEmpty && dialogShown) {
        Navigator.pop(context); // Close the dialog once the speech is detected
        dialogShown = false; // Reset the dialog flag
      }
    });

    // Trigger search event with the updated result
    context.read<TaskBloc>().add(SearchTasks(_lastWords));
  }

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter; // Update the filterName and rebuild UI
    });
  }

  getIsFirst() async {
    isFirst = await HiveStorage.isFirstTime();
  }


  void onDeleteTask(task) {
    context.read<TaskBloc>().add(DeleteTask(task));
    final setting = context.read<TaskBloc>();
    setting.stream.listen((state) {
      if (state is TaskDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is TaskDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(id: widget.taskId,isSubtask: true));

  }

  Future<void> _onRefresh() async {

    BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(id: widget.taskId,isSubtask: true));

  }

  @override
  Widget build(BuildContext context) {
    context.read<PermissionsBloc>().isManageTask;
    context.read<PermissionsBloc>().iscreatetask;
    context.read<PermissionsBloc>().iseditTask;
    context.read<PermissionsBloc>().isdeleteTask;

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return  Column(
        children: [

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
                          // Clear the search field
                          searchController.clear();
                          // Optionally trigger the search event with an empty string
                          context.read<TaskBloc>().add(SearchTasks(""));
                        },
                      ),
                    ),
                  SizedBox(
                    width: 30.w,
                    child: IconButton(
                      icon: Icon(
                        _speechToText.isNotListening
                            ? Icons.mic_off
                            : Icons.mic,
                        size: 20.sp,
                        color: Theme.of(context).colorScheme.textFieldColor,
                      ),
                      onPressed: () {
                        if (_speechToText.isNotListening) {
                          _startListening();
                        } else {
                          _stopListening();
                        }
                      },
                    ),
                  ),
                  BlocBuilder<TaskFilterCountBloc, TaskFilterCountState>(
                    builder: (context, state) {

                      return SizedBox(
                        width: 35.w,
                        child: Stack(
                          children: [
                            IconButton(
                              icon: HeroIcon(
                                HeroIcons.adjustmentsHorizontal,
                                style: HeroIconStyle.solid,
                                color: Theme.of(context).colorScheme.textFieldColor,
                                size: 30.sp,
                              ),
                              onPressed: () {

                                BlocProvider.of<ClientBloc>(context)
                                    .add(ClientList());
                                BlocProvider.of<StatusMultiBloc>(context)
                                    .add(StatusMultiList());
                                BlocProvider.of<PriorityMultiBloc>(context)
                                    .add(PriorityMultiList());
                                BlocProvider.of<ProjectMultiBloc>(context)
                                    .add(ProjectMultiList());
                                BlocProvider.of<UserBloc>(context).add(UserList());
                                _filterDialog(context, isLightTheme);
                              },
                            ),
                            if (state.count > 0)
                              Positioned(
                                right: 5.w,
                                top: 7.h,
                                child: Container(
                                  padding: EdgeInsets.zero,
                                  alignment: Alignment.center,
                                  height: 12.h,
                                  width: 10.w,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                  child: CustomText(
                                    text: state.count.toString(),
                                    color: Colors.white,
                                    size: 6,
                                    textAlign: TextAlign.center,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  )

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
          SizedBox(
            height: 60.h,
          ),
        ],
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
                                UpdateFilterCount(filterType: 'clients', isSelected: true),
                              );
                            }
                            if (userSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                UpdateFilterCount(filterType: 'users', isSelected: true),
                              );
                            }
                            if (statusSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                UpdateFilterCount(filterType: 'status', isSelected: true),
                              );
                            }
                            if (prioritySelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                UpdateFilterCount(filterType: 'priorities', isSelected: true),
                              );
                            }
                            if (projectSelectedIdS.isNotEmpty) {
                              context.read<TaskFilterCountBloc>().add(
                                UpdateFilterCount(filterType: 'projects', isSelected: true),
                              );
                            }
                            if (fromDate!=null || toDate!=null) {
                              context.read<TaskFilterCountBloc>().add(
                                UpdateFilterCount(filterType: 'date', isSelected: true),
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
                            context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());
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

  Widget _taskBlocList(isLightTheme) {
    return Expanded(
      child: RefreshIndicator(
        color: AppColors.primary, // Spinner color
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        onRefresh: _onRefresh,
        child: (context.read<PermissionsBloc>().isManageTask == true)
            ?  FutureBuilder(
            future: Future.delayed(Duration(seconds: 1)), // Delay by 2 seconds
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const NotesShimmer(); // Show loading indicator while waiting
              }
              return BlocConsumer<TaskBloc, TaskState>(
                listener: (context, state) {

                  if (state is TaskPaginated) {
                  }
                },
                builder: (context, state) {
                  print("zgknfdvm , $state");

                  if (state is TaskLoading) {
                    return const NotesShimmer();
                  } else if (state is TaskPaginated) {

                    return NotificationListener<ScrollNotification>(
                      onNotification: (scrollInfo) {
                        if (scrollInfo is ScrollStartNotification) {
                          FocusScope.of(context).unfocus(); // Dismiss keyboard
                        }
                        if (!state.hasReachedMax &&
                            scrollInfo.metrics.pixels ==
                                scrollInfo.metrics.maxScrollExtent) {
                          context.read<TaskBloc>().add(LoadMore(
                              searchQuery: searchValue!,
                              projectId: projectSelectedIdS,
                              clientId: clientSelectedIdS,
                              userId: userSelectedIdS,
                              statusId: statusSelectedIdS,
                           //   priorityId: prioritySelectedIdS,
                              fromDate: fromDate,
                              toDate: toDate));
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
                                var dateCreated =
                                parseDateStringFromApi(task.createdAt!);
                                date = dateFormatConfirmed(
                                    dateCreated, context);
                              }
                              return index == 0
                                  ? ShakeWidget(
                                  child: _listOfProject(
                                      task,
                                      isLightTheme,
                                      date,
                                      state.task,
                                      index))
                                  : _listOfProject(task, isLightTheme, date,
                                  state.task, index);
                            } else {
                              // Show a loading indicator when more notes are being loaded
                              return Padding(
                                padding:
                                const EdgeInsets.symmetric(vertical: 0),
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
                          })
                      // ? taskList(isLightTheme,state.hasReachedMax,state.task)
                          : NoData(
                        isImage: true,
                      ),
                    );
                  }

                  return const Text("");
                },
              );})
            : NoPermission(),
      ),
    );
  }

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
                if (scrollController.position.pixels != 0 && !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<ClientBloc>(context)
                      .add(ClientLoadMore(searchword));
                }
              }
            });

            return StatefulBuilder(builder:
                (BuildContext context, void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.client.isNotEmpty ?ListView.builder(
                  controller: scrollController,
                  // physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: state.client.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index < state.client.length) {
                      final isSelected =
                      clientSelectedIdS.contains(state.client[index].id!);
                      // final isSelected = widget.userId?.contains(state.user[index].id);

                      return InkWell(
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              clientSelectedIdS.remove(state.client[index].id!);
                              clientSelectedname.remove(state.client[index].firstName!);
                              // If no clients are selected anymore, update filter count
                              if (clientSelectedIdS.isEmpty) {
                                context.read<TaskFilterCountBloc>().add(
                                  UpdateFilterCount(
                                    filterType: 'clients',
                                    isSelected: false,
                                  ),
                                );
                              }
                            }
                            else {
                              if (!clientSelectedIdS.contains(state.client[index].id!)) {
                                clientSelectedIdS.add(state.client[index].id!);
                                clientSelectedname.add(state.client[index].firstName!);
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
                              ToggleClientSelection(state.client[index].id!,
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
                                                CrossAxisAlignment.start,
                                                children: [
                                                  Flexible(
                                                    child: CustomText(
                                                      text: state.client[index]
                                                          .firstName!,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : Theme.of(context)
                                                          .colorScheme
                                                          .textClrChange,
                                                    ),
                                                  ),
                                                  SizedBox(width: 5.w),
                                                  Flexible(
                                                    child: CustomText(
                                                      text: state.client[index]
                                                          .lastName!,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      size: 18.sp,
                                                      color: isSelected
                                                          ? AppColors.primary
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
                                                    child: CustomText(
                                                      text: state
                                                          .client[index].email!,
                                                      fontWeight:
                                                      FontWeight.w500,
                                                      maxLines: 1,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      size: 14.sp,
                                                      color: isSelected
                                                          ? AppColors.primary
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
                ):NoData(),
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
                    if (scrollController.position.pixels != 0 && !state.hasReachedMax) {
                      // We're at the bottom
                      BlocProvider.of<StatusMultiBloc>(context)
                          .add(StatusMultiLoadMore());
                    }
                  }
                });

                return StatefulBuilder(builder:
                    (BuildContext context, void Function(void Function()) setState) {
                  return Container(
                    constraints: BoxConstraints(maxHeight: 900.h),
                    width: 200.w,
                    height: 530,
                    child: state.statusMulti.isNotEmpty ?ListView.builder(
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
                                  statusSelectedIdS.remove(state.statusMulti[index].id!);
                                  statusSelectedname.remove(state.statusMulti[index].title!);
                                  // If no clients are selected anymore, update filter count
                                  if (statusSelectedIdS.isEmpty) {
                                    context.read<TaskFilterCountBloc>().add(
                                      UpdateFilterCount(
                                        filterType: 'status',
                                        isSelected: false,
                                      ),
                                    );
                                  }
                                }
                                else {
                                  if (!statusSelectedIdS.contains(state.statusMulti[index].id!)) {
                                    statusSelectedIdS.add(state.statusMulti[index].id!);
                                    statusSelectedname.add(state.statusMulti[index].title!);
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
                                  SelectedStatusMulti(
                                      index, state.statusMulti[index].title!));
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
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          child: CustomText(
                                            text: state.statusMulti[index].title!,
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
                                            ? const HeroIcon(HeroIcons.checkCircle,
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
                    ):NoData(),
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
                    if (scrollController.position.pixels != 0 && !state.hasReachedMax) {

                      BlocProvider.of<PriorityMultiBloc>(context)
                          .add(PriorityMultiLoadMore());
                    }
                  }
                });

                return StatefulBuilder(builder:
                    (BuildContext context, void Function(void Function()) setState) {
                  return Container(
                    constraints: BoxConstraints(maxHeight: 900.h),
                    width: 200.w,
                    height: 530,
                    child: state.priorityMulti.isNotEmpty ?ListView.builder(
                      controller: scrollController,
                      // physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: state.priorityMulti.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index < state.priorityMulti.length) {
                          final isSelected = prioritySelectedIdS.contains(state.priorityMulti[index].id!);
                          return InkWell(
                            splashColor: Colors.transparent,
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  priorityDisSelected = true;
                                  prioritySelectedIdS.remove(state.priorityMulti[index].id!);
                                  prioritySelectedname.remove(state.priorityMulti[index].title!);
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
                                  if (!prioritySelectedIdS.contains(state.priorityMulti[index].id!)) {
                                    prioritySelectedIdS.add(state.priorityMulti[index].id!);
                                    prioritySelectedname.add(state.priorityMulti[index].title!);

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
                                  filterSelectedId = state.priorityMulti[index].id!;
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
                                  SelectedStatusMulti(
                                      index, state.priorityMulti[index].title!));
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
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          child: CustomText(
                                            text: state.priorityMulti[index].title!,
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
                                            ? const HeroIcon(HeroIcons.checkCircle,
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
                    ):NoData(),
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

                    if (scrollController.position.pixels != 0 && !state.hasReachedMax) {
                      BlocProvider.of<ProjectMultiBloc>(context)
                          .add(ProjectMultiLoadMore());
                    }
                  }
                });

                return StatefulBuilder(builder:
                    (BuildContext context, void Function(void Function()) setState) {
                  return Container(
                    constraints: BoxConstraints(maxHeight: 900.h),
                    width: 200.w,
                    height: 530,
                    child: state.projectMulti.isNotEmpty ?ListView.builder(
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
                                  userSelectedIdS.remove(state.projectMulti[index].id!);
                                  userSelectedname.remove(state.projectMulti[index].title!);
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
                                  if (!userSelectedIdS.contains(state.projectMulti[index].id!)) {
                                    userSelectedIdS.add(state.projectMulti[index].id!);
                                    userSelectedname.add(state.projectMulti[index].title!);

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
                                  filterSelectedId = state.projectMulti[index].id!;
                                  filterSelectedNmae = "users";
                                }

                                _onFilterSelected('project');
                              });
                              BlocProvider.of<ProjectMultiBloc>(context).add(
                                  SelectedProjectMulti(
                                      index, state.projectMulti[index].title!));
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
                                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(
                                          width: 110.w,
                                          child: CustomText(
                                            text: state.projectMulti[index].title!,
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
                                            ? const HeroIcon(HeroIcons.checkCircle,
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
                    ):NoData(),
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
                if (scrollController.position.pixels != 0 && !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<UserBloc>(context).add(UserLoadMore(searchword));
                }
              }
            });

            return StatefulBuilder(builder:
                (BuildContext context, void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.user.isNotEmpty ?ListView.builder(
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
                              userSelectedIdS.remove(state.user[index].id!);
                              userSelectedname.remove(state.user[index].firstName!);
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
                              if (!userSelectedIdS.contains(state.user[index].id!)) {
                                userSelectedIdS.add(state.user[index].id!);
                                userSelectedname.add(state.user[index].firstName!);

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
                          BlocProvider.of<UserBloc>(context).add(SelectedUser(
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
                                  padding:
                                  EdgeInsets.symmetric(horizontal: 0.w),
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
                                                  backgroundImage: NetworkImage(
                                                      state.user[index]
                                                          .profile!),
                                                ),
                                                SizedBox(
                                                  width: 5.w,
                                                ), // Column takes up maximum available space
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 0.w),
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
                                                              child: CustomText(
                                                                text: state
                                                                    .user[index]
                                                                    .firstName!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
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
                                                            SizedBox(
                                                                width: 5.w),
                                                            Flexible(
                                                              child: CustomText(
                                                                text: state
                                                                    .user[index]
                                                                    .lastName!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
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
                                                                    .user[index]
                                                                    .email!,
                                                                fontWeight:
                                                                FontWeight
                                                                    .w500,
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
                ):NoData(),
              );
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget _listOfProject(task, isLightTheme, date, statetask, index) {

    return Padding(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteTask == true &&
              context.read<PermissionsBloc>().iseditTask == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteTask == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditTask == true
              ? DismissDirection.startToEnd // Allow edit
              : DismissDirection.none,
          title: task.id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart  ) {
              // Right to left swipe (Delete action)
              final result = await showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.r), // Set the desired radius here
                    ),
                    backgroundColor:
                    Theme.of(context).colorScheme.alertBoxBackGroundColor,
                    title: Text(
                      AppLocalizations.of(context)!.confirmDelete,
                    ),
                    content: Text(
                      AppLocalizations.of(context)!.areyousure,
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true); // Confirm deletion
                        },
                        child: Text(
                          AppLocalizations.of(context)!.delete,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Cancel deletion
                        },
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                        ),
                      ),
                    ],
                  );
                },
              );
              return result; // Return the result of the dialog
            }
            else if (direction == DismissDirection.startToEnd) {
              List<String> username = [];
              for (var names in task.users!) {
                username.add(names.firstName!);
              }
              List<int>? ids = [];
              for (var i in task.users!) {
                ids.add(i.id!);

              }

              router.push(
                '/createtask',
                extra: {
                  "id": task.id,
                  "isCreate": false,
                  "title": task.title,
                  "users": username,
                  "desc": task.description,
                  "start": task.startDate,
                  "end": task.dueDate,
                  // "user":task.users,
                  'priority': task.priority,
                  // or true, depending on your needs
                  'priorityId': task.priorityId,
                  "usersid": ids,
                  // or true, depending on your needs
                  'statusId': task.statusId,
                  // or true, depending on your needs
                  'note': task.note,
                  // or true, depending on your needs
                  'project': task.project,
                  "userList": task.users,
                  "tasks": statetask[index],
                  // or true, depending on your needs
                  'projectId': task.projectId,
                  // or true, depending on your needs
                  'status': task.status,
                  // or true, depending on your needs
                  'req': <CreateTaskModel>[],
                  // your list of LeaveRequests
                },
              );
              BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
              return false; // Prevent dismiss
            }
            // flutterToastCustom(msg: AppLocalizations.of(context)!.isDemooperation);

            return false; // Default case
          },
          dismissWidget: InkWell(
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
                  'from':"subtask"
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
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteTask == true) {
              // Perform delete action
              setState(() {
                statetask.removeAt(index);

                onDeleteTask(task.id);
              });

            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditTask == true) {
              // Perform edit action
            }
          },
        ));
  }
}
