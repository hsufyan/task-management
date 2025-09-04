import 'dart:async';
import 'dart:math';
import 'package:custom_date_range_picker/custom_date_range_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter/material.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/permissions/permissions_bloc.dart';
import 'package:taskify/bloc/permissions/permissions_event.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/data/model/Project/all_project.dart';
import 'package:taskify/utils/widgets/custom_dimissible.dart';
import 'package:taskify/utils/widgets/row_dashboard.dart';
import 'package:taskify/utils/widgets/shake_widget.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/priority/priority_state.dart';
import '../../bloc/project_filter/project_filter_bloc.dart';
import '../../bloc/project_filter/project_filter_event.dart';
import '../../bloc/project_filter/project_filter_state.dart';
import '../../bloc/tags/tags_state.dart';
import '../../bloc/multi_tag/tag_multi_bloc.dart';
import '../../bloc/multi_tag/tag_multi_event.dart';
import '../../bloc/multi_tag/tag_multi_state.dart';
import '../../bloc/priority_multi/priority_multi_bloc.dart';
import '../../bloc/priority_multi/priority_multi_event.dart';
import '../../bloc/priority_multi/priority_multi_state.dart';
import '../../bloc/status_multi/status_multi_bloc.dart';
import '../../bloc/status_multi/status_multi_event.dart';
import '../../bloc/status_multi/status_multi_state.dart';
import '../../bloc/task_filter/task_filter_bloc.dart';
import '../../bloc/task_filter/task_filter_event.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../config/constants.dart';
import '../../config/strings.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:intl/intl.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../config/colors.dart';
import '../../data/repositories/Project/project_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../../utils/widgets/back_arrow.dart';
import '../../utils/widgets/search_pop_up.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/custom_date.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../widgets/no_permission_screen.dart';
import '../widgets/search_field.dart';
import '../widgets/user_client_box.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

double progress = 0.6;

class _ProjectScreenState extends State<ProjectScreen>
    with TickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(

    
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);
  late final AnimationController _pinnedcController = AnimationController(
      duration: const Duration(milliseconds: 200), vsync: this, value: 1.0);

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  bool hasShownShowcase = false;
  String _lastWords = "";
  String searchword = "";
  bool isListening =
      false; // Flag to track if speech recognition is in progress
  bool dialogShown = false;

  int? projectsId;
  String? fromDate;
  String? toDate;
  bool? isFirstTimeUSer;
  DateTime selectedDateStarts = DateTime.now();
  DateTime? selectedDateEnds = DateTime.now();
  final TextEditingController _clientSearchController = TextEditingController();
  final TextEditingController _statusSearchController = TextEditingController();
  final TextEditingController _prioritySearchController =
      TextEditingController();
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  final TextEditingController _userSearchController = TextEditingController();
  final TextEditingController _tagSearchController = TextEditingController();

  TextEditingController startsController = TextEditingController();
  TextEditingController endController = TextEditingController();

  List<int> userSelectedId = [];
  List<int> userSelectedIdS = [];
  List<String> userSelectedname = [];

  List<int> clientSelectedIdS = [];
  String? currency;
  String? currencyPosition;
  List<String> clientSelectedname = [];

  List<int> prioritySelectedIdS = [];
  List<String> prioritySelectedname = [];

  List<int> tagsSelectedIdS = [];
  List<String> tagsSelectedname = [];
  bool? isLoading = true;
  bool? clientSelected = false;
  bool? clientDisSelected = false;
  bool? priorityDisSelected = false;
  bool? userDisSelected = false;
  bool? tagDisSelected = false;
  bool? statusDisSelected = false;
  bool? dateDisSelected = false;
  bool? userSelected = false;
  bool? statusSelected = false;
  bool? prioritySelected = false;
  bool? tagSelected = false;
  bool? dateSelected = false;

  List<int> statusSelectedIdS = [];
  List<String> statusSelectedname = [];

  final ValueNotifier<String> filterNameNotifier =
      ValueNotifier<String>('Clients'); // Initialize with default value

  String filterName = 'Clients';

  int? selectedIndex;

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

  _getFirstTimeUser() async {
    var box = await Hive.openBox(authBox);
    isFirstTimeUSer = box.get(firstTimeUserKey) ?? true;
    print("fr;hesfreskf $isFirstTimeUSer");
  }

  Future<void> requestForPermission() async {
    await Permission.microphone.request();
  }

  void _onDeleteProject({required int id}) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(id));
    setting.stream.listen((state) {
      if (state is ProjectDeleteSuccess) {
        if (mounted) {
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
  }

  TextEditingController searchController = TextEditingController();
  final GlobalKey _one = GlobalKey();

  int filterSelectedId = 0;
  String searchWord = "";
  int filterCount = 0;
  String filterSelectedName = "";
  bool? isFirst;
  final List<String> filter = [
    'Clients',
    'Users',
    'Status',
    'Priorities',
    'Tags',
    'Date'
  ];

  @override
  void dispose() {
    super.dispose();
    searchController.dispose();
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
                                filterNameNotifier.value = filter[index];
                                filterName = filter[index];
                              });
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 2.h),
                              child: Container(
                                height: 50.h,
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
                                      flex: 35,
                                      child: Center(
                                        child: Text(
                                          filter[index],
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
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    // Apply Button
                    InkWell(
                      onTap: () {
                        // Calculate and update filter count based on selections
                        if (clientSelectedIdS.isNotEmpty) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'clients', isSelected: true),
                              );
                        }
                        if (userSelectedIdS.isNotEmpty) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'users', isSelected: true),
                              );
                        }
                        if (statusSelectedIdS.isNotEmpty) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'status', isSelected: true),
                              );
                        }
                        if (prioritySelectedIdS.isNotEmpty) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'priorities', isSelected: true),
                              );
                        }
                        if (tagsSelectedIdS.isNotEmpty) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'tags', isSelected: true),
                              );
                        }
                        if (fromDate != null || toDate != null) {
                          context.read<FilterCountBloc>().add(
                                ProjectUpdateFilterCount(
                                    filterType: 'date', isSelected: true),
                              );
                        }

                        // Apply filters to project dashboard
                        BlocProvider.of<ProjectBloc>(context).add(
                          ProjectDashBoardList(
                            tagId: tagsSelectedIdS,
                            clientId: clientSelectedIdS,
                            userId: userSelectedIdS,
                            statusId: statusSelectedIdS,
                            priorityId: prioritySelectedIdS,
                            fromDate: fromDate,
                            toDate: toDate,
                          ),
                        );

                        // Clear search controllers
                        _clientSearchController.clear();
                        _statusSearchController.clear();
                        _prioritySearchController.clear();
                        _userSearchController.clear();
                        _tagSearchController.clear();

                        Navigator.of(context).pop();
                      },
                      child: Container(
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 15.w, vertical: 0.h),
                          child: Center(
                            child: CustomText(
                              text: AppLocalizations.of(context)!.apply,
                              size: 12.sp,
                              color: AppColors.pureWhiteColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 30.w),
                    // Clear Button
                    InkWell(
                      onTap: () {
                        setState(() {
                          // Reset all filter selections
                          context
                              .read<FilterCountBloc>()
                              .add(ProjectResetFilterCount());

                          // Clear all selected IDs
                          tagsSelectedIdS.clear();
                          clientSelectedIdS.clear();
                          userSelectedIdS.clear();
                          statusSelectedIdS.clear();
                          prioritySelectedIdS.clear();

                          // Reset date filters
                          fromDate = "";
                          toDate = "";
                          startsController.text = "";
                          endController.text = "";

                          // Clear search controllers
                          _clientSearchController.clear();
                          _statusSearchController.clear();
                          _prioritySearchController.clear();
                          _userSearchController.clear();
                          _tagSearchController.clear();

                          // Reset filter name
                          filterNameNotifier.value = 'Clients';

                          // Reset project dashboard
                          BlocProvider.of<ProjectBloc>(context)
                              .add(ProjectDashBoardList());

                          Navigator.of(context).pop();
                        });
                      },
                      child: Container(
                        height: 35.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 15.w),
                          child: Center(
                            child: CustomText(
                              text: AppLocalizations.of(context)!.clear,
                              size: 12.sp,
                              color: AppColors.pureWhiteColor,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    context.read<FilterCountBloc>().add(ProjectResetFilterCount());
    context.read<TaskFilterCountBloc>().add(TaskResetFilterCount());

    currency = context.read<SettingsBloc>().currencySymbol;
    currencyPosition = context.read<SettingsBloc>().currencyPosition;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => ShowCaseWidget.of(context).startShowCase([
        _one,
      ]),
    );

    listenForPermissions();
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    if (!_speechEnabled) {
      _initSpeech();
    }
    _getFirstTimeUser();
    super.initState();
  }

  _setIsFirst(value) async {
    isFirst = value;
    var box = await Hive.openBox(authBox);
    box.put("isFirstCase", value);
  }

  // void onShowCaseCompleted() {
  //   _setIsFirst(false);
  // }

  Future<void> _onRefresh() async {
    setState(() {
      isLoading = true;
    });
    filterCount = 0;
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());

    setState(() {
      isLoading = false;
    });
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

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
  }

  bool shouldDisableEdit = true;
  double minSoundLevel = 50000;
  double maxSoundLevel = -50000;
  static final bool _onDevice = false;

  void soundLevelListener(double level) {
    minSoundLevel = min(minSoundLevel, level);
    maxSoundLevel = max(maxSoundLevel, level);
    // _logEvent('sound level $level: $minSoundLevel - $maxSoundLevel ');
    setState(() {
      this.level = level;
    });
  }

  double level = 0.0;

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
      setState(() {});
    }
  }

  final options = SpeechListenOptions(
      onDevice: _onDevice,
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
      autoPunctuation: true,
      enableHapticFeedback: true);

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

    // Trigger search with the current recognized words
    context.read<ProjectBloc>().add(SearchProject(
          _lastWords,
          [],
          [],
        ));
  }

  bool isLoadingMore = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return Scaffold(
        floatingActionButton:
            (context.read<PermissionsBloc>().iscreateProject == true)
                ? Padding(
                    padding: EdgeInsets.only(bottom: 60.h),
                    child: FloatingActionButton(
                      isExtended: true,
                      onPressed: () {
                        context.read<PermissionsBloc>().iscreateProject == true
                            ? router.push('/createproject', extra: {
                                "id": 0,
                                "isCreate": true,
                                "title": "",
                                "desc": "",
                                "start": "",
                                "budget": "",
                                "end": "",
                                // "user":task.users,
                                'priority': "",
                                'priorityId': 0,
                                'statusId': 0,
                                'note': "",
                                'status': "",
                              })
                            : null;
                      }, // Icon inside the FAB
                      backgroundColor: AppColors.primary,
                      child: isFirstTimeUSer == true
                          ? const Icon(
                              Icons.add,
                              color: AppColors.whiteColor,
                            )
                          : const Icon(
                              Icons.add,
                              color: AppColors.whiteColor,
                            ), // Background color of the FAB
                    ),
                  )
                : SizedBox.shrink(),
        backgroundColor: Theme.of(context).colorScheme.backGroundColor,
        body: Container(
          color: Theme.of(context).colorScheme.backGroundColor,
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),
                child: BackArrow(
                  iSBackArrow: true,
                  fromDash: true,
                  isFav: true,
                  onFav: () {
                    router.push(
                      '/favorite',
                    );
                  },
                  title: AppLocalizations.of(context)!.projects,
                ),
              ),
              SizedBox(height: 20.h),
              CustomSearchField(
                isLightTheme: isLightTheme,
                controller: searchController,
                suffixIcon: Row(
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
                            searchController.clear();
                            context
                                .read<ProjectBloc>()
                                .add(SearchProject('', [], []));
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
                    BlocBuilder<FilterCountBloc, FilterCountState>(
                      builder: (context, state) {
                        return SizedBox(
                          width: 35.w,
                          child: Stack(
                            children: [
                              IconButton(
                                icon: HeroIcon(
                                  HeroIcons.adjustmentsHorizontal,
                                  style: HeroIconStyle.solid,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textFieldColor,
                                  size: 30.sp,
                                ),
                                onPressed: () {
                                  BlocProvider.of<ClientBloc>(context)
                                      .add(ClientList());
                                  BlocProvider.of<UserBloc>(context)
                                      .add(UserList());
                                  BlocProvider.of<StatusMultiBloc>(context)
                                      .add(StatusMultiList());
                                  BlocProvider.of<TagMultiBloc>(context)
                                      .add(TagMultiList());
                                  BlocProvider.of<PriorityMultiBloc>(context)
                                      .add(PriorityMultiList());

                                  // Your existing filter dialog logic
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
                onChanged: (value) {
                  searchword = value;
                  context.read<ProjectBloc>().add(SearchProject(value, [], []));
                },
              ),
              SizedBox(height: 20.h),
              Expanded(
                child: RefreshIndicator(
                    color: AppColors.primary, // Spinner color
                    backgroundColor:
                        Theme.of(context).colorScheme.backGroundColor,
                    onRefresh: _onRefresh,
                    child: context.read<PermissionsBloc>().isManageProject ==
                            true
                        ? BlocConsumer<ProjectBloc, ProjectState>(
                            listener: (context, state) {
                              if (state is ProjectPaginated) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              print("sfdjnxcvdzxcvgfn  $state");
                              if (state is ProjectLoading) {
                                return const NotesShimmer();
                              } else if (state is ProjectPaginated) {
                                // Show notes list with pagination
                                return NotificationListener<ScrollNotification>(
                                  onNotification: (scrollInfo) {
                                    if (scrollInfo is ScrollStartNotification) {
                                      FocusScope.of(context)
                                          .unfocus(); // Dismiss keyboard
                                    }
                                    // Check if the user has scrolled to the end and load more notes if needed
                                    if (!state.hasReachedMax &&
                                        scrollInfo.metrics.pixels ==
                                            scrollInfo
                                                .metrics.maxScrollExtent &&
                                        isLoadingMore == false) {
                                      isLoadingMore = true;
                                      setState(() {});
                                      context.read<ProjectBloc>().add(
                                          ProjectLoadMore(searchWord, [], []));
                                    }
                                    return false;
                                  },
                                  child: context
                                              .read<PermissionsBloc>()
                                              .isManageProject ==
                                          true
                                      ? state.project.isNotEmpty
                                          ? ListView.builder(
                                              padding: EdgeInsets.only(
                                                  left: 18.w,
                                                  right: 18.w,
                                                  bottom: 70.h,
                                                  top: 0),
                                              // physics: NeverScrollableScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.project.length
                                                  : state.project.length + 1,
                                              itemBuilder: (context, index) {
                                                if (index <
                                                    state.project.length) {
                                                  ProjectModel project =
                                                      state.project[index];
                                                  String? date;

                                                  if (project.startDate !=
                                                      null) {
                                                    date = formatDateFromApi(
                                                        project.startDate!,
                                                        context);
                                                  }
                                                  return (index == 0 ||
                                                          isFirstTimeUSer ==
                                                              true)
                                                      ? ShakeWidget(
                                                          child: (index == 0 &&
                                                                  isFirstTimeUSer ==
                                                                      true)
                                                              ? Showcase(
                                                                  onTargetClick:
                                                                      () {
                                                                    ShowCaseWidget.of(
                                                                            context)
                                                                        .completed(
                                                                            _one);
                                                                    if (ShowCaseWidget.of(context)
                                                                            .activeWidgetId ==
                                                                        1) {
                                                                      //  onShowCaseCompleted();
                                                                    }
                                                                    _setIsFirst(
                                                                        false);
                                                                  },
                                                                  disposeOnTap:
                                                                      true,
                                                                  key: _one,
                                                                  title: AppLocalizations.of(
                                                                          context)!
                                                                      .swipe,
                                                                  titleAlignment:
                                                                      Alignment
                                                                          .center,
                                                                  descriptionAlignment:
                                                                      Alignment
                                                                          .center,
                                                                  description:
                                                                      "${AppLocalizations.of(context)!.swipelefttodelete} \n${AppLocalizations.of(context)!.swiperighttoedit}",
                                                                  tooltipBackgroundColor:
                                                                      AppColors
                                                                          .primary,
                                                                  textColor:
                                                                      Colors
                                                                          .white,
                                                                  child: projectList(
                                                                      state
                                                                          .project,
                                                                      index,
                                                                      project,
                                                                      date,
                                                                      isLightTheme),
                                                                )
                                                              : projectList(
                                                                  state.project,
                                                                  index,
                                                                  project,
                                                                  date,
                                                                  isLightTheme
                                                                  ),
                                                        )
                                                      : projectList(
                                                          state.project,
                                                          index,
                                                          project,
                                                          date,
                                                          isLightTheme);
                                                } else {
                                                  // Show a loading indicator when more notes are being loaded
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 0),
                                                    child: Center(
                                                      child: state.hasReachedMax
                                                          ? const Text('')
                                                          : const SpinKitFadingCircle(
                                                              color: AppColors
                                                                  .primary,
                                                              size: 40.0,
                                                            ),
                                                    ),
                                                  );
                                                }
                                              })
                                          : NoData(
                                              isImage: true,
                                            )
                                      : NoPermission(),
                                );
                              } else if (state is ProjectError) {
                                // Show error message
                                return const NotesShimmer();
                              } else if (state is ProjectSuccess) {}
                              // Handle other states
                              return Container();
                            },
                          )
                        : const NoPermission()),
              ),
            ],
          ),
        ));
  }

  void _onFilterSelected(String selectedFilter) {
    setState(() {
      filterName = selectedFilter; // Update the filterName and rebuild UI
    });
  }

  Widget _getFilteredWidget(filterName, isLightTheme) {
    switch (filterName.toLowerCase()) {
      case 'clients':
        return clientLists(); // Show ClientList if filterName is "client"
      case 'users':
        return userLists(); // Show UserList if filterName is "user"
      case 'tags':
        return tagsLists();
      case 'status':
        return statusLists();
      case 'priorities':
        return priorityLists();
      case 'date':
        return dateList(isLightTheme); // Show TagsList if filterName is "tags"
      default:
        return clientLists(); // Default view
    }
  }

  Widget dateList(isLightTheme) {
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
                      // if (start.isBefore(DateTime.now())) {
                      //   start = DateTime
                      //       .now(); // Reset the start date to today if earlier
                      // }

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

  Widget clientLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Container(
            padding: EdgeInsets.zero,
            height: 35.h,
            child: TextField(
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _clientSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 30.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: AppLocalizations.of(context)!.search,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                context.read<ClientBloc>().add(SearchClients(value));
              },
              onSubmitted: (value) {
                context.read<ClientBloc>().add(SearchClients(value));
              },
            ),
          ),
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
                      .add(ClientLoadMore(searchWord));
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
                                      clientSelectedname.remove(
                                          state.client[index].firstName!);
                                      // If no clients are selected anymore, update filter count
                                      if (clientSelectedIdS.isEmpty) {
                                        context.read<FilterCountBloc>().add(
                                              ProjectUpdateFilterCount(
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
                                        clientSelectedname.add(
                                            state.client[index].firstName!);
                                        // Update filter count when first client is selected
                                        if (clientSelectedIdS.length == 1) {
                                          context.read<FilterCountBloc>().add(
                                                ProjectUpdateFilterCount(
                                                  filterType: 'clients',
                                                  isSelected: true,
                                                ),
                                              );
                                        }
                                      }
                                    }
                                  });
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
                                                    state.client[index]
                                                        .profile!),
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
                                                                  .client[index]
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
                                                          SizedBox(width: 5.w),
                                                          Flexible(
                                                            child: CustomText(
                                                              text: state
                                                                  .client[index]
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
                                                                  .client[index]
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
                          },
                        )
                      : NoData());
            });
          }
          return SizedBox();
        }),
      ],
    );
  }

  Widget statusLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _statusSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.greyForgetColor,
                    // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors.purple,
                    // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                context.read<StatusMultiBloc>().add(SearchStatusMultis(value));
              },
            ),
          ),
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
                                      context.read<FilterCountBloc>().add(
                                            ProjectUpdateFilterCount(
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
                                        context.read<FilterCountBloc>().add(
                                              ProjectUpdateFilterCount(
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
                                // context.read<ProjectBloc>().add(SearchProject("", filterSelectedId, filterSelectedNmae));
                                // Future.delayed(Duration(seconds: 1), () {
                                //   Navigator.pop(context);
                                // });

                                // userSelectedIdS.clear();
                                // userSelectedname.clear();
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
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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

  Widget priorityLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _prioritySearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.greyForgetColor,
                    // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors.purple,
                    // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                context
                    .read<PriorityMultiBloc>()
                    .add(SearchPriorityMultis(value));
              },
            ),
          ),
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
                  // We're at the bottom
                  BlocProvider.of<ClientBloc>(context)
                      .add(ClientLoadMore(searchWord));
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530.h,
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
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                // userSelectedname.clear();
                                // userSelectedIdS.clear();
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
                                      context.read<FilterCountBloc>().add(
                                            ProjectUpdateFilterCount(
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
                                        context.read<FilterCountBloc>().add(
                                              ProjectUpdateFilterCount(
                                                filterType: 'priorities',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId =
                                        state.priorityMulti[index].id!;
                                    filterSelectedName = "priorities";
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
                                // context.read<ProjectBloc>().add(SearchProject("", filterSelectedId, filterSelectedNmae));
                                // Future.delayed(Duration(seconds: 1), () {
                                //   Navigator.pop(context);
                                // });

                                // userSelectedIdS.clear();
                                // userSelectedname.clear();
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
                                              overflow: TextOverflow.ellipsis,
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

  Widget tagsLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _tagSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                context.read<TagMultiBloc>().add(SearchTagMultis(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<TagMultiBloc, TagMultiState>(builder: (context, state) {
          if (state is TagsLoading || state is TagsInitial) {
            return SpinKitFadingCircle(
              size: 40,
              color: AppColors.primary,
            );
          }
          if (state is TagMultiPaginated) {
            ScrollController scrollController = ScrollController();
            scrollController.addListener(() {
              if (scrollController.position.atEdge) {
                if (scrollController.position.pixels != 0 &&
                    !state.hasReachedMax) {
                  // We're at the bottom
                  BlocProvider.of<TagMultiBloc>(context)
                      .add(TagMultiLoadMore());
                }
              }
            });

            return StatefulBuilder(builder: (BuildContext context,
                void Function(void Function()) setState) {
              return Container(
                constraints: BoxConstraints(maxHeight: 900.h),
                width: 200.w,
                height: 530,
                child: state.tagMulti.isNotEmpty
                    ? ListView.builder(
                        controller: scrollController,
                        // physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: state.tagMulti.length + 1,
                        itemBuilder: (BuildContext context, int index) {
                          if (index < state.tagMulti.length) {
                            final isSelected = tagsSelectedIdS
                                .contains(state.tagMulti[index].id!);
                            // final isSelected = widget.userId?.contains(state.user[index].id);

                            return InkWell(
                              splashColor: Colors.transparent,
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    tagDisSelected = true;
                                    tagsSelectedIdS
                                        .remove(state.tagMulti[index].id!);
                                    tagsSelectedname
                                        .remove(state.tagMulti[index].title!);
                                    tagSelected = false;

                                    // If no tags are selected anymore, update filter count
                                    if (tagsSelectedIdS.isEmpty) {
                                      context.read<FilterCountBloc>().add(
                                            ProjectUpdateFilterCount(
                                              filterType: 'tags',
                                              isSelected: false,
                                            ),
                                          );
                                    }
                                  } else {
                                    tagDisSelected = false;
                                    if (!tagsSelectedIdS
                                        .contains(state.tagMulti[index].id!)) {
                                      tagsSelectedIdS
                                          .add(state.tagMulti[index].id!);
                                      tagsSelectedname
                                          .add(state.tagMulti[index].title!);

                                      // Update filter count when first tag is selected
                                      if (tagsSelectedIdS.length == 1) {
                                        context.read<FilterCountBloc>().add(
                                              ProjectUpdateFilterCount(
                                                filterType: 'tags',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId =
                                        state.tagMulti[index].id!;
                                    filterSelectedName = "tags";
                                  }

                                  _onFilterSelected('tags');
                                });

                                BlocProvider.of<TagMultiBloc>(context).add(
                                    SelectedTagMulti(
                                        index, state.tagMulti[index].title!));

                                BlocProvider.of<TagMultiBloc>(context).add(
                                    ToggleTagMultiSelection(
                                        state.tagMulti[index].id!,
                                        state.tagMulti[index].title!));
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
                                              text:
                                                  state.tagMulti[index].title!,
                                              fontWeight: FontWeight.w500,
                                              size: 18.sp,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
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

  Widget projectList(stateProject, index, project, date, isLightTheme) {
    return Padding(
        padding: isFirstTimeUSer == true && index == 0
            ? EdgeInsets.zero
            : EdgeInsets.only(bottom: 10.h),
        child: DismissibleCard(
          direction: context.read<PermissionsBloc>().isdeleteProject == true &&
                  context.read<PermissionsBloc>().iseditProject == true
              ? DismissDirection.horizontal // Allow both directions
              : context.read<PermissionsBloc>().isdeleteProject == true
                  ? DismissDirection.endToStart // Allow delete
                  : context.read<PermissionsBloc>().iseditProject == true
                      ? DismissDirection.startToEnd // Allow edit
                      : DismissDirection.none,
          title: stateProject[index].id.toString(),
          confirmDismiss: (DismissDirection direction) async {
            if (direction == DismissDirection.startToEnd) {
              if (context.read<PermissionsBloc>().iseditProject == true) {
                // Navigate to the edit page
                List<String>? userList = [];
                List<String>? clientList = [];
                List<String>? tagList = [];

                if (project.users != null) {
                  for (var user in project.users!) {
                    userList.add(user.firstName!);
                  }
                }

                if (project.clients != null) {
                  for (var client in project.clients!) {
                    clientList.add(client.firstName!);
                  }
                }

                if (project.tags != null) {
                  for (var tag in project.tags!) {
                    tagList.add(tag.title!);
                  }
                }

                router.push(
                  '/createproject',
                  extra: {
                    "id": project.id,
                    "isCreate": false,
                    "title": project.title,
                    "desc": project.description,
                    "start": project.startDate ?? "",
                    "end": project.endDate ?? "",
                    "budget": project.budget,
                    'priority': project.priority,
                    'priorityId': project.priorityId,
                    'statusId': project.statusId,
                    'note': project.note,
                    "clientNames": clientList,
                    "userNames": userList,
                    "tagNames": tagList,
                    "userId": project.userId,
                    "tagId": project.tagIds,
                    "canClientDiscuss": project.clientCanDiscuss,
                    "clientId": project.clientId,
                    "access": project.taskAccessibility,
                    'status': project.status,
                  },
                );

                // Prevent the widget from being dismissed
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
                        title:
                            Text(AppLocalizations.of(context)!.confirmDelete),
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
                context.read<PermissionsBloc>().isdeleteProject == true) {
              setState(() {
                stateProject.removeAt(index);
                _onDeleteProject(id: stateProject[index].id);
              });
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditProject == true) {}
          },
          dismissWidget: Padding(
            padding: EdgeInsets.only(top: 18.h),
            child: InkWell(
              onTap: () {
                router.push('/projectdetails',
                    extra: {"id": stateProject[index].id, "from": "dashboard"});
              },
              child: Container(
                // height: 250.h,
                decoration: BoxDecoration(
                    boxShadow: [
                      isLightTheme
                          ? MyThemes.lightThemeShadow
                          : MyThemes.darkThemeShadow,
                    ],
                    color: Theme.of(context).colorScheme.containerDark,
                    borderRadius: BorderRadius.circular(12)),
                width: double.infinity,
                // color: Colors.yellow,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CustomText(
                            text: "#${project.id.toString()}",
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
                                    project.pinned =
                                        project.pinned == 1 ? 0 : 1;
                                    ProjectRepo().updateProjectPinned(
                                      id: stateProject[index].id,
                                      isPinned: project.pinned,
                                    );
                                  });
                                  _pinnedcController.reverse().then(
                                      (value) => _pinnedcController.forward());
                                },
                                child: Container(
                                    width: 40.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          isLightTheme
                                              ? MyThemes.lightThemeShadow
                                              : MyThemes.darkThemeShadow,
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .backGroundColor,
                                        shape: BoxShape.circle),
                                    child: ScaleTransition(
                                      scale: Tween(begin: 0.7, end: 1.0)
                                          .animate(CurvedAnimation(
                                              parent: _pinnedcController,
                                              curve: Curves.easeOut)),
                                      child: Icon(
                                        project.pinned == 1
                                            ? Icons.push_pin
                                            : Icons.push_pin_outlined,
                                        size: 20,
                                        color: project.pinned == 1
                                            ? Colors.blue
                                            : Colors.blue,
                                      ),
                                    )),
                              ),
                              InkWell(
                                onTap: () {
                                  setState(() {
                                    project.favorite =
                                        project.favorite == 1 ? 0 : 1;
                                    ProjectRepo().updateProjectFavorite(
                                      id: stateProject[index].id,
                                      isFavorite: project.favorite,
                                    );
                                  });
                                  _controller
                                      .reverse()
                                      .then((value) => _controller.forward());
                                },
                                child: Container(
                                    width: 40.w,
                                    height: 30.h,
                                    decoration: BoxDecoration(
                                        boxShadow: [
                                          isLightTheme
                                              ? MyThemes.lightThemeShadow
                                              : MyThemes.darkThemeShadow,
                                        ],
                                        color: Theme.of(context)
                                            .colorScheme
                                            .backGroundColor,
                                        shape: BoxShape.circle),
                                    child: ScaleTransition(
                                      scale: Tween(begin: 0.7, end: 1.0)
                                          .animate(CurvedAnimation(
                                              parent: _controller,
                                              curve: Curves.easeOut)),
                                      child: Icon(
                                        project.favorite == 1
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        size: 20,
                                        color: project.favorite == 1
                                            ? Colors.red
                                            : Colors.red,
                                      ),
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              HeroIcon(
                                HeroIcons.clipboardDocumentList,
                                style: HeroIconStyle.outline,
                                color: AppColors.primary,
                              ),
                              project.taskCount != null && project.taskCount > 1
                                  ? CustomText(
                                      text:
                                          " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.tasksFromDrawer}",
                                      size: 14.sp,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textClrChange,
                                      fontWeight: FontWeight.w700,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    )
                                  : project.taskCount == 1
                                      ? CustomText(
                                          text:
                                              " ${project.taskCount} ${AppLocalizations.of(context)!.task}",
                                          size: 14.sp,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textClrChange,
                                          fontWeight: FontWeight.w700,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        )
                                      : CustomText(
                                          text:
                                              " 0 ${AppLocalizations.of(context)!.task}",
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
                          project.budget != null && project.budget!.isNotEmpty
                              ? Row(
                                  children: [
                                    // CircleAvatar(
                                    //   backgroundColor: Colors.transparent,
                                    //   radius: 10.0,
                                    //   child: Image.asset(
                                    //     AppImages.budgetImage,
                                    //     height: 50,
                                    //   ),
                                    // ),
                                    Container(
                                      alignment: Alignment.centerRight,
                                      // color: Colors.teal,
                                      // width: 100.w,
                                      height: 40.h,
                                      child: CustomText(
                                        text:
                                            " ${currency != null ? "$currency" : ""}${project.budget}",
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        fontWeight: FontWeight.w700,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink(),
                        ],
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 0.h),
                        child: SizedBox(
                          width: 300.w,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                // color: Colors.teal,
                                width: 200.w,
                                height: 40.h,
                                child: CustomText(
                                  text: project.title!,
                                  size: 24,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w700,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      project.description == null || project.description == ""
                          ? const SizedBox.shrink()
                          : SizedBox(
                              height: 5.h,
                            ),
                      project.description == null || project.description == ""
                          ? SizedBox()
                          : htmlWidget(project.description!, context,
                              height: 38.h),
                      SizedBox(height: 5.h),
                      SizedBox(
                        // color: Colors.red,
                        width: 300.w,
                        child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 0.h),
                            child: statusClientRow(project.status,
                                project.priority, context, false)),
                      ),
                      Padding(
                          padding: EdgeInsets.only(top: 10.h),
                          child: SizedBox(
                            // color: Colors.tealAccent,
                            height: 60.h,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        userClientDialog(
                                            context: context,
                                            from: "user",
                                            isFrom: "homescreen",
                                            title: AppLocalizations.of(context)!
                                                .allusers,
                                            list: project.users.isEmpty
                                                ? []
                                                : project.users);
                                      },
                                      child: RowDashboard(
                                          list: project.users!, title: "user")),
                                ),
                                project.users!.isEmpty
                                    ? const SizedBox.shrink()
                                    : SizedBox(
                                        width: 40.w,
                                      ),
                                Expanded(
                                  child: InkWell(
                                      onTap: () {
                                        userClientDialog(
                                          context: context,
                                          from: "client",
                                          title: project.clients.isNotEmpty
                                              ? AppLocalizations.of(context)!
                                                  .allclients
                                              : AppLocalizations.of(context)!
                                                  .allclients,
                                          list: project.clients.isEmpty
                                              ? []
                                              : project.clients,
                                        );
                                      },
                                      child: RowDashboard(
                                          list: project.clients!,
                                          title: "client")),
                                )
                              ],
                            ),
                          )),
                      date != null
                          ? Padding(
                              padding: EdgeInsets.only(top: 5.h),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 15.w,
                                        // color: Colors.yellow,
                                        child: const HeroIcon(
                                          HeroIcons.calendar,
                                          style: HeroIconStyle.outline,
                                          // color: colors.blueColor,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5.w,
                                      ),
                                      CustomText(
                                        text: date,
                                        size: 12.26,
                                        fontWeight: FontWeight.w300,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            )
                          : SizedBox.shrink(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget userLists() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            height: 35.h,
            child: TextField(
              cursorColor: AppColors.greyForgetColor,
              cursorWidth: 1,
              controller: _userSearchController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(
                  vertical: (35.h - 20.sp) / 2,
                  horizontal: 10.w,
                ),
                hintText: 'Search...',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors
                        .greyForgetColor, // Set your desired color here
                    width: 1.0, // Set the border width if needed
                  ),
                  borderRadius: BorderRadius.circular(
                      20.0), // Optional: adjust the border radius
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                  borderSide: BorderSide(
                    color: AppColors
                        .purple, // Border color when TextField is focused
                    width: 1.0,
                  ),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchWord = value;
                });
                context.read<UserBloc>().add(SearchUsers(value));
              },
            ),
          ),
        ),
        SizedBox(
          height: 10.h,
        ),
        BlocBuilder<UserBloc, UserState>(builder: (context, state) {
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
                      .add(UserLoadMore(searchWord));
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
                                      context.read<FilterCountBloc>().add(
                                            ProjectUpdateFilterCount(
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
                                        context.read<FilterCountBloc>().add(
                                              ProjectUpdateFilterCount(
                                                filterType: 'users',
                                                isSelected: true,
                                              ),
                                            );
                                      }
                                    }
                                    filterSelectedId = state.user[index].id!;
                                    filterSelectedName = "users";
                                  }

                                  _onFilterSelected('users');
                                });

                                BlocProvider.of<UserBloc>(context).add(
                                    SelectedUser(
                                        index, state.user[index].firstName!));

                                BlocProvider.of<UserBloc>(context).add(
                                    ToggleUserSelection(state.user[index].id!,
                                        state.user[index].firstName!));
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
                                                      // if (isSelected) ...[
                                                      //   SizedBox(
                                                      //       width: 8
                                                      //           .w), // Optional spacing between text and icon
                                                      //   HeroIcon(
                                                      //     HeroIcons.checkCircle,
                                                      //     style: HeroIconStyle.solid,
                                                      //     color: AppColors.purple,
                                                      //   ),
                                                      // ]
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
}
