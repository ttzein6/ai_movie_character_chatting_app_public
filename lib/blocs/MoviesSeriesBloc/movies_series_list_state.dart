part of 'movies_series_list_bloc.dart';

abstract class MoviesSeriesListState {}

class MoviesSeriesListInitial extends MoviesSeriesListState {}

class MoviesSeriesLoading extends MoviesSeriesListState {}

class MoviesSeriesLoaded extends MoviesSeriesListState {
  List<MoviesSeries> moviesSeries;
  MoviesSeriesLoaded({required this.moviesSeries});
}
