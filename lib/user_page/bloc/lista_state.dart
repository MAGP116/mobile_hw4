part of 'lista_bloc.dart';

abstract class ListaState extends Equatable {
  const ListaState();

  @override
  List<Object> get props => [];
}

class ListaInitial extends ListaState {}

class ListaLoadingState extends ListaState {}

class ListaShowListState extends ListaState {
  dynamic res;

  ListaShowListState({required this.res});

  @override
  List<Object> get props => [res];
}

class ListaErrorState extends ListaState {
  dynamic errorCode;

  ListaErrorState({required this.errorCode});

  @override
  List<Object> get props => [errorCode];
}
