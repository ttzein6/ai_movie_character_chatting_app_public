import 'package:ai_char_chat_app/models/movies_series.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'movies_series_list_event.dart';
part 'movies_series_list_state.dart';

class MoviesSeriesListBloc
    extends Bloc<MoviesSeriesListEvent, MoviesSeriesListState> {
  MoviesSeriesListBloc() : super(MoviesSeriesListInitial()) {
    on<GetListOfMoviesSeries>((event, emit) {
      emit(MoviesSeriesLoading());
      Future.delayed(const Duration(seconds: 1)).then((value) {
        List<MoviesSeries> moviesSeries = [];
        emit(MoviesSeriesLoaded(moviesSeries: moviesSeries));
      });
    });
  }
}
