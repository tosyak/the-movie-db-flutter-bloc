
import 'package:the_movie_db/domain/api_client/account_api_client.dart';
import 'package:the_movie_db/domain/api_client/auth_api_client.dart';
import 'package:the_movie_db/domain/data_providers/session_data_provider.dart';

// abstract class AuthEvent {}

// class AuthCheckStatusEvent extends AuthEvent {}

// class AuthLogoutEvent extends AuthEvent {}

// class AuthLoginEvent extends AuthEvent {
//   final String login;
//   final String password;
//   AuthLoginEvent({
//     required this.login,
//     required this.password,
//   });
// }

// enum AuthStateStatus { authorized, notAuthorized, inProgress }

// abstract class AuthState {}

// class AuthAuthorizedState extends AuthState {}

// class AuthUnauthorizedState extends AuthState {}

// class AuthFailureState extends AuthState {
//   final Object error;
//   AuthFailureState({
//     required this.error,
//   });
// }

// class AuthInProgressState extends AuthState {}

// class AuthBloc extends Bloc<AuthEvent, AuthState> {
//   final _authApiClient = AuthApiClient();
//   final _sessionDataProvider = SessionDataProvider();
//   final _accountApiClient = AccountApiClient();

//   AuthBloc(AuthState initialState) : super(initialState) {
//     on<AuthEvent>((event, emit) async {
//       if (event is AuthCheckStatusEvent) {
//         onAuthCheckStatusEvent(event, emit);
//       } else if (event is AuthLoginEvent) {
//         onAuthLoginEvent(event, emit);
//       } else if (event is AuthLogoutEvent) {
//         onAuthLogoutEvent(event, emit);
//       }
//     }, transformer: sequential());
//     add(AuthCheckStatusEvent());
//   }

//   void onAuthCheckStatusEvent(
//     AuthCheckStatusEvent event,
//     Emitter<AuthState> emit,
//   ) async {
//     final sessionId = await _sessionDataProvider.getSessionId();
//     final newState =
//         sessionId != null ? AuthAuthorizedState() : AuthUnauthorizedState();
//     emit(newState);
//   }

//   void onAuthLoginEvent(
//     AuthLoginEvent event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       final sessionId = await _authApiClient.auth(
//         username: event.login,
//         password: event.password,
//       );
//       final accountId = await _accountApiClient.getAccountInfo(sessionId);
//       await _sessionDataProvider.setSessionId(sessionId);
//       await _sessionDataProvider.setAccountId(accountId);
//       emit(AuthAuthorizedState());
//     } catch (e) {
//       emit(AuthFailureState(error: e));
//     }
//   }

//   void onAuthLogoutEvent(
//     AuthLogoutEvent event,
//     Emitter<AuthState> emit,
//   ) async {
//     try {
//       await _sessionDataProvider.deleteSessionId();
//       await _sessionDataProvider.deleteAccountId();
//       // emit(AuthUnauthorizedState());
//     } catch (e) {
//       emit(AuthFailureState(error: e));
//     }
//   }
//   // void onAuthCheckStatusEvent(
//   //     AuthCheckStatusEvent event, Emitter<AuthState> emit) async {}
// }

class AuthService {
  final _authApiClient = AuthApiClient();
  final _sessionDataProvider = SessionDataProvider();
  final _accountApiClient = AccountApiClient();

  Future<bool> isAuth() async {
    final sessionId = await _sessionDataProvider.getSessionId();
    final isAuth = sessionId != null;
    return isAuth;
  }

  Future<void> login(String login, String password) async {
    final sessionId = await _authApiClient.auth(
      username: login,
      password: password,
    );
    final accountId = await _accountApiClient.getAccountInfo(sessionId);

    await _sessionDataProvider.setSessionId(sessionId);
    await _sessionDataProvider.setAccountId(accountId);
  }

  Future<void> logout() async {
    await _sessionDataProvider.deleteSessionId();
    await _sessionDataProvider.deleteAccountId();
  }
}
