import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:slidable_bar/slidable_bar.dart';
import 'package:taskify/bloc/theme/theme_state.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';

import 'package:taskify/config/constants.dart';
import 'package:taskify/data/model/clients/all_client_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/back_arrow.dart';
import '../../bloc/client_id/clientid_bloc.dart';
import '../../bloc/client_id/clientid_event.dart';
import '../../bloc/client_id/clientid_state.dart';
import '../../bloc/project/project_state.dart';
import '../../bloc/clients/client_bloc.dart';
import '../../bloc/clients/client_event.dart';
import '../../bloc/clients/client_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/project/project_bloc.dart';
import '../../bloc/project/project_event.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/task/task_bloc.dart';
import '../../bloc/task/task_event.dart';
import '../../bloc/task/task_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import '../../data/model/create_task_model.dart';
import '../../data/model/task/task_model.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_dimissible.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
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

class ClientDetailsScreen extends StatefulWidget {
  final int id;
  final String? isClient;

  const ClientDetailsScreen({super.key, required this.id, this.isClient});

  @override
  State<ClientDetailsScreen> createState() => _ClientDetailsScreenState();
}

class _ClientDetailsScreenState extends State<ClientDetailsScreen>
    with TickerProviderStateMixin {
  String initialCountry = defaultCountry;
  PhoneNumber number = PhoneNumber(isoCode: defaultCountry);

  DateTime selectedDateStarts = DateTime.now();
  DateTime selectedDateEnds = DateTime.now();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  String selectedCategory = '';
  String? firstName;
  String? uploadPicture;
  String? lastName;
  String? role;
  String? company;
  String? email;
  String? phone;
  String? countryCode;
  String? countryIsoCode;
  String? password;
  String? passwordConfirmation;
  String? type;
  String? dob;
  String? doj;
  String? address;
  String? city;
  String? stateOfCity;
  String? country;
  String? zip;
  String? profile;
  int? status;
  int? internalPurpose;
  int? emailVerificationMailSent;
  String? emailVerifiedAt;
  String? createdAt;
  String? updatedAt;
  Assigned? assigned;
  AllClientModel? clientModel;
  bool isLoadingMore = false;
  String currency = "";
  String dateUpdated = "";
  String dateCreated = "";
  int? id ;
  String statusOfClient = "Inactive";
  String isNavigated = ""; // Declare a variable to track navigation

  final SlidableBarController sideBarController =
      SlidableBarController(initialStatus: false);
  final _key = GlobalKey<ExpandableFabState>();
  late TabController _tabController;
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
    context.read<SettingsBloc>().add(const SettingsList("general_settings"));
    currency = context.read<SettingsBloc>().currencySymbol!;

    BlocProvider.of<TaskBloc>(context)
        .add(AllTaskListOnTask(clientId: [widget.id]));
    BlocProvider.of<ProjectBloc>(context)
        .add(ProjectDashBoardList(clientId: [widget.id]));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(widget.id));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList(clientId: [widget.id]));
  }

  Future<void> _onRefresh() async {
    BlocProvider.of<TaskBloc>(context)
        .add(AllTaskListOnTask(clientId: [widget.id]));
    BlocProvider.of<ProjectBloc>(context)
        .add(ProjectDashBoardList(clientId: [widget.id]));
    BlocProvider.of<PermissionsBloc>(context).add(GetPermissions());
    BlocProvider.of<ClientidBloc>(context).add(ClientIdListId(
      widget.id,
    ));
    BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
  }

  void _onDeleteClient(clientId) {
    final setting = context.read<ClientBloc>();
    BlocProvider.of<ClientBloc>(context).add(DeleteClients(clientId));
    setting.stream.listen((state) {

      if (state is ClientDeleteSuccess) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(
              msg: AppLocalizations.of(context)!.deletedsuccessfully,
              color: AppColors.primary);
        }
      }
      if (state is ClientError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(
              msg: state.errorMessage,
              color: AppColors.primary);
        }
      }
      if (state is ClientDeleteError) {
        if (mounted) {
          Navigator.of(context).pop();
          router.replace('/client');
          flutterToastCustom(msg: state.errorMessage);
        }
      }
    });
  }

  void _onEditClient(clientModel) {
    _key.currentState?.toggle();
    if (context.read<PermissionsBloc>().iseditClient == true) {
      router.push(
        '/createclient',
        extra: {
          'isCreate': false,
          "clientModel": clientModel,
          "fromDetail": true
        },
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _connectivitySubscription.cancel();
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

                router.pop();
              }
              BlocProvider.of<ProjectBloc>(context).add(ProjectDashBoardList());
              BlocProvider.of<TaskBloc>(context).add(AllTaskListOnTask());
            },
            child: BlocConsumer<ClientidBloc, ClientidState>(
                listener: (BuildContext context, state) {

              if (state is ClientidWithId) {
                for (var client in state.client) {
                  if (client.id == widget.id) {

                    if (client.status == 1) {
                      statusOfClient = "Active";
                    } else {
                      statusOfClient = "Inactive";
                    }
                    if (client.updatedAt != null) {
                      dateUpdated =
                          formatDateFromApi(client.updatedAt!, context);
                    }
                    if (client.createdAt != null) {
                      dateCreated =
                          formatDateFromApi(client.createdAt!, context);
                    }
                  }
                }
              }
            }, builder: (context, state) {

              if (state is ClientInitial) {
                return Scaffold(
                    backgroundColor:
                        Theme.of(context).colorScheme.backGroundColor,
                    body: SingleChildScrollView(
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.w, right: 20.w, top: 0.h),
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
                                            router.pop();

                                            BlocProvider.of<ProjectBloc>(
                                                    context)
                                                .add(ProjectDashBoardList());
                                            BlocProvider.of<TaskBloc>(context)
                                                .add(AllTaskListOnTask());
                                          },
                                          child: BackArrow(
                                            title: AppLocalizations.of(context)!
                                                .clientdetails,
                                          ),
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 30.h),
                          shimmerDetails(isLightTheme, context, 150.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 150.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 50.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 120.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 120.h),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ));
              }
              if (state is ClientIdError) {
                return SizedBox(
                  child: CustomText(
                    text: state.errorMessage,
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 15,
                    fontWeight: FontWeight.w700,
                  ),
                );
              }
              if (state is ClientidLoading) {
                return Scaffold(
                  backgroundColor:
                      Theme.of(context).colorScheme.backGroundColor,
                  body: SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 18.w),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 20.w, right: 20.w, top: 0.h),
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
                                            router.pop();

                                            BlocProvider.of<ProjectBloc>(
                                                    context)
                                                .add(ProjectDashBoardList());
                                            BlocProvider.of<TaskBloc>(context)
                                                .add(AllTaskListOnTask());
                                          },
                                          child: BackArrow(
                                            title: AppLocalizations.of(context)!
                                                .clientdetails,
                                          ),
                                        )),
                                  ],
                                ),
                              )
                            ],
                          ),
                          SizedBox(height: 30.h),
                          shimmerAvatarDetails(
                            isLightTheme,
                            context,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 150.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 150.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 50.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 120.h),
                          const SizedBox(
                            height: 20,
                          ),
                          shimmerDetails(isLightTheme, context, 120.h),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
              else if (state is ClientidWithId) {
                for (var client in state.client) {
                  if (client.id == widget.id) {
                    AllClientModel selectedUser = state.client.firstWhere((client) => client.id == widget.id);
                    id = selectedUser.id;
                    statusOfClient = (client.status == 1) ? "Active" : "Inactive";
                    clientModel = AllClientModel(
                      id: selectedUser.id,
                      profile: selectedUser.profile,
                      firstName: selectedUser.firstName,
                      lastName: selectedUser.lastName,
                      role: selectedUser.role,
                      company: selectedUser.company,
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
                      internalPurpose: selectedUser.internalPurpose,
                      emailVerificationMailSent: selectedUser.emailVerificationMailSent,
                      emailVerifiedAt: selectedUser.emailVerifiedAt
                    );

                    // Assign values to individual variables
                    uploadPicture = selectedUser.profile;
                    firstName = selectedUser.firstName;
                    lastName = selectedUser.lastName;
                    role = selectedUser.role;
                    company = selectedUser.company;
                    email = selectedUser.email;
                    phone = selectedUser.phone;
                    countryCode = selectedUser.countryCode;
                    type = selectedUser.type;
                    dob = selectedUser.dob;
                    doj = selectedUser.doj;
                    address = selectedUser.address;
                    city = selectedUser.city;
                    stateOfCity = selectedUser.state;
                    country = selectedUser.country;
                    zip = selectedUser.zip;
                    status = selectedUser.status;
                    createdAt = selectedUser.createdAt;
                    updatedAt = selectedUser.updatedAt;
                    assigned = selectedUser.assigned;
                    internalPurpose = selectedUser.internalPurpose;
                    emailVerifiedAt = selectedUser.emailVerifiedAt;
                    emailVerificationMailSent = selectedUser.emailVerificationMailSent;
                    profile = selectedUser.profile;
                    if (client.updatedAt != null) {
                      dateUpdated =
                          formatDateFromApi(client.updatedAt!, context);
                    }
                    if (client.createdAt != null) {
                      dateCreated =
                          formatDateFromApi(client.createdAt!, context);
                    }

                    return Scaffold(
                        backgroundColor:
                            Theme.of(context).colorScheme.backGroundColor,
                        floatingActionButtonLocation: ExpandableFab.location,
                        floatingActionButton: context
                                        .read<PermissionsBloc>()
                                        .isdeleteProject ==
                                    true ||
                                context.read<PermissionsBloc>().iseditProject ==
                                    true
                            ? detailMenu(
                         //   isDiscuss:false,
                             isEdit:    context.read<PermissionsBloc>().iseditProject,
                              isDelete : context.read<PermissionsBloc>().isdeleteProject,
                               key:  _key,
                               context:  context,
                                onpressEdit: () {
                                _onEditClient(client);
                                // Navigator.pop(context);
                              }, onpressDelete: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10
                                            .r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      title: Text(
                                        AppLocalizations.of(context)!
                                            .confirmDelete,
                                      ),
                                      content: Text(
                                        AppLocalizations.of(context)!
                                            .areyousure,
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            _onDeleteClient(widget.id);
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .delete),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(false); // Cancel deletion
                                          },
                                          child: Text(
                                              AppLocalizations.of(context)!
                                                  .cancel),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              })
                            : SizedBox.shrink(),
                        body:  SideBar(
                                    context: context,
                                    controller: sideBarController,
                                    underWidget: RefreshIndicator(
                                        color:
                                            AppColors.primary, // Spinner color
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .backGroundColor,
                                        onRefresh: _onRefresh,
                                        child:  NestedScrollView(

                                          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) => [
                                            SliverToBoxAdapter(
                                              child:      Row(
                                                mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 20.w,
                                                        right: 20.w,
                                                        top: 0.h),
                                                    child: Column(
                                                      children: [
                                                        Container(
                                                            decoration:
                                                            BoxDecoration(
                                                                boxShadow: [
                                                                  isLightTheme
                                                                      ? MyThemes
                                                                      .lightThemeShadow
                                                                      : MyThemes
                                                                      .darkThemeShadow,
                                                                ]),
                                                            // color: Colors.red,
                                                            // width: 300.w,
                                                            child: InkWell(
                                                              onTap: () {
                                                                router.pop();

                                                                BlocProvider.of<
                                                                    ProjectBloc>(
                                                                    context)
                                                                    .add(
                                                                    ProjectDashBoardList());
                                                                BlocProvider.of<
                                                                    TaskBloc>(
                                                                    context)
                                                                    .add(
                                                                    AllTaskListOnTask());
                                                              },
                                                              child: BackArrow(
                                                                title: AppLocalizations
                                                                    .of(context)!
                                                                    .clientdetails,
                                                              ),
                                                            )),
                                                      ],
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                            SliverToBoxAdapter(
                                              child:  Column(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .start,
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment
                                                      .start,
                                                  children: [
                                                    SizedBox(height: 20.h,),
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .center,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .center,
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 45.r,
                                                          backgroundColor:
                                                          Colors.white,
                                                          child: Container(
                                                            decoration:
                                                            BoxDecoration(
                                                              shape: BoxShape
                                                                  .circle,
                                                              border: Border
                                                                  .all(
                                                                color: AppColors
                                                                    .greyColor,
                                                                width:
                                                                1.5.w,
                                                              ),
                                                            ),
                                                            child:
                                                            CircleAvatar(
                                                              backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                              radius: 45.r,
                                                              backgroundImage:
                                                              NetworkImage(
                                                                  profile!),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(
                                                      height: 20.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              10.w,
                                                              vertical:
                                                              10.h),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  HeroIcon(
                                                                    HeroIcons
                                                                        .userCircle,
                                                                    style: HeroIconStyle
                                                                        .outline,
                                                                    color: Theme.of(
                                                                        context)
                                                                        .colorScheme
                                                                        .textClrChange,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                    5.w,
                                                                  ),
                                                                  CustomText(
                                                                    text: AppLocalizations.of(
                                                                        context)!
                                                                        .personalinfo,
                                                                    // text: getTranslated(context, 'myweeklyTask'),
                                                                    color: Theme.of(
                                                                        context)
                                                                        .colorScheme
                                                                        .textClrChange,
                                                                    size: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,

                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .firstname,
                                                                      title: firstName ??
                                                                          ""),
                                                                  SizedBox(
                                                                    width:
                                                                    30.w,
                                                                  ),
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .lastname,
                                                                      title: client.lastName ??
                                                                          ""),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,

                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .email,
                                                                      title: client.email ??
                                                                          ""),
                                                                  SizedBox(
                                                                    width:
                                                                    30.w,
                                                                  ),
                                                                  client.countryCode !=
                                                                      null &&
                                                                      client.countryCode !=
                                                                          ""
                                                                      ? _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .phonenumber,
                                                                      title:
                                                                      "${client.countryCode} ${client.phone ?? "-"}")
                                                                      : _details(
                                                                      label:
                                                                      AppLocalizations.of(context)!.phonenumber,
                                                                      title: "-"),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                              horizontal:
                                                              10.w,
                                                              vertical:
                                                              10.h),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                            children: [
                                                              Row(
                                                                children: [
                                                                  HeroIcon(
                                                                    HeroIcons
                                                                        .mapPin,
                                                                    style: HeroIconStyle
                                                                        .outline,
                                                                    color: Theme.of(
                                                                        context)
                                                                        .colorScheme
                                                                        .textClrChange,
                                                                  ),
                                                                  SizedBox(
                                                                    width:
                                                                    5.w,
                                                                  ),
                                                                  CustomText(
                                                                    text: AppLocalizations.of(
                                                                        context)!
                                                                        .addressinfo,
                                                                    // text: getTranslated(context, 'myweeklyTask'),
                                                                    color: Theme.of(
                                                                        context)
                                                                        .colorScheme
                                                                        .textClrChange,
                                                                    size: 15,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                                  ),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 10.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,

                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .city,
                                                                      title: client.city ??
                                                                          "-"),
                                                                  SizedBox(
                                                                    width:
                                                                    30.w,
                                                                  ),
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .country,
                                                                      title: client.country ??
                                                                          "-"),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,

                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .zipcode,
                                                                      title: client.zip ??
                                                                          "-"),
                                                                  SizedBox(
                                                                    width:
                                                                    30.w,
                                                                  ),
                                                                  _details(
                                                                      label: AppLocalizations.of(context)!
                                                                          .state,
                                                                      title: client.state ??
                                                                          "-"),
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: 8.h,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,

                                                                // crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  _details(
                                                                      iswidth:
                                                                      true,
                                                                      label: AppLocalizations.of(context)!
                                                                          .address,
                                                                      title: client.address ??
                                                                          "-"),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                          width: 600.w,
                                                          context: context,
                                                          addWidget: Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                horizontal:
                                                                10.w,
                                                                vertical:
                                                                10.h),
                                                            child: Column(
                                                              children: [
                                                                Row(
                                                                  children: [
                                                                    _details(
                                                                        label: AppLocalizations.of(context)!
                                                                            .createdat,
                                                                        title:
                                                                        dateCreated),
                                                                    SizedBox(
                                                                      width:
                                                                      30.w,
                                                                    ),
                                                                    _details(
                                                                        label: AppLocalizations.of(context)!
                                                                            .updatedAt,
                                                                        title:
                                                                        dateUpdated),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                          )),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: singleDetails(
                                                            context: context,
                                                            label: AppLocalizations
                                                                .of(
                                                                context)!
                                                                .role,
                                                            title:
                                                            client.role ??
                                                                "-"),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: singleDetails(
                                                            context: context,
                                                            label: AppLocalizations
                                                                .of(
                                                                context)!
                                                                .company,
                                                            title: client
                                                                .company ??
                                                                "-"),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: singleDetails(
                                                            context: context,
                                                            label: AppLocalizations
                                                                .of(
                                                                context)!
                                                                .status,
                                                            title:
                                                            statusOfClient,
                                                            button: true,
                                                            color:
                                                            client.emailVerificationMailSent ==
                                                                1
                                                                ? Colors
                                                                .green
                                                                : Colors
                                                                .red),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: singleDetails(
                                                            context: context,
                                                            isTickIcon: true,
                                                            label: AppLocalizations
                                                                .of(
                                                                context)!
                                                                .verifiedemail,
                                                            title: client
                                                                .emailVerificationMailSent ==
                                                                1
                                                                ? "Email Verified"
                                                                : "Not Verified",
                                                            button: false,
                                                            color:
                                                            client.emailVerificationMailSent ==
                                                                1
                                                                ? Colors
                                                                .green
                                                                : Colors
                                                                .red),
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      height: 15.h,
                                                    ),
                                                    Padding(
                                                      padding:  EdgeInsets.symmetric(horizontal:18.w),
                                                      child: customContainer(
                                                        width: 600.w,
                                                        context: context,
                                                        addWidget: singleDetails(
                                                            context: context,
                                                            label: AppLocalizations
                                                                .of(
                                                                context)!
                                                                .status,
                                                            title:
                                                            internalPurpose == 0 ?  AppLocalizations
                                                                        .of(
                                                                        context)!
                                                                        .off:AppLocalizations
                                                                .of(
                                                                context)!
                                                                .on,
                                                            button: true,
                                                            color:
                                                            client.internalPurpose ==
                                                                1
                                                                ? Colors
                                                                .green
                                                                : Colors
                                                                .red),
                                                      ),
                                                    ),


                                                  ])
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
                                          body:   TabBarView(
                                            controller:
                                            _tabController,
                                            children: [
                                              tasks(
                                                  isLightTheme,
                                                  isLoadingMore),
                                              projects(
                                                  isLightTheme),
                                            ],
                                          ),
                                        ),


                                    )));
                  }
                }
              }
                return Scaffold(
                backgroundColor:
                Theme.of(context).colorScheme.backGroundColor,
                body: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18.w),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  left: 20.w, right: 20.w, top: 0.h),
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
                                          router.pop();

                                          BlocProvider.of<ProjectBloc>(
                                              context)
                                              .add(ProjectDashBoardList());
                                          BlocProvider.of<TaskBloc>(context)
                                              .add(AllTaskListOnTask());
                                        },
                                        child: BackArrow(
                                          title: AppLocalizations.of(context)!
                                              .clientdetails,
                                        ),
                                      )),
                                ],
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 30.h),
                        shimmerAvatarDetails(
                          isLightTheme,
                          context,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        shimmerDetails(isLightTheme, context, 150.h),
                        const SizedBox(
                          height: 20,
                        ),
                        shimmerDetails(isLightTheme, context, 150.h),
                        const SizedBox(
                          height: 20,
                        ),
                        shimmerDetails(isLightTheme, context, 50.h),
                        const SizedBox(
                          height: 20,
                        ),
                        shimmerDetails(isLightTheme, context, 120.h),
                        const SizedBox(
                          height: 20,
                        ),
                        shimmerDetails(isLightTheme, context, 120.h),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }));
  }

  Widget tasks(isLightTheme, isLoadingMore) {
    return (context.read<PermissionsBloc>().isManageTask == true)
        ? BlocConsumer<TaskBloc, TaskState>(
            listener: (context, state) {
              if (state is TaskPaginated) {
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
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
                            clientId: [widget.id],
                          ));
                    }
                    return false;
                  },
                  child: state.task.isNotEmpty
                      ? ListView.builder(
                          padding: EdgeInsets.zero,
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
                              return _listOfProject(
                                  task, isLightTheme, date, state.task, index);
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
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal:18.w),
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
                                  color:
                                      Theme.of(context).colorScheme.textClrChange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              task.description != null
                                  ? SizedBox(
                                      height: 8.h,
                                    )
                                  : SizedBox.shrink(),
                              task.description != null
                                  ? ExpandableHtmlWidget(text:task.description!,context: context)

                                  : SizedBox.shrink(),
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
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      padding:
                          EdgeInsets.only(bottom: 10.h, left: 20.h, right: 20.h),
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
                isLoadingMore = false;
                setState(() {});
              }
            },
            builder: (context, state) {
              if (state is ProjectLoading) {
                return const NotesShimmer();
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
                            scrollInfo.metrics.maxScrollExtent &&
                        isLoadingMore == false) {
                      isLoadingMore = true;
                      setState(() {});
                      context
                          .read<ProjectBloc>()
                          .add(ProjectLoadMore("", [widget.id], []));
                    }
                    return false;
                  },
                  child: context.read<PermissionsBloc>().isManageProject == true
                      ? state.project.isNotEmpty
                          ? ListView.builder(
                              padding: EdgeInsets.zero,
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
          // flutterToastCustom(msg: state.errorMessage);
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
          padding: EdgeInsets.symmetric(vertical: 18.h,horizontal: 18.w),
          child: InkWell(
            onTap: () {
              router.push('/projectdetails', extra: {
                "id": stateProject[index].id,
              });
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
              width: double.infinity,
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
                        width: 300.w,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              alignment: Alignment.centerLeft,
                              width: 200.w,
                              height: 40.h,
                              child: CustomText(
                                text: project.title!,
                                size: 24,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                fontWeight: FontWeight.w700,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            project.budget!.isNotEmpty
                                ? Container(
                                    alignment: Alignment.centerRight,
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
                        : htmlWidget(project.description!,context,width:290.w,height: 36.h),
                    SizedBox(
                      width: 300.w,
                      child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 0.h),
                          child: statusClientRow(project.status,
                              project.priority, context, false)),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.h),
                        child: SizedBox(
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
                                  child: const HeroIcon(
                                    HeroIcons.calendar,
                                    style: HeroIconStyle.outline,
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

  Widget _details(
      {required String label, required String title, bool? iswidth}) {
    return SizedBox(
      width: iswidth == true ? 290 : 140.w,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            text: label,
            color: Theme.of(context).colorScheme.textClrChange,
            size: 14.sp,
            fontWeight: FontWeight.w600,
          ),
          CustomText(
            text: title,
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