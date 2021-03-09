import 'dart:ui';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class InicioPage extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            return controller.recarregarEstabelecimentos();
          },
          child: SingleChildScrollView(
            child: Column(children: [
              CategoriasDestaque(),
              DestaquesCarousel(),
              Divider(),
              ListCategoria(),
            ]),
          ),
        ),
      ),
    );
  }
}

class ListCategoria extends StatefulWidget {
  @override
  _ListCategoriaState createState() => _ListCategoriaState();
}

class _ListCategoriaState extends State<ListCategoria> {
  List<Estabelecimento> estabelecimentos = List();
  LocationData locationData;
  Location location = Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;

  @override
  void initState() {
    //initDistancia();
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

  initDistancia() async {
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locationData = await location.getLocation();
    setState(() {});

    print('locationData: $locationData');
  }

  @override
  Widget build(BuildContext context) {
    print('build listCategoria');
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
              height: 270,
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
                  Expanded(
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: mapCategoria['estabelecimentos']
                          .map<Widget>(
                              (e) => EstabelecimentoCard(e, locationData))
                          .toList(),
                    ),
                  ),
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
  LocationData locationData;
  Location location = Location();
  String distancia;
  @override
  void initState() {
    super.initState();
    if (widget.locationData != null) {
      utilService
          .calcularDistancia(widget.estabelecimento, widget.locationData)
          .then((value) {
        setState(() {
          distancia = (value / 1000).toStringAsFixed(2);
        });
      });
    }
    //initDistancia(); Retirado para testes no início page
    /*  utilService.calcularDistancia(widget.estabelecimento).then((value) {
      if (distancia == null)
        setState(() {
          distancia = (value / 1000).toStringAsFixed(2);
        });
      else {}
    }); */
  }

  initDistancia() async {
    location.onLocationChanged.listen((locationData) async {
      /*  print('LocationData initDistancia: $locationData'); */
      if (distancia == null) {
        distancia = (await utilService.calcularDistancia(
                    widget.estabelecimento, locationData) /
                1000)
            .toStringAsFixed(2);
        setState(() {});
      }
    });

    /*  distancia =
        (await utilService.calcularDistancia(widget.estabelecimento) / 1000)
            .toStringAsFixed(2); //Primeiro busca a localização em tempo real

    utilService.calcularDistancia(widget.estabelecimento).then((value) {
      if (distancia == null)
        setState(() {
          distancia = (value / 1000).toStringAsFixed(2);
        });
      else {}
    }); */
  }

  @override
  Widget build(BuildContext context) {
    /* StreamBuilder<String> futureDistancia() {
      return StreamBuilder(
        stream: utilService.streamLocationData(widget.estabelecimento),
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
    } */

    return Container(
      height: 260,
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
              flex: 2,
              child: Container(
                  margin: EdgeInsets.only(top: 5),
                  child: AutoSizeText(
                    widget.estabelecimento.nome,
                    maxLines: 2,
                    wrapWords: false,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  )),
            ),
            Container(
              child: distancia != null && !distancia.contains('-')
                  ? Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 20),
                          Text('$distancia km'),
                        ],
                      ))
                  : Container(),
            ),
            if (widget.estabelecimento.telefonePrimarioWhatsapp)
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
                    //color: Colors.green,
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
