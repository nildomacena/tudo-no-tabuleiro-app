import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';
import 'package:tudo_no_tabuleiro_app/pages/visualizar_imagem_page/visualizar_imagem_page.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

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
                        onPressed: () {
                          utilService.contatoAdmin(
                              'Olá, gostaria de reportar um achado ou perdido');
                        }),
                  )
                ],
              )),
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Achados e Perdidos'),
      ),
      body: achados.length == 0
          ? Column(
              children: [
                cardContato,
                Container(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    'Por enquanto não há objetos cadastrados no achados e perdidos. Se você encontrou ou perdeu alguma coisa, entre em contato pelo WhatsApp. Nós publicaremos aqui.',
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
                    return Container(
                      margin: EdgeInsets.only(left: 10, right: 10, bottom: 20),
                      child: Card(
                        child: Container(
                          height: 180,
                          width: Get.width,
                          //margin: EdgeInsets.only(left: 10, right: 10),
                          child: Column(
                            children: [
                              if (achado.imagem != null && achado.imagem != "")
                                InkWell(
                                  onTap: () {
                                    Get.to(VisualizarImagemPage(achado.imagem));
                                  },
                                  child: Container(
                                      height: 115,
                                      width: double.infinity,
                                      margin: EdgeInsets.only(bottom: 15),
                                      child: CachedNetworkImage(
                                        placeholder: (context, url) =>
                                            CircularProgressIndicator(),
                                        imageUrl: achado.imagem,
                                        fit: BoxFit.cover,
                                      ) /* CachedNetworkImage(placeholder: (context, url) => CircularProgressIndicator(),imageUrl:
                                      achado.imagem,
                                      fit: BoxFit.cover,
                                    ), */
                                      ),
                                ),
                              Container(
                                child: Text(
                                  achado.descricao,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              Container(
                                child: Text('Achado por: ${achado.achadoPor}',
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.w400)),
                              )
                            ],
                          ),
                        ),
                      ),
                    );
                  })),
    );
  }
}
