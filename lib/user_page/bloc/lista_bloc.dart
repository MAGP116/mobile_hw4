import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:http/http.dart' as http;

part 'lista_event.dart';
part 'lista_state.dart';

String _urlDir =
    'https://api.sheety.co/d55b035556b0ebbc21ca9d10cdc1a32e/dummyApi/cuentas';

class ListaBloc extends Bloc<ListaEvent, ListaState> {
  ListaBloc() : super(ListaInitial()) {
    on<ListaEvent>(_onLoadList);
  }
  void _onLoadList(ListaEvent event, Emitter emit) async {
    emit(ListaLoadingState());
    var url = Uri.parse(_urlDir);
    var res = await http.get(url);
    print("Aqui");
    if (res.statusCode != 200) {
      emit(ListaErrorState(errorCode: res.statusCode));
      return;
    }
    emit(ListaShowListState(res: jsonDecode(res.body)));
  }
}
