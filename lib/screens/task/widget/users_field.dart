import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hive/hive.dart';
import 'package:taskify/config/colors.dart';

import '../../../bloc/theme/theme_bloc.dart';
import '../../../bloc/theme/theme_state.dart';
import '../../../bloc/user/user_bloc.dart';
import '../../../bloc/user/user_event.dart';
import '../../../bloc/user/user_state.dart';
import '../../../config/strings.dart';
import '../../../data/model/task/task_model.dart';
import '../../../utils/widgets/custom_text.dart';
import '../../../utils/widgets/my_theme.dart';
import '../../widgets/custom_cancel_create_button.dart';

class UsersField extends StatefulWidget {
  final bool? isRequired;
  final bool isCreate;
  final bool? isMeeting;
  final List<String> usersname;
  final List<int> usersid;
  final List<Tasks> project;
  final Function(List<String>, List<int>) onSelected;

  final bool enabled;
  const UsersField(
      {super.key,
      usersField,
      this.isRequired = false,
      required this.usersid,
      required this.isCreate,
      this.isMeeting,
      required this.usersname,
      required this.project,
this.enabled = true, // Add this line
      required this.onSelected});

  @override
  State<UsersField> createState() => _UsersFieldState();
}

class _UsersFieldState extends State<UsersField> {
  String? projectsname;
  int? projectsId;
  List<int> userSelectedId = [];
  List<String> userSelectedname = [];
  String searchWord = "";
  int? userId;
  final TextEditingController _userSearchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getUserId().then((_) {
      if (widget.isCreate && userId != null) {
        if (widget.isMeeting == true) {
          userSelectedId.add(userId!);
        }
      }else{
        BlocProvider.of<UserBloc>(context).add(UserList());

      }
    });
  }

  Future<void> getUserId() async {
    var userbox = await Hive.openBox(userBox);
    userId = userbox.get('user_id');
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < widget.usersid.length; i++) {
      final id = widget.usersid[i];
      if (!userSelectedId.contains(id)) {
        userSelectedId.add(id);
        if (widget.usersname.isNotEmpty) {
          userSelectedname.add(widget.usersname[i]);
        }
      }
    }
    //
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              Row(
                children: [
                  CustomText(
                    text: AppLocalizations.of(context)!.users,
                    color: Theme.of(context).colorScheme.textClrChange,
                    size: 16.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  widget.isRequired == true
                      ? const CustomText(
                          text: " *",
                          // text: getTranslated(context, 'myweeklyTask'),
                          color: AppColors.red,
                          size: 15,
                          fontWeight: FontWeight.w400,
                        )
                      : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
        // SizedBox(height: 5.h),
        BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            if (state is UserInitial) {
              return AbsorbPointer(
                absorbing: !widget.enabled,
             //   absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {

                              if (state is UserSuccess) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {

                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectuser,
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
                                                      _userSearchController,
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

                                                    context.read<UserBloc>().add(SearchUsers(value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.user.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // if (index <  state.user.length) {

                                            final isSelected =
                                                userSelectedId.contains(
                                                    state.user[index].id!);

                                            return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 2.h),
                                                child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        if (isSelected) {
                                                          userSelectedId.remove(
                                                              state.user[index]
                                                                  .id!);
                                                          userSelectedname
                                                              .remove(state
                                                                  .user[index]
                                                                  .firstName!);
                                                        } else {
                                                          userSelectedId.add(
                                                              state.user[index]
                                                                  .id!);
                                                          userSelectedname.add(
                                                              state.user[index]
                                                                  .firstName!);

                                                        }
                                                        widget.onSelected(
                                                            userSelectedname,
                                                            userSelectedId);
                                                        BlocProvider.of<
                                                                    UserBloc>(
                                                                context)
                                                            .add(SelectedUser(
                                                                index,
                                                                state
                                                                    .user[index]
                                                                    .firstName!));
                                                        BlocProvider.of<
                                                                    UserBloc>(
                                                                context)
                                                            .add(
                                                          ToggleUserSelection(
                                                            index,
                                                            state.user[index]
                                                                .firstName!,
                                                          ),
                                                        );
                                                      });
                                                    },
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                        horizontal: 20.w,
                                                      ),
                                                      child: Container(
                                                        width: double.infinity,
                                                        height: 35.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          // borderRadius: BorderRadius
                                                          //     .circular(15),
                                                        color: widget.enabled ? null : Colors.grey.withOpacity(0.2) 

                                                        
                                                        ),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Expanded(
                                                              flex: 7,
                                                              child: SizedBox(
                                                                width: 200.w,
                                                                child: Row(
                                                                  children: [
                                                                    CircleAvatar(
                                                                      radius:
                                                                          20,
                                                                      backgroundImage: NetworkImage(state
                                                                          .user[
                                                                              index]
                                                                          .profile!),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Padding(
                                                                        padding:
                                                                            EdgeInsets.symmetric(horizontal: 18.w),
                                                                        child:
                                                                            Column(
                                                                          // Changed from Row to Column to stack vertically
                                                                          crossAxisAlignment:
                                                                              CrossAxisAlignment.start, // Align items to the left
                                                                          children: [
                                                                            Row(
                                                                              // First row with names
                                                                              children: [
                                                                                Flexible(
                                                                                  child: CustomText(
                                                                                    text: state.user[index].firstName!,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    size: 18.sp,
                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                  ),
                                                                                ),
                                                                                SizedBox(width: 5.w),
                                                                                Flexible(
                                                                                  child: CustomText(
                                                                                    text: state.user[index].lastName!,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    size: 18.sp,
                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                            // SizedBox(height: 2.h),  // Add some spacing between rows
                                                                            Row(
                                                                              children: [
                                                                                Flexible(
                                                                                  child: CustomText(
                                                                                    text: state.user[index].email!,
                                                                                    fontWeight: FontWeight.w500,
                                                                                    maxLines: 1,
                                                                                    overflow: TextOverflow.ellipsis,
                                                                                    size: 18.sp,
                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                            isSelected
                                                                ? Expanded(
                                                                    flex: 1,
                                                                    child: const HeroIcon(
                                                                        HeroIcons
                                                                            .checkCircle,
                                                                        style: HeroIconStyle
                                                                            .solid,
                                                                        color: AppColors
                                                                            .purple),
                                                                  )
                                                                : const SizedBox
                                                                    .shrink(),
                                                          ],
                                                        ),
                                                      ),
                                                    )));
                                            // }
                                          }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            Navigator.pop(context);
                                            BlocProvider.of<UserBloc>(context).add(UserList());

                                          },
                                          onpressCreate: () {
                                            Navigator.pop(context);
                                            BlocProvider.of<UserBloc>(context).add(UserList());

                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              if (state is UserPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {

                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    // backgroundColor: Theme.of(context)
                                    //     .colorScheme
                                    //     .AlertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .selectusers,
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          )
                                        ],
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                                  child: BlocBuilder<UserBloc, UserState>(
                                                      builder: (context, state) {

                                                    if (state is UserPaginated) {
                                                      ScrollController scrollController =
                                                          ScrollController();
                                                      scrollController.addListener(() {
                                                        // !state.hasReachedMax

                                                        if (scrollController
                                                            .position.atEdge) {

                                                          if (scrollController
                                                                  .position.pixels !=
                                                              0) {
                                                            BlocProvider.of<UserBloc>(
                                                                    context)
                                                                .add(UserLoadMore(
                                                                    searchWord));
                                                          }
                                                        }
                                                      });
                                                      return ListView.builder(
                                                          controller: scrollController,
                                                          shrinkWrap: true,
                                                          itemCount: state.hasReachedMax
                                                              ? state.user.length
                                                              : state.user.length + 1,
                                                          itemBuilder:
                                                              (BuildContext context,
                                                                  int index) {
                                                            if (index < state.user.length) {
                                                              // final isSelected =
                                                              //     userSelectedId.contains(
                                                              //             state.user[index]
                                                              //                 .id!) ||
                                                              //         userSelectedId
                                                              //             .contains(userId);
                                                              final isSelected =
                                                                  userSelectedId.contains(
                                                                      state
                                                                          .user[index].id!);
                                                              // userSelectedId.addAll(widget.usersid);

                                                              return Padding(
                                                                padding:
                                                                    EdgeInsets.symmetric(
                                                                        horizontal: 20.h),
                                                                child: InkWell(
                                                                  splashColor:
                                                                      Colors.transparent,
                                                                  onTap: () {
                                                                    setState(() {
                                                                      final isSelected =
                                                                          userSelectedId
                                                                              .contains(state
                                                                                  .user[
                                                                                      index]
                                                                                  .id!);

                                                                      if (isSelected) {
                                                                        // Remove the selected ID and corresponding username
                                                                        final removeIndex =
                                                                            userSelectedId
                                                                                .indexOf(state
                                                                                    .user[
                                                                                        index]
                                                                                    .id!);
                                                                        userSelectedId
                                                                            .removeAt(
                                                                                removeIndex);
                                                                        widget.usersid.removeAt(
                                                                            removeIndex); // Sync with widget.usersid
                                                                        userSelectedname
                                                                            .removeAt(
                                                                                removeIndex); // Remove corresponding username


                                                                      } else {
                                                                        // Add the selected ID and corresponding username
                                                                        userSelectedId.add(
                                                                            state
                                                                                .user[index]
                                                                                .id!);
                                                                        widget.usersid.add(state
                                                                            .user[index]
                                                                            .id!); // Sync with widget.usersid
                                                                        userSelectedname
                                                                            .add(state
                                                                                .user[index]
                                                                                .firstName!); // Add corresponding username

                                                                    }

                                                                      // Trigger any necessary UI or Bloc updates
                                                                      widget.onSelected(
                                                                          userSelectedname,
                                                                          userSelectedId);
                                                                      BlocProvider.of<
                                                                                  UserBloc>(
                                                                              context)
                                                                          .add(SelectedUser(
                                                                              index,
                                                                              state
                                                                                  .user[
                                                                                      index]
                                                                                  .firstName!));
                                                                      BlocProvider.of<
                                                                                  UserBloc>(
                                                                              context)
                                                                          .add(ToggleUserSelection(
                                                                              index,
                                                                              state
                                                                                  .user[
                                                                                      index]
                                                                                  .firstName!));
                                                                    });
                                                                  },
                                                                  child: Padding(
                                                                      padding: EdgeInsets
                                                                          .symmetric(
                                                                        vertical: 2.h,
                                                                      ),
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
                                                                                        .purple
                                                                                    : Colors
                                                                                        .transparent)),
                                                                        width:
                                                                            double.infinity,
                                                                        height: 40.h,
                                                                        child: Center(
                                                                          child: Padding(
                                                                            padding: EdgeInsets
                                                                                .symmetric(
                                                                                    horizontal:
                                                                                        10.w),
                                                                            child: Row(
                                                                              mainAxisAlignment:
                                                                                  MainAxisAlignment
                                                                                      .spaceBetween,
                                                                              children: [
                                                                                Expanded(
                                                                                  flex: 4,
                                                                                  child:
                                                                                      SizedBox(
                                                                                    width:
                                                                                        200.w,
                                                                                    child:
                                                                                        CustomText(
                                                                                      text: state
                                                                                          .user[index]
                                                                                          .firstName!,
                                                                                      fontWeight:
                                                                                          FontWeight.w500,
                                                                                      maxLines:
                                                                                          1,
                                                                                      overflow:
                                                                                          TextOverflow.ellipsis,
                                                                                      size:
                                                                                          18.sp,
                                                                                      color: isSelected
                                                                                          ? AppColors.primary
                                                                                          : Theme.of(context).colorScheme.textClrChange,
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                                isSelected
                                                                                    ? Expanded(
                                                                                        flex:
                                                                                            1,
                                                                                        child: const HeroIcon(HeroIcons.checkCircle,
                                                                                            style: HeroIconStyle.solid,
                                                                                            color: AppColors.purple),
                                                                                      )
                                                                                    : const SizedBox
                                                                                        .shrink(),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      )),
                                                                ),
                                                              );
                                                            } else {
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
                                                          });
                                                    }
                                                    return Container();
                                                  }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            // _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            // _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              return Container();
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                // color: Colors.red,
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (userSelectedname.isNotEmpty
                                          ? userSelectedname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers)
                                      : (widget.usersname.isNotEmpty
                                          ? widget.usersname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserLoading) {
              AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      highlightColor: Colors.transparent, // No highlight on tap
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              if (state is UserPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: 'Select Users',
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                  context
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
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
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.hasReachedMax
                                              ? state.user.length
                                              : state.user.length + 1,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (index < state.user.length) {
                                              final isSelected =
                                                  userSelectedId.contains(
                                                      state.user[index].id!);

                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 2.h),
                                                child: InkWell(
                                                  highlightColor: Colors
                                                      .transparent, // No highlight on tap
                                                  splashColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        userSelectedId.remove(
                                                            state.user[index]
                                                                .id!);
                                                        userSelectedname.remove(
                                                            state.user[index]
                                                                .firstName!);
                                                      } else {
                                                        userSelectedId.add(state
                                                            .user[index].id!);
                                                        userSelectedname.add(
                                                            state.user[index]
                                                                .firstName!);

                                                      }
                                                      widget.onSelected(
                                                          userSelectedname,
                                                          userSelectedId);
                                                      BlocProvider.of<UserBloc>(
                                                              context)
                                                          .add(SelectedUser(
                                                              index,
                                                              state.user[index]
                                                                  .firstName!));
                                                      BlocProvider.of<UserBloc>(
                                                              context)
                                                          .add(
                                                        ToggleUserSelection(
                                                          index,
                                                          state.user[index]
                                                              .firstName!,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 20.w,
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 35.h,
                                                      decoration: const BoxDecoration(
                                                          // borderRadius: BorderRadius
                                                          //     .circular(15),
                                                          // color: isSelected ? colors
                                                          //     .purple : Colors.grey
                                                          //     .shade400,
                                                          ),
                                                      child: Center(
                                                        child: CustomText(
                                                          text: state
                                                              .user[index]
                                                              .firstName!,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          size: 18,
                                                          color: AppColors
                                                              .whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0),
                                                child: Center(
                                                  child: state.hasReachedMax
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                          color:
                                                              AppColors.primary,
                                                          size: 40.0,
                                                        ),
                                                ),
                                              );
                                            }
                                          }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              return Container();
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (userSelectedname.isNotEmpty
                                      ? userSelectedname.join(", ")
                                      : "Select projects")
                                  : (userSelectedname.isNotEmpty
                                      ? userSelectedname.join(", ")
                                      : widget.usersname.join(", ")),
                              fontWeight: FontWeight.w400,
                              size: 14.sp,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserSuccess) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {
                              if (state is UserPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .selectusers,
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
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
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.hasReachedMax
                                              ? state.user.length
                                              : state.user.length + 1,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            if (index < state.user.length) {
                                              final isSelected =
                                                  userSelectedId.contains(
                                                      state.user[index].id!);

                                              return Padding(
                                                padding: EdgeInsets.symmetric(
                                                    vertical: 2.h),
                                                child: InkWell(
                                                  splashColor:
                                                      Colors.transparent,
                                                  onTap: () {
                                                    setState(() {
                                                      if (isSelected) {
                                                        userSelectedId.remove(
                                                            state.user[index]
                                                                .id!);
                                                        userSelectedname.remove(
                                                            state.user[index]
                                                                .firstName!);
                                                      } else {
                                                        userSelectedId.add(state
                                                            .user[index].id!);
                                                        userSelectedname.add(
                                                            state.user[index]
                                                                .firstName!);

                                                      }
                                                      widget.onSelected(
                                                          userSelectedname,
                                                          userSelectedId);
                                                      BlocProvider.of<UserBloc>(
                                                              context)
                                                          .add(SelectedUser(
                                                              index,
                                                              state.user[index]
                                                                  .firstName!));
                                                      BlocProvider.of<UserBloc>(
                                                              context)
                                                          .add(
                                                        ToggleUserSelection(
                                                          index,
                                                          state.user[index]
                                                              .firstName!,
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                      horizontal: 20.w,
                                                    ),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: 35.h,
                                                      decoration: const BoxDecoration(
                                                          // borderRadius: BorderRadius
                                                          //     .circular(15),
                                                          // color: isSelected ? colors
                                                          //     .purple : Colors.grey
                                                          //     .shade400,
                                                          ),
                                                      child: Center(
                                                        child: CustomText(
                                                          text: state
                                                              .user[index]
                                                              .firstName!,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          size: 18,
                                                          color: AppColors
                                                              .whiteColor,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 0),
                                                child: Center(
                                                  child: state.hasReachedMax
                                                      ? const Text('')
                                                      : const SpinKitFadingCircle(
                                                          color:
                                                              AppColors.primary,
                                                          size: 40.0,
                                                        ),
                                                ),
                                              );
                                            }
                                          }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              return Container();
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
                          color: Theme.of(context).colorScheme.containerDark,
                          boxShadow: [
                            isLightTheme
                                ? MyThemes.lightThemeShadow
                                : MyThemes.darkThemeShadow,
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CustomText(
                              text: widget.isCreate
                                  ? (userSelectedname.isNotEmpty
                                      ? userSelectedname.join(", ")
                                      : "Select projects")
                                  : (userSelectedname.isNotEmpty
                                      ? userSelectedname.join(", ")
                                      : widget.usersname.join(", ")),
                              fontWeight: FontWeight.w400,
                              size: 12,
                              color:
                                  Theme.of(context).colorScheme.textClrChange,
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserPaginated) {

              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {

                              if (state is UserSuccess) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {

                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectuser,
                                              fontWeight: FontWeight.w800,
                                              size: 20.sp,
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
                                                      _userSearchController,
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
                                                        .read<UserBloc>()
                                                        .add(
                                                            SearchUsers(value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.user.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // if (index <  state.user.length) {
                                           final isSelected = userSelectedId
                                                    .contains(state
                                                        .user[index].id!) ||
                                                userSelectedId.contains(userId);

                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.h),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    if (isSelected) {
                                                      userSelectedId.remove(
                                                          state
                                                              .user[index].id!);
                                                      userSelectedname.remove(
                                                          state.user[index]
                                                              .firstName!);
                                                    } else {
                                                      userSelectedId.add(state
                                                          .user[index].id!);
                                                      userSelectedname.add(state
                                                          .user[index]
                                                          .firstName!);

                                                    }
                                                    widget.onSelected(
                                                        userSelectedname,
                                                        userSelectedId);
                                                    BlocProvider.of<UserBloc>(
                                                            context)
                                                        .add(SelectedUser(
                                                            index,
                                                            state.user[index]
                                                                .firstName!));
                                                    BlocProvider.of<UserBloc>(
                                                            context)
                                                        .add(
                                                      ToggleUserSelection(
                                                        index,
                                                        state.user[index]
                                                            .firstName!,
                                                      ),
                                                    );
                                                  });
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                  ),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 35.h,
                                                    decoration: BoxDecoration(
                                                      // borderRadius: BorderRadius
                                                      //     .circular(15),
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : Colors
                                                              .grey.shade400,
                                                    ),
                                                    child: Center(
                                                      child: CustomText(
                                                        text: state.user[index]
                                                            .firstName!,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        size: 18,
                                                        color: AppColors
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                            // }
                                          }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              if (state is UserPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {

                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    // backgroundColor: Theme.of(context)
                                    //     .colorScheme
                                    //     .AlertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .selectusers,
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          )
                                        ],
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: BlocBuilder<UserBloc, UserState>(
                                          builder: (context, state) {
                                        if (state is UserPaginated) {
                                          ScrollController scrollController =
                                              ScrollController();
                                          scrollController.addListener(() {
                                            // !state.hasReachedMax

                                            if (scrollController
                                                .position.atEdge) {

                                              if (scrollController
                                                      .position.pixels !=
                                                  0) {
                                                BlocProvider.of<UserBloc>(
                                                        context)
                                                    .add(UserLoadMore(
                                                        searchWord));
                                              }
                                            }
                                          });
                                          return ListView.builder(
                                              controller: scrollController,
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.user.length
                                                  : state.user.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                if (index < state.user.length) {
                                                  final isSelected =
                                                      userSelectedId.contains(
                                                          state.user[index].id);
                                                  return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20.h),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        setState(() {
                                                          final isSelected =
                                                              userSelectedId
                                                                  .contains(state
                                                                      .user[
                                                                          index]
                                                                      .id!);

                                                          if (isSelected) {
                                                            // Remove the selected ID and corresponding username
                                                            final removeIndex =
                                                                userSelectedId
                                                                    .indexOf(state
                                                                        .user[
                                                                            index]
                                                                        .id!);
                                                            userSelectedId
                                                                .removeAt(
                                                                    removeIndex);
                                                            widget.usersid.removeAt(
                                                                removeIndex); // Sync with widget.usersid
                                                            userSelectedname
                                                                .removeAt(
                                                                    removeIndex); // Remove corresponding username

                                                          } else {
                                                            // Add the selected ID and corresponding username
                                                            userSelectedId.add(
                                                                state
                                                                    .user[index]
                                                                    .id!);
                                                            widget.usersid.add(state
                                                                .user[index]
                                                                .id!); // Sync with widget.usersid
                                                            userSelectedname
                                                                .add(state
                                                                    .user[index]
                                                                    .firstName!); // Add corresponding username

                                                          }

                                                          // Trigger any necessary UI or Bloc updates
                                                          widget.onSelected(
                                                              userSelectedname,
                                                              userSelectedId);
                                                          BlocProvider.of<
                                                                      UserBloc>(
                                                                  context)
                                                              .add(SelectedUser(
                                                                  index,
                                                                  state
                                                                      .user[
                                                                          index]
                                                                      .firstName!));
                                                          BlocProvider.of<
                                                                      UserBloc>(
                                                                  context)
                                                              .add(ToggleUserSelection(
                                                                  index,
                                                                  state
                                                                      .user[
                                                                          index]
                                                                      .firstName!));
                                                        });
                                                      },
                                                      child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: 2.h,
                                                          ),
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
                                                                            .purple
                                                                        : Colors
                                                                            .transparent)),
                                                            width:
                                                                double.infinity,
                                                            // height: 40.h,
                                                            child: Center(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10.w),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            200.w,
                                                                        child:
                                                                            Row(
                                                                          children: [
                                                                            Expanded(
                                                                              flex: 7,
                                                                              child: SizedBox(
                                                                                width: 200.w,
                                                                                child: Row(
                                                                                  children: [
                                                                                    CircleAvatar(
                                                                                      radius: 20,
                                                                                      backgroundImage: NetworkImage(state.user[index].profile!),
                                                                                    ),
                                                                                    Expanded(
                                                                                      child: Padding(
                                                                                        padding: EdgeInsets.symmetric(horizontal: 18.w),
                                                                                        child: Column(
                                                                                          // Changed from Row to Column to stack vertically
                                                                                          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
                                                                                          children: [
                                                                                            Row(
                                                                                              // First row with names
                                                                                              children: [
                                                                                                Flexible(
                                                                                                  child: CustomText(
                                                                                                    text: state.user[index].firstName!,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    size: 18.sp,
                                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                  ),
                                                                                                ),
                                                                                                SizedBox(width: 5.w),
                                                                                                Flexible(
                                                                                                  child: CustomText(
                                                                                                    text: state.user[index].lastName!,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    size: 18.sp,
                                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                            // SizedBox(height: 2.h),  // Add some spacing between rows
                                                                                            Row(
                                                                                              children: [
                                                                                                Flexible(
                                                                                                  child: CustomText(
                                                                                                    text: state.user[index].email!,
                                                                                                    fontWeight: FontWeight.w500,
                                                                                                    maxLines: 1,
                                                                                                    overflow: TextOverflow.ellipsis,
                                                                                                    size: 18.sp,
                                                                                                    color: isSelected ? AppColors.primary : Theme.of(context).colorScheme.textClrChange,
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    isSelected
                                                                        ? Expanded(
                                                                            flex:
                                                                                1,
                                                                            child: const HeroIcon(HeroIcons.checkCircle,
                                                                                style: HeroIconStyle.solid,
                                                                                color: AppColors.purple),
                                                                          )
                                                                        : const SizedBox
                                                                            .shrink(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )),
                                                    ),
                                                  );
                                                } else {
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
                                              });
                                        }
                                        return Container();
                                      }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              return Container();
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                // color: Colors.red,
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (userSelectedname.isNotEmpty
                                          ? userSelectedname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers)
                                      : (widget.usersname.isNotEmpty
                                          ? widget.usersname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is UserError) {
              return AbsorbPointer(
                absorbing: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 5.h),
                    InkWell(
                      splashColor: Colors.transparent,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                            builder: (context, state) {

                              if (state is UserSuccess) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {
                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {

                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.9,
                                        child: Column(
                                          children: [
                                            CustomText(
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .selectuser,
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
                                                      _userSearchController,
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
                                                        .read<UserBloc>()
                                                        .add(
                                                            SearchUsers(value));
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 5.h,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: ListView.builder(
                                          controller: scrollController,
                                          shrinkWrap: true,
                                          itemCount: state.user.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // if (index <  state.user.length) {

                                            final isSelected =
                                                userSelectedId.contains(
                                                    state.user[index].id!);

                                            return Padding(
                                              padding: EdgeInsets.symmetric(
                                                  vertical: 2.h),
                                              child: InkWell(
                                                splashColor: Colors.transparent,
                                                onTap: () {
                                                  setState(() {
                                                    if (isSelected) {
                                                      userSelectedId.remove(
                                                          state
                                                              .user[index].id!);
                                                      userSelectedname.remove(
                                                          state.user[index]
                                                              .firstName!);
                                                    } else {
                                                      userSelectedId.add(state
                                                          .user[index].id!);
                                                      userSelectedname.add(state
                                                          .user[index]
                                                          .firstName!);

                                                    }
                                                    widget.onSelected(
                                                        userSelectedname,
                                                        userSelectedId);
                                                    BlocProvider.of<UserBloc>(
                                                            context)
                                                        .add(SelectedUser(
                                                            index,
                                                            state.user[index]
                                                                .firstName!));
                                                    BlocProvider.of<UserBloc>(
                                                            context)
                                                        .add(
                                                      ToggleUserSelection(
                                                        index,
                                                        state.user[index]
                                                            .firstName!,
                                                      ),
                                                    );
                                                  });
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 20.w,
                                                  ),
                                                  child: Container(
                                                    width: double.infinity,
                                                    height: 35.h,
                                                    decoration: BoxDecoration(
                                                      // borderRadius: BorderRadius
                                                      //     .circular(15),
                                                      color: isSelected
                                                          ? AppColors.primary
                                                          : Colors
                                                              .grey.shade400,
                                                    ),
                                                    child: Center(
                                                      child: CustomText(
                                                        text: state.user[index]
                                                            .firstName!,
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        size: 18,
                                                        color: AppColors
                                                            .whiteColor,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                            // }
                                          }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              if (state is UserPaginated) {
                                ScrollController scrollController =
                                    ScrollController();
                                scrollController.addListener(() {

                                  if (scrollController.position.atEdge) {
                                    if (scrollController.position.pixels != 0) {
                                      BlocProvider.of<UserBloc>(context)
                                          .add(UserLoadMore(searchWord));
                                    }
                                  }
                                });

                                return StatefulBuilder(builder: (BuildContext
                                        context,
                                    void Function(void Function()) setState) {
                                  return AlertDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          10.r), // Set the desired radius here
                                    ),
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .alertBoxBackGroundColor,
                                    // backgroundColor: Theme.of(context)
                                    //     .colorScheme
                                    //     .AlertBoxBackGroundColor,
                                    contentPadding: EdgeInsets.zero,
                                    title: Center(
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .selectusers,
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          )
                                        ],
                                      ),
                                    ),
                                    content: Container(
                                      constraints:
                                          BoxConstraints(maxHeight: 900.h),
                                      width: MediaQuery.of(context).size.width,
                                      child: BlocBuilder<UserBloc, UserState>(
                                          builder: (context, state) {
                                        if (state is UserPaginated) {
                                          ScrollController scrollController =
                                              ScrollController();
                                          scrollController.addListener(() {
                                            // !state.hasReachedMax

                                            if (scrollController
                                                .position.atEdge) {

                                              if (scrollController
                                                      .position.pixels !=
                                                  0) {
                                                BlocProvider.of<UserBloc>(
                                                        context)
                                                    .add(UserLoadMore(
                                                        searchWord));
                                              }
                                            }
                                          });
                                          return ListView.builder(
                                              controller: scrollController,
                                              shrinkWrap: true,
                                              itemCount: state.hasReachedMax
                                                  ? state.user.length
                                                  : state.user.length + 1,
                                              itemBuilder:
                                                  (BuildContext context,
                                                      int index) {
                                                if (index < state.user.length) {
                                                  final isSelected =
                                                      userSelectedId.contains(
                                                          state
                                                              .user[index].id!);

                                                 return Padding(
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 20.h),
                                                    child: InkWell(
                                                      splashColor:
                                                          Colors.transparent,
                                                      onTap: () {
                                                        setState(() {
                                                          final isSelected =
                                                              userSelectedId
                                                                  .contains(state
                                                                      .user[
                                                                          index]
                                                                      .id!);

                                                          if (isSelected) {
                                                            // Remove the selected ID and corresponding username
                                                            final removeIndex =
                                                                userSelectedId
                                                                    .indexOf(state
                                                                        .user[
                                                                            index]
                                                                        .id!);
                                                            userSelectedId
                                                                .removeAt(
                                                                    removeIndex);
                                                            widget.usersid.removeAt(
                                                                removeIndex); // Sync with widget.usersid
                                                            userSelectedname
                                                                .removeAt(
                                                                    removeIndex); // Remove corresponding username

                                                         } else {
                                                            // Add the selected ID and corresponding username
                                                            userSelectedId.add(
                                                                state
                                                                    .user[index]
                                                                    .id!);
                                                            widget.usersid.add(state
                                                                .user[index]
                                                                .id!); // Sync with widget.usersid
                                                            userSelectedname
                                                                .add(state
                                                                    .user[index]
                                                                    .firstName!); // Add corresponding username

                                                           }

                                                          // Trigger any necessary UI or Bloc updates
                                                          widget.onSelected(
                                                              userSelectedname,
                                                              userSelectedId);
                                                          BlocProvider.of<
                                                                      UserBloc>(
                                                                  context)
                                                              .add(SelectedUser(
                                                                  index,
                                                                  state
                                                                      .user[
                                                                          index]
                                                                      .firstName!));
                                                          BlocProvider.of<
                                                                      UserBloc>(
                                                                  context)
                                                              .add(ToggleUserSelection(
                                                                  index,
                                                                  state
                                                                      .user[
                                                                          index]
                                                                      .firstName!));
                                                        });
                                                      },
                                                      child: Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                            vertical: 2.h,
                                                          ),
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
                                                                            .purple
                                                                        : Colors
                                                                            .transparent)),
                                                            width:
                                                                double.infinity,
                                                            height: 40.h,
                                                            child: Center(
                                                              child: Padding(
                                                                padding: EdgeInsets
                                                                    .symmetric(
                                                                        horizontal:
                                                                            10.w),
                                                                child: Row(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .spaceBetween,
                                                                  children: [
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            200.w,
                                                                        child:
                                                                            CustomText(
                                                                          text: state
                                                                              .user[index]
                                                                              .firstName!,
                                                                          fontWeight:
                                                                              FontWeight.w500,
                                                                          maxLines:
                                                                              1,
                                                                          overflow:
                                                                              TextOverflow.ellipsis,
                                                                          size:
                                                                              18.sp,
                                                                          color: isSelected
                                                                              ? AppColors.primary
                                                                              : Theme.of(context).colorScheme.textClrChange,
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    isSelected
                                                                        ? Expanded(
                                                                            flex:
                                                                                1,
                                                                            child: const HeroIcon(HeroIcons.checkCircle,
                                                                                style: HeroIconStyle.solid,
                                                                                color: AppColors.purple),
                                                                          )
                                                                        : const SizedBox
                                                                            .shrink(),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          )
                                                          // child: Container(
                                                          //   width: double.infinity,
                                                          //   height: 35.h,
                                                          //   decoration: BoxDecoration(
                                                          //     // borderRadius: BorderRadius
                                                          //     //     .circular(15),
                                                          //     color: isSelected
                                                          //         ? Theme.of(context)
                                                          //             .colorScheme
                                                          //             .selectedFieldListChange
                                                          //         : Colors
                                                          //             .transparent,
                                                          //     // color: isSelected ? colors
                                                          //     //     .purple : Colors.grey
                                                          //     //     .shade400,
                                                          //   ),
                                                          //   child: Center(
                                                          //     child: Padding(
                                                          //       padding: EdgeInsets
                                                          //           .symmetric(
                                                          //               horizontal:
                                                          //                   28.w),
                                                          //       child: Row(
                                                          //         mainAxisAlignment:
                                                          //             MainAxisAlignment
                                                          //                 .spaceBetween,
                                                          //         children: [
                                                          //           Container(
                                                          //             width: 190.w,
                                                          //             // color: Colors.red,
                                                          //             child:
                                                          //                 CustomText(
                                                          //               text: state
                                                          //                   .user[
                                                          //                       index]
                                                          //                   .firstName!,
                                                          //               fontWeight:
                                                          //                   FontWeight
                                                          //                       .w400,
                                                          //               size: 18,
                                                          //               maxLines: 1,
                                                          //               overflow:
                                                          //                   TextOverflow
                                                          //                       .ellipsis,
                                                          //               color: Theme.of(
                                                          //                       context)
                                                          //                   .colorScheme
                                                          //                   .textClrChange,
                                                          //             ),
                                                          //           ),
                                                          //           isSelected
                                                          //               ? HeroIcon(
                                                          //                   HeroIcons
                                                          //                       .checkBadge,
                                                          //                   style: HeroIconStyle
                                                          //                       .outline,
                                                          //                   color: colors
                                                          //                       .blueColor,
                                                          //                 )
                                                          //               : SizedBox
                                                          //                   .shrink(),
                                                          //         ],
                                                          //       ),
                                                          //     ),
                                                          //   ),
                                                          // ),
                                                          ),
                                                    ),
                                                  );
                                                } else {
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
                                              });
                                        }
                                        return Container();
                                      }),
                                    ),
                                    actions: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.only(top: 20.h),
                                        child: CreateCancelButtom(
                                          title: "OK",
                                          onpressCancel: () {
                                            _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                          onpressCreate: () {
                                            _userSearchController.clear();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                    ],
                                  );
                                });
                              }
                              return Container();
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
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: SizedBox(
                                // color: Colors.red,
                                child: CustomText(
                                  text: widget.isCreate
                                      ? (userSelectedname.isNotEmpty
                                          ? userSelectedname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers)
                                      : (widget.usersname.isNotEmpty
                                          ? widget.usersname.join(", ")
                                          : AppLocalizations.of(context)!
                                              .selectusers),
                                  fontWeight: FontWeight.w500,
                                  size: 14.sp,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .textClrChange,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                            const Icon(Icons.arrow_drop_down),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
            return AbsorbPointer(
              absorbing: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 5.h),
                  InkWell(
                    splashColor: Colors.transparent,
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (ctx) => BlocBuilder<UserBloc, UserState>(
                          builder: (context, state) {
print("fdgjxzgj $state");
                            if (state is UserSuccess) {
                              ScrollController scrollController =
                                  ScrollController();
                              scrollController.addListener(() {
                                if (scrollController.position.atEdge) {
                                  if (scrollController.position.pixels != 0) {

                                    BlocProvider.of<UserBloc>(context)
                                        .add(UserLoadMore(searchWord));
                                  }
                                }
                              });

                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      void Function(void Function()) setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.r), // Set the desired radius here
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .alertBoxBackGroundColor,
                                  contentPadding: EdgeInsets.zero,
                                  title: Center(
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      child: Column(
                                        children: [
                                          CustomText(
                                            text: AppLocalizations.of(context)!
                                                .selectuser,
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
                                                    _userSearchController,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                    vertical:
                                                        (35.h - 20.sp) / 2,
                                                    horizontal: 10.w,
                                                  ),
                                                  hintText: AppLocalizations.of(
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
                                                      .read<UserBloc>()
                                                      .add(SearchUsers(value));
                                                },
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5.h,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  content: Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 900.h),
                                    width: MediaQuery.of(context).size.width,
                                    child: ListView.builder(
                                        controller: scrollController,
                                        shrinkWrap: true,
                                        itemCount: state.user.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          // if (index <  state.user.length) {

                                          final isSelected = userSelectedId
                                              .contains(state.user[index].id!);

                                          return Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 2.h),
                                            child: InkWell(
                                              splashColor: Colors.transparent,
                                              onTap: () {
                                                setState(() {
                                                  if (isSelected) {
                                                    userSelectedId.remove(
                                                        state.user[index].id!);
                                                    userSelectedname.remove(
                                                        state.user[index]
                                                            .firstName!);
                                                  } else {
                                                    userSelectedId.add(
                                                        state.user[index].id!);
                                                    userSelectedname.add(state
                                                        .user[index]
                                                        .firstName!);

                                                  }
                                                  widget.onSelected(
                                                      userSelectedname,
                                                      userSelectedId);
                                                  BlocProvider.of<UserBloc>(
                                                          context)
                                                      .add(SelectedUser(
                                                          index,
                                                          state.user[index]
                                                              .firstName!));
                                                  BlocProvider.of<UserBloc>(
                                                          context)
                                                      .add(
                                                    ToggleUserSelection(
                                                      index,
                                                      state.user[index]
                                                          .firstName!,
                                                    ),
                                                  );
                                                });
                                              },
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: 20.w,
                                                ),
                                                child: Container(
                                                  width: double.infinity,
                                                  height: 35.h,
                                                  decoration: BoxDecoration(
                                                    // borderRadius: BorderRadius
                                                    //     .circular(15),
                                                    color: isSelected
                                                        ? AppColors.primary
                                                        : Colors.grey.shade400,
                                                  ),
                                                  child: Center(
                                                    child: CustomText(
                                                      text: state.user[index]
                                                          .firstName!,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      size: 18,
                                                      color:
                                                          AppColors.whiteColor,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                          // }
                                        }),
                                  ),
                                  actions: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: CreateCancelButtom(
                                        title: "OK",
                                        onpressCancel: () {
                                          Navigator.pop(context);
                                        },
                                        onpressCreate: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              });
                            }
                            if (state is UserPaginated) {
                              ScrollController scrollController =
                                  ScrollController();
                              scrollController.addListener(() {

                                if (scrollController.position.atEdge) {
                                  if (scrollController.position.pixels != 0) {
                                    BlocProvider.of<UserBloc>(context)
                                        .add(UserLoadMore(searchWord));
                                  }
                                }
                              });

                              return StatefulBuilder(builder:
                                  (BuildContext context,
                                      void Function(void Function()) setState) {
                                return AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        10.r), // Set the desired radius here
                                  ),
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .alertBoxBackGroundColor,
                                  // backgroundColor: Theme.of(context)
                                  //     .colorScheme
                                  //     .AlertBoxBackGroundColor,
                                  contentPadding: EdgeInsets.zero,
                                  title: Center(
                                    child: Column(
                                      children: [
                                        CustomText(
                                          text: AppLocalizations.of(context)!
                                              .selectusers,
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
                                              controller: _userSearchController,
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  vertical: (35.h - 20.sp) / 2,
                                                  horizontal: 10.w,
                                                ),
                                                hintText: AppLocalizations.of(
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
                                                    .read<UserBloc>()
                                                    .add(SearchUsers(value));
                                              },
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: 10.h,
                                        )
                                      ],
                                    ),
                                  ),
                                  content: Container(
                                    constraints:
                                        BoxConstraints(maxHeight: 900.h),
                                    width: MediaQuery.of(context).size.width,
                                    child: BlocBuilder<UserBloc, UserState>(
                                        builder: (context, state) {
                                      if (state is UserPaginated) {
                                        ScrollController scrollController =
                                            ScrollController();
                                        scrollController.addListener(() {
                                          // !state.hasReachedMax

                                          if (scrollController
                                              .position.atEdge) {

                                            if (scrollController
                                                    .position.pixels !=
                                                0) {
                                              BlocProvider.of<UserBloc>(context)
                                                  .add(
                                                      UserLoadMore(searchWord));
                                            }
                                          }
                                        });
                                        return ListView.builder(
                                            controller: scrollController,
                                            shrinkWrap: true,
                                            itemCount: state.hasReachedMax
                                                ? state.user.length
                                                : state.user.length + 1,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              if (index < state.user.length) {
                                                final isSelected =
                                                    userSelectedId.contains(
                                                        state.user[index].id!);

                                                return Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal: 20.h),
                                                  child: InkWell(
                                                    splashColor:
                                                        Colors.transparent,
                                                    onTap: () {
                                                      setState(() {
                                                        final isSelected =
                                                            userSelectedId
                                                                .contains(state
                                                                    .user[index]
                                                                    .id!);

                                                        if (isSelected) {
                                                          // Remove the selected ID and corresponding username
                                                          final removeIndex =
                                                              userSelectedId
                                                                  .indexOf(state
                                                                      .user[
                                                                          index]
                                                                      .id!);
                                                          userSelectedId
                                                              .removeAt(
                                                                  removeIndex);
                                                          widget.usersid.removeAt(
                                                              removeIndex); // Sync with widget.usersid
                                                          userSelectedname.removeAt(
                                                              removeIndex); // Remove corresponding username

                                                        } else {
                                                          // Add the selected ID and corresponding username
                                                          userSelectedId.add(
                                                              state.user[index]
                                                                  .id!);
                                                          widget.usersid.add(state
                                                              .user[index]
                                                              .id!); // Sync with widget.usersid
                                                          userSelectedname.add(state
                                                              .user[index]
                                                              .firstName!); // Add corresponding username
 }

                                                        // Trigger any necessary UI or Bloc updates
                                                        widget.onSelected(
                                                            userSelectedname,
                                                            userSelectedId);
                                                        BlocProvider.of<
                                                                    UserBloc>(
                                                                context)
                                                            .add(SelectedUser(
                                                                index,
                                                                state
                                                                    .user[index]
                                                                    .firstName!));
                                                        BlocProvider.of<
                                                                    UserBloc>(
                                                                context)
                                                            .add(ToggleUserSelection(
                                                                index,
                                                                state
                                                                    .user[index]
                                                                    .firstName!));
                                                      });
                                                    },
                                                    child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                          vertical: 2.h,
                                                        ),
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
                                                                          .purple
                                                                      : Colors
                                                                          .transparent)),
                                                          width:
                                                              double.infinity,
                                                          height: 40.h,
                                                          child: Center(
                                                            child: Padding(
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          10.w),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Expanded(
                                                                    flex: 4,
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          200.w,
                                                                      child:
                                                                          CustomText(
                                                                        text: state
                                                                            .user[index]
                                                                            .firstName!,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        maxLines:
                                                                            1,
                                                                        overflow:
                                                                            TextOverflow.ellipsis,
                                                                        size: 18
                                                                            .sp,
                                                                        color: isSelected
                                                                            ? AppColors.primary
                                                                            : Theme.of(context).colorScheme.textClrChange,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  isSelected
                                                                      ? Expanded(
                                                                          flex:
                                                                              1,
                                                                          child: const HeroIcon(
                                                                              HeroIcons.checkCircle,
                                                                              style: HeroIconStyle.solid,
                                                                              color: AppColors.purple),
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                        // child: Container(
                                                        //   width: double.infinity,
                                                        //   height: 35.h,
                                                        //   decoration: BoxDecoration(
                                                        //     // borderRadius: BorderRadius
                                                        //     //     .circular(15),
                                                        //     color: isSelected
                                                        //         ? Theme.of(context)
                                                        //             .colorScheme
                                                        //             .selectedFieldListChange
                                                        //         : Colors
                                                        //             .transparent,
                                                        //     // color: isSelected ? colors
                                                        //     //     .purple : Colors.grey
                                                        //     //     .shade400,
                                                        //   ),
                                                        //   child: Center(
                                                        //     child: Padding(
                                                        //       padding: EdgeInsets
                                                        //           .symmetric(
                                                        //               horizontal:
                                                        //                   28.w),
                                                        //       child: Row(
                                                        //         mainAxisAlignment:
                                                        //             MainAxisAlignment
                                                        //                 .spaceBetween,
                                                        //         children: [
                                                        //           Container(
                                                        //             width: 190.w,
                                                        //             // color: Colors.red,
                                                        //             child:
                                                        //                 CustomText(
                                                        //               text: state
                                                        //                   .user[
                                                        //                       index]
                                                        //                   .firstName!,
                                                        //               fontWeight:
                                                        //                   FontWeight
                                                        //                       .w400,
                                                        //               size: 18,
                                                        //               maxLines: 1,
                                                        //               overflow:
                                                        //                   TextOverflow
                                                        //                       .ellipsis,
                                                        //               color: Theme.of(
                                                        //                       context)
                                                        //                   .colorScheme
                                                        //                   .textClrChange,
                                                        //             ),
                                                        //           ),
                                                        //           isSelected
                                                        //               ? HeroIcon(
                                                        //                   HeroIcons
                                                        //                       .checkBadge,
                                                        //                   style: HeroIconStyle
                                                        //                       .outline,
                                                        //                   color: colors
                                                        //                       .blueColor,
                                                        //                 )
                                                        //               : SizedBox
                                                        //                   .shrink(),
                                                        //         ],
                                                        //       ),
                                                        //     ),
                                                        //   ),
                                                        // ),
                                                        ),
                                                  ),
                                                );
                                              } else {
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
                                            });
                                      }
                                      return Container();
                                    }),
                                  ),
                                  actions: <Widget>[
                                    Padding(
                                      padding: EdgeInsets.only(top: 20.h),
                                      child: CreateCancelButtom(
                                        title: "OK",
                                        onpressCancel: () {
                                          _userSearchController.clear();
                                          Navigator.pop(context);
                                        },
                                        onpressCreate: () {
                                          _userSearchController.clear();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ),
                                  ],
                                );
                              });
                            }
                            return Container();
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: SizedBox(
                              // color: Colors.red,
                              child: CustomText(
                                text: widget.isCreate
                                    ? (userSelectedname.isNotEmpty
                                        ? userSelectedname.join(", ")
                                        : AppLocalizations.of(context)!
                                            .selectusers)
                                    : (widget.usersname.isNotEmpty
                                        ? widget.usersname.join(", ")
                                        : AppLocalizations.of(context)!
                                            .selectusers),
                                fontWeight: FontWeight.w500,
                                size: 14.sp,
                                color:
                                    Theme.of(context).colorScheme.textClrChange,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
