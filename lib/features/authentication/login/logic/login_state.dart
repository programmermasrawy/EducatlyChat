part of 'login_cubit.dart';

class InitialFirebaseState extends LoginState {}

class LoginState extends Equatable {
  final bool loading;
  final bool otpVisibility;

  final int? statusCode;
  final String? message;

  final bool? networkIssue;

  const LoginState({
    this.loading = false,
    this.otpVisibility = false,
    this.statusCode,
    this.message,
    this.networkIssue = false,
  });

  LoginState requestSuccess({required String message, required int statusCode}) => copyWith(
        loading: false,
        statusCode: statusCode,
        message: message,
        networkIssue: false,
      );

  LoginState requestFailed() => copyWith(
        loading: false,
        networkIssue: false,
      );

  networkFailure() {
    return copyWith(networkIssue: true, loading: false);
  }

  LoginState requestLoading() => copyWith(
        loading: true,
        failure: null,
        networkIssue: false,
      );

  LoginState requestOtpInput({String? verificationID}) => copyWith(
        otpVisibility: true,
        loading: false,
        failure: null,
        networkIssue: false,
      );

  LoginState copyWith({
    dynamic failure,
    bool? loading,
    networkIssue,
    bool? otpVisibility,
    int? statusCode,
    String? message,
    String? verificationID,
  }) {
    return LoginState(
      loading: loading ?? this.loading,
      networkIssue: networkIssue ?? this.networkIssue,
      otpVisibility: otpVisibility ?? this.otpVisibility,
      statusCode: statusCode ?? 0,
      message: message ?? '',
    );
  }

  @override
  List<Object?> get props => [
        loading,
        statusCode,
        message,
        otpVisibility,
        networkIssue,
      ];

  @override
  bool get stringify => true;
}
