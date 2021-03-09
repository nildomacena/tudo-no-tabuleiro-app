import 'package:auto_size_text/auto_size_text.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/controllers/auth_controller.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/services/auth_service.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SorteioCard extends StatefulWidget {
  final Sorteio sorteio;
  SorteioCard(this.sorteio);
  @override
  _SorteioCardState createState() => _SorteioCardState();
}

class _SorteioCardState extends State<SorteioCard> {
  User user;
  Color _primaryColor = Get.theme.primaryColor;
  _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  void initState() {
    /* databaseService.getUser().then((u) {
      setState(() {
        user = u;
      });
    }); */
    user = authService.user;
    print('User initState: $user');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget participarButton() {
      if (user == null) {
        return RaisedButton(
          child: Text(
            'Faça login para concorrer ${user?.email}',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
          color: Get.theme.primaryColor,
          onPressed: () {
            authService.loginComGoogle().then((u) {
              setState(() {
                user = u;
              });
            });
          },
        );
      } else if (widget.sorteio.participantes.contains(user?.uid)) {
        return RaisedButton(child: Text('Já inscrito'), onPressed: null);
      } else
        return RaisedButton(
          child: Text('Participar', style: TextStyle(color: Colors.white)),
          color: _primaryColor,
          onPressed: () async {
            bool fezLogin = false;
            print('_Currentuser função $user');
            try {
              await databaseService.inscreverSorteio(widget.sorteio);
              Get.dialog(AlertDialog(
                title: Text('Parabéns! Você já está concorrendo ao prêmio'),
                content: Text(
                    'Mas atenção, lembre-se de cumprir todos os requisitos na página do post oficial no INSTAGRAM!\nCaso você não cumpra as regras, poderá perder o prêmio.'),
                actions: [
                  TextButton(
                    child: Text('FECHAR'),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                  TextButton(
                    child: Text('IR PARA INSTAGRAM'),
                    onPressed: () {
                      launch(widget.sorteio.link);
                    },
                  )
                ],
              ));
            } catch (e) {
              print('Erro na inscrição: $e');
              Get.dialog(AlertDialog(
                  title: Text('Ocorreu um erro!'),
                  content: Text(
                      'Ocorreu algum problema durante o processo de inscrição. Tente novamente mais tarde')));
            }
            /* 
            await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text("Você está logado como ${controller.user.email}"),
                  content: Text(widget.sorteio.instrucoes),
                  actions: <Widget>[
                    TextButton(
                      child: Text("Fazer Logoff"),
                      onPressed: () async {
                        controller.signOut();
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text("Ir para o Instagram"),
                      onPressed: () async {
                        await _launchURL(widget.sorteio.link);
                        print('Launch');
                        fezLogin = true;
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );

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
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text("Já cumpri todos os passos"),
                        onPressed: () async {
                          await databaseService.inscreverSorteio(sorteio);
                          print('Launch');
                          Fluttertoast.showToast(
                              msg:
                                  "Parabéns! Você está concorrendo ao ${widget.sorteio.titulo}",
                              toastLength: Toast.LENGTH_LONG,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: Colors.black,
                              textColor: Colors.white,
                              fontSize: 16.0);

                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            }*/
          },
        );
    }

    return Card(
      margin: EdgeInsets.only(bottom: 25),
      child: Column(
        children: <Widget>[
          GestureDetector(
            onLongPress: () {
              utilService.loadingAlert();
            },
            child: Container(
              height: 190,
              width: double.infinity,
              child: CachedNetworkImage(
                placeholder: (context, url) => CircularProgressIndicator(),
                imageUrl: widget.sorteio.imagem ??
                    'https://st3.depositphotos.com/1518767/15994/i/1600/depositphotos_159945820-stock-photo-hamburger-with-french-fries.jpg',
                fit: BoxFit.cover,
              ),
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
                        child: Text(widget.sorteio.titulo,
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
                              'Data do sorteio: ${widget.sorteio.data.day}/${widget.sorteio.data.month}/${widget.sorteio.data.year}',
                              style: TextStyle(
                                  color: _primaryColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18))),
                      if (widget.sorteio.descricao != null &&
                          widget.sorteio.descricao != '')
                        Container(
                            alignment: Alignment.centerLeft,
                            margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
                            child: Text(widget.sorteio.descricao,
                                style: TextStyle(
                                    color: _primaryColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18))),
                    ],
                  ),
                ),
                if (widget.sorteio.pendente)
                  Expanded(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(child: participarButton()),
                          Container(
                            // width: double.infinity,
                            child: TextButton.icon(
                              // color: Colors.pink,
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
                              onPressed: () {
                                launch(widget.sorteio.link);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(7),
                )
              ],
            ),
          ),
          if (widget.sorteio.estabelecimentoId != null) ...{
            Container(
              margin: EdgeInsets.fromLTRB(10, 0, 5, 10),
              //height: 80,
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Patrocinado por: ${widget.sorteio.estabelecimentoNome}',
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
          if (!widget.sorteio.pendente) ...{
            Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.fromLTRB(20, 0, 5, 10),
              child: Text(
                  user?.uid == widget.sorteio.ganhadorUid
                      ? 'PARABÉNS, VOCÊ FOI O GANHADOR!!'
                      : 'Nome do ganhador: ${widget.sorteio.ganhador}',
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
