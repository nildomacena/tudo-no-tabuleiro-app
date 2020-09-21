import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class ListaEstabelecimentosPage extends StatelessWidget {
  final Categoria categoria;

  ListaEstabelecimentosPage(this.categoria);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(categoria.nome),
        backgroundColor: Colors.grey,
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

class EstabelecimentoCard extends StatelessWidget {
  final Estabelecimento estabelecimento;
  EstabelecimentoCard(this.estabelecimento);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.fromLTRB(15, 15, 15, 15),
      height: 300,
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
                    child: ExtendedImage.network(
                        estabelecimento.imagemUrl ??
                            'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921',
                        fit: BoxFit.cover),
                  )),
              Divider(),
              Container(
                margin: EdgeInsets.only(left: 10),
                child:
                    Text(estabelecimento.nome, style: TextStyle(fontSize: 23)),
              ),
              Container(
                margin: EdgeInsets.only(bottom: 20, left: 10),
                child: Text(estabelecimento.endereco ?? '',
                    style: TextStyle(fontSize: 15)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
