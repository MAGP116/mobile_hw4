part of 'lista_bloc.dart';

abstract class ListaEvent extends Equatable {
  const ListaEvent();

  @override
  List<Object> get props => [];
}

class LoadListaEvent extends ListaEvent {}
