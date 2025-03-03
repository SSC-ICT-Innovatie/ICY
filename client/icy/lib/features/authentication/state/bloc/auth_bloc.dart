import 'package:flutter/widgets.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:icy/features/authentication/models/user.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends HydratedBloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthLogin>((event, emit) {
      emit(AuthLoading());
      emit(AuthSuccess(user: event.user));
    });

    on<SignUp>((event, emit) {
      emit(AuthLoading());
      emit(AuthSuccess(user: event.user));
    });

    on<Logout>((event, emit) {
      emit(AuthLoading());
      emit(AuthInitial());
    });
  }

  @override
  AuthState? fromJson(Map<String, dynamic> json) {
    print("JSON from STORAGE:::::::::$json");
    return AuthSuccess.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(AuthState state) {
    return state is AuthSuccess ? state.toJson() : null;
  }
}
