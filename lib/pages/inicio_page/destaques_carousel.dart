import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/model/oferta_emprego.dart';
import 'package:tudo_no_tabuleiro_app/pages/achados_perdidos_page/achados_perdidos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/empregos_page/empregos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class DestaquesCarousel extends StatefulWidget {
  List<Estabelecimento> estabelecimentos = List();

  @override
  _DestaquesCarouselState createState() => _DestaquesCarouselState();
}

class _DestaquesCarouselState extends State<DestaquesCarousel> {
  @override
  void initState() {
    if (databaseService.estabelecimentosCarregados) {
      setState(() {
        widget.estabelecimentos = databaseService.getEstabelecimentosDestaque();
      });
    } else
      databaseService.futureEstabelecimentosDestaque().then((value) {
        setState(() {
          widget.estabelecimentos = value;
        });
      });
    super.initState();
  }

  Widget containerEmpregos = Container(
    height: 130,
    width: Get.width,
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Material(
      elevation: 5,
      child: InkWell(
        child: Ink.image(
          image: AssetImage('assets/images/emprego.png'),
          fit: BoxFit.fill,
        ),
        onTap: () async {
          Get.dialog(
              AlertDialog(
                  content: Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Text(
                      'Carregando dados',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    )
                  ],
                ),
              )),
              barrierDismissible: false);
          try {
            List<OfertaEmprego> ofertas =
                await databaseService.getOfertasEmprego();
            Get.back();
            Get.to(EmpregosPage(ofertas));
          } catch (e) {
            Get.back();
            print('Erro ofertas de emprego: $e');
            Get.dialog(
              AlertDialog(
                title: Text('Erro durante a solicitação'),
                content: Container(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Ocorreu um erro durante a solicitação. Tente novamente mais tarde',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              ),
            );
          }
        },
      ),
    ),
  );

  Widget containerAchados = Container(
    height: 130,
    width: Get.width,
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Material(
      elevation: 5,
      child: InkWell(
        child: Ink.image(
          image: AssetImage('assets/images/achados-perdidos.png'),
          fit: BoxFit.fill,
        ),
        onTap: () async {
          Get.dialog(
              AlertDialog(
                  content: Container(
                height: 80,
                child: Column(
                  children: <Widget>[
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                    ),
                    Text(
                      'Carregando dados',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue),
                    )
                  ],
                ),
              )),
              barrierDismissible: false);
          try {
            List<Achado> achados = await databaseService.getAchados();
            Get.back();
            Get.to(AchadosPerdidosPage(achados));
          } catch (e) {
            Get.back();
            print('Erro ofertas de emprego: $e');
            Get.dialog(
              AlertDialog(
                title: Text('Erro durante a solicitação'),
                content: Container(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Ocorreu um erro durante a solicitação. Tente novamente mais tarde',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              ),
            );
          }
        },
      ),
    ),
  );

  Widget containerContato = Container(
    height: 130,
    width: Get.width,
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Material(
      elevation: 5,
      child: InkWell(
        child: Ink.image(
          image: AssetImage('assets/images/divulgacao.png'),
          fit: BoxFit.fill,
        ),
        onTap: () async {
          try {
            utilService.entrarEmContato();
          } catch (e) {
            Get.back();
            print('Erro ofertas de emprego: $e');
            Get.dialog(
              AlertDialog(
                title: Text('Erro durante a solicitação'),
                content: Container(
                  height: 80,
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Ocorreu um erro durante a solicitação. Tente novamente mais tarde',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
                actions: [
                  FlatButton(
                    child: Text('OK'),
                    onPressed: () {
                      Get.back();
                    },
                  )
                ],
              ),
            );
          }
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    List<Widget> itensCarrossel = [];
    itensCarrossel = widget.estabelecimentos.map((e) {
      return Builder(
        builder: (BuildContext context) {
          return Container(
              width: MediaQuery.of(context).size.width,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ExtendedImage.network(
                    e.imagemUrl ?? databaseService.nophoto,
                    fit: BoxFit.fill,
                  ),
                  Positioned.fill(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        splashColor: Colors.blue.withOpacity(.5),
                        onTap: () {
                          Get.to(EstabelecimentoPage(e));
                        },
                      ),
                    ),
                  )
                ],
              ));
        },
      );
    }).toList();
    itensCarrossel.add(Builder(
      builder: (BuildContext context) => containerEmpregos,
    ));
    itensCarrossel.add(Builder(
      builder: (BuildContext context) => containerAchados,
    ));
    itensCarrossel.add(Builder(
      builder: (BuildContext context) => containerContato,
    ));
    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        height: 150,
        autoPlay: true,
      ),
      items:
          itensCarrossel /* estabelecimentos.map((e) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      e.imagemUrl,
                      fit: BoxFit.fill,
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.blue.withOpacity(.5),
                          onTap: () {
                            Get.to(EstabelecimentoPage(e));
                          },
                        ),
                      ),
                    )
                  ],
                ));
          },
        );
      }).toList() */
      ,
    );
  }
}
