import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';

class AchadosPerdidosPage extends StatelessWidget {
  final List<Achado> achados;

  AchadosPerdidosPage(this.achados);

  @override
  Widget build(BuildContext context) {
    Widget cardContato = Container(
        margin: EdgeInsets.only(bottom: 20),
        child: Card(
          child: Container(
              padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  Text(
                    'Achou ou perdeu algum documento, animal ou outro objeto? Entre em contato conosco através do WhatsApp. Nós publicaremos para ajudar ',
                    style: TextStyle(
                      fontSize: 18,
                      wordSpacing: 1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 15),
                    child: RaisedButton(
                        color: Colors.green,
                        child: Container(
                            width: Get.width * .6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 10),
                                  child: Icon(FontAwesome.whatsapp,
                                      size: 25, color: Colors.white),
                                ),
                                Text(
                                  'Contato',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 24),
                                )
                              ],
                            )),
                        onPressed: () {}),
                  )
                ],
              )),
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Empregos - Vagas e Currículos'),
      ),
      body: achados.length == 0
          ? Column(
              children: [
                cardContato,
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Por enquanto não há ofertas de emprego. Mas continue acompanhando o app, uma vaga pode surgir a qualquer momento.\nEnquanto isso, você pode entrar em contato e nos enviar seu currículo. Nós encaminharemos às empresas parceiras',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                        fontSize: 18,
                        wordSpacing: 1.2,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )
          : Container(
              child: ListView.builder(
                  itemCount: achados.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0) return cardContato;

                    Achado achado = achados[index - 1];
                    return Card(
                      child: Container(
                        height: 150,
                        width: Get.width,
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            if (achado.imagem != null && achado.imagem != "")
                              Image.network(achado.imagem),
                            Container(
                              child: Text(achado.descricao),
                            ),
                            Container(
                              child: Text(
                                  'Achado por: ${achado.achadoPor}\nContato: ${achado.contato}'),
                            )
                          ],
                        ),
                      ),
                    );
                  })),
    );
  }
}
