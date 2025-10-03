import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/user_id/userid_bloc.dart';
import '../../bloc/user_id/userid_event.dart';
import '../../bloc/user_id/userid_state.dart';
import '../../data/model/create_task_model.dart';
import '../../data/model/task/task_model.dart';

import '../../routes/routes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/permissions/permissions_bloc.dart';

import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/user/user_bloc.dart';
import '../../bloc/user/user_event.dart';
import '../../bloc/user/user_state.dart';
import '../../config/constants.dart';
import '../../data/model/user_model.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
// import '../../utils/widgets/no_internet_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../../utils/widgets/row_dashboard.dart';
import '../../utils/widgets/status_priority_row.dart';
import '../../utils/widgets/toast_widget.dart';
import '../notes/widgets/notes_shimmer_widget.dart';
import '../widgets/custom_container.dart';
import '../widgets/detail_container.dart';
import '../widgets/detail_page_menu.dart';
import '../widgets/html_widget.dart';
import '../widgets/no_data.dart';
import '../widgets/no_permission_screen.dart';
import '../widgets/side_bar.dart';
import '../widgets/user_client_box.dart';

class UserDetailsScreen extends StatefulWidget {
  final int? id;
  final String? isUser;
  final String? from;
  const UserDetailsScreen({super.key, this.id, this.isUser, this.from});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen>
    with TickerProviderStateMixin {
  String? uploadPicture;
  int? id;
  String? firstName;
  String? lastName;
  String? role;
  int? roleId;
  String? email;
  String? phone;
  String? countryCode;
  String? password;
  String? passwordConfirmation;
  String? type;
  String? dob;
  String? doj;
  String? address;
  String? city;
  String? stateOfCountry;
  String? country;
  String? zip;
  String? profile;
  int? status;
  String? createdAt;
  String? updatedAt;
  Assigned? assigned;
  int? requireEv;
  User? userModel;
  String currency = "";
  bool isLoadingMoreTask = false;
  String dateUpdated = "-";
  String dateCreated = "-";
  String dojFormated = "-";
  String dobFormated = "-";
  String statusOfUser = "Inactive";
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  final _key = GlobalKey<ExpandableFabState>();
  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  late TabController _tabController;
  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
    _tabController.dispose();
  }

  Future<void> _onRefresh() async {
    // BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask(id: widget.id));
    BlocProvider.of<UseridBloc>(context).add(UserIdListId(widget.id));
  }

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
    _tabController = TabController(length: 2, vsync: this);

    // Listen for tab changes
    _tabController.addListener(() {
      setState(() {});
    });
    currency = context.read<SettingsBloc>().currencySymbol!;
    BlocProvider.of<TaskBloc>(context)
        .add(AllTaskListOnTask(userId: [widget.id!]));
    BlocProvider.of<ProjectBloc>(context)
        .add(ProjectDashBoardList(userId: [widget.id!]));
    // BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<UseridBloc>(context).add(UserIdListId(widget.id));
  }

  void _onDeleteUser(taskId) {
    final user = context.read<UserBloc>();
    BlocProvider.of<UserBloc>(context).add(DeleteUsers(taskId));
    user.stream.listen((state) {
      if (state is UserDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/user');
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is UserDeleteError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/user');
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is UserError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/user');
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : PopScope(
            canPop: false,
            onPopInvokedWithResult: (bool didPop, Object? result) async {
              if (!didPop) {
                if (widget.from == "homescreen") {
                  BlocProvider.of<UserBloc>(context).add(UserList());
                  BlocProvider.of<ProjectBloc>(context)
                      .add(ProjectDashBoardList());
                  router.pop();
                } else {
                  router.pop();
                }
              }
            },
            child: Scaffold(
              backgroundColor: Theme.of(context).colorScheme.backGroundColor,
              floatingActionButtonLocation: ExpandableFab.location,
              floatingActionButton:
                  context.read<PermissionsBloc>().isdeleteUser == true ||
                          context.read<PermissionsBloc>().iseditUser == true
                      ? detailMenu(
                   //   isDiscuss:false,
                         isEdit:  context.read<PermissionsBloc>().iseditUser,
                         isDelete: context.read<PermissionsBloc>().isdeleteUser,
                        key:   _key,
                         context:  context,
                          onpressEdit: () {
                          _key.currentState?.toggle();
                          router.push(
                            '/createuser',
                            extra: {
                              'isCreate': false,
                              "fromDetail": true,
                              // "index": index,
                              "users": [],
                              "userModel": userModel
                            },
                          );

                          // Navigator.pop(context);
                        },
                        onpressDelete:   () {
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
                                      _onDeleteUser(widget.id);
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
                    child: NestedScrollView(

                      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
                      SliverToBoxAdapter(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 18.w, right: 18.w, top: 0.h),
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
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                        onTap: () {
                                          if (widget.from == "homescreen") {
                                            BlocProvider.of<UserBloc>(context)
                                                .add(UserList());
                                            router.pop();
                                          } else {
                                            router.pop();
                                          }
                                        },
                                        child: BackArrow(
                                          title: AppLocalizations.of(context)!
                                              .userdetails,
                                        ),
                                      )),
                                  SizedBox(height: 20.h),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                        SliverToBoxAdapter(
                          child: BlocConsumer<UseridBloc, UseridState>(
                              listener: (context, state) {
                                if (state is UseridWithId) {
                                  for (var user in state.user) {
                                    if (user.id == widget.id) {
                                      User selectedUser = state.user.firstWhere(
                                              (user) => user.id == widget.id);
                                      id = selectedUser.id;
                                      statusOfUser = selectedUser.status == 1
                                          ? "Active"
                                          : "Inactive";

                                      userModel = User(
                                        id: selectedUser.id,
                                        profile: selectedUser.profile,
                                        firstName: selectedUser.firstName,
                                        lastName: selectedUser.lastName,
                                        role: selectedUser.role,
                                        roleId: selectedUser.roleId,
                                        email: selectedUser.email,
                                        phone: selectedUser.phone,
                                        countryCode: selectedUser.countryCode,
                                        type: selectedUser.type,
                                        dob: selectedUser.dob,
                                        doj: selectedUser.doj,
                                        address: selectedUser.address,
                                        city: selectedUser.city,
                                        state: selectedUser.state,
                                        country: selectedUser.country,
                                        zip: selectedUser.zip,
                                        status: selectedUser.status,
                                        createdAt: selectedUser.createdAt,
                                        updatedAt: selectedUser.updatedAt,
                                        assigned: selectedUser.assigned,
                                        requireEv: selectedUser.requireEv,
                                      );

                                      // Assign values to individual variables
                                      uploadPicture = selectedUser.profile;
                                      firstName = selectedUser.firstName;
                                      lastName = selectedUser.lastName;
                                      role = selectedUser.role;
                                      roleId = selectedUser.roleId;
                                      email = selectedUser.email;
                                      phone = selectedUser.phone;
                                      countryCode = selectedUser.countryCode;
                                      type = selectedUser.type;
                                      dob = selectedUser.dob;
                                      doj = selectedUser.doj;
                                      address = selectedUser.address;
                                      city = selectedUser.city;
                                      stateOfCountry = selectedUser.state;
                                      country = selectedUser.country;
                                      zip = selectedUser.zip;
                                      status = selectedUser.status;
                                      createdAt = selectedUser.createdAt;
                                      updatedAt = selectedUser.updatedAt;
                                      assigned = selectedUser.assigned;
                                      requireEv = selectedUser.requireEv;
                                      profile = selectedUser.profile;



                                      if (dob != null) {
                                        dobFormated =
                                            formatDateFromApi(dob!, context);
                                      }
                                      if (doj != null) {
                                        dojFormated =
                                            formatDateFromApi(doj!, context);
                                      }
                                      dateUpdated =
                                          formatDateFromApi(updatedAt!, context);
                                      dateCreated =
                                          formatDateFromApi(createdAt!, context);
                                    }
                                  }
                                }
                              }, builder: (context, state) {
                            if (state is UseridInitial) {
                              return Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 18.w),
                                child: Column(
                                  children: [
                                    shimmerAvatarDetails(
                                      isLightTheme,
                                      context,
                                    ),
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
                            if (state is UserIdError) {
                              return SizedBox(
                                child: CustomText(
                                  text: state.errorMessage,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  size: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              );
                            }
                            else if (state is UseridLoading) {
                              return Padding(
                                padding:
                                EdgeInsets.symmetric(horizontal: 18.w),
                                child: Column(
                                  children: [
                                    shimmerAvatarDetails(
                                      isLightTheme,
                                      context,
                                    ),
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
                            else if (state is UseridWithId) {
                              for (var user in state.user) {

                                if (user.id == widget.id) {
                                  User selectedUser = state.user.firstWhere(
                                          (user) => user.id == widget.id);
                                  id = selectedUser.id;
                                  statusOfUser = selectedUser.status == 1
                                      ? "Active"
                                      : "Inactive";
                                  if (user.status == 1) {
                                    statusOfUser = "Active";
                                  } else {
                                    statusOfUser = "Inactive";
                                  }

                                  userModel = User(
                                    id: selectedUser.id,
                                    profile: selectedUser.profile,
                                    firstName: selectedUser.firstName,
                                    lastName: selectedUser.lastName,
                                    role: selectedUser.role,
                                    roleId: selectedUser.roleId,
                                    email: selectedUser.email,
                                    phone: selectedUser.phone,
                                    countryCode: selectedUser.countryCode,
                                    type: selectedUser.type,
                                    dob: selectedUser.dob,
                                    doj: selectedUser.doj,
                                    address: selectedUser.address,
                                    city: selectedUser.city,
                                    state: selectedUser.state,
                                    country: selectedUser.country,
                                    zip: selectedUser.zip,
                                    status: selectedUser.status,
                                    createdAt: selectedUser.createdAt,
                                    updatedAt: selectedUser.updatedAt,
                                    assigned: selectedUser.assigned,
                                    requireEv: selectedUser.requireEv,
                                  );

                                  // Assign values to individual variables
                                  uploadPicture = selectedUser.profile;
                                  firstName = selectedUser.firstName;
                                  lastName = selectedUser.lastName;
                                  role = selectedUser.role;
                                  roleId = selectedUser.roleId;
                                  email = selectedUser.email;
                                  phone = selectedUser.phone;
                                  countryCode = selectedUser.countryCode;
                                  type = selectedUser.type;
                                  dob = selectedUser.dob;
                                  doj = selectedUser.doj;
                                  address = selectedUser.address;
                                  city = selectedUser.city;
                                  stateOfCountry = selectedUser.state;
                                  country = selectedUser.country;
                                  zip = selectedUser.zip;
                                  status = selectedUser.status;
                                  createdAt = selectedUser.createdAt;
                                  updatedAt = selectedUser.updatedAt;
                                  assigned = selectedUser.assigned;
                                  requireEv = selectedUser.requireEv;
                                  profile = selectedUser.profile;


                                  if (dob != null) {
                                    dobFormated =
                                        formatDateFromApi(dob!, context);
                                  }
                                  if (doj != null) {
                                    dojFormated =
                                        formatDateFromApi(doj!, context);
                                  }
                                  dateUpdated =
                                      formatDateFromApi(updatedAt!, context);
                                  dateCreated =
                                      formatDateFromApi(createdAt!, context);

                                  return Column(
                                    children: [

                                      Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.center,
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [_profile(profile)],
                                      ),
                                      SizedBox(
                                        height: 20.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                                        child: _personalInfo(
                                            firstName,
                                            lastName,
                                            email,
                                            countryCode,
                                            phone,
                                            dobFormated,
                                            dojFormated),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: _addressInfo(),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: _dateCard(
                                            dateCreated, dateUpdated),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: customContainer(
                                          context: context,
                                          addWidget: singleDetails(
                                              context: context,
                                              label: AppLocalizations.of(
                                                  context)!
                                                  .role,
                                              title: role ?? "not defined"),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: customContainer(
                                            context: context,
                                            addWidget: singleDetails(
                                              context: context,
                                              label: AppLocalizations.of(
                                                  context)!
                                                  .company,
                                              title: assigned != null
                                                  ? "-"
                                                  : "-",
                                            )),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: customContainer(
                                          context: context,
                                          addWidget: singleDetails(
                                              context: context,
                                              label: AppLocalizations.of(
                                                  context)!
                                                  .status,
                                              title: statusOfUser,
                                              button: true,
                                              color: status == 1
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 18.w),
                                        child: customContainer(
                                          context: context,
                                          addWidget: singleDetails(
                                              isTickIcon: true,
                                              button: false,
                                              context: context,
                                              label: AppLocalizations.of(
                                                  context)!
                                                  .verifiedemail,
                                              title: requireEv == 1
                                                  ? "Email Verified"
                                                  : "Not Verified",
                                              color: requireEv == 1
                                                  ? Colors.green
                                                  : Colors.red),
                                        ),
                                      ),
                                      // SizedBox(
                                      //   height: 20.h,
                                      // ),
                                      // SizedBox(height: 30.h),
                                    ],
                                  );

                                }
                              }
                              return SizedBox();
                            }
                            return SizedBox.shrink();
                          }),
                        ),
                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _AppBarDelegate(
                            SizedBox.shrink(), // Or use Container() if needed
                            minHeight: 40.h,   // Ensure it matches the desired height
                            maxHeight: 40.h,   // Keep both values the same to prevent stretching
                          ),
                        ),

                        SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverAppBarDelegate(
                            TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              padding: EdgeInsets.zero,
                              labelPadding: EdgeInsets.zero,
                              labelColor: Colors.white, // Selected tab text color
                              unselectedLabelColor: AppColors.primary, // Unselected tab text color
                              indicator: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                              tabs: [
                                Tab(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.tasks,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Tab(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    width: double.infinity,
                                    child: Center(
                                      child: Text(
                                        AppLocalizations.of(context)!.projectwithCounce,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.sp,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                      body: TabBarView(
                        controller:
                        _tabController,
                        children: [
                          tasks(
                              isLightTheme),
                          projects(
                              isLightTheme)
                        ],
                      ),
                    ),
                  )),
            ));
  }

  Widget tasks(
    isLightTheme,
  ) {
    return (context.read<PermissionsBloc>().isManageTask == true)
        ? BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskPaginated) {
                // isLoadingMoreTask = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is TaskLoading) {
                return const NotesShimmer(
                  isNoti: true,
                );
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
                            userId: [widget.id!],
                          ));
                    }
                    return false;
                  },
                  child: state.task.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
                                date =
                                    dateFormatConfirmed(dateCreated, context);
                              }
                              return Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18.w),
                                child: _listOfProject(task, isLightTheme, date,
                                    state.task, index),
                              );
                            } else {
                              // Show a loading indicator when more notes are being loaded
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
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
          )
        : NoPermission();
  }

  Widget _listOfProject(task, isLightTheme, date, statetask, index) {
    return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
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
            if (direction == DismissDirection.endToStart) {
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
            } else if (direction == DismissDirection.startToEnd) {
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
              child: SingleChildScrollView(
                child: Column(
                  children: [

                    Padding(
                      padding:
                          EdgeInsets.only(top: 20.h, left: 20.h, right: 20.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                text: "#${task.id.toString()}",
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w700,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(
                                width: 280.w,
                                child: CustomText(
                                  text: task.title!,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  size: 24.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              task.description != null
                                  ? SizedBox(
                                      height: 8.h,
                                    )
                                  : SizedBox.shrink(),
                              task.description != null
                                  ? htmlWidget(task.description!, context,
                                  height: 38.h):SizedBox(),

                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      // color: Colors.red,
                      width: 300.w,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.h),
                          child: statusClientRow(
                              task.status, task.priority, context, false)),
                    ),
                    task.users!.isEmpty && task.clients!.isEmpty
                        ? SizedBox.shrink()
                        : Padding(
                            padding: EdgeInsets.only(
                                top: 10.h, left: 18.w, right: 18.w),
                            child: SizedBox(
                              height: 60.h,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: InkWell(
                                        onTap: () {
                                          userClientDialog(
                                            from: "user",
                                            context: context,
                                            title: AppLocalizations.of(context)!
                                                .allusers,
                                            list: task.users!.isEmpty
                                                ? []
                                                : task.users,
                                          );
                                        },
                                        child: RowDashboard(
                                            list: task.users!, title: "user")),
                                  ),
                                  task.users!.isEmpty
                                      ? const SizedBox.shrink()
                                      : SizedBox(
                                          width: 40.w,
                                        ),
                                  task.clients!.isEmpty
                                      ? const SizedBox.shrink()
                                      : Expanded(
                                          child: InkWell(
                                              onTap: () {
                                                userClientDialog(
                                                  from: 'client',
                                                  context: context,
                                                  title: AppLocalizations.of(
                                                          context)!
                                                      .allclients,
                                                  list: task.clients.isEmpty
                                                      ? []
                                                      : task.clients,
                                                );
                                              },
                                              child: RowDashboard(
                                                  list: task.clients!,
                                                  title: "client")),
                                        )
                                ],
                              ),
                            )),
                    Divider(
                        color: Theme.of(context).colorScheme.dividerClrChange),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: 10.h, left: 20.h, right: 20.h),
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
                              SizedBox(
                                width: 20.w,
                              ),
                              CustomText(
                                text: date ?? "",
                                color: AppColors.greyColor,
                                size: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ],
                          ),

                          // child: Row(
                          //   // mainAxisAlignment: MainAxisAlignment.end,
                          //   children: [
                          //     SizedBox(
                          //         width: 100.w,
                          //         // color: Colors.red,
                          //         child: RowUserClientList(
                          //           list: task.users!,
                          //           title: "user",
                          //           isusertitle: false,
                          //           fromNotification: true,
                          //         )),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          onDismissed: (DismissDirection direction) async {
            if (direction == DismissDirection.endToStart &&
                context.read<PermissionsBloc>().isdeleteTask == true) {
              // Perform delete action
              setState(() {
                statetask.removeAt(index);

                onDeleteTask(task.users![index].id);
              });
            } else if (direction == DismissDirection.startToEnd &&
                context.read<PermissionsBloc>().iseditTask == true) {
              // Perform edit action

            }
          },
        ));
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
          BlocProvider.of<TaskBloc>(context).add(AllTaskList());
        }
      }
      if (state is TaskDeleteError) {
        flutterToastCustom(msg: state.errorMessage);
      }
    });
  }

  Widget projects(isLightTheme) {
    return context.read<PermissionsBloc>().isManageProject == true
        ? BlocConsumer<ProjectBloc, ProjectState>(
            listener: (context, state) {
              if (state is ProjectPaginated) {
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const NotesShimmer(paddingNeeded: false);
              } else if (state is ProjectPaginated) {
                // Show notes list with pagination
                return NotificationListener<ScrollNotification>(
                  onNotification: (scrollInfo) {
                    if (scrollInfo is ScrollStartNotification) {
                      FocusScope.of(context).unfocus(); // Dismiss keyboard
                    }
                    // Check if the user has scrolled to the end and load more notes if needed
                    if (!state.hasReachedMax &&
                        scrollInfo.metrics.pixels ==
                            scrollInfo.metrics.maxScrollExtent) {
                      // isLoadingMore = true;
                      setState(() {});
                      context
                          .read<ProjectBloc>()
                          .add(ProjectLoadMore("", [], [widget.id!]));
                    }
                    return false;
                  },
                  child: context.read<PermissionsBloc>().isManageProject == true
                      ? state.project.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: state.hasReachedMax
                                  ? state.project.length
                                  : state.project.length + 1,
                              itemBuilder: (context, index) {
                                if (index < state.project.length) {
                                  var project = state.project[index];
                                  String? date;

                                  if (project.startDate != null) {
                                    date = formatDateFromApi(
                                        project.startDate!, context);
                                  }
                                  return projectList(state.project, index,
                                      project, date, isLightTheme, currency);
                                  // No
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
                          : NoData(
                              isImage: true,
                            )
                      : NoPermission(),
                );
              } else if (state is ProjectError) {
                // Show error message
                return Center(
                  child: Text(
                    state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                );
              } else if (state is ProjectSuccess) {}
              // Handle other states
              return Container();
            },
          )
        : const NoPermission();
  }

  void _onDeleteProject({required int id}) {
    final setting = context.read<ProjectBloc>();
    BlocProvider.of<ProjectBloc>(context).add(DeleteProject(id));
    setting.stream.listen((state) {
      if (state is ProjectDeleteSuccess) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ProjectDeleteError) {
        if (mounted) {
          BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  Widget projectList(
      stateProject, index, project, date, isLightTheme, currency) {
    return DismissibleCard(
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
            context.read<PermissionsBloc>().isdeleteProject == true) {
          setState(() {
            _onDeleteProject(id: stateProject[index].id);
            stateProject.removeAt(index);
          });
        } else if (direction == DismissDirection.startToEnd &&
            context.read<PermissionsBloc>().iseditProject == true) {
          // Perform edit action

        }
      },
      dismissWidget: Padding(
          padding: EdgeInsets.symmetric(vertical: 18.h),
          child: InkWell(
            onTap: () {
              router.push('/projectdetails', extra: {
                "id": stateProject[index].id,
              });
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
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 10.h),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                            HeroIcon(
                              HeroIcons.clipboardDocumentList,
                              style: HeroIconStyle.outline,
                              color: AppColors.primary,
                            ),
                            project.taskCount > 1
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
                                : CustomText(
                                    text:
                                        " ${project.taskCount.toString()} ${AppLocalizations.of(context)!.task}",
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
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 0.h),
                      child: SizedBox(
                        // width: 300.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 8,
                              child: Container(
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
                            ),
                            project.budget!.isNotEmpty
                                ? Expanded(
                                    flex: 3,
                                    child: Container(
                                      alignment: Alignment.centerRight,
                                      // color: Colors.teal,
                                      width: 100.w,
                                      height: 40.h,
                                      child: CustomText(
                                        text:
                                            "${currency != null ? "$currency" : ""}${project.budget}",
                                        size: 14,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textClrChange,
                                        fontWeight: FontWeight.w700,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  )
                                : SizedBox.shrink(),
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
                        ? Container(
                            height: 0.h,
                          )
                        : htmlWidget(project.description!, context,
                            width: 290.w, height: 36.h),
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
                                )
                              ],
                            ),
                          )
                        : SizedBox.shrink(),
                  ],
                ),
              ),
            ),
          )),
    );
  }

  Widget _profile(profile) {
    return CircleAvatar(
      radius: 45.r,
      backgroundColor: Colors.white,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.greyColor,
            width: 2.w,
          ),
        ),
        child: CircleAvatar(
          radius: 45.r,
          backgroundImage: NetworkImage(profile!),
        ),
      ),
    );
  }

  Widget _personalInfo(firstName, lastName, email, countryCode, phone,
      dobFormated, dojFormated) {
    return customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  HeroIcon(
                    HeroIcons.userCircle,
                    style: HeroIconStyle.outline,
                    color: Theme.of(context).colorScheme.textClrChange,
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  CustomText(
                    text: AppLocalizations.of(context)!.personalinfo,
                    // text: getTranslated(context, 'myweeklyTask'),
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ],
              ),
              SizedBox(
                height: 10.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      label: AppLocalizations.of(context)!.firstname,
                      title: firstName!),
                  SizedBox(
                    width: 30.w,
                  ),
                  _details(
                      label: AppLocalizations.of(context)!.lastname,
                      title: lastName!),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      label: AppLocalizations.of(context)!.dob,
                      title: dobFormated),
                  SizedBox(
                    width: 30.w,
                  ),
                  _details(
                      label: AppLocalizations.of(context)!.doj,
                      title: dojFormated),
                ],
              ),
              SizedBox(
                height: 8.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      label: AppLocalizations.of(context)!.email,
                      title: email!),
                  SizedBox(
                    width: 30.w,
                  ),
                  _details(
                      label: AppLocalizations.of(context)!.phonenumber,
                      title: phone != null ? "$countryCode $phone" : "-"),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _addressInfo() {
    return customContainer(
      context: context,
      addWidget: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                HeroIcon(
                  HeroIcons.mapPin,
                  style: HeroIconStyle.outline,
                  color: Theme.of(context).colorScheme.textClrChange,
                ),
                SizedBox(
                  width: 10.w,
                ),
                CustomText(
                  text: AppLocalizations.of(context)!.addressinfo,
                  // text: getTranslated(context, 'myweeklyTask'),
                  color: Theme.of(context).colorScheme.textClrChange,
                  size: 15,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
            SizedBox(
              height: 10.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _details(
                    label: AppLocalizations.of(context)!.city,
                    title: city ?? "-"),
                SizedBox(
                  width: 30.w,
                ),
                _details(
                    label: AppLocalizations.of(context)!.country,
                    title: country ?? "-"),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _details(
                    label: AppLocalizations.of(context)!.zipcode,
                    title: zip ?? "-"),
                SizedBox(
                  width: 30.w,
                ),
                _details(
                    label: AppLocalizations.of(context)!.state,
                    title: stateOfCountry ?? "-"),
              ],
            ),
            SizedBox(
              height: 8.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,

              // crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _details(
                    iswidth: true,
                    label: AppLocalizations.of(context)!.address,
                    title: address ?? "-"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dateCard(dateCreated, dateUpdated) {
    return customContainer(
        context: context,
        addWidget: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,

                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _details(
                      label: AppLocalizations.of(context)!.createdat,
                      title: dateCreated),
                  SizedBox(
                    width: 30.w,
                  ),
                  _details(
                      label: AppLocalizations.of(context)!.updatedAt,
                      title: dateUpdated),
                ],
              ),
            ],
          ),
        ));
  }

  Widget _details(
      {required String label, required String? title, bool? iswidth}) {
    return SizedBox(
      // color: Colors.red,
      width: iswidth == true ? 290 : 140.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            // text:getTranslated(context, "email"),
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            text: title ?? "-",
            // text:"${widget.client.email}",
            // text: getTranslated(context, 'myweeklyTask'),
            color: Theme.of(context).colorScheme.textClrChange,
            size: 12.sp,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}


class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(

      color: Theme.of(context).scaffoldBackgroundColor,
      child: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            // SizedBox(height: 50,),
            Padding(
              padding:
              EdgeInsets.symmetric(
                  horizontal: 18.w),
              child: Container(
                height: 40.h,
                decoration:
                BoxDecoration(
                  border: Border.all(
                      color: AppColors
                          .primary,
                      width: 2),
                  borderRadius:
                  BorderRadius
                      .circular(
                      15.r),
                ),
                child: _tabBar,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

class _AppBarDelegate extends SliverPersistentHeaderDelegate {
  _AppBarDelegate(this.child, {this.minHeight = kToolbarHeight, this.maxHeight});

  final Widget child;
  final double minHeight;
  final double? maxHeight;

  @override
  double get minExtent => minHeight;
  @override
  double get maxExtent => maxHeight ?? minHeight;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox.expand(  // Ensures child fills the header
      child: Container(
        color: Theme.of(context).colorScheme.backGroundColor,
        child: child,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _AppBarDelegate oldDelegate) {
    return child != oldDelegate.child ||
        minHeight != oldDelegate.minHeight ||
        maxHeight != oldDelegate.maxHeight;
  }
}

