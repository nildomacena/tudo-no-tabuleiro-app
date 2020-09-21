import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/lista_estabelecimentos_page/lista_estabelecimentos_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class PesquisaPage extends StatelessWidget {
  PesquisaPage();

  @override
  Widget build(BuildContext context) {
    // databaseService.getEstabelecimentos().then((value) => print('estabelecimentos: $value'));
    return Scaffold(
        body: StreamBuilder(
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
                  return ListViewCategorias(snapshot.data);
              }
            }));
  }
}

// ignore: must_be_immutable
class ListViewCategorias extends StatefulWidget {
  List<Categoria> categorias;
  ListViewCategorias(this.categorias);

  @override
  _ListViewCategoriasState createState() => _ListViewCategoriasState();
}

class _ListViewCategoriasState extends State<ListViewCategorias> {
  List<Categoria> categoriasFiltradas;
  List<Estabelecimento> estabelecimentosFiltrados;
  List<Estabelecimento> estabelecimentos;

  @override
  void initState() {
    widget.categorias = widget.categorias
        .where((c) => databaseService.categoriaPossuiEstabelecimento(c))
        .toList();
    categoriasFiltradas = widget.categorias;
    estabelecimentos = databaseService.estabelecimentosFinal;
    estabelecimentosFiltrados = List();
    super.initState();
  }

  TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
//    print('Estabelecimentos $estabelecimentos - $estabelecimentosFiltrados');
    return Container(
      child: ListView(
        children: [
          TextField(
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Pesquisa uma categoria',
                icon: Icon(Icons.search)),
            controller: searchController,
            onChanged: (txt) {
              if (txt.length > 0) {
                setState(() {
                  categoriasFiltradas = widget.categorias
                      .where((c) =>
                          c.nome.toLowerCase().contains(txt.toLowerCase()))
                      .toList();
                });
                setState(() {
                  estabelecimentosFiltrados =
                      estabelecimentos.where((e) => e.search(txt)).toList();
                  /* estabelecimentosFiltrados = estabelecimentos
                      .where((e) =>
                          e.nome.toLowerCase().contains(txt.toLowerCase()) ||
                          e.categoria.nome
                              .toLowerCase()
                              .contains(txt.toLowerCase()))
                      .toList(); */
                });
              } else
                setState(() {
                  categoriasFiltradas = widget.categorias;
                });
            },
          ),
          StaggeredGridView.countBuilder(
            shrinkWrap: true,
            crossAxisCount: 2,
            physics: NeverScrollableScrollPhysics(),
            itemCount: categoriasFiltradas.length,
            itemBuilder: (BuildContext context, int index) {
              Categoria categoria = categoriasFiltradas[index];
              return Material(
                elevation: 5,
                child: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  height: 150,
                  width: double.infinity,
                  alignment: Alignment.center,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        color: Colors.black.withOpacity(.4),
                      ),
                      InkWell(
                        child: ExtendedImage.network(
                          categoria.imagemUrl,
                          fit: BoxFit.cover,
                        ),
                        onTap: () {
                          Get.to(ListaEstabelecimentosPage(categoria));
                        },
                      ),
                      /* Ink.image(
                        image: NetworkImage(
                          categoria.imagemUrl,
                        ),
                        fit: BoxFit.cover,
                        child: InkWell(
                          splashColor: Colors.green.withOpacity(.5),
                          onTap: () {
                            Get.to(ListaEstabelecimentosPage(categoria));
                          },
                        ),
                      ), */
                      GestureDetector(
                        onTap: () {
                          print('on tap Categoria');
                          Get.to(ListaEstabelecimentosPage(categoria));
                        },
                        child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(left: 5, right: 5),
                            child: Text(
                              categoria.nome,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    ),
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 3.0,
                                      color: Colors.black,
                                    )
                                  ]),
                            )),
                      ),
                    ],
                  ),
                ),
              );
            },
            staggeredTileBuilder: (int index) => new StaggeredTile.count(
                categoriasFiltradas.length == 1 ? 2 : 1, 1),
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0,
          ),
          if (estabelecimentosFiltrados.length > 0 &&
              searchController.text.length > 2)
            ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: estabelecimentosFiltrados.length,
                itemBuilder: (BuildContext context, int index) {
                  Estabelecimento estabelecimento =
                      estabelecimentosFiltrados[index];

                  return ListTile(
                    title: Text(estabelecimento.nome ?? ''),
                    subtitle:
                        Text('Categoria: ${estabelecimento.categoria.nome}'),
                    leading: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                        maxWidth: 64,
                        maxHeight: 64,
                      ),
                      child: Image.network(estabelecimento.imagemUrl,
                          fit: BoxFit.cover),
                    ),
                    onTap: () {
                      Get.to(EstabelecimentoPage(estabelecimento));
                    },
                  );
                })
        ],
      ),
    );
    return Container(
      child: ListView.builder(
        itemCount: categoriasFiltradas.length + 1,
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Container();
          }

          Categoria categoria = categoriasFiltradas[index - 1];
          return Material(
            elevation: 5,
            child: Container(
              margin: EdgeInsets.only(top: 5, bottom: 5),
              height: 150,
              width: double.infinity,
              alignment: Alignment.center,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    color: Colors.black.withOpacity(.4),
                  ),
                  Ink.image(
                    image: NetworkImage(
                      categoria.imagemUrl,
                    ),
                    fit: BoxFit.cover,
                    child: InkWell(
                      splashColor: Colors.green.withOpacity(.5),
                      onTap: () {
                        Get.to(ListaEstabelecimentosPage(categoria));
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.to(ListaEstabelecimentosPage(categoria));
                    },
                    child: Center(
                        child: Text(
                      categoria.nome,
                      style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 3.0,
                              color: Colors.black,
                            ),
                            Shadow(
                              offset: Offset(2, 2),
                              blurRadius: 3.0,
                              color: Colors.black,
                            )
                          ]),
                    )),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
