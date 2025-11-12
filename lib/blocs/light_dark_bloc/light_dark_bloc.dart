import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'light_dark_event.dart';
part 'light_dark_state.dart';

class LightDarkBloc extends HydratedBloc<LightDarkEvent, LightDarkState> {
  LightDarkBloc() : super(DarkMode()) {
    on<SetLightMode>((event, emit) {
      emit(LightMode());
    });
    on<SetDarkMode>((event, emit) {
      emit(DarkMode());
    });
    on<SetSystemMode>((event, emit) {
      emit(SystemMode());
    });
  }

  @override
  LightDarkState? fromJson(Map<String, dynamic> json) {
    switch (json["state"]) {
      case "SystemMode":
        return SystemMode();
      case "DarkMode":
        return DarkMode();
      case "LightMode":
        return LightMode();
      default:
        return DarkMode();
    }
  }

  @override
  Map<String, dynamic>? toJson(LightDarkState state) {
    return {
      "state": state.runtimeType.toString(),
    };
  }
}
