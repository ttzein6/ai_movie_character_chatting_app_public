part of 'light_dark_bloc.dart';

abstract class LightDarkEvent {}

class SetDarkMode extends LightDarkEvent {}

class SetLightMode extends LightDarkEvent {}

class SetSystemMode extends LightDarkEvent {}
