import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class ListaEstabelecimentosPage extends StatelessWidget {
  final Categoria categoria;

  ListaEstabelecimentosPage(this.categoria);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.nome),
        centerTitle: true,
      ),
      body: SafeArea(
          child: Container(
        child: ListView.builder(
            itemCount: databaseService
                .getEstabelecimentoPorCategoria(categoria)
                .length,
            itemBuilder: (BuildContext context, int index) {
              Estabelecimento estabelecimento = databaseService
                  .getEstabelecimentoPorCategoria(categoria)[index];
              return EstabelecimentoCard(estabelecimento);
            }),
      )),
    );
  }
}

// ignore: must_be_immutable
class EstabelecimentoCard extends StatelessWidget {
  final Estabelecimento estabelecimento;
  EstabelecimentoCard(this.estabelecimento);
  bool ligar = false;
  @override
  Widget build(BuildContext context) {
    Widget botaoTelefone() {
      if (estabelecimento.telefonePrimario != null &&
          estabelecimento.telefonePrimarioWhatsapp)
        return Container(
          margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
          child: TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FlutterIcons.logo_whatsapp_ion,
                      color: Colors.white, size: 20),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  AutoSizeText(
                    'WHATSAPP',
                    maxLines: 1,
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              ),
              //color: Colors.green,
              onPressed: () async {
                ligar = true;
                await utilService.ligarEstabelecimento(estabelecimento);
                ligar = false;
                print('ligar');
              }),
        );
      else if (estabelecimento.telefonePrimario != null &&
          !estabelecimento.telefonePrimarioWhatsapp)
        return Container(
          margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
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
        );
      return Container();
    }

    Widget botaoLocalizacao() {
      if (estabelecimento.possuiLocalizacao)
        return Container(
          margin: EdgeInsets.only(left: 7, right: 7, bottom: 10),
          child: TextButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, color: Colors.white, size: 20),
                  Padding(
                    padding: EdgeInsets.all(4),
                  ),
                  Expanded(
                    child: AutoSizeText(
                      'LOCALIZAÇÃO',
                      maxLines: 1,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              //color: Colors.red,
              onPressed: () async {
                ligar = true;
                await utilService.abrirLocalizacao(estabelecimento);
                ligar = false;
              }),
        );
      return Container();
    }

    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
      height: 200,
      width: Get.width,
      child: Card(
        color: Colors.grey[200],
        child: InkWell(
          onTap: () {
            Get.to(EstabelecimentoPage(estabelecimento));
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 5,
                  child: Container(
                    width: double.infinity,
                    child: Hero(
                      tag: estabelecimento.imagemUrl ??
                          databaseService.randomNumber.toString(),
                      child: CachedNetworkImage(
                          placeholder: (context, url) => Container(
                              padding: EdgeInsets.all(15),
                              child: CircularProgressIndicator()),
                          imageUrl: estabelecimento.imagemUrl ??
                              'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921',
                          fit: BoxFit.cover),
                    ),
                  )),
              Divider(),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Container(
                      width: Get.width * .6,
                      margin: EdgeInsets.only(right: 50),
                      height: 20,
                      child: AutoSizeText(estabelecimento.nome,
                          maxLines: 1,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.bold)),
                    ),
                    if (estabelecimento.telefonePrimario != null &&
                        estabelecimento.possuiLocalizacao)
                      IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () async {
                            String result = await Get.bottomSheet(Container(
                              color: Colors.white,
                              child: Wrap(
                                children: [
                                  Container(
                                    margin: EdgeInsets.fromLTRB(5, 10, 5, 5),
                                    alignment: Alignment.center,
                                    child: Text(estabelecimento.nome,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  Divider(),
                                  if (estabelecimento.telefonePrimario != null)
                                    ListTile(
                                      leading: Icon(estabelecimento
                                              .telefonePrimarioWhatsapp
                                          ? FlutterIcons.logo_whatsapp_ion
                                          : Icons.phone),
                                      title: Text(estabelecimento
                                              .telefonePrimarioWhatsapp
                                          ? 'WhatsApp'
                                          : 'Ligar'),
                                      onTap: () {
                                        Get.back(result: 'telefone');
                                      },
                                    ),
                                  if (estabelecimento.possuiLocalizacao)
                                    ListTile(
                                      leading: Icon(Icons.location_on),
                                      title: Text('Localização'),
                                      onTap: () {
                                        Get.back(result: 'localizacao');
                                      },
                                    )
                                ],
                              ),
                            ));
                            if (result.isNull) return;
                            if (result == 'telefone')
                              utilService.ligarEstabelecimento(estabelecimento);
                            if (result == 'localizacao')
                              utilService.abrirLocalizacao(estabelecimento);
                          })
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10, bottom: 10),
                child: AutoSizeText(
                  estabelecimento.endereco ?? '',
                  maxLines: 2,
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                ),
              ),
              /* 
              Linha com botãos de ligar e abrir localização
              Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                height: 60,
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: botaoTelefone()),
                    Expanded(child: botaoLocalizacao())
                  ],
                ),
              ) */
              /* Container(
                margin: EdgeInsets.only(bottom: 15, left: 10),
                child: Text(estabelecimento.endereco ?? '',
                    style: TextStyle(fontSize: 15)),
              ), */
            ],
          ),
        ),
      ),
    );
  }
}
