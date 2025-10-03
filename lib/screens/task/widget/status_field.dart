import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:taskify/config/colors.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../../../bloc/status/status_bloc.dart';
import '../../../bloc/status/status_event.dart';
import '../../../bloc/status/status_state.dart';
import '../../../bloc/theme/theme_bloc.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/toast_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../widgets/custom_cancel_create_button.dart';

class StatusField extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? status;
  final bool? isRequired;
  // final List<StatusModel> status;
  final int? index;
  final Function(String, int) onSelected;
  const StatusField(
      {super.key,
      required this.isCreate,
      this.name,
      required this.status,
      this.isRequired,
      // required this.status,
      required this.index,
      required this.onSelected});

  @override
  State<StatusField> createState() => _StatusFieldState();
}

class _StatusFieldState extends State<StatusField> {
  String? projectsname;
  int? projectsId;
  bool isLoadingMore = false;
  String searchWord = "";
  String? name;
  final TextEditingController _statusSearchController = TextEditingController();
  @override
  void initState() {
    name = widget.name;
    if (!widget.isCreate) {
      projectsId = widget.status;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isCreate) {
      projectsId = widget.status;
    }

    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w,
          ),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.status,
                // text: getTranslated(context, 'myweeklyTask'),
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              widget.isRequired == true
                  ? CustomText(
                      text: " *",
                      // text: getTranslated(context, 'myweeklyTask'),
                      color: AppColors.red,
                      size: 15,
                      fontWeight: FontWeight.w400,
                    )
                  : SizedBox.shrink(),
            ],
          ),
        ),
        SizedBox(
          height: 5.h,
        ),
        BlocBuilder<StatusBloc, StatusState>(
          builder: (context, state) {
            if (state is StatusInitial) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (ctx) {
                              return StatefulBuilder(
                                  builder: (context, state) =>
                                      BlocConsumer<StatusBloc, StatusState>(
                                        listener: (context, state) {
                                          if (state is StatusSuccess) {
                                            isLoadingMore = false;
                                            setState(() {});
                                          }
                                        },
                                        builder: (context, state) {
                                          if (state is StatusSuccess) {
                                            return NotificationListener<
                                                    ScrollNotification>(
                                                onNotification: (scrollInfo) {
                                                  // Check if the user has scrolled to the end and load more notes if needed
                                                  if (!state.isLoadingMore &&
                                                      scrollInfo
                                                              .metrics.pixels ==
                                                          scrollInfo.metrics
                                                              .maxScrollExtent &&
                                                      isLoadingMore == false) {
                                                    isLoadingMore = true;
                                                    setState(() {});
                                                    context
                                                        .read<StatusBloc>()
                                                        .add(StatusLoadMore(
                                                            searchWord));
                                                  }
                                                  isLoadingMore = false;
                                                  return false;
                                                },
                                                child: AlertDialog(
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(10
                                                            .r), // Set the desired radius here
                                                  ),
                                                  backgroundColor: Theme.of(
                                                          context)
                                                      .colorScheme
                                                      .alertBoxBackGroundColor,
                                                  contentPadding:
                                                      EdgeInsets.zero,
                                                  title: Column(
                                                    children: [
                                                      CustomText(
                                                        text: AppLocalizations
                                                                .of(context)!
                                                            .selectstatus,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        size: 12,
                                                        color: Theme.of(
                                                                context)
                                                            .colorScheme
                                                            .whitepurpleChange,
                                                      ),
                                                      const Divider(),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    0.w),
                                                        child: SizedBox(
                                                          // color: Colors.red,
                                                          height: 35.h,
                                                          width:
                                                              double.infinity,
                                                          child: TextField(
                                                            cursorColor: AppColors
                                                                .greyForgetColor,
                                                            cursorWidth: 1,
                                                            controller:
                                                                _statusSearchController,
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  EdgeInsets
                                                                      .symmetric(
                                                                vertical: (35
                                                                            .h -
                                                                        20.sp) /
                                                                    2,
                                                                horizontal:
                                                                    10.w,
                                                              ),
                                                              hintText:
                                                                  AppLocalizations.of(
                                                                          context)!
                                                                      .search,
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: AppColors
                                                                      .greyForgetColor, // Set your desired color here
                                                                  width:
                                                                      1.0, // Set the border width if needed
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0), // Optional: adjust the border radius
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            10.0),
                                                                borderSide:
                                                                    BorderSide(
                                                                  color: AppColors
                                                                      .purple, // Border color when TextField is focused
                                                                  width: 1.0,
                                                                ),
                                                              ),
                                                            ),
                                                            onChanged:
                                                                (value) {
                                                              setState(() {
                                                                searchWord =
                                                                    value;
                                                              });
                                                              context
                                                                  .read<
                                                                      StatusBloc>()
                                                                  .add(SearchStatus(
                                                                      value));
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  content: Container(
                                                    constraints: BoxConstraints(
                                                        maxHeight: 900.h),
                                                    width:
                                                        MediaQuery.of(context)
                                                            .size
                                                            .width,
                                                    child: ListView.builder(
                                                      // physics: const NeverScrollableScrollPhysics(),
                                                      shrinkWrap: true,
                                                      itemCount: state
                                                              .status.length +
                                                          (state.isLoadingMore
                                                              ? 1
                                                              : 0),

                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        if (index <
                                                            state.status
                                                                .length) {
                                                          final isSelected =
                                                              projectsId !=
                                                                      null &&
                                                                  state.status[index]
                                                                          .id ==
                                                                      projectsId;
                                                          return Padding(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        2.h,
                                                                    horizontal:
                                                                        20.w),
                                                            child: InkWell(
                                                              highlightColor: Colors
                                                                  .transparent, // No highlight on tap
                                                              splashColor: Colors
                                                                  .transparent,
                                                              onTap: () {
                                                                print(
                                                                    "Tap detected - Before update: projectsId = $projectsId");
                                                                setState(() {
                                                                  projectsId = state
                                                                      .status[
                                                                          index]
                                                                      .id!;
                                                                });

                                                                print(
                                                                    "Tap detected - After update: projectsId = $projectsId");

                                                                widget.onSelected(
                                                                    state
                                                                        .status[
                                                                            index]
                                                                        .title!,
                                                                    state
                                                                        .status[
                                                                            index]
                                                                        .id!);

                                                                BlocProvider.of<
                                                                            StatusBloc>(
                                                                        context)
                                                                    .add(
                                                                        SelectedStatus(
                                                                  index,
                                                                  state
                                                                      .status[
                                                                          index]
                                                                      .title!,
                                                                ));
                                                              },

                                                              child: Container(
                                                                decoration: BoxDecoration(
                                                                    color: isSelected
                                                                        ? AppColors
                                                                            .purpleShade
                                                                        : Colors
                                                                            .transparent,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10),
                                                                    border: Border.all(
                                                                        color: isSelected
                                                                            ? AppColors.primary
                                                                            : Colors.transparent)),
                                                                width: double
                                                                    .infinity,
                                                                height: 40.h,
                                                                child: Center(
                                                                  child:
                                                                      Container(
                                                                    padding: EdgeInsets.symmetric(
                                                                        horizontal:
                                                                            10.w),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        CustomText(
                                                                          text: state
                                                                              .status[index]
                                                                              .title!,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          size:
                                                                              18,
                                                                          color: isSelected
                                                                              ? AppColors.purple
                                                                              : Theme.of(context).colorScheme.textClrChange,
                                                                        ),
                                                                        isSelected
                                                                            ? const HeroIcon(
                                                                                HeroIcons.checkCircle,
                                                                                style: HeroIconStyle.solid,
                                                                                color: AppColors.purple,
                                                                              )
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
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        0),
                                                            child: Center(
                                                              child: state
                                                                      .isLoadingMore
                                                                  ? const Text(
                                                                      '')
                                                                  : const SpinKitFadingCircle(
                                                                      color: AppColors
                                                                          .primary,
                                                                      size:
                                                                          40.0,
                                                                    ),
                                                            ),
                                                          );
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  actions: <Widget>[
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          top: 20.h),
                                                      child: CreateCancelButtom(
                                                        title: "OK",
                                                        onpressCancel: () {
                                                          _statusSearchController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        onpressCreate: () {
                                                          _statusSearchController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                ));
                                          }
                                          return const Center(
                                              child: Text('Loading...'));
                                        },
                                      ));
                            });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (projectsname?.isEmpty ?? true
                                      ? "Select status"
                                      : projectsname!)
                                  : (projectsname?.isEmpty ?? true
                                      ? widget.name!
                                      : projectsname!),
                              // text:  Projectsname ,
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is StatusLoading) {
            } else if (state is StatusSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) =>
                              BlocConsumer<StatusBloc, StatusState>(
                            listener: (context, state) {
                              if (state is StatusSuccess) {
                                isLoadingMore = false;
                                setState(() {});
                              }
                            },
                            builder: (context, state) {
                              if (state is StatusSuccess) {
                                return NotificationListener<ScrollNotification>(
                                    onNotification: (scrollInfo) {
                                      // Check if the user has scrolled to the end and load more notes if needed
                                      if (!state.isLoadingMore &&
                                          scrollInfo.metrics.pixels ==
                                              scrollInfo
                                                  .metrics.maxScrollExtent &&
                                          isLoadingMore == false) {
                                        isLoadingMore = true;
                                        setState(() {});
                                        context
                                            .read<StatusBloc>()
                                            .add(StatusLoadMore(searchWord));
                                      }
                                      isLoadingMore = false;
                                      return false;
                                    },
                                    child: AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10
                                            .r), // Set the desired radius here
                                      ),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .alertBoxBackGroundColor,
                                      contentPadding: EdgeInsets.zero,
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectstatus,
                                              fontWeight: FontWeight.w800,
                                              size: 20,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .whitepurpleChange,
                                            ),
                                            const Divider(),
                                            Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 0.w),
                                              child: SizedBox(
                                                // color: Colors.red,
                                                height: 35.h,
                                                width: double.infinity,
                                                child: TextField(
                                                  cursorColor:
                                                      AppColors.greyForgetColor,
                                                  cursorWidth: 1,
                                                  controller:
                                                      _statusSearchController,
                                                  decoration: InputDecoration(
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                      vertical:
                                                          (35.h - 20.sp) / 2,
                                                      horizontal: 10.w,
                                                    ),
                                                    hintText:
                                                        AppLocalizations.of(
                                                                context)!
                                                            .search,
                                                    enabledBorder:
                                                        OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: AppColors
                                                            .greyForgetColor, // Set your desired color here
                                                        width:
                                                            1.0, // Set the border width if needed
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0), // Optional: adjust the border radius
                                                    ),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
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
                                                    context
                                                        .read<StatusBloc>()
                                                        .add(SearchStatus(
                                                            value));
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      content: Container(
                                        constraints:
                                            BoxConstraints(maxHeight: 900.h),
                                        width:
                                            MediaQuery.of(context).size.width,
                                        child: StatefulBuilder(
                                            builder: (context, setState) {
                                          return ListView.builder(
                                            // physics: const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: state.status.length +
                                                (state.isLoadingMore ? 1 : 0),

                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              print("sdfhvkhjfdn $projectsId");
                                              print(
                                                  "sdfhvkhjfdn ${projectsId != null && state.status[index].id == projectsId}");
                                              if (index < state.status.length) {
                                                final isSelected = projectsId !=
                                                        null &&
                                                    state.status[index].id ==
                                                        projectsId;
                                                return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 2.h,
                                                            horizontal: 20.w),
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        print("Tap detected");
                                                        setState(() {
                                                          if (widget.isCreate ==
                                                              true) {
                                                            projectsname = state
                                                                .status[index]
                                                                .title!;
                                                            projectsId = state
                                                                .status[index]
                                                                .id!;
                                                            print(
                                                                "fdfjhfk $projectsId");
                                                            widget.onSelected(
                                                                state
                                                                    .status[
                                                                        index]
                                                                    .title!,
                                                                state
                                                                    .status[
                                                                        index]
                                                                    .id!);
                                                          } else {
                                                            name = state
                                                                .status[index]
                                                                .title;
                                                            projectsname = state
                                                                .status[index]
                                                                .title!;
                                                            projectsId = state
                                                                .status[index]
                                                                .id!;
                                                            print(
                                                                "fdfjhfkwse  $projectsId");
                                                            widget.onSelected(
                                                                state
                                                                    .status[
                                                                        index]
                                                                    .title!,
                                                                state
                                                                    .status[
                                                                        index]
                                                                    .id!);
                                                          }
                                                        });
                                                        BlocProvider.of<
                                                                    StatusBloc>(
                                                                context)
                                                            .add(SelectedStatus(
                                                                index,
                                                                state
                                                                    .status[
                                                                        index]
                                                                    .title!));
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                            color: isSelected
                                                                ? AppColors
                                                                    .purpleShade
                                                                : Colors
                                                                    .transparent,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                                color: isSelected
                                                                    ? AppColors
                                                                        .primary
                                                                    : Colors
                                                                        .transparent)),
                                                        width: double.infinity,
                                                        height: 40.h,
                                                        child: Center(
                                                          child: Container(
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    horizontal:
                                                                        10.w),
                                                            child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceBetween,
                                                              children: [
                                                                CustomText(
                                                                  text: state
                                                                      .status[
                                                                          index]
                                                                      .title!,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w500,
                                                                  size: 18,
                                                                  color: isSelected
                                                                      ? AppColors
                                                                          .purple
                                                                      : Theme.of(
                                                                              context)
                                                                          .colorScheme
                                                                          .textClrChange,
                                                                ),
                                                                isSelected
                                                                    ? const HeroIcon(
                                                                        HeroIcons
                                                                            .checkCircle,
                                                                        style: HeroIconStyle
                                                                            .solid,
                                                                        color: AppColors
                                                                            .purple,
                                                                      )
                                                                    : const SizedBox
                                                                        .shrink(),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ));
                                              } else {
                                                // Show a loading indicator when more notes are being loaded
                                                return Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(vertical: 0),
                                                  child: Center(
                                                    child: state.isLoadingMore
                                                        ? const Text('')
                                                        : const SpinKitFadingCircle(
                                                            color: AppColors
                                                                .primary,
                                                            size: 40.0,
                                                          ),
                                                  ),
                                                );
                                              }
                                            },
                                          );
                                        }),
                                      ),
                                      actions: <Widget>[
                                        Padding(
                                          padding: EdgeInsets.only(top: 20.h),
                                          child: CreateCancelButtom(
                                            title: "OK",
                                            onpressCancel: () {
                                              _statusSearchController.clear();
                                              Navigator.pop(context);
                                            },
                                            onpressCreate: () {
                                              _statusSearchController.clear();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ));
                              }
                              return const Center(child: Text('Loading...'));
                            },
                          ),
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                        ),
                        // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (projectsname?.isEmpty ?? true
                                      ? "Select status"
                                      : projectsname!)
                                  : (projectsname?.isEmpty ?? true
                                      ? widget.name!
                                      : projectsname!),
                              // text:  Projectsname ,
                              fontWeight: FontWeight.w500,
                              size: 14.sp,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            } else if (state is StatusError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        flutterToastCustom(msg: state.errorMessage);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        height: 40.h,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.greyColor),
                          color: Theme.of(context).colorScheme.containerDark,
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                        ), // decoration: DesignConfiguration.shadow(),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (projectsname?.isEmpty ?? true
                                      ? "Select status"
                                      : projectsname!)
                                  : (projectsname?.isEmpty ?? true
                                      ? widget.name!
                                      : projectsname!),
                              // text:  Projectsname ,
                              fontWeight: FontWeight.w400,
                              size: 12,
                              color: AppColors.greyForgetColor,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              );
            }
            return Container();
          },
        )
      ],
    );
  }
}





class StatusField1 extends StatefulWidget {
  final bool isCreate;
  final String? name;
  final int? status;
  final bool? isRequired;
  final int? index;
  final Function(String, int) onSelected;

  const StatusField1({
    super.key,
    required this.isCreate,
    this.name,
    required this.status,
    this.isRequired,
    required this.index,
    required this.onSelected,
  });

  @override
  State<StatusField1> createState() => _StatusField1State();
}

class _StatusField1State extends State<StatusField1> {
  String? projectsname;
  int? projectsId;
  bool isLoadingMore = false;
  String searchWord = "";
  final TextEditingController _statusSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    projectsname = widget.name;
    if (!widget.isCreate) {
      projectsId = widget.status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;
    bool isLightTheme = currentTheme is LightThemeState;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              CustomText(
                text: AppLocalizations.of(context)!.status,
                color: Theme.of(context).colorScheme.textClrChange,
                size: 16,
                fontWeight: FontWeight.w700,
              ),
              if (widget.isRequired == true)
                CustomText(
                  text: " *",
                  color: AppColors.red,
                  size: 15,
                  fontWeight: FontWeight.w400,
                ),
            ],
          ),
        ),
        SizedBox(height: 5.h),
        BlocBuilder<StatusBloc, StatusState>(
          builder: (context, state) {
            if (state is StatusInitial || state is StatusLoading) {
              return AbsorbPointer(
                absorbing: true,
                child: InkWell(
                  onTap: () {},
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 40.h,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: "Loading...",
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is StatusSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: InkWell(
                  highlightColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => StatefulBuilder(
                        builder: (context, setState) => BlocConsumer<StatusBloc, StatusState>(
                          listener: (context, state) {
                            if (state is StatusSuccess) {
                              isLoadingMore = false;
                              setState(() {});
                            }
                          },
                          builder: (context, state) {
                            if (state is StatusSuccess) {
                              return NotificationListener<ScrollNotification>(
                                onNotification: (scrollInfo) {
                                  if (!state.isLoadingMore &&
                                      scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent &&
                                      isLoadingMore == false) {
                                    isLoadingMore = true;
                                    setState(() {});
                                    context.read<StatusBloc>().add(StatusLoadMore(searchWord));
                                  }
                                  isLoadingMore = false;
                                  return false;
                                },
                                child: AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                  backgroundColor: Theme.of(context).colorScheme.alertBoxBackGroundColor,
                                  contentPadding: EdgeInsets.zero,
                                  title: Center(
                                    child: Column(
                                      children: [
                                        CustomText(
                                          text: AppLocalizations.of(context)!.selectstatus,
                                          fontWeight: FontWeight.w800,
                                          size: 20,
                                          color: Theme.of(context).colorScheme.whitepurpleChange,
                                        ),
                                        const Divider(),
                                        Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 0.w),
                                          child: SizedBox(
                                            height: 35.h,
                                            width: double.infinity,
                                            child: TextField(
                                              cursorColor: AppColors.greyForgetColor,
                                              cursorWidth: 1,
                                              controller: _statusSearchController,
                                              decoration: InputDecoration(
                                                contentPadding: EdgeInsets.symmetric(
                                                  vertical: (35.h - 20.sp) / 2,
                                                  horizontal: 10.w,
                                                ),
                                                hintText: AppLocalizations.of(context)!.search,
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(color: AppColors.greyForgetColor, width: 1.0),
                                                  borderRadius: BorderRadius.circular(10.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  borderSide: BorderSide(color: AppColors.purple, width: 1.0),
                                                ),
                                              ),
                                              onChanged: (value) {
                                                setState(() {
                                                  searchWord = value;
                                                });
                                                context.read<StatusBloc>().add(SearchStatus(value));
                                              },
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  content: SizedBox(
                                    width: MediaQuery.of(context).size.width * 0.8,
                                    child: Container(
                                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
                                      child: ListView.builder(
                                        physics: const AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        itemCount: state.status.length + (state.isLoadingMore ? 1 : 0),
                                        itemBuilder: (BuildContext context, int index) {
                                          if (index < state.status.length) {
                                            final isSelected = projectsId != null && state.status[index].id == projectsId;
                                            return Padding(
                                              padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 20.w),
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    projectsId = state.status[index].id!;
                                                    projectsname = state.status[index].title!;
                                                    widget.onSelected(projectsname!, projectsId!);
                                                  });
                                                  BlocProvider.of<StatusBloc>(context).add(SelectedStatus(index, state.status[index].title!));
                                                  Navigator.pop(context);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color: isSelected ? AppColors.purpleShade : Colors.transparent,
                                                    borderRadius: BorderRadius.circular(10),
                                                    border: Border.all(color: isSelected ? AppColors.primary : Colors.transparent),
                                                  ),
                                                  width: double.infinity,
                                                  height: 40.h,
                                                  child: Center(
                                                    child: Container(
                                                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                                                      child: Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          CustomText(
                                                            text: state.status[index].title!,
                                                            fontWeight: FontWeight.w500,
                                                            size: 18,
                                                            color: isSelected ? AppColors.purple : Theme.of(context).colorScheme.textClrChange,
                                                          ),
                                                          isSelected
                                                              ? const HeroIcon(HeroIcons.checkCircle, style: HeroIconStyle.solid, color: AppColors.purple)
                                                              : const SizedBox.shrink(),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          } else {
                                            return Padding(
                                              padding: const EdgeInsets.symmetric(vertical: 0),
                                              child: Center(
                                                child: state.isLoadingMore
                                                    ? const Text('')
                                                    : const SpinKitFadingCircle(color: AppColors.primary, size: 40.0),
                                              ),
                                            );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: CreateCancelButtom(
                                        title: "OK",
                                        onpressCancel: () {
                                          _statusSearchController.clear();
                                          Navigator.pop(context);
                                        },
                                        onpressCreate: () {
                                          _statusSearchController.clear();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }
                            return const Center(child: Text('Loading...'));
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 40.h,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: widget.isCreate
                              ? (projectsname?.isEmpty ?? true ? "Select status" : projectsname!)
                              : (projectsname?.isEmpty ?? true ? widget.name! : projectsname!),
                          fontWeight: FontWeight.w500,
                          size: 14.sp,
                          color: Theme.of(context).colorScheme.textClrChange,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              );
            } else if (state is StatusError) {
              return AbsorbPointer(
                absorbing: false,
                child: InkWell(
                  onTap: () {
                    flutterToastCustom(msg: state.errorMessage);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    height: 40.h,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.greyColor),
                      color: Theme.of(context).colorScheme.containerDark,
                      boxShadow: [
                        isLightTheme ? MyThemes.lightThemeShadow : MyThemes.darkThemeShadow,
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          text: widget.isCreate
                              ? (projectsname?.isEmpty ?? true ? "Select status" : projectsname!)
                              : (projectsname?.isEmpty ?? true ? widget.name! : projectsname!),
                          fontWeight: FontWeight.w400,
                          size: 12,
                          color: AppColors.greyForgetColor,
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
                ),
              );
            }
            return Container();
          },
        ),
      ],
    );
  }
}