import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:taskify/bloc/auth/auth_event.dart';
import 'package:taskify/config/colors.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../bloc/roles/role_bloc.dart';
import '../../bloc/roles/role_event.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_state.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../bloc/theme/theme_state.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/custom_text.dart';
import '../../config/internet_connectivity.dart';
import '../../utils/widgets/my_theme.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../../utils/widgets/toast_widget.dart';
import '../widgets/custom_button.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedLabel = "As a Client";
  int _selectedIndex = 0;
  bool? isLoading;
  int? roleId;
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController companyController = TextEditingController();
  TextEditingController roleController = TextEditingController();
  TextEditingController conPasswordController = TextEditingController();
  String? isMember;
  bool? _showPassword = true;
  bool? _showConPassword = true;
  FocusNode? emailFocus,
      firstnameFocus,
      lastnameFocus,
      comapnyFocus,
      roleFocus,
      conPasswordFocus,
      passFocus = FocusNode();
  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  void validateAndSubmit() async {
    FocusScope.of(context).unfocus();
    if (firstnameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        conPasswordController.text.isNotEmpty) {
      if (_selectedIndex == 0) {
        selectedLabel = "client";
      }
      if (_selectedIndex == 1) {
        selectedLabel = "member";
      }
      if (!emailController.text.contains('@')) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.entervalidemail,
        );
        return;
      }

      if (passwordController.text != conPasswordController.text) {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pasconpassnotcorrect,
        );
        return;
      }
      setState(() {
        isLoading = true;
      });
      BlocProvider.of<AuthBloc>(context).add(AuthSignUp(
          context: context,
          email: emailController.text,
          role: roleId ?? 0,
          firstname: firstnameController.text,
          lastname: lastNameController.text,
          company: companyController.text,
          confirmPass: conPasswordController.text,
          type: selectedLabel,
          password: passwordController.text));
      final signUp = context.read<AuthBloc>();
      signUp.stream.listen((state) {
        if (state is AuthSignUpLoadSuccess) {
          setState(() {
            isLoading = false;
          });
          if (mounted) {
            flutterToastCustom(
              msg: AppLocalizations.of(context)!.registeredsuccessfully,
              color: AppColors.primary,
            );
            router.go("/login"); // Use go instead of push to replace the route
          }
        }

        if (state is AuthSignUpLoadFailure) {
          setState(() {
            isLoading = false;
          });
          flutterToastCustom(msg: state.message);
        }
      });
    } else {
      flutterToastCustom(
        msg: AppLocalizations.of(context)!.pleasefilltherequiredfield,
      );
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  void initState() {
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
    BlocProvider.of<RoleBloc>(context).add(RoleList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final themeBloc = context.read<ThemeBloc>();
    final currentTheme = themeBloc.currentThemeState;

    bool isLightTheme = currentTheme is LightThemeState;
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: signupBloc(isLightTheme, isLoading));
  }

  Widget signupBloc(isLightTheme, isLoading) {
    
    return BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
      if (state is AuthLoadFailure) {
      } else if (state is AuthLoadSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/login');
        });
      }

      return SingleChildScrollView(
          child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              // color: Colors.purple.shade100,
              child: Stack(
                children: [
                  Positioned(
                    top: 80.h,
                    // right: 5,
                    left: 20.w,
                    right: 20.w,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          signUpText(context),
                          SizedBox(
                            height: 30.h,
                          ),
                          const SizedBox(height: 10),
                          Container(
                            height: 50.h,
                            width: 370.w,
                            margin: const EdgeInsets.symmetric(horizontal: 0),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.greyColor),
                              color:
                                  Theme.of(context).colorScheme.containerDark,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                isLightTheme
                                    ? MyThemes.lightThemeShadow
                                    : MyThemes.darkThemeShadow,
                              ],
                            ),
                            child: ToggleSwitch(
                              cornerRadius: 11,
                              activeBgColor: const [AppColors.primary],
                              inactiveBgColor:
                                  Theme.of(context).colorScheme.containerDark,
                              minHeight: 40,
                              minWidth: double.infinity,
                              initialLabelIndex: _selectedIndex,
                              totalSwitches: 2,
                              customTextStyles: [
                                TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                )
                              ],
                              labels: [
                                AppLocalizations.of(context)!.asaclient,
                                AppLocalizations.of(context)!.asateammember,
                              ],
                              onToggle: (index) {
                                setState(() {
                                  _selectedIndex = index!;
                                  roleController.clear();
                                });
                              },
                            ),
                          ),
                          SizedBox(height: 30.h),
                          SizedBox(
                              height: 50.h,
                              width: 370.w,
                              // decoration: DesignConfiguration.shadow(),
                              child: TextFormField(
                                style: TextStyle(fontSize: 14.sp),
                                cursorColor: AppColors.greyForgetColor,
                                cursorWidth: 1.w,
                                // enableInteractiveSelection: false,//: false,
                                controller: firstnameController,
                                keyboardType: TextInputType.text,
                                onFieldSubmitted: (v) {
                                  _fieldFocusChange(
                                    context,
                                    firstnameFocus!,
                                    lastnameFocus,
                                  );
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      null, // Set labelText to null to use label instead
                                  label: RichText(
                                    text: TextSpan(
                                      text: AppLocalizations.of(context)!
                                          .firstname, // Regular text
                                      style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .textFieldColor,
                                        fontSize: 13.sp,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: ' *', // Asterisk
                                          style: TextStyle(
                                            color: Colors
                                                .red, // Red color for the asterisk
                                            fontSize: 13.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    borderSide: const BorderSide(
                                        color: AppColors.hintColor),
                                  ),
                                ),
                              )),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50.h,
                            width: 370.w,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14.sp),
                              cursorColor: AppColors.greyForgetColor,
                              cursorWidth: 1.w,
                              controller: lastNameController,
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(
                                  context,
                                  lastnameFocus!,
                                  comapnyFocus,
                                );
                              },
                              decoration: InputDecoration(
                                labelText: null,
                                label: RichText(
                                  text: TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .lastname, // The regular label text
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' *', // Red-colored asterisk
                                        style: TextStyle(
                                          color: Colors
                                              .red, // Red color for the asterisk
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.hintColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50.h,
                            width: 370.w,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14.sp),
                              cursorColor: AppColors.greyForgetColor,
                              cursorWidth: 1.w,
                              // enableInteractiveSelection: false,
                              controller: emailController,
                              keyboardType: TextInputType.text,
                              onFieldSubmitted: (v) {
                                _fieldFocusChange(
                                  context,
                                  emailFocus!,
                                  passFocus,
                                );
                              },
                              decoration: InputDecoration(
                                labelText:
                                    null, // Set labelText to null to use RichText for the label
                                label: RichText(
                                  text: TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .email, // Regular label text
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13.sp,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' *', // Red-colored asterisk
                                        style: TextStyle(
                                          color: Colors
                                              .red, // Red color for the asterisk
                                          fontSize: 13.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.hintColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _selectedIndex == 0
                              ? SizedBox(
                                  height: 50.h,
                                  width: 370.w,
                                  child: TextFormField(
                                    style: TextStyle(fontSize: 14.sp),
                                    cursorColor: AppColors.greyForgetColor,
                                    cursorWidth: 1.w,
                                    controller: companyController,
                                    keyboardType: TextInputType.text,
                                    onSaved: (String? value) {},
                                    onFieldSubmitted: (v) {
                                      _fieldFocusChange(
                                        context,
                                        comapnyFocus!,
                                        emailFocus,
                                      );
                                    },
                                    decoration: InputDecoration(
                                      labelText:
                                          AppLocalizations.of(context)!.company,
                                      labelStyle: TextStyle(
                                          // fontFamily: fontFamily,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .textFieldColor,
                                          fontSize: 13),
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          borderSide: const BorderSide(
                                              color: AppColors.hintColor)),
                                    ),
                                  ),
                                )
                              : SizedBox.shrink(),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50.h,
                            width: 370.w,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14.sp),
                              cursorColor: AppColors.greyForgetColor,
                              cursorWidth: 1.w,
                              // enableInteractiveSelection: false,////: false,
                              controller: passwordController,
                              obscureText: _showPassword!,
                              keyboardType: TextInputType.text,
                              focusNode: passFocus,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp('[ ]')),
                              ],
                              onSaved: (String? value) {},

                              decoration: InputDecoration(
                                labelText: null,
                                label: RichText(
                                  text: TextSpan(
                                    text: 'Password',
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' *',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: const BorderSide(
                                      color: AppColors.hintColor),
                                ),
                                suffixIcon: InkWell(
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      _showPassword = !_showPassword!;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10.0),
                                    child: Icon(
                                      !_showPassword!
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withValues(alpha: 0.4),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            height: 50.h,
                            width: 370.w,
                            child: TextFormField(
                              style: TextStyle(fontSize: 14.sp),
                              cursorColor: AppColors.greyForgetColor,
                              cursorWidth: 1.w,
                              // enableInteractiveSelection: false,
                              controller: conPasswordController,
                              obscureText: _showConPassword!,
                              keyboardType: TextInputType.text,
                              focusNode: conPasswordFocus,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(RegExp('[ ]')),
                              ],
                              onSaved: (String? value) {
                                // context.read<AuthenticationProvider>().setsinUpPassword(value);
                              },
                              onFieldSubmitted: (v) {
                                // _fieldFocusChange(context, passFocus!, referFocus);
                              },
                              decoration: InputDecoration(
                                labelText:
                                    null, // Remove labelText to use RichText for label
                                label: RichText(
                                  text: TextSpan(
                                    text: AppLocalizations.of(context)!
                                        .conPassword, // Regular label text
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: ' *', // Red-colored asterisk
                                        style: TextStyle(
                                          color: Colors
                                              .red, // Red color for the asterisk
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: Colors.red.shade600),
                                ),
                                suffixIcon: InkWell(
                                  highlightColor:
                                      Colors.transparent, // No highlight on tap
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    setState(() {
                                      _showConPassword = !_showConPassword!;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsetsDirectional.only(
                                        end: 10.0),
                                    child: Icon(
                                      !_showConPassword!
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .fontColor
                                          .withValues(alpha: 0.4),
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          BlocBuilder<AuthBloc, AuthState>(
                            builder: (context, state) {
                              if (state is AuthSignUpLoadSuccess) {
                                // Remove this navigation
                                // WidgetsBinding.instance.addPostFrameCallback((_) {
                                //   router.go('/login');
                                // });
                              }
                              if (state is AuthLoadInProgress) {}
                              if (state is AuthLoadFailure) {}
                              if (state is AuthInitial) {}
                              return InkWell(
                                highlightColor: Colors.transparent,
                                splashColor: Colors.transparent,
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  validateAndSubmit();
                                },
                                child: CustomButton(
                                  height: 50.h,
                                  isLoading: isLoading,
                                  isLogin: true,
                                  isBorder: true,
                                  text: AppLocalizations.of(context)!.signUp,
                                  textcolor: AppColors.pureWhiteColor,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: 370.w,
                            // color: colors.red,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CustomText(
                                  text: AppLocalizations.of(context)!
                                      .alreadyhaveanaccount,
                                  size: 16.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.greyForgetColor,
                                ),
                                InkWell(
                                  highlightColor:
                                      Colors.transparent, // No highlight on tap
                                  splashColor: Colors.transparent,
                                  onTap: () {
                                    router.go('/login');
                                    // validateAndSubmit();
                                    // Navigator.of(context).pushReplacement(
                                    //     MaterialPageRoute(
                                    //         builder: (context) => LoginScreen()));
                                  },
                                  child: CustomText(
                                    text: AppLocalizations.of(context)!.signIn,
                                    size: 16.sp,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              )));
    });
  }
}

Widget signUpText(context) {
  return SizedBox(
    // color: colors.red,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          text: AppLocalizations.of(context)!.createNewAccount,
          fontWeight: FontWeight.w700,
          size: 25.sp,
          color: AppColors.primary,
        ),
      ],
    ),
  );
}
