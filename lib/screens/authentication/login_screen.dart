

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:taskify/bloc/auth/auth_state.dart';
import 'package:taskify/config/constants.dart';
import 'package:taskify/utils/widgets/custom_text.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/setting/settings_bloc.dart';
import '../../bloc/setting/settings_event.dart';
import '../../bloc/setting/settings_state.dart';
import '../../config/app_images.dart';
import '../../config/colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/end_points.dart';
import '../../config/strings.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/Auth/auth_repo.dart';
import '../../routes/routes.dart';

import '../../config/internet_connectivity.dart';
import '../../utils/widgets/no_internet_screen.dart';
import '../widgets/custom_button.dart';
import '../widgets/validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  List<ConnectivityResult> _connectionStatus = [ConnectivityResult.none];
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;

  ConnectivityResult connectivityCheck = ConnectivityResult.none;
  TextEditingController passwordController = TextEditingController();
  bool? _showPassword = true;
  bool? isAdmin = false;
  bool? isMember = false;
  bool? isClient = false;
  FocusNode? emailFocus, passFocus = FocusNode();
  String? fcmToken;

  bool validateAndSave() {
    final form = _formKey.currentState!;
    form.save();
    if (form.validate()) {
      return true;
    }
    return false;
  }

void _getFCMToken() async {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  String? token = await messaging.getToken();

  print("FCM Token: $token"); // 👈 Print it in debug console

  setState(() {
    fcmToken = token;
  });

  await HiveStorage.setFcm(token!);
  AuthRepository().getFcmId(fcmId: token);
}


  void validateAndSubmit() async {

// if(isDemo){
//   if(isAdmin == true){
//     context.read<AuthBloc>().add(GetEmail(email: "admin@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password:"123456"));
//   }else if(isClient == true){
//     context.read<AuthBloc>().add(GetEmail(email: "client@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password: "123456"));
//   }else if(isMember == true){
//     context.read<AuthBloc>().add(GetEmail(email: "member@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password: "123456"));
//   }
// }else{
//   if(isAdmin == true){

//     context.read<AuthBloc>().add(GetEmail(email: "admin@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password:"12345678"));
//   }else if(isClient == true){
//     context.read<AuthBloc>().add(GetEmail(email: "infinitie.parasgiri@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password: "12345678"));
//   }else if(isMember == true){
//     context.read<AuthBloc>().add(GetEmail(email: "infinitietechnologies09@gmail.com"));
//     context.read<AuthBloc>().add(GetPassword(password: "12345678"));
//   }
// }
    if (emailController.text.isNotEmpty &&
        emailController.text != "" &&
        passwordController.text != "" &&
        passwordController.text.isNotEmpty) {
      BlocProvider.of<AuthBloc>(context).add(AuthSignIn());
      context.read<AuthBloc>().stream.listen((event) {

        if (event is AuthLoadSuccess) {
          if (mounted) {
            flutterToastCustom(
                msg: AppLocalizations.of(context)!.successfullyloggedIn,
                color: AppColors.primary);
            context.read<SettingsBloc>().add(const SettingsList("general_settings"));
            context.read<PermissionsBloc>().add(GetPermissions());
            final setting = context.read<SettingsBloc>();
            setting.stream.listen((state) {
              if (state is SettingsSuccess) {
                if (mounted) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    router.go('/dashboard');

                  });
                }
              }
              if (state is SettingsError) {
                router.go("/emailVerification");
                flutterToastCustom(msg: state.errorMessage);
              }
            });
          }
        }
        if (event is AuthLoadFailure) {
          flutterToastCustom(msg: event.message, color: AppColors.red);
        }
      });
    } else {
      if (emailController.text.isEmpty ||
          emailController.text != "" && passwordController.text.isEmpty ||
          passwordController.text.isEmpty ||
          passwordController.text != "") {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.emailpassreq,
        );
      } else if (emailController.text.isEmpty || emailController.text != "") {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.emailreq,
        );
      } else if (passwordController.text.isEmpty ||
          passwordController.text != "") {
        flutterToastCustom(
          msg: AppLocalizations.of(context)!.pasreq,
        );
      }
    }
  }

  Future<void> _launchUrl(url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  _fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode? nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

//
  @override
  void initState() {
    CheckInternet.initConnectivity().then((List<ConnectivityResult> results) {
      if (results.isNotEmpty) {
        setState(() {
          _connectionStatus = results;
        });
      }else{
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.nointernet,
            color: AppColors.red);
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
      }else{
        flutterToastCustom(
            msg: AppLocalizations.of(context)!.nointernet,
            color: AppColors.red);
      }
    });
    _getFCMToken();
    // _getFCMToken();
    HiveStorage.setIsFirstTime(false);
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _connectivitySubscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return _connectionStatus.contains(connectivityCheck)
        ? NoInternetScreen()
        : Scaffold(
            backgroundColor: Theme.of(context).colorScheme.backGroundColor,
            body: SingleChildScrollView(
                child: SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              // color: Colors.purple.shade100,
              child: Stack(
                children: [
                  backgroundImage(),
                  logoImage(),
                  Positioned(
                    top: 260.h,
                    left: 20.w,
                    right: 20.w,
                    bottom: 0,
                    child: Form(
                      key: _formKey,
                      child: AutofillGroup(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            loginText(context),
                            SizedBox(
                              height: 40.h,
                            ),
                            SizedBox(
                              height: 50.h,
                              width: 370.w,
                              // decoration: DesignConfiguration.shadow(),
                              child: TextFormField(
                                autofillHints: [AutofillHints.email],
                                style: TextStyle(fontSize: 14.sp),
                                cursorColor: AppColors.greyForgetColor,
                                cursorWidth: 1.w,
                                // enableInteractiveSelection: false,
                                controller: emailController,
                                keyboardType: TextInputType.text,

                                onSaved: (String? value) {
                                  context
                                      .read<AuthBloc>()
                                      .add(GetEmail(email: value!));
                                },
                                onChanged: (val) {
                                  context
                                      .read<AuthBloc>()
                                      .add(GetEmail(email: val));
                                },
                                // focusNode: emailFocus,
                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.email,
                                  labelStyle: TextStyle(
                                      // fontFamily: fontFamily,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13.sp),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                              .shade600) // No border when focused
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                              .shade600) // Normal border color
                                      ),
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(height: 30.h),
                            SizedBox(
                              height: 50.h,
                              width: 370.w,
                              child: TextFormField(
                                autofillHints: [AutofillHints.password],
                                style: TextStyle(fontSize: 14.sp),
                                controller: passwordController,
                                obscureText: _showPassword!,
                                cursorColor: AppColors.greyForgetColor,
                                cursorWidth: 1.w,
                                // enableInteractiveSelection: false,
                                keyboardType: TextInputType.text,
                                onFieldSubmitted: (v) {
                                  _fieldFocusChange(
                                    context,
                                    emailFocus!,
                                    passFocus,
                                  );
                                },
                                inputFormatters: [
                                  FilteringTextInputFormatter.deny(
                                      RegExp('[ ]')),
                                ],
                                focusNode: passFocus,
                                validator: (value) =>
                                    StringValidation.validatePass(value!,
                                        "required", "Please enter valid email",
                                        onlyRequired: false),
                                onChanged: (val) {
                                  context
                                      .read<AuthBloc>()
                                      .add(GetPassword(password: val));
                                },
                                onSaved: (String? value) {
                                  passwordController.text = value!;
                                  context
                                      .read<AuthBloc>()
                                      .add(GetPassword(password: value));
                                },

                                decoration: InputDecoration(
                                  labelText:
                                      AppLocalizations.of(context)!.password,
                                  labelStyle: TextStyle(
                                      // fontFamily: fontFamily,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .textFieldColor,
                                      fontSize: 13.sp),
                                  focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                              .shade600) // No border when focused
                                      ),
                                  enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                      borderSide: BorderSide(
                                          color: Colors.grey
                                              .shade600) // Normal border color
                                      ),
                                  border: OutlineInputBorder(),
                                  suffixIcon: InkWell(
                                    onTap: () {
                                      setState(() {
                                        _showPassword = !_showPassword!;
                                      });
                                    },
                                    child: Padding(
                                      padding:
                                          EdgeInsetsDirectional.only(end: 10.h),
                                      child: Icon(
                                        !_showPassword!
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .fontColor
                                            .withValues(alpha: 0.4),
                                        size: 22.sp,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10.h),
                            forgetPassword(),
                            SizedBox(height: 40.h),
                           loginButton(),
                            SizedBox(height: 20.h),
                          loginWithDemoButton(),
                          SizedBox(height: 10.h),
                            dontHaveAccount()
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            )),
          );
  }

  Widget forgetPassword() {
    return InkWell(
      splashColor: Colors.transparent,
      onTap: () {
        _launchUrl(
          Uri.parse(forgetPasswordUrl),
        );
        // ForgetPassword();
      },
      child: SizedBox(
        width: 370.w,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CustomText(
              text: AppLocalizations.of(context)!.forgetPassword,
              size: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.greyForgetColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget dontHaveAccount() {
    return SizedBox(
      // width: 370,
      // color: colors.red,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CustomText(
            text: AppLocalizations.of(context)!.dontHaveanAccount,
            size: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.greyForgetColor,
          ),
          InkWell(
            splashColor: Colors.transparent,
            onTap: () {
              router.push("/signup");
            },
            child: CustomText(
              text: AppLocalizations.of(context)!.signUp,
              size: 16.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget loginButton() {
    return InkWell(
      onTap: () {
        FocusScope.of(context).unfocus();
        validateAndSubmit();
      },
      child: CustomButton(
        height: 50.h,
         isLoading: false,
           isLogin:true,
        isBorder:true,
        text: AppLocalizations.of(context)!.login,
        textcolor: AppColors.pureWhiteColor,
      ),
    );
  }

  
  Widget loginWithDemoButton() {
    return Row(
      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              isAdmin = true;
              if(isDemo ){
                emailController.text = "admin@gmail.com";
                passwordController.text = "123456";
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "admin@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "123456"));
              }else{
                emailController.text = "admin@gmail.com";
                passwordController.text = "12345678";
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "admin@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "12345678"));
              }

            });
          },
          child: CustomButton(
            textcolor: Color(0xfff5a525),
            height: 35.h,
            width: 100.w,
            isLoading: false,
            isLogin: false,
            isBorder:false,
            text: AppLocalizations.of(context)!.admin,

          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,

          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              isMember= true;
              if(isDemo ){
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "member@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "123456"));
                emailController.text = "member@gmail.com";
                passwordController.text = "123456";
              }else{
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "infinitietechnologies09@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "12345678"));
                emailController.text = "infinitietechnologies09@gmail.com";
                passwordController.text = "12345678";
              }
            });
          },
          child: CustomButton(
            textcolor: Color(0xfff32660),
            width: 100.w,
            height: 35.h,
            isLoading: false,
            isLogin: false,
    isBorder: false,
            text: AppLocalizations.of(context)!.member,
          ),
        ),
        InkWell(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () {
            FocusScope.of(context).unfocus();
            setState(() {
              isClient = true;
              if(isDemo ){
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "client@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "123456"));
                emailController.text = "client@gmail.com";
                passwordController.text = "123456";
              }else{
                context
                    .read<AuthBloc>()
                    .add(GetEmail(email: "infinitie.parasgiri@gmail.com"));
                context
                    .read<AuthBloc>()
                    .add(GetPassword(password: "12345678"));
                emailController.text = "infinitie.parasgiri@gmail.com";
                passwordController.text = "12345678";
              }
            });

          },
          child: CustomButton(
            textcolor: Color(0xff36BA98),
            width: 100.w,
            height: 35.h,
            isBorder: false,
            isLoading: false,
            isLogin: false,
            text: AppLocalizations.of(context)!.client,

          ),
        )
      ],
    );
  }

  Widget backgroundImage() {
    return Positioned(
      top: 0,
      bottom: 550.h,
      right: 0,
      left: 0,
      child: Container(
          height: 400.h,
          width: 500.w,
          decoration: BoxDecoration(
            // color: Colors.red,
            image: DecorationImage(
                image: AssetImage(AppImages.loginBackgroundImage),
                fit: BoxFit.fill),
          )),
    );
  }

  Widget logoImage() {
    return Positioned(
      top: 70,
      // bottom: 550.h,
      right: 30,
      left: 30,
      child: Container(
          height: 70.h,
          width: 150.w,
          decoration: BoxDecoration(
            // color: Colors.red,
            image: DecorationImage(
                image: AssetImage(AppImages.splashLogo), fit: BoxFit.fill),
          )),
    );
  }

  Widget loginText(context) {
    return SizedBox(
      // color: colors.red,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              height: 100.h,
              width: 290.w,
              // color: Colors.cyan,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CustomText(
                        text: AppLocalizations.of(context)!.welcomeBack,
                        fontWeight: FontWeight.w700,
                        size: 30.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                      SizedBox(
                        width: 5.w,
                      ),
                      CustomText(
                        text: AppLocalizations.of(context)!.to,
                        fontWeight: FontWeight.w700,
                        size: 30.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      CustomText(
                        text: appName,
                        fontWeight: FontWeight.w700,
                        size: 30.sp,
                        color: Theme.of(context).colorScheme.textClrChange,
                      ),
                    ],
                  ),
                ],
              )),
          SizedBox(
            height: 20.h,
          ),
          CustomText(
            text: AppLocalizations.of(context)!.logInToYourAccount,
            fontWeight: FontWeight.w600,
            size: 14.sp,
            color: AppColors.greyForgetColor,
          ),
        ],
      ),
    );
  }
}
