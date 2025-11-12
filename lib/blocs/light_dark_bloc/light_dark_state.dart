part of 'light_dark_bloc.dart';

abstract class LightDarkState {}

class LightDarkInitial extends LightDarkState {}

class DarkMode extends LightDarkState {}

class LightMode extends LightDarkState {}

class SystemMode extends LightDarkState {}
