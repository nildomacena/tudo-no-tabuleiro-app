import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:url_launcher/url_launcher.dart';

class SorteioCard extends GetWidget<AuthController> {
  final Sorteio sorteio;
  SorteioCard(this.sorteio);

  @override
  Widget build(BuildContext context) {
    _launchURL(String url) async {
      if (await canLaunch(url)) {
        await launch(url);
      } else {
        throw 'Could not launch $url';
      }
    }

    Color _primaryColor = Theme.of(context).primaryColor;
    return Card(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        children: <Widget>[
          Container(
            height: 190,
            width: double.infinity,
            child: CachedNetworkImage(
              placeholder: (context, url) => CircularProgressIndicator(),
              imageUrl: sorteio.imagem ??
                  'https://st3.depositphotos.com/1518767/15994/i/1600/depositphotos_159945820-stock-photo-hamburger-with-french-fries.jpg',
              fit: BoxFit.cover,
            ),
          ),
          Container(
            //color: Colors.red,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.fromLTRB(10, 20, 20, 5),
                        child: Text(sorteio.titulo,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                color: _primaryColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 22)),
                      ),
                      Container(
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                          child: Text(
                              'Data do sorteio: ${sorteio.data.day}/${sorteio.data.month}/${sorteio.data.year}',
                              style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18))),
                      if (sorteio.descricao != null && sorteio.descricao != '')
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                            child: Text(sorteio.descricao,
                                style: TextStyle(
                                    color: _primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                    ],
                  ),
                ),
                if (sorteio.pendente)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              child: RaisedButton(
                                child: Text(
                                    sorteio.participantes
                                            .contains(controller.user?.uid)
                                        ? 'Já inscrito        '
                                        : 'Participar',
                                    style: TextStyle(color: Colors.white)),
                                color: _primaryColor,
                                onPressed: controller.user != null &&
                                        sorteio.participantes.contains(controller
                                            .user
                                            .uid) //Verifica se o usuário já está inscrito no sorteio
                                    ? null
                                    : () async {
                                        bool fezLogin = false;
                                        print(
                                            '_Currentuser função $controller.user');
                                        if (controller.user == null) {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: new Text(
                                                    "Faça o login com o Google para concorrer"),
                                                content: new Text(
                                                    sorteio.instrucoes),
                                                actions: <Widget>[
                                                  new TextButton(
                                                    child: new Text(
                                                        "CLIQUE AQUI PRA FAZER LOGIN"),
                                                    onPressed: () async {
                                                      await controller.login();
                                                      print(
                                                          'controller.user: ${controller.user}');
                                                      _launchURL(sorteio.link);
                                                      fezLogin = controller
                                                              .user !=
                                                          null; // Verifica se o login foi feito com sucesso
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        } else {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Você está logado como ${controller.user.email}"),
                                                content:
                                                    Text(sorteio.instrucoes),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text("Fazer Logoff"),
                                                    onPressed: () async {
                                                      controller.signOut();
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                        "Ir para o Instagram"),
                                                    onPressed: () async {
                                                      await _launchURL(
                                                          sorteio.link);
                                                      print('Launch');
                                                      fezLogin = true;
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                        if (fezLogin) {
                                          Future.delayed(Duration(seconds: 2));
                                          showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              return AlertDialog(
                                                title: Text(
                                                    "Você cumpriu os requisitos para participar do sorteio?"),
                                                content: Text(
                                                    'Lembre-se que é necessário compartilhar em suas redes sociais para concorrer ao sorteio. Você fez isso?'),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text("Não"),
                                                    onPressed: () async {
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Clique de novo em Participar, e cumpra todos os requisitos para participar do sorteio",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.black,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0);
                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text(
                                                        "Já cumpri todos os passos"),
                                                    onPressed: () async {
                                                      await databaseService
                                                          .inscreverSorteio(
                                                              sorteio);
                                                      print('Launch');
                                                      Fluttertoast.showToast(
                                                          msg:
                                                              "Parabéns! Você está concorrendo ao ${sorteio.titulo}",
                                                          toastLength:
                                                              Toast.LENGTH_LONG,
                                                          gravity: ToastGravity
                                                              .BOTTOM,
                                                          backgroundColor:
                                                              Colors.black,
                                                          textColor:
                                                              Colors.white,
                                                          fontSize: 16.0);

                                                      Navigator.of(context)
                                                          .pop();
                                                    },
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }
                                      },
                              ),
                            ),
                            Container(
                              // width: double.infinity,
                              child: TextButton.icon(
                                //color: Colors.pink,
                                label: AutoSizeText(
                                  'Post Oficial',
                                  style: TextStyle(color: Colors.white),
                                  maxLines: 1,
                                ),
                                icon: Icon(
                                  Zocial.instagram,
                                  color: Colors.white,
                                  size: 16,
                                ),
                                onPressed: () {},
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(7),
                )
              ],
            ),
          ),
          if (sorteio.estabelecimentoId != null) ...{
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
              //height: 80,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Patrocinado por: ${sorteio.estabelecimentoNome}',
                      style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                  TextButton(onPressed: () {}, child: Text('SAIBA MAIS'))
                ],
              ),
            )
          },
          if (!sorteio.pendente) ...{
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(20, 0, 5, 10),
              child: Text(
                  controller.user?.uid == sorteio.ganhadorUid
                      ? 'PARABÉNS, VOCÊ FOI O GANHADOR!!'
                      : 'Nome do ganhador: ${sorteio.ganhador}',
                  style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18)),
            )
          },
        ],
      ),
    );
  }
}
