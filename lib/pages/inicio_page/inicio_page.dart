import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/model/oferta_emprego.dart';
import 'package:tudo_no_tabuleiro_app/pages/achados_perdidos_page/achados_perdidos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/empregos_page/empregos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/lista_estabelecimentos_page/lista_estabelecimentos_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class InicioPage extends GetWidget<AuthController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(children: [
            DestaquesCarousel(),
            Divider(),
            ListCategoria(),
          ]),
        ),
      ),
    );
  }
}

class DestaquesCarousel extends StatelessWidget {
  List<Estabelecimento> estabelecimentos;
  DestaquesCarousel() {
    estabelecimentos = databaseService.getEstabelecimentosDestaque();
  }

  Widget containerEmpregos = Container(
    height: 170,
    width: Get.width,
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Material(
      elevation: 5,
      child: InkWell(
        child: Ink.image(
          image: AssetImage('assets/images/emprego.png'),
          fit: BoxFit.cover,
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
    height: 170,
    width: Get.width,
    padding: EdgeInsets.only(left: 5, right: 5),
    child: Material(
      elevation: 5,
      child: InkWell(
        child: Ink.image(
          image: AssetImage('assets/images/achados-perdidos.png'),
          fit: BoxFit.cover,
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

  @override
  Widget build(BuildContext context) {
    List<Widget> itensCarrossel = [];
    itensCarrossel = estabelecimentos.map((e) {
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
    return CarouselSlider(
      options: CarouselOptions(
        enlargeCenterPage: true,
        height: 200,
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

class ListCategoria extends StatelessWidget {
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
              height: 170,
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
                          .map<Widget>((e) => EstabelecimentoCard(e))
                          .toList(),
                    ),
                  ),
                  Divider()
                ],
              ),
            );
          }),
    );
  }
}

class EstabelecimentoCard extends StatelessWidget {
  final Estabelecimento estabelecimento;
  EstabelecimentoCard(this.estabelecimento);
  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: 100,
        margin: EdgeInsets.only(right: 20),
        child: InkWell(
          onTap: () {
            Get.to(EstabelecimentoPage(estabelecimento));
          },
          child: Column(
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
                    child: ExtendedImage.network(
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
                    child: ExtendedImage.network(
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
                    child: ExtendedImage.network(
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
