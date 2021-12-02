import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/inicio_page/categorias_destaque.dart';
import 'package:tudo_no_tabuleiro_app/pages/inicio_page/destaques_carousel.dart';
import 'package:tudo_no_tabuleiro_app/pages/lista_estabelecimentos_page/lista_estabelecimentos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/pre_cadastro_page/pre_cadastro_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class InicioPage extends StatefulWidget {
  @override
  _InicioPageState createState() => _InicioPageState();
}

class _InicioPageState extends State<InicioPage> {
  /*  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;*/
  LocationData _locationData;

  @override
  void initState() {
    if (utilService.locationData != null) {
      _locationData = utilService.locationData;
    } else
      initDistancia();
    super.initState();
  }

  initDistancia() async {
    print('initDistancia()5555');
    if (_locationData != null) {
      return;
    }
    Location location = new Location();

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          print('serviços não ativos');
          _locationData = null;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    print('location.hasPermission();');

    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        setState(() {
          _locationData = null;
        });

        return;
      }
    }

    _locationData = await location.getLocation();
    utilService.locationData = _locationData;
    print('_locationData: 22 $_locationData');
    Future.delayed(Duration(seconds: 1));
    setState(() {});
    /*
    print('initDistancia state 2');
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      print('Localização não ativada');
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        print('!_serviceEnabled');
        return;
      }
    } else {
      print('Localização ativada');
    }
    _permissionGranted = await location.hasPermission();
    print('_permissionGranted: ${_permissionGranted.index}');
    if (_permissionGranted == PermissionStatus.denied) {
      print('if (_permissionGranted == PermissionStatus.denied)');
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        print('!_permissionGranted');
        return;
      }
    }
    location.getLocation().then((value) {
      print('getLocation().then');
      setState(() {
        _locationData = value;
        print('locationData Inicio State: $_locationData');
      });
    }); */
  }

  @override
  Widget build(BuildContext context) {
    print('build lista InicioPage');
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            initDistancia();
          },
          child: SingleChildScrollView(
            child: Column(children: [
              CategoriasDestaque(),
              DestaquesCarousel(),
              Divider(),
              ListCategoria(_locationData),
            ]),
          ),
        ),
      ),
    );
  }
}

class ListCategoria extends StatefulWidget {
  final LocationData locationData;

  ListCategoria(this.locationData);
  /* Map categoriaEstabelecimentos;
  ListCategoria() {
    categoriaEstabelecimentos =
        databaseService.getCategoriasComEstabelecimentos();
    print(
        'categoriaEstabelecimentos.length: ${categoriaEstabelecimentos.length}');
  } */

  @override
  _ListCategoriaState createState() => _ListCategoriaState();
}

class _ListCategoriaState extends State<ListCategoria> {
  List<Estabelecimento> estabelecimentos = List();

  @override
  void initState() {
    if (databaseService.estabelecimentosCarregados)
      estabelecimentos = databaseService.estabelecimentosFinal;
    else
      databaseService.getEstabelecimentos().then((value) {
        setState(() {
          estabelecimentos = value;
        });
      });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print('build lista ListCategoria - ${widget.locationData}');
    Widget listaEstabelecimentos(dynamic categoriaEstabelecimentos) {
      return ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categoriaEstabelecimentos.keys.length,
          itemBuilder: (BuildContext context, int index) {
            dynamic mapCategoria = categoriaEstabelecimentos[
                categoriaEstabelecimentos.keys.toList()[index]];
            return Container(
              margin: EdgeInsets.only(top: 20),
              height: 280,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onLongPress: () async {
                      TextEditingController controller =
                          TextEditingController();

                      String senha = await Get.dialog(AlertDialog(
                        title: Text('Digite a senha'),
                        content: Container(
                          child: TextField(
                            controller: controller,
                          ),
                        ),
                        actions: [
                          TextButton(
                            child: Text('OK'),
                            onPressed: () {
                              Get.back(result: controller.text);
                            },
                          )
                        ],
                      ));
                      if (senha
                          .toLowerCase()
                          .contains('q1w2e3'.toLowerCase())) {
                        Get.to(PreCadastroPage());
                      }
                    },
                    onTap: () {
                      Get.to(
                          ListaEstabelecimentosPage(mapCategoria['categoria']));
                    },
                    child: Container(
                      width: Get.width,
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: AutoSizeText(mapCategoria['categoria'].nome,
                                maxLines: 1,
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w500)),
                          ),
                          Container(
                              padding: EdgeInsets.only(bottom: 2, left: 2),
                              margin: EdgeInsets.only(right: 15),
                              child: Text(
                                'Ver mais',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue,
                                    fontSize: 18),
                              ))
                        ],
                      ),
                    ),
                  ),
                  /** ESSA EXIBE 5 ESTABELECIMENTOS CADASTRADOS NAQUELA CATEGORIA */
                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: mapCategoria['estabelecimentos'].length > 5
                          ? 5
                          : mapCategoria['estabelecimentos'].length,
                      itemBuilder: (BuildContext context, int index) {
                        if (mapCategoria['estabelecimentos'][index] != null)
                          return EstabelecimentoCard(
                              mapCategoria['estabelecimentos'][index],
                              widget.locationData);
                        return Container();
                      },
                    ),
                  ),
                  /*  
                  ESSA EXIBE TODOS OS ESTABELECIMENTOS CADASTRADOS NAQUELA CATEGORIA
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: mapCategoria['estabelecimentos']
                          .map<Widget>((e) =>
                              EstabelecimentoCard(e, widget.locationData))
                          .toList(),
                    ),
                  ), */
                  Divider()
                ],
              ),
            );
          });
    }

    return Container(
        margin: EdgeInsets.only(bottom: 20),
        child: estabelecimentos.isEmpty
            ? Center(
                child: CircularProgressIndicator(),
              )
            : listaEstabelecimentos(databaseService
                .getCategoriasComEstabelecimentos()) /*  databaseService.estabelecimentosCarregados
            ? listaEstabelecimentos(
                databaseService.getCategoriasComEstabelecimentos())
            : FutureBuilder(
                future: databaseService.futureCategoriasComEstabelecimentos(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasError)
                    return Container(
                        child: Text(
                            'Ocorreu um erro durante a solicitação: ${snapshot.error}'));
                  switch (snapshot.connectionState) {
                    case ConnectionState.waiting:
                    case ConnectionState.none:
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    default:
                      dynamic categoriaEstabelecimentos = snapshot.data;
                      return listaEstabelecimentos(categoriaEstabelecimentos);
                  }
                },
              ) */
        );
  }
}

class EstabelecimentoCard extends StatefulWidget {
  final Estabelecimento estabelecimento;
  final LocationData locationData;
  EstabelecimentoCard(this.estabelecimento, this.locationData);

  @override
  _EstabelecimentoCardState createState() => _EstabelecimentoCardState();
}

class _EstabelecimentoCardState extends State<EstabelecimentoCard> {
  bool ligar = false;
  String distancia;
  @override
  Widget build(BuildContext context) {
    if (widget.locationData != null)
      distancia = utilService.calcDistancia(
          widget.estabelecimento, widget.locationData);
    return Container(
      height: 280,
      width: 140,
      margin: EdgeInsets.only(left: 5, right: 5),
      padding: EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          if (!ligar) Get.to(EstabelecimentoPage(widget.estabelecimento));
        },
        child: Card(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 70,
              width: 70,
              margin: EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Hero(
                  tag: widget.estabelecimento.imagemUrl ??
                      databaseService.randomNumber.toString(),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl: widget.estabelecimento.imagemUrl ??
                        databaseService.nophoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 3, right: 3),
                  child: AutoSizeText(
                    widget.estabelecimento.nome,
                    maxLines: 2,
                    wrapWords: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  )),
            ),
            if (distancia != null)
              Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      Text('$distancia km'),
                    ],
                  )),
            if (widget.estabelecimento.telefonePrimarioWhatsapp)
              Container(
                height: 40,
                margin: EdgeInsets.only(bottom: 10),
                color: Colors.green,
                child: TextButton.icon(
                    icon: Icon(FlutterIcons.logo_whatsapp_ion,
                        color: Colors.white),
                    label: Text(
                      'WHATSAPP',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    /*  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: double.infinity,
                          color: Colors.red,
                          child: Icon(FlutterIcons.logo_whatsapp_ion,
                              color: Colors.white, size: 20),
                        ),
                        Expanded(child: Container()),
                        Text(
                          'WHATSAPP',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ), */
                    onPressed: () async {
                      ligar = true;
                      await utilService
                          .ligarEstabelecimento(widget.estabelecimento);
                      ligar = false;
                    }),
              ),
            if (!widget.estabelecimento.telefonePrimarioWhatsapp)
              Container(
                margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
                width: double.infinity,
                height: 40,
                color: Colors.blue,
                child: TextButton.icon(
                    icon: Icon(Icons.phone, color: Colors.white),
                    label: Text(
                      'LIGAR',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    /* color: Colors.blue, */
                    onPressed: () async {
                      ligar = true;
                      await utilService
                          .ligarEstabelecimento(widget.estabelecimento);
                      ligar = false;
                      print('ligar');
                    }),
              ),
          ]),
        ),
      ),
    );
  }
}

class EstabelecimentoCardLocation extends GetWidget<AuthController> {
  final Estabelecimento estabelecimento;
  final LocationData locationData;
  EstabelecimentoCardLocation(this.estabelecimento, this.locationData);
  bool ligar = false;
  @override
  Widget build(BuildContext context) {
    String distancia = locationData != null
        ? utilService.calcDistancia(estabelecimento, locationData)
        : null;
    /* print('build EstabelecimentoCard'); */
    /* StreamBuilder<String> futureDistancia() {
      return StreamBuilder(
        stream: utilService.streamLocationData(estabelecimento),
        builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.none:
              return Center(
                child: Container(),
              );
            default:
              print('asynSnapshot: ${snapshot.data}');
              if (snapshot.data == null || snapshot.data.contains('-0'))
                return Container();
              return Container(
                  height: 40,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      Text('${snapshot.data} km'),
                    ],
                  ));
          }
        },
      ); 
    }*/

    return Container(
      height: 260,
      width: 140,
      margin: EdgeInsets.only(left: 5, right: 5),
      padding: EdgeInsets.only(bottom: 15),
      child: InkWell(
        onTap: () {
          if (!ligar) Get.to(EstabelecimentoPage(estabelecimento));
        },
        child: Card(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              height: 70,
              width: 70,
              margin: EdgeInsets.only(top: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(50),
                child: Hero(
                  tag: estabelecimento.imagemUrl ??
                      databaseService.randomNumber.toString(),
                  child: CachedNetworkImage(
                    placeholder: (context, url) => CircularProgressIndicator(),
                    imageUrl:
                        estabelecimento.imagemUrl ?? databaseService.nophoto,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                  margin: EdgeInsets.only(top: 5),
                  padding: EdgeInsets.only(left: 3, right: 3),
                  child: AutoSizeText(
                    estabelecimento.nome,
                    maxLines: 2,
                    wrapWords: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  )),
            ),
            if (distancia != null)
              Expanded(
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.red, size: 20),
                      Text('$distancia km'),
                    ],
                  ),
                ),
              ),
            /*  Container(
                child: Obx(() => controller.locationData != null
                    ? Text(
                        "Location: ${controller.locationData.latitude.toString()}")
                    : Text('Não achou localização'))), */
            if (estabelecimento.telefonePrimarioWhatsapp)
              Container(
                height: 30,
                margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
                child: TextButton(
                    child: Row(
                      children: [
                        Icon(FlutterIcons.logo_whatsapp_ion,
                            color: Colors.white, size: 20),
                        Expanded(child: Container()),
                        Text(
                          'WHATSAPP',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    /* color: Colors.green, */
                    onPressed: () async {
                      ligar = true;
                      await utilService.ligarEstabelecimento(estabelecimento);
                      ligar = false;
                    }),
              ),
            if (!estabelecimento.telefonePrimarioWhatsapp)
              Container(
                margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
                height: 30,
                child: TextButton(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.phone, color: Colors.white, size: 20),
                        Padding(
                          padding: EdgeInsets.all(4),
                        ),
                        Text(
                          'LIGAR',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    //color: Colors.blue,
                    onPressed: () async {
                      ligar = true;
                      await utilService.ligarEstabelecimento(estabelecimento);
                      ligar = false;
                      print('ligar');
                    }),
              ),
          ]),
        ),
      ),
    );
  }
  /* 
    Avatar dos estabelecimentos antes dos cards
    return Container(
        height: 100,
        width: 100,
        //margin: EdgeInsets.only(right: 5),
        child: InkWell(
          onTap: () {
            Get.to(EstabelecimentoPage(estabelecimento));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 72,
                width: 72,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Hero(
                    tag: estabelecimento.imagemUrl ??
                        databaseService.randomNumber.toString(),
                    child: CachedNetworkImage(placeholder: (context, url) => CircularProgressIndicator(),imageUrl:
                      estabelecimento.imagemUrl ?? databaseService.nophoto,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(estabelecimento.nome,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    )),
              )
            ],
          ),
        ));
  } */
}
/* 

AVATAR ANTIGO

Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                height: 70,
                width: 70,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Hero(
                    tag: estabelecimento.imagemUrl ??
                        databaseService.randomNumber.toString(),
                    child: CachedNetworkImage(placeholder: (context, url) => CircularProgressIndicator(),imageUrl:
                      estabelecimento.imagemUrl ?? databaseService.nophoto,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 10),
                child: Text(estabelecimento.nome,
                    maxLines: 2,
                    softWrap: true,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    )),
              )
            ],
          ),


ESTABELECIMENTO CARD HORIZONTAL ANTIGO
class EstabelecimentoCard extends StatelessWidget {
  final Estabelecimento estabelecimento;
  EstabelecimentoCard(this.estabelecimento);
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      width: 180,
      margin: EdgeInsets.only(right: 10),
      child: Card(
        elevation: 5,
        child: InkWell(
          splashColor: Colors.red,
          onTap: () {
            Get.to(EstabelecimentoPage(estabelecimento));
          },
          child: Container(
            //height: 280,
            width: double.infinity,
            padding: EdgeInsets.only(bottom: 10),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    child: CachedNetworkImage(placeholder: (context, url) => CircularProgressIndicator(),imageUrl:
                      estabelecimento.imagemUrl ?? databaseService.nophoto,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(
                      left: 5,
                      right: 5,
                    ),
                    margin: EdgeInsets.only(top: 10),
                    child: AutoSizeText(estabelecimento.nome ?? '',
                        maxLines: 1, style: TextStyle(fontSize: 20))),
                Container(
                    padding: EdgeInsets.only(left: 5, right: 5, top: 5),
                    child: AutoSizeText(estabelecimento.endereco ?? '',
                        maxLines: 2, style: TextStyle(fontSize: 15)))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 */

/* class ListCategoria extends StatelessWidget {
  Map categoriaEstabelecimentos;
  ListCategoria() {
    categoriaEstabelecimentos =
        databaseService.getCategoriasComEstabelecimentos();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 20),
      child: ListView.builder(
          physics: NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: categoriaEstabelecimentos.keys.length,
          itemBuilder: (BuildContext context, int index) {
            dynamic mapCategoria = categoriaEstabelecimentos[
                categoriaEstabelecimentos.keys.toList()[index]];
            return Container(
              margin: EdgeInsets.only(top: 20),
              height: 220,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () {
                      Get.to(
                          ListaEstabelecimentosPage(mapCategoria['categoria']));
                    },
                    child: Container(
                      width: Get.width,
                      margin: EdgeInsets.only(left: 10, bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(mapCategoria['categoria'].nome,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w500)),
                          Container(
                              padding: EdgeInsets.only(bottom: 2, left: 2),
                              child: Icon(
                                Icons.arrow_forward,
                                size: 16,
                              ))
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: mapCategoria['estabelecimentos']
                          .map<Widget>((e) => EstabelecimentoCard(e))
                          .toList(),
                    ),
                  ),
                ],
              ),
            );
          }),
    );
  }
} */
