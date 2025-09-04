import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:heroicons/heroicons.dart';
import 'package:hive/hive.dart';
import 'package:mobkit_dashed_border/mobkit_dashed_border.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:taskify/bloc/task_discussion/task_media/task_media_bloc.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:taskify/screens/task/task_discussion_screen/subtask_screen.dart';
import 'package:taskify/screens/task/task_discussion_screen/task_activity_log.dart';
import 'package:taskify/screens/task/task_discussion_screen/task_media_screen.dart';
import 'package:taskify/screens/task/task_discussion_screen/task_status_timeline.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:timeline_tile/timeline_tile.dart';

import '../../bloc/activity_log/activity_log_bloc.dart';
import '../../bloc/activity_log/activity_log_event.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';


import '../../bloc/task_discussion/task_timeline/task_status_timeline_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/app_images.dart';
import '../../config/internet_connectivity.dart';
import '../../config/strings.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_container.dart';
import '../widgets/speech_to_text.dart';


class TaskDiscussionTabs extends StatefulWidget {
  final bool? fromDetail;
  final int? id;
  const TaskDiscussionTabs({super.key, this.fromDetail, this.id});

  @override
  State<TaskDiscussionTabs> createState() => _TaskDiscussionTabsState();
}

class _TaskDiscussionTabsState extends State<TaskDiscussionTabs>
    with TickerProviderStateMixin {
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  bool? isLoading = true;
  bool isLoadingMore = false;
  int _selectedIndex = 0;
  String? selectedColorName;
  final Connectivity _connectivity = Connectivity();
  TextEditingController searchController = TextEditingController();
  TextEditingController mediaSearchController = TextEditingController();
  TextEditingController activityLogSearchController = TextEditingController();
  TextEditingController startController = TextEditingController();
  TextEditingController endController = TextEditingController();
  String fromDate = "";
  String toDate = "";
  TextEditingController startDateBetweenController = TextEditingController();
  TextEditingController endDateBetweenController = TextEditingController();
  TextEditingController startDateBetweenstartController =
      TextEditingController();
  TextEditingController endDateBetweenendController = TextEditingController();
  String fromDateBetween = "";
  String toDateBetween = "";
  String fromEndDateBetweenStart = "";
  String toDateEndBetweenEnd = "";
  late SpeechToTextHelper speechHelper;
  String selectedTabText = "";
  int isWhichIndex = 0;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  DateTime selectedDateBetweenStarts = DateTime.now();
  DateTime? selectedDateBetweenEnds = DateTime.now();
  DateTime selectedDateEndBetweenStarts = DateTime.now();
  DateTime? selectedDateEndBetweenEnds = DateTime.now();
  bool? isFirstTimeUSer;
  bool? isFirst;
  String mileStoneSearchQuery = '';
  String mediaSearchQuery = '';
  String activityLogSearchQuery = '';

  TextEditingController titleController = TextEditingController();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  late TabController _tabController;
  final GlobalKey _one = GlobalKey();
  String? statusname;
  bool isDownloading = false;
  double progress = 0.0;

  List<String> status = ["Complete", "Incomplete"];
  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Date between');

  String filterName = 'Date between';
  ValueNotifier<List<File>> selectedFilesNotifier = ValueNotifier([]);

  void _navigateToIndex(int index) {
    setState(() {
      _selectedIndex = index;
      _tabController.animateTo(index);
    });
  }

  _handleStartEndDate(String from, String to) {
    setState(() {
      fromDate = from;
      toDate = to;
    });
    print("fihdid $toDate");
  }

  _handleStartdateBetween(String from, String to) {
    setState(() {
      fromDateBetween = from;
      toDateBetween = to;
    });
  }

  __handleEnddateBetween(String from, String to) {
    setState(() {
      fromEndDateBetweenStart = from;
      toDateEndBetweenEnd = to;
    });
  }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    // filterCount = 0;

    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));

    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
  }

  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
  }

  Future<void> downloadFile(file, fileName) async {
    print("sjfgdjk $fileName");
    // Check storage permissions (only needed for Android)
    if (Platform.isAndroid) {
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }
    }

    try {
      setState(() {
        isDownloading = true;
        progress = 0.0;
      });

      Dio dio = Dio();
      Directory directory = await getApplicationDocumentsDirectory();
      String filePath = "${directory.path}/$fileName";
      print("sofudlgj asas $filePath");
      await dio.download(
        file,
        filePath,
        onReceiveProgress: (received, total) {
          setState(() {
            progress = (received / total);
            print("sofudlgj $progress");
          });
        },
      );

      setState(() {
        isDownloading = false;
      });

      flutterToastCustom(
          msg: "Download completed: $fileName", color: AppColors.primary);
    } catch (e) {
      setState(() {
        isDownloading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Download failed: $e")),
      );
    }
  }

  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  void onShowCaseCompleted() {
    _setIsFirst(false);
  }

  final List<String> filter = [
    'Date between',
    'Start date between',
    'End date between',
    'Statuses',
  ];


  @override
  void initState() {
    super.initState();
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }
    });

    _connectivitySubscription = _connectivity.onConnectivityChanged
        .listen((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        CheckInternet.updateConnectionStatus(results).then((value) {
          setState(() {
            _connectionStatus = value;
          });
        });
      }
    });
    searchController.addListener(() {
      setState(() {});
    });
    mediaSearchController.addListener(() {
      setState(() {});
    });
    activityLogSearchController.addListener(() {
      setState(() {});
    });
    _tabController = TabController(length: 4, vsync: this);
    speechHelper = SpeechToTextHelper(
      onSpeechResultCallback: (result) {
        setState(() {
          searchController.text = result;
        });
        Navigator.pop(context);
      },
    );
    speechHelper.initSpeech();
    // Listen for tab changes
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _getFirstTimeUser();
    BlocProvider.of<ActivityLogBloc>(context)
        .add(AllActivityLogList(type: "task", typeId: widget.id));
    BlocProvider.of<TaskMediaBloc>(context).add(TaskMediaList(id: widget.id));
    BlocProvider.of<TaskStatusTimelineBloc>(context)
        .add(TaskStatusTimelineList(id: widget.id));
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _pickFile() async {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowMultiple: true,
        allowedExtensions: [
          'pdf', 'doc', 'docx', 'xls','jpg', 'xlsx', 'png', 'zip', 'rar', 'txt'
        ],
      );

      if (result != null) {
        List<File> pickedFiles = result.paths.whereType<String>().map((path) => File(path)).toList();

        // Update the ValueNotifier
        selectedFilesNotifier.value = [...selectedFilesNotifier.value, ...pickedFiles];

        print("Selected Files: ${selectedFilesNotifier.value}");
      }
    }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.backGroundColor,
      body: Stack(
        children: [
          // Main content
          Column(
            children: [
              _appBar(isLightTheme),
              SizedBox(height: 20.h),

              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    SubTaskScreen(taskId:widget.id!),
                    TaskMediaScreen(id:widget.id),
                    TaskStatusTimeline(id :widget.id),
                    TaskActivityLogScreen(id:widget.id)
                  ],
                ),
              ),
              // Add bottom space to ensure content is visible behind the floating bar
              // SizedBox(height: 60.h),
            ],
          ),

          // Floating action button
          Visibility(
          visible: _selectedIndex != 2 &&_selectedIndex != 3 ,
         // Hide for index 2 and 3
          child: Positioned(
            right: 20.w,
            bottom: 100.h,
            child: FloatingActionButton(
              isExtended: true,
              // onPressed: () {
              //   isWhichIndex == 0? router.push("/milestone",extra: {"isCreate":true});
              // },
              onPressed: () {
                switch (_selectedIndex) {
                  case 0:

                  case 1: // Media tab
                    _uploadFile(
                        pickFile: _pickFile,
                        selectedFileName: selectedFilesNotifier);
                    break;
                  case 2: // Status tab
                    router.push("/status", extra: {"isCreate": true});
                    break;
                  case 3: // Activity tab
                    router.push("/activity", extra: {"isCreate": true});
                    break;
                  default:
                    break;
                }
              },

              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.add,
                color: AppColors.whiteColor,
              ),
            ),
          )),

          // Floating bottom navigation
          Positioned(
            bottom: 20.h,
            left: 18.w,
            right: 18.w,
            child: _floatingBottomNavBar(context, isLightTheme),
          ),
        ],
      ),
    );
  }



  Widget _tabItem(
    HeroIcons icon,
    String text,
    Color color,
    int index,
  ) {
    bool isSelected = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _navigateToIndex(index);
        isWhichIndex = index;
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HeroIcon(
            icon,
            style: HeroIconStyle.outline,
            size: 18.sp,
            color: color,
          ),
          AnimatedSwitcher(
            duration: Duration(milliseconds: 200),
            child: isSelected
                ? Padding(
                    padding: EdgeInsets.only(top: 3.h),
                    child: Text(
                      text,
                      key: ValueKey(text), // Smooth transition
                      style: TextStyle(
                          fontSize: 9.sp, fontWeight: FontWeight.bold),
                    ),
                  )
                : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _appBar(isLightTheme) {
    return InkWell(
      onTap: (){

      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: BackArrow(
          projectId: widget.id,
          discussionScreen: "TaskDiscussion",
          iSBackArrow: true,
          iscreatePermission: true,
          title: (() {
            switch (_selectedIndex) {

              // case 0:
              //   return AppLocalizations.of(context)!.subtask;
              case 1:
                return AppLocalizations.of(context)!.media;
              case 2:
                return AppLocalizations.of(context)!.statustimeline;
              case 3:
                return AppLocalizations.of(context)!.activityLog;
              default:
                return AppLocalizations.of(context)!.subtask;
            }
          })(),
          onPress: () {


            // _createEditStatus(isLightTheme: isLightTheme, isCreate: true);
          },
        ),
      ),
    );
  }

  Widget _floatingBottomNavBar(BuildContext context, bool isLightTheme) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
        child: Container(
          height: 50.h, // Reduced height
          decoration: BoxDecoration(
            color: isLightTheme
                ? Colors.white
                    .withOpacity(0.15) // More transparent for light theme
                : Colors.black
                    .withOpacity(0.15), // More transparent for dark theme
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: isLightTheme
                  ? Colors.white.withOpacity(0.2)
                  : Colors.white.withOpacity(0.1),
              width: 0.5,
            ),
            boxShadow: [
              BoxShadow(
                color: isLightTheme
                    ? Colors.black.withOpacity(0.05)
                    : Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 0,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // _tabItem(HeroIcons.photo, "Sub Task", AppColors.photoColor, 0),
              _tabItem(HeroIcons.photo, "Media", AppColors.photoColor, 1),
              _tabItem(HeroIcons.bars3, "Status", AppColors.yellow, 2),
              _tabItem(HeroIcons.chartBar, "Activity", AppColors.activityLogColor, 3),
            ],
          ),
        ),
      ),
    );
  }




  Widget mediaCard(
    TaskMedia,
    index,
    media,
    startDate,
    endDate,
  ) {
    return DismissibleCard(
      direction: context.read<PermissionsBloc>().isdeleteTask == true &&
              context.read<PermissionsBloc>().iseditTask == true
          ? DismissDirection.horizontal // Allow both directions
          : context.read<PermissionsBloc>().isdeleteTask == true
              ? DismissDirection.endToStart // Allow delete
              : context.read<PermissionsBloc>().iseditTask == true
                  ? DismissDirection.startToEnd // Allow edit
                  : DismissDirection.none,
      title: index.toString(),
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.startToEnd) {
          if (context.read<PermissionsBloc>().iseditTask == true) {
            return false;
          } else {
            // No edit permission, prevent swipe
            return false;
          }
        }

        // Handle deletion confirmation
        if (direction == DismissDirection.endToStart) {
          return await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(AppLocalizations.of(context)!.confirmDelete),
                    content: Text(AppLocalizations.of(context)!.areyousure),
                    actions: [
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(true), // Confirm
                        child: const Text('Delete'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(false), // Cancel
                        child: const Text('Cancel'),
                      ),
                    ],
                  );
                },
              ) ??
              false; // Default to false if dialog is dismissed without action
        }

        return false; // Default case for other directions
      },
      onDismissed: (DismissDirection direction) {
        if (direction == DismissDirection.endToStart &&
            context.read<PermissionsBloc>().isdeleteTask == true) {
          // setState(() {
          //   stateTask.removeAt(index);
          //   _onDeleteTask(id: stateTask[index].id);
          // });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditTask == true) {}
      },
      dismissWidget: InkWell(
          onTap: () {
            // router.push('/Taskdetails', extra: {
            //   "id": stateTask[index].id,
            // });
          },
          child: Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: customContainer(
              context: context,
              addWidget: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 18.w,
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Container(
                    // color: Colors.teal,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          text: "#${media.id.toString()}",
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                          fontWeight: FontWeight.w700,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Container(
                                  margin: EdgeInsets.all(10),
                                  height: 50.h,
                                  width: 50.w,
                                  decoration: BoxDecoration(
                                    // color: Colors.red,
                                    image: DecorationImage(
                                        image: NetworkImage(media.preview),
                                        fit: BoxFit.cover),
                                  )),
                            ),
                            SizedBox(
                              width: 5.w,
                            ),
                            Expanded(
                              flex: 3,
                              child: Container(
                                // color: Colors.yellow,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: CustomText(
                                            text: media.fileName,
                                            size: 15.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                            fontWeight: FontWeight.w700,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Container(
                                        //     height: 20.h,
                                        //     width: 20.w,
                                        //     decoration: BoxDecoration(
                                        //       // color: Colors.red,
                                        //       image: DecorationImage(
                                        //           image:
                                        //           AssetImage(AppImages.downloadGif),
                                        //           fit: BoxFit.cover),
                                        //     ))
                                        InkWell(
                                          onTap: () {
                                            print("DZgfxzg ${media.file}");
                                            context
                                                .read<TaskMediaBloc>()
                                                .add(TaskStartDownload(
                                                    fileUrl: media.file,
                                                    fileName: media.fileName));

                                            // downloadFile(media.file,media.fileName);
                                          },
                                          child: HeroIcon(
                                            HeroIcons.documentArrowDown,
                                            style: HeroIconStyle.outline,
                                            size: 25.sp,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .textClrChange,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        CustomText(
                                          text: media.fileSize,
                                          size: 12.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w700,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(top: 10.h),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: startDate,
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          Expanded(
                                            flex: 1,
                                            child: Center(
                                              child: Icon(
                                                Icons.compare_arrows,
                                                color: AppColors.greyColor,
                                                size: 20,
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 5,
                                            child: CustomText(
                                              text: endDate,
                                              size: 12.sp,
                                              color: AppColors.greyColor,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )),
    );
  }

  Widget StatusTimelineCard(TaskTimelineList, TaskTimeline, index) {
    Color? colorOfNewStatus;
    Color? colorOfOldStatus;

    switch (TaskTimeline.oldColor) {
      case "primary":
        colorOfOldStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfOldStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfOldStatus = Colors.green;
        break;
      case "danger":
        colorOfOldStatus = Colors.red;
        break;
      case "warning":
        colorOfOldStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfOldStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfOldStatus = Colors.black;
        break;
      default:
        colorOfOldStatus = Colors.grey; // Fallback color
    }
    switch (TaskTimeline.newColor) {
      case "primary":
        colorOfNewStatus = AppColors.primary;
        break;
      case "secondary":
        colorOfNewStatus = Color(0xFF8592a3);
        break;
      case "success":
        colorOfNewStatus = Colors.green;
        break;
      case "danger":
        colorOfNewStatus = Colors.red;
        break;
      case "warning":
        colorOfNewStatus = Color(0xFFfaab01);
        break;
      case "info":
        colorOfNewStatus = Color(0xFF36c3ec);
        break;
      case "dark":
        colorOfNewStatus = Colors.black;
        break;
      default:
        colorOfNewStatus = Colors.grey; // Fallback color
    }
    // Output: 2025-03-03
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      child: TimelineTile(
        isFirst: index == 0,
        isLast: index == TaskTimelineList.length - 1,
        beforeLineStyle: LineStyle(color: colorOfNewStatus, thickness: 3),
        indicatorStyle: IndicatorStyle(
          width: 15.w,
          color: colorOfNewStatus,
        ),
        endChild: Padding(
          padding: const EdgeInsets.all(10.0),
          child: customContainer(
              addWidget: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          TaskTimeline.timeDiff,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 10.h,
                    ),
                    Text(
                      "${TaskTimeline.changedAt}  ${TaskTimeline.changedAtTime}",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey),
                    ),
                    Text(
                      "changed status from ",
                      style: TextStyle(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.textClrChange),
                    ),
                    SizedBox(
                      height: 5.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfOldStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: TaskTimeline.previousStatus,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                        Text(
                          " >> ",
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.textClrChange),
                        ),
                        Container(
                          alignment: Alignment.center,
                          height: 20.h,
                          // width: 110.w, //
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color:
                                  colorOfNewStatus), // Set the height of the dropdown
                          child: Center(
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10.w),
                                child: CustomText(
                                  text: TaskTimeline.status,
                                  color: AppColors.whiteColor,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w600,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              context: context),
        ),
      ),
    );
  }
  Future<void> _uploadFile({pickFile, selectedFileName}) {
    return showModalBottomSheet<void>(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: const [],
                borderRadius: BorderRadius.circular(25),
                color: Theme.of(context).colorScheme.backGroundColor,
              ),
              height: 430.h,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          child: Row(
                            children: [
                              Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.greyColor
                                      .withValues(alpha: 0.3),
                                ),
                                child: HeroIcon(
                                  HeroIcons.cloudArrowUp,
                                  style: HeroIconStyle.outline,
                                  size: 25.sp,
                                  color: AppColors.greyColor,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(left: 10.w),
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text("Upload files",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold)),
                                      Text("Select and upload the files ",
                                          style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          width: 35,
                          // color: Colors.red,
                          child: Center(
                            child: IconButton(
                              icon: Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      decoration: const BoxDecoration(
                          border: DashedBorder.fromBorderSide(
                              dashLength: 15,
                              side: BorderSide(
                                  color: AppColors.greyColor, width: 1)),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: [
                          Container(
                              height: 70.h,
                              width: 70.w,
                              decoration: BoxDecoration(
                                // color: Colors.red,
                                image: DecorationImage(
                                    image: AssetImage(AppImages.cloudGif),
                                    fit: BoxFit.cover),
                              )),
                          const SizedBox(height: 8),
                          FittedBox(
                            child: CustomText(
                                text: AppLocalizations.of(context)!
                                    .chooseafileorclickbelow,
                                size: 20.sp,
                                textAlign:
                                    TextAlign.center, // Center align if needed
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context)
                                    .colorScheme
                                    .textClrChange),
                          ),
                          CustomText(
                            text: AppLocalizations.of(context)!.formatandsize,
                            color: AppColors.greyColor,
                            size: 15.sp,
                            textAlign: TextAlign
                                .center, // Make sure it wraps instead of cutting off
                          ),
                          const SizedBox(height: 12),
                          InkWell(
                            onTap: pickFile,
                            child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(6)),
                                height: 30.h,
                                width: 100.w,
                                margin: EdgeInsets.symmetric(vertical: 10.h),
                                child: CustomText(
                                  text:
                                      AppLocalizations.of(context)!.browsefile,
                                  size: 12.sp,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.pureWhiteColor,
                                )),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    InkWell(
                      onTap: (){
                        print("gklr dlgknv ");
                        context.read<TaskMediaBloc>().add(UploadTaskMedia(id: widget.id!, media: selectedFilesNotifier.value));
                        selectedFilesNotifier.value = [];
                        router.pop();

                      },
                      child: Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(6)),
                          height: 30.h,
                          width: 100.w,
                          margin: EdgeInsets.symmetric(vertical: 10.h),
                          child: CustomText(
                            text: AppLocalizations.of(context)!.upload,
                            size: 12.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.pureWhiteColor,
                          )),
                    ),
                    // if (selectedFileName != null)
                    //   Padding(
                    //     padding: const EdgeInsets.only(top: 12),
                    //     child: Text("Selected File: $selectedFileName"),
                    //   ),
                  ],
                ),
              ),
            ),
          );
        });
  }
  //
  // Widget StatusOfMilestoneField() {
  //   return StatefulBuilder(builder:
  //       (BuildContext context, void Function(void Function()) setState) {
  //     return Container(
  //       constraints: BoxConstraints(maxHeight: 900.h),
  //       width: MediaQuery.of(context).size.width,
  //       child: ListView.builder(
  //         shrinkWrap: true,
  //         itemCount: status.length,
  //         itemBuilder: (BuildContext context, int index) {
  //           final isSelected = statusname == status[index];
  //
  //           return Padding(
  //             padding: EdgeInsets.symmetric(vertical: 2.h),
  //             child: InkWell(
  //               highlightColor: Colors.transparent, // No highlight on tap
  //               splashColor: Colors.transparent,
  //               onTap: () {
  //                 setState(() {
  //                   statusname = status[index];
  //                 });
  //               },
  //               child: Padding(
  //                 padding: EdgeInsets.symmetric(
  //                   horizontal: 20.w,
  //                 ),
  //                 child: Container(
  //                   width: double.infinity,
  //                   height: 35.h,
  //                   decoration: BoxDecoration(
  //                       color: isSelected
  //                           ? AppColors.purpleShade
  //                           : Colors.transparent,
  //                       borderRadius: BorderRadius.circular(10),
  //                       border: Border.all(
  //                           color: isSelected
  //                               ? AppColors.purple
  //                               : Colors.transparent)),
  //                   child: Center(
  //                     child: Padding(
  //                       padding: EdgeInsets.symmetric(horizontal: 18.w),
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                         children: [
  //                           SizedBox(
  //                             width: 120.w,
  //                             // color: Colors.red,
  //                             child: CustomText(
  //                               text: status[index],
  //                               fontWeight: FontWeight.w500,
  //                               size: 18.sp,
  //                               maxLines: 1,
  //                               overflow: TextOverflow.ellipsis,
  //                               color: isSelected
  //                                   ? AppColors.purple
  //                                   : Theme.of(context)
  //                                       .colorScheme
  //                                       .textClrChange,
  //                             ),
  //                           ),
  //                           isSelected
  //                               ? const HeroIcon(HeroIcons.checkCircle,
  //                                   style: HeroIconStyle.solid,
  //                                   color: AppColors.purple)
  //                               : const SizedBox.shrink(),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                 ),
  //               ),
  //             ),
  //           );
  //         },
  //       ),
  //     );
  //   });
  // }
  //
  // Widget activityLog(isLightTheme) {
  //   return RefreshIndicator(
  //     color: AppColors.primary, // Spinner color
  //     backgroundColor: Theme.of(context).colorScheme.backGroundColor,
  //     onRefresh: _onRefresh,
  //     child: Column(
  //       children: [
  //         CustomSearchField(
  //           isLightTheme: isLightTheme,
  //           controller: activityLogSearchController,
  //           suffixIcon: Padding(
  //             padding: EdgeInsets.symmetric(horizontal: 10.w),
  //             child: Row(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 if (activityLogSearchController.text.isNotEmpty)
  //                   SizedBox(
  //                     width: 20.w,
  //                     // color: AppColors.red,
  //                     child: IconButton(
  //                       highlightColor: Colors.transparent,
  //                       padding: EdgeInsets.zero,
  //                       icon: Icon(
  //                         Icons.clear,
  //                         size: 20.sp,
  //                         color: Theme.of(context).colorScheme.textFieldColor,
  //                       ),
  //                       onPressed: () {
  //                         // Clear the search field
  //                         setState(() {
  //                           activityLogSearchController.clear();
  //                         });
  //                         // Optionally trigger the search event with an empty string
  //                         context
  //                             .read<ActivityLogBloc>()
  //                             .add(SearchActivityLog("", widget.id, "Task"));
  //                       },
  //                     ),
  //                   ),
  //                 SizedBox(
  //                   width: 30.w,
  //                   child: IconButton(
  //                     icon: Icon(
  //                       !speechHelper.isListening ? Icons.mic_off : Icons.mic,
  //                       size: 20.sp,
  //                       color: Theme.of(context).colorScheme.textFieldColor,
  //                     ),
  //                     onPressed: () {
  //                       if (speechHelper.isListening) {
  //                         speechHelper.stopListening();
  //                       } else {
  //                         speechHelper.startListening(
  //                             context, searchController, SearchPopUp());
  //                       }
  //                     },
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ),
  //           onChanged: (value) {
  //             activityLogSearchQuery = value;
  //             context.read<ActivityLogBloc>().add(SearchActivityLog(
  //                 activityLogSearchQuery, widget.id, "Task"));
  //           },
  //         ),
  //         SizedBox(height: 10.h),
  //         BlocConsumer<ActivityLogBloc, ActivityLogState>(
  //           listener: (context, state) {
  //             if (state is ActivityLogDeleteSuccess) {
  //               flutterToastCustom(
  //                   msg: AppLocalizations.of(context)!.deletedsuccessfully,
  //                   color: AppColors.primary);
  //               BlocProvider.of<ActivityLogBloc>(context)
  //                   .add(AllActivityLogList());
  //             } else if (state is ActivityLogError) {
  //               BlocProvider.of<ActivityLogBloc>(context)
  //                   .add(AllActivityLogList());
  //
  //               flutterToastCustom(msg: state.errorMessage);
  //             } else if (state is ActivityLogDeleteError) {
  //               BlocProvider.of<ActivityLogBloc>(context)
  //                   .add(AllActivityLogList());
  //
  //               flutterToastCustom(msg: state.errorMessage);
  //             }
  //           },
  //           builder: (context, state) {
  //             if (state is ActivityLogLoading) {
  //               return Expanded(
  //                 child: NotesShimmer(
  //                   height: 190.h,
  //                   count: 4,
  //                 ),
  //               );
  //             } else if (state is ActivityLogPaginated) {
  //               return NotificationListener<ScrollNotification>(
  //                 onNotification: (scrollInfo) {
  //                   if (!state.hasReachedMax &&
  //                       scrollInfo.metrics.pixels ==
  //                           scrollInfo.metrics.maxScrollExtent) {
  //                     context
  //                         .read<ActivityLogBloc>()
  //                         .add(LoadMoreActivityLog(""));
  //                   }
  //                   return false;
  //                 },
  //                 child: state.activityLog.isNotEmpty
  //                     ? _activityLogList(
  //                         isLightTheme, state.hasReachedMax, state.activityLog)
  //
  //                     // height: 500,
  //
  //                     : NoData(
  //                         isImage: true,
  //                       ),
  //               );
  //             }
  //             // Handle other states
  //             return const Text("");
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }
  //
  // Widget _activityLogList(isLightTheme, hasReachedMax, activityLog) {
  //   return Expanded(
  //     child: ListView.builder(
  //       padding: EdgeInsets.only(bottom: 0.h),
  //       // shrinkWrap: true,
  //       itemCount: hasReachedMax
  //           ? activityLog.length // No extra item if all data is loaded
  //           : activityLog.length + 1, // Add 1 for the loading indicator
  //       itemBuilder: (context, index) {
  //         if (index < activityLog.length) {
  //           final activity = activityLog[index];
  //           String? dateCreated;
  //           dateCreated = formatDateFromApi(activity.createdAt!, context);
  //           return index == 0
  //               ? ShakeWidget(
  //                   child: Padding(
  //                       padding: EdgeInsets.symmetric(
  //                           vertical: 10.h, horizontal: 18.w),
  //                       child: DismissibleCard(
  //                         title: activityLog[index].id.toString(),
  //                         confirmDismiss: (DismissDirection direction) async {
  //                           if (direction == DismissDirection.endToStart) {
  //                             // Right to left swipe (Delete action)
  //                             final result = await showDialog(
  //                               context: context,
  //                               builder: (context) {
  //                                 return AlertDialog(
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(
  //                                         10.r), // Set the desired radius here
  //                                   ),
  //                                   backgroundColor: Theme.of(context)
  //                                       .colorScheme
  //                                       .alertBoxBackGroundColor,
  //                                   title: Text(
  //                                     AppLocalizations.of(context)!
  //                                         .confirmDelete,
  //                                   ),
  //                                   content: Text(
  //                                     AppLocalizations.of(context)!.areyousure,
  //                                   ),
  //                                   actions: [
  //                                     TextButton(
  //                                       onPressed: () {
  //                                         Navigator.of(context)
  //                                             .pop(true); // Confirm deletion
  //                                       },
  //                                       child: Text(
  //                                         AppLocalizations.of(context)!.delete,
  //                                       ),
  //                                     ),
  //                                     TextButton(
  //                                       onPressed: () {
  //                                         Navigator.of(context)
  //                                             .pop(false); // Cancel deletion
  //                                       },
  //                                       child: Text(
  //                                         AppLocalizations.of(context)!.cancel,
  //                                       ),
  //                                     ),
  //                                   ],
  //                                 );
  //                               },
  //                             );
  //                             return result;
  //                           }
  //                           return false;
  //                         },
  //                         dismissWidget: _activityChild(
  //                             isLightTheme, activityLog[index], dateCreated),
  //                         direction: context
  //                                     .read<PermissionsBloc>()
  //                                     .isdeleteActivityLog ==
  //                                 true
  //                             ? DismissDirection.endToStart
  //                             : DismissDirection.none,
  //                         onDismissed: (DismissDirection direction) {
  //                           if (direction == DismissDirection.endToStart) {
  //                             setState(() {
  //                               activityLog.removeAt(index);
  //                               // onDeleteActivityLog(activity.id!);
  //                             });
  //                           }
  //                         },
  //                       )),
  //                 )
  //               : Padding(
  //                   padding:
  //                       EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
  //                   child: DismissibleCard(
  //                     title: activityLog[index].id.toString(),
  //                     confirmDismiss: (DismissDirection direction) async {
  //                       if (direction == DismissDirection.endToStart) {
  //                         // Right to left swipe (Delete action)
  //                         final result = await showDialog(
  //                           context: context,
  //                           builder: (context) {
  //                             return AlertDialog(
  //                               shape: RoundedRectangleBorder(
  //                                 borderRadius: BorderRadius.circular(
  //                                     10.r), // Set the desired radius here
  //                               ),
  //                               backgroundColor: Theme.of(context)
  //                                   .colorScheme
  //                                   .alertBoxBackGroundColor,
  //                               title: Text(
  //                                 AppLocalizations.of(context)!.confirmDelete,
  //                               ),
  //                               content: Text(
  //                                 AppLocalizations.of(context)!.areyousure,
  //                               ),
  //                               actions: [
  //                                 TextButton(
  //                                   onPressed: () {
  //                                     Navigator.of(context)
  //                                         .pop(true); // Confirm deletion
  //                                   },
  //                                   child: Text(
  //                                     AppLocalizations.of(context)!.delete,
  //                                   ),
  //                                 ),
  //                                 TextButton(
  //                                   onPressed: () {
  //                                     Navigator.of(context)
  //                                         .pop(false); // Cancel deletion
  //                                   },
  //                                   child: Text(
  //                                     AppLocalizations.of(context)!.cancel,
  //                                   ),
  //                                 ),
  //                               ],
  //                             );
  //                           },
  //                         );
  //                         return result;
  //                       }
  //                       return false;
  //                     },
  //                     dismissWidget: _activityChild(
  //                         isLightTheme, activityLog[index], dateCreated),
  //                     direction:
  //                         context.read<PermissionsBloc>().isdeleteActivityLog ==
  //                                 true
  //                             ? DismissDirection.endToStart
  //                             : DismissDirection.none,
  //                     onDismissed: (DismissDirection direction) {
  //                       if (direction == DismissDirection.endToStart) {
  //                         setState(() {
  //                           activityLog.removeAt(index);
  //                           // onDeleteActivityLog(activity.id!);
  //                         });
  //                       }
  //                     },
  //                   ));
  //         } else {
  //           // Show a loading indicator when more Meeting are being loaded
  //           return CircularProgressIndicatorCustom(
  //             hasReachedMax: hasReachedMax,
  //           );
  //         }
  //       },
  //     ),
  //   );
  // }
  //
  // Widget _activityChild(isLightTheme, activityLog, dateCreated) {
  //   String? profilePic;
  //   if (context.read<UserProfileBloc>().profilePic != null) {
  //     profilePic = context.read<UserProfileBloc>().profilePic;
  //   }
  //   return Container(
  //       decoration: BoxDecoration(
  //           boxShadow: [
  //             isLightTheme
  //                 ? MyThemes.lightThemeShadow
  //                 : MyThemes.darkThemeShadow,
  //           ],
  //           color: Theme.of(context).colorScheme.containerDark,
  //           borderRadius: BorderRadius.circular(12)),
  //       // height: 170.h,
  //       child: Row(
  //         mainAxisAlignment: MainAxisAlignment.start,
  //         crossAxisAlignment: CrossAxisAlignment.center,
  //         children: [
  //           Flexible(
  //             flex: 3,
  //             child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Padding(
  //                     padding:
  //                         EdgeInsets.only(top: 20.h, left: 18.w, right: 18.w),
  //                     child: SizedBox(
  //                       // height: 40.h,
  //
  //                       // color: Colors.yellow,
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.start,
  //                         crossAxisAlignment: CrossAxisAlignment.start,
  //                         children: [
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               Row(
  //                                 mainAxisAlignment: MainAxisAlignment.start,
  //                                 crossAxisAlignment: CrossAxisAlignment.start,
  //                                 children: [
  //                                   Column(
  //                                     mainAxisAlignment:
  //                                         MainAxisAlignment.start,
  //                                     crossAxisAlignment:
  //                                         CrossAxisAlignment.start,
  //                                     children: [
  //                                       CustomText(
  //                                         text: "#${activityLog.id.toString()}",
  //                                         size: 12.sp,
  //                                         color: AppColors.projDetailsSubText,
  //                                         fontWeight: FontWeight.w600,
  //                                       ),
  //                                       SizedBox(
  //                                         height: 15.h,
  //                                       ),
  //                                       SizedBox(
  //                                         // color: Colors.red,
  //                                         child: Row(
  //                                           mainAxisAlignment:
  //                                               MainAxisAlignment.center,
  //                                           crossAxisAlignment:
  //                                               CrossAxisAlignment.center,
  //                                           children: [
  //                                             SizedBox(
  //                                               // width:30.w,
  //                                               // alignment: Alignment.center,
  //                                               child: CircleAvatar(
  //                                                 radius: 25.r,
  //                                                 backgroundColor:
  //                                                     Theme.of(context)
  //                                                         .colorScheme
  //                                                         .backGroundColor,
  //                                                 child: profilePic != null
  //                                                     ? CircleAvatar(
  //                                                         backgroundImage:
  //                                                             NetworkImage(
  //                                                                 profilePic!),
  //                                                         radius: 25
  //                                                             .r, // Size of the profile image
  //                                                       )
  //                                                     : CircleAvatar(
  //                                                         radius: 25
  //                                                             .r, // Size of the profile image
  //                                                         backgroundColor:
  //                                                             Colors.grey[200],
  //                                                         child: Icon(
  //                                                           Icons.person,
  //                                                           size: 20.sp,
  //                                                           color: Colors.grey,
  //                                                         ), // Replace with your image URL
  //                                                       ),
  //                                               ),
  //                                             ),
  //                                             SizedBox(
  //                                               width: 10.w,
  //                                             ),
  //                                             SizedBox(
  //                                               width: 140.w,
  //                                               // color: Colors.orange,
  //                                               child: CustomText(
  //                                                 text: activityLog.actorName ??
  //                                                     "",
  //                                                 color: Theme.of(context)
  //                                                     .colorScheme
  //                                                     .textClrChange,
  //                                                 size: 17,
  //                                                 maxLines: 2,
  //                                                 fontWeight: FontWeight.w500,
  //                                               ),
  //                                             ),
  //                                           ],
  //                                         ),
  //                                       ),
  //                                       SizedBox(
  //                                         height: 10.h,
  //                                       ),
  //                                       Padding(
  //                                         padding: EdgeInsets.only(left: 0.w),
  //                                         child: SizedBox(
  //                                           child: Column(
  //                                             mainAxisAlignment:
  //                                                 MainAxisAlignment.start,
  //                                             crossAxisAlignment:
  //                                                 CrossAxisAlignment.start,
  //                                             children: [
  //                                               Row(
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment
  //                                                         .start, // Align text to the top
  //                                                 children: [
  //                                                   HeroIcon(
  //                                                     HeroIcons.envelope,
  //                                                     style:
  //                                                         HeroIconStyle.outline,
  //                                                     color: AppColors
  //                                                         .projDetailsSubText,
  //                                                     size: 20.sp,
  //                                                   ),
  //                                                   SizedBox(width: 10.w),
  //                                                   ConstrainedBox(
  //                                                     constraints: BoxConstraints(
  //                                                         maxWidth: 180
  //                                                             .w), // Adjust width accordingly
  //                                                     child: CustomText(
  //                                                       text: activityLog
  //                                                               .message ??
  //                                                           "No message",
  //                                                       color: Colors.grey,
  //                                                       size: 15,
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                       maxLines: null,
  //                                                       softwrap: true,
  //                                                       overflow: TextOverflow
  //                                                           .visible,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                               SizedBox(
  //                                                 height: 10.w,
  //                                               ),
  //                                               Row(
  //                                                 mainAxisAlignment:
  //                                                     MainAxisAlignment.start,
  //                                                 crossAxisAlignment:
  //                                                     CrossAxisAlignment.start,
  //                                                 children: [
  //                                                   HeroIcon(
  //                                                     HeroIcons.clock,
  //                                                     style:
  //                                                         HeroIconStyle.outline,
  //                                                     color: AppColors
  //                                                         .projDetailsSubText,
  //                                                     size: 20.sp,
  //                                                   ),
  //                                                   SizedBox(
  //                                                     width: 10.w,
  //                                                   ),
  //                                                   Container(
  //                                                     // width: 220.w,
  //                                                     alignment:
  //                                                         Alignment.topLeft,
  //                                                     // color: Colors.orange,
  //                                                     child: CustomText(
  //                                                       text: dateCreated,
  //                                                       color: Colors.grey,
  //                                                       size: 15,
  //                                                       fontWeight:
  //                                                           FontWeight.w500,
  //                                                     ),
  //                                                   ),
  //                                                 ],
  //                                               ),
  //                                             ],
  //                                           ),
  //                                         ),
  //                                       ),
  //                                       SizedBox(
  //                                         height: 20.w,
  //                                       ),
  //                                     ],
  //                                   )
  //                                 ],
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                   ),
  //                   // Divider(color: colors.darkColor),
  //                 ]),
  //           ),
  //           // Flexible(
  //           //   flex: 1,
  //           //   child: Container(
  //           //     // color: Colors.red,
  //           //     child: Image.asset(AppImages.activityImage,
  //           //         height: 70.h, width: 70.w),
  //           //   ),
  //           // )
  //         ],
  //       ));
  // }

  void showToastWithProgress(BuildContext context, double progress) {
    OverlayState overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80.0,
        left: 20.0,
        right: 20.0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(17.4),
              color: Theme.of(context).colorScheme.containerDark,
            ),

            // height: 50.h,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  CustomText(
                    text:
                        "Downloading... ${(progress * 100).toStringAsFixed(0)} %",
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15.sp,
                  ),
                  SizedBox(height: 15),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor:
                        Theme.of(context).colorScheme.textClrChange,
                    minHeight: 8.h,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

    overlayState.insert(overlayEntry);

    // Remove after a few seconds or upon completion
    Future.delayed(Duration(seconds: 5), () {
      overlayEntry.remove();
    });
  }
}
