import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/pages/pre_cadastro_page/cadastro_categoria_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class SelectCategoriaPage extends StatefulWidget {
  @override
  _SelectCategoriaPageState createState() => _SelectCategoriaPageState();
}

class _SelectCategoriaPageState extends State<SelectCategoriaPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () async {
            dynamic result = await Get.to(CadastroCategoriaPage());
            print('result dialog: $result');
          },
        ),
        appBar: AppBar(title: Text('Selecione a Categoria')),
        body: Container(
          child: StreamBuilder(
            stream: databaseService.streamCategorias(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Categoria>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                case ConnectionState.none:
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                default:
                  List<Categoria> categorias = snapshot.data;
                  return ListView.builder(
                      itemCount: categorias.length + 1,
                      itemBuilder: (BuildContext context, int index) {
                        if (index ==
                            categorias
                                .length) //Verifica se é o último item para adicionar um padding no final
                          return Padding(
                            padding: EdgeInsets.all(20),
                          );
                        Categoria categoria = categorias[index];
                        return ListTile(
                          onTap: () {
                            Get.back(result: categoria);
                          },
                          title: Text(categoria.nome),
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(categoria.imagemUrl),
                          ),
                        );
                      });
              }
            },
          ),
        ));
  }
}
