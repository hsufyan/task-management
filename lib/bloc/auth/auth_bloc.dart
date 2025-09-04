
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taskify/utils/widgets/toast_widget.dart';
import '../../data/localStorage/hive.dart';
import '../../data/repositories/Auth/auth_repo.dart';
import '../../routes/routes.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  String email = "";
  String password = "";
  String conPassword = "";
  String workspaceTitleUpdated = "";

  String? custom;
  String? guard;
  String? role;

  bool? hasAllDataAccess;
  int? userId;
  int? workspaceIdd;
  bool? isLeaveEditor;
  AuthBloc() : super(AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthSignUp>(_onSignUp);
    on<WorkspaceUpdate>(_onWorkspaceChange);
    on<AuthSignIn>(_onSignIn);
    on<LoggedOut>(_onLoggedOut);
    on<AuthProgress>(_onAuthProgress);
    on<GetEmail>(_onGetEmail);
    on<GetPassword>(_onGetPassword);
  }

  void _onAuthProgress(AuthProgress event, Emitter<AuthState> emit) async {
    emit(AuthLoadInProgress());
  }

  void _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(AuthLoadInProgress());
  }

  void _onWorkspaceChange(
      WorkspaceUpdate event, Emitter<AuthState> emit) async {
    workspaceTitleUpdated = event.workspaceTitle!;

    emit(WorkspaceUpdated(workspace: workspaceTitleUpdated));
  }
  void _onGetPassword(GetPassword event, Emitter<AuthState> emit) async {

    password = event.password;
  }
  void _onSignUp(AuthSignUp event, Emitter<AuthState> emit) async {
    try {
      var result = await AuthRepository().signUp(
          email: event.email!,
          password: event.password!,
          firstname: event.firstname!,
          lastname: event.lastname!,
          company: event.company!,
          role: '2',
          conpassword: event.confirmPass!,
          type: event.type!);
      if (result['error'] == false) {
        emit(AuthSignUpLoadSuccess(user: result));
      } else if (result['error'] == true) {
        emit(AuthSignUpLoadFailure(message: ' ${result['message']}'));
        flutterToastCustom(msg: result['message']);
      }
    } catch (e) {
      emit(AuthSignUpLoadFailure(message: e.toString()));
      flutterToastCustom(msg: e.toString());
    }
  }

  void _onSignIn(AuthSignIn event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoadSuccessLoading());

      var result = await AuthRepository().signIn(
        email: email,
        password: password,
      );
      if (result['error'] == false) {
        workspaceIdd = result['data']["workspace_id"];
        workspaceTitleUpdated = result['data']["workspace_title"];
        userId = result['data']['user_id'];
        role = result['data']['role'];
        custom = result['token'];
        guard = result['data']['guard'];
        hasAllDataAccess = result['data']['is_admin_or_has_all_data_access'];
        isLeaveEditor = result['data']['is_leave_editor'];


        HiveStorage.setWorkspaceId(workspaceIdd!);
        HiveStorage.setUserId(userId!);
        HiveStorage.setWorkspaceTitle(workspaceTitleUpdated);
        HiveStorage.setHasAllDataAccess(hasAllDataAccess!);
        HiveStorage.setRole(role!);
        HiveStorage.getAllDataAccess();
        HiveStorage.getRole();
        HiveStorage.putToken(custom!);
        WorkspaceUpdate(workspaceTitle: workspaceTitleUpdated);

        emit(AuthLoadSuccess(user: result));
      } else if (result['error'] == true) {
        emit(AuthLoadFailure(message: ' ${result['message']}'));
      }
    } catch (e) {
      emit(AuthLoadFailure(message: " Error ${e.toString()}"));
    }
  }

  void _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await AuthRepository.signOut().then((value) {
      router.go('/login');
    });
    emit(AuthInitial());
    event.onLoggedOutCompleted.call();
  }

  void _onGetEmail(GetEmail event, Emitter<AuthState> emit) async {
    email = event.email;
  }

}
