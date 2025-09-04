import 'dart:async';
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:taskify/bloc/setting/settings_state.dart';
import 'package:taskify/bloc/setting/settings_bloc.dart';
import 'package:taskify/config/app_images.dart';
import 'package:taskify/data/localStorage/hive.dart';
import '../../bloc/languages/language_switcher_bloc.dart';
import '../../bloc/permissions/permissions_state.dart';
import '../../bloc/permissions/permissions_bloc.dart';
import '../../bloc/permissions/permissions_event.dart';
import '../../bloc/setting/settings_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../config/colors.dart';
import '../../config/strings.dart';
import '../../data/GlobalVariable/globalvariable.dart';
import '../../data/repositories/Auth/auth_repo.dart';
import '../../routes/routes.dart';
import '../../utils/widgets/toast_widget.dart';

class StreamSubscriptionManager {
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _permissionsSubscription;

  void dispose() {
    _settingsSubscription?.cancel();
    _permissionsSubscription?.cancel();
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.navigateAfterSeconds,
    required this.imageUrl,
    this.title,
  });

  final int navigateAfterSeconds;
  final String imageUrl;
  final String? title;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  String? fromDate;
  String? toDate;
  bool? isFirstTimeUser;
  String? fcmToken;

  final _subscriptionManager = StreamSubscriptionManager();

  @override
  void initState() {
    super.initState();

    // Start navigation logic after the specified delay
    Future.delayed(Duration(seconds: widget.navigateAfterSeconds), () {
      _initializeAsync();
    });

    // Handle Firebase initial message
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        try {
          context.read<PermissionsBloc>().add(GetPermissions());
          final payload = {
            'type': message.data['type'],
            'item': jsonDecode(message.data['item']),
          };
          final Map<String, dynamic> data = payload['item'];
          final String type = data['type'];
          if (type == 'project') {
            final Map<String, dynamic> item = data['item'];
            final int id = item['id'];
            router.push('/projectdetails', extra: {'id': id, 'fromNoti': true});
          } else if (type == 'task') {
            final Map<String, dynamic> item = data['item'];
            router.push(
              '/taskdetail',
              extra: {
                'fromNoti': true,
                'id': item['id'],
              },
            );
          } else if (type == 'meeting') {
            router.push('/meetings', extra: {'fromNoti': true});
          } else if (type == 'leave_request') {
            router.push('/leaverequest', extra: {'fromNoti': true});
          } else if (type == 'workspace') {
            router.push('/workspaces', extra: {'fromNoti': true});
          }
        } catch (e) {
          debugPrint('[Debug] Error handling Firebase message: $e');
          _initializeAsync(); // Fallback to default navigation
        }
      }
    }).catchError((error) {
      debugPrint('[Debug] Error getting Firebase initial message: $error');
      _initializeAsync(); // Ensure navigation proceeds even if Firebase fails
    });

    _getFirstTimeUser();
    _getLanguage();
    _getFCMToken();
  }

  void _getFCMToken() async {
    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      if (token != null) {
        setState(() {
          fcmToken = token;
        });
        AuthRepository().getFcmId(fcmId: token); // Handle errors in AuthRepository
        HiveStorage.setFcm(token);
      } else {
        debugPrint('[Debug] FCM token is null');
      }
    } catch (e) {
      debugPrint('[Debug] Error in _getFCMToken: $e');
    }
  }

  Future<void> _getLanguage() async {
    try {
      await LanguageBloc.initLanguage();
    } catch (e) {
      debugPrint('[Debug] Error initializing language: $e');
    }
  }

  Future<void> _getFirstTimeUser() async {
    try {
      var box = await Hive.openBox(authBox);
      setState(() {
        isFirstTimeUser = box.get(firstTimeUserKey) ?? true;
      });
      debugPrint('[Debug] isFirstTimeUser: $isFirstTimeUser');
    } catch (e) {
      debugPrint('[Debug] Error getting first-time user: $e');
    }
  }

  Future<void> _initializeAsync() async {
    try {
      if (!mounted) {
        debugPrint('[Debug] Widget not mounted, aborting navigation');
        return;
      }

      final token = await HiveStorage.isToken();
      debugPrint('[Debug] Token exists: $token');

      if (token == false && isFirstTimeUser == true) {
        debugPrint('[Debug] Navigating to onboarding');
        router.go('/onboarding');
        return;
      }

      if (token == false && isFirstTimeUser == false) {
        debugPrint('[Debug] Navigating to login');
        router.go('/login');
        return;
      }

      if (token == true) {
        debugPrint('[Debug] Navigating to dashboard');
        router.go('/dashboard');
        return;
      }
    } catch (e) {
      debugPrint('[Debug] Initialization error: $e');
      router.go('/login'); // Fallback to login on error
    }
  }

  @override
  void dispose() {
    _subscriptionManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.primary,
            image: DecorationImage(
              image: AssetImage(AppImages.splashLogoGif),
            ),
          ),
        ),
      ),
    );
  }
}