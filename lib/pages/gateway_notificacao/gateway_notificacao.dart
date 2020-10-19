import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class GatewayNotificacao extends StatelessWidget {
  final Map data;
  Future future;
  GatewayNotificacao(this.data) {
    if (data['tipo'] == 'estabelecimento') {
      print('get estabelecimento');
      future = databaseService.getEstabelecimentoById(data['key']);
    } else
      future = Future.delayed(Duration(seconds: 3));
  }

  @override
  Widget build(BuildContext context) {
    databaseService
        .getEstabelecimentoById(data['key'])
        .then((value) => print('value getEstabelecimentoById: $value'));
    return Scaffold(
      body: FutureBuilder(
        future: future,
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
              return Center(
                child: CircularProgressIndicator(),
              );
            /* if (snapshot.hasData) {
                if (data['tipo'] == 'estabelecimento') {
                  Get.to(EstabelecimentoPage(snapshot.data));
                  return Container();
                } else if (data['tipo'] == 'sorteio') {
                  return Container()
                  //Get.to(Sorteios());
                }
                } */

          }
        },
      ),
    );
  }
}
