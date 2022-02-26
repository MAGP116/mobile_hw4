import 'dart:io';
import 'dart:typed_data';

import 'package:feature_discovery/feature_discovery.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:money_track/user_page/bloc/lista_bloc.dart';
import 'package:money_track/user_page/bloc/picture_bloc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';
import 'package:path_provider/path_provider.dart';

import 'circular_button.dart';
import 'cuenta_item.dart';

class Profile extends StatefulWidget {
  Profile({Key? key}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

ScreenshotController _screenshotController = ScreenshotController();

class _ProfileState extends State<Profile> {
  Future _captureAndShare() async {
    Uint8List? image = await _screenshotController.capture();
    if (image != null) {
      final directory = await getApplicationDocumentsDirectory();
      final imagePath = await File('${directory.path}/image.png').create();
      await imagePath.writeAsBytes(image);

      /// Share Plugin
      await Share.shareFiles([imagePath.path]);
    }
  }

  @override
  void initState() {
    super.initState();
    BlocProvider.of<ListaBloc>(context).add(
      LoadListaEvent(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Screenshot(
      controller: _screenshotController,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            DescribedFeatureOverlay(
              featureId: 'compartir_pantalla_id',
              tapTarget: Icon(Icons.share),
              title: Text("Compartir pantalla"),
              description:
                  Text('Realiza una captura de pantalla y permite compartirla'),
              child: IconButton(
                tooltip: "Compartir pantalla",
                onPressed: () async {
                  await _captureAndShare();
                },
                icon: Icon(Icons.share),
              ),
            ),
          ],
        ),
        body: Padding(
          padding: EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //Se crea un consumidor que usa bloc y estado de picture
                BlocConsumer<PictureBloc, PictureState>(
                  //Consumidor, no debe retornar contenido
                  listener: (context, state) {
                    if (state is PictureErrorState) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                            SnackBar(content: Text("${state.errorMsg}")));
                    }
                  },
                  //Consumidor que regresa contenido
                  builder: (context, state) {
                    if (state is PictureSelectedState) {
                      return CircleAvatar(
                        backgroundImage: FileImage(state.picture),
                        minRadius: 40,
                        maxRadius: 80,
                      );
                    }
                    return CircleAvatar(
                      backgroundImage: NetworkImage(
                        "https://www.nicepng.com/png/detail/413-4138963_unknown-person-unknown-person-png.png",
                      ),
                      minRadius: 40,
                      maxRadius: 80,
                    );
                  },
                ),
                SizedBox(height: 16),
                Text(
                  "Bienvenido",
                  style: Theme.of(context)
                      .textTheme
                      .headline4!
                      .copyWith(color: Colors.black),
                ),
                SizedBox(height: 8),
                Text("Usuario${UniqueKey()}"),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    DescribedFeatureOverlay(
                      featureId: 'ver_tarjeta_id',
                      tapTarget: Icon(Icons.credit_card),
                      title: Text("Ver tarjeta"),
                      description: Text('Boton para ver tarjetas'),
                      child: CircularButton(
                        textAction: "Ver tarjeta",
                        iconData: Icons.credit_card,
                        bgColor: Color(0xff123b5e),
                        action: null,
                      ),
                    ),
                    DescribedFeatureOverlay(
                      featureId: 'Cambiar_foto_id',
                      tapTarget: Icon(Icons.camera_alt),
                      title: Text("Cambiar foto"),
                      description: Text(
                          'Boton que toma foto con la \ncamara y la guarda como \nimagen de perfil'),
                      child: CircularButton(
                        textAction: "Cambiar foto",
                        iconData: Icons.camera_alt,
                        bgColor: Colors.orange,
                        action: () {
                          //Contenido para realizar evento
                          BlocProvider.of<PictureBloc>(context).add(
                            ChangeImageEvent(),
                          );
                        },
                      ),
                    ),
                    DescribedFeatureOverlay(
                      featureId: 'ver_turotial_id',
                      tapTarget: Icon(Icons.play_arrow),
                      title: Text("Ver tutorial"),
                      description: Text('Muetra el tutorial de los botones'),
                      child: CircularButton(
                        textAction: "Ver tutorial",
                        iconData: Icons.play_arrow,
                        bgColor: Colors.green,
                        action: () {
                          FeatureDiscovery.clearPreferences(context, <String>{
                            'ver_tarjeta_id',
                            'Cambiar_foto_id',
                            'ver_turotial_id',
                            'compartir_pantalla_id'
                          });
                          FeatureDiscovery.discoverFeatures(
                              context, const <String>{
                            'ver_tarjeta_id',
                            'Cambiar_foto_id',
                            'ver_turotial_id',
                            'compartir_pantalla_id'
                          });
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 48),
                BlocConsumer<ListaBloc, ListaState>(
                  listener: (context, state) {},
                  builder: (context, state) {
                    if (state is ListaLoadingState) {
                      return CircularProgressIndicator();
                    }
                    if (state is ListaErrorState)
                      return Text(
                          "No hay datos disponibles: ${state.errorCode}");
                    if (state is ListaShowListState) {
                      return SizedBox(
                        width: 300,
                        height: 300,
                        child: ListView(
                          children: state.res['cuentas']
                              .map<Widget>((item) => CuentaItem(
                                    saldoDisponible: '${item['dinero']}',
                                    tipoCuenta: '${item['cuenta']}',
                                    terminacion: '${item['tarjeta']}'.substring(
                                        '${item['tarjeta']}'.length - 4),
                                  ))
                              .toList(),
                        ),
                      );
                    }
                    return Text("Estado desconicido");
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
