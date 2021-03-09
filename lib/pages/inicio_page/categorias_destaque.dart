import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/pages/lista_estabelecimentos_page/lista_estabelecimentos_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class CategoriasDestaque extends StatelessWidget {
  CategoriasDestaque();

  Widget iconeCategoria(List<Categoria> categorias) {
    List<Categoria> categoriasDestaque = List();
    categoriasDestaque = categorias.where((c) => c.destaque).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(top: 15),
      height: 150,
      width: double.infinity,
      child: Column(
        children: [
          Divider(),
          Expanded(
            child: StreamBuilder(
                stream: databaseService.streamCategorias(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Categoria>> snapshot) {
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
                      List<Categoria> categoriasDestaque = List();
                      categoriasDestaque =
                          snapshot.data.where((c) => c.destaque).toList();
                      return ListView.builder(
                        itemCount: categoriasDestaque.length,
                        itemBuilder: (context, int index) {
                          Categoria categoria = categoriasDestaque[index];
                          return InkWell(
                            onTap: () {
                              Get.to(ListaEstabelecimentosPage(categoria));
                            },
                            child: Container(
                              height: 80,
                              width: 80,
                              margin: EdgeInsets.only(left: 5, right: 5),
                              child: Column(
                                children: [
                                  CachedNetworkImage(
                                    placeholder: (context, url) => Center(
                                        child: CircularProgressIndicator()),
                                    imageUrl: categoria.icone,
                                    //cache: true,
                                    fit: BoxFit.fill,
                                    height: 60,
                                  ),
                                  AutoSizeText(
                                    categoria.nome,
                                    maxLines: 2,
                                    textAlign: TextAlign.center,
                                    wrapWords: false,
                                    softWrap: true,
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                        scrollDirection: Axis.horizontal,
                      );
                  }
                }),
          ),
          Divider()
        ],
      ),
    );
  }
}
