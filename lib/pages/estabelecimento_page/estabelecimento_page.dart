import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/carossel_imagens.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/listview_itens.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class EstabelecimentoPage extends StatefulWidget {
  final Estabelecimento estabelecimento;

  EstabelecimentoPage(this.estabelecimento);
  @override
  _EstabelecimentoPageState createState() => _EstabelecimentoPageState();
}

class _EstabelecimentoPageState extends State<EstabelecimentoPage> {
  ScrollController scrollController = ScrollController();
  bool mostrarAppBar = false;
  final dataKey = new GlobalKey();

  @override
  void initState() {
    scrollController.addListener(() {
      if (scrollController.offset > 100 && !mostrarAppBar)
        setState(() {
          mostrarAppBar = true;
        });
      else if (mostrarAppBar && scrollController.offset < 100)
        setState(() {
          mostrarAppBar = false;
        });
      //print('Position: ${scrollController.offset}');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.estabelecimento.nome),
        backgroundColor: Colors.grey,
      ),
      body: ListView(
        children: [
          Container(
            width: double.infinity,
            height: 200,
            color: Colors.grey[300],
            child: Image.network(widget.estabelecimento.imagemUrl ?? databaseService.nophoto,
                fit: BoxFit.cover),
          ),
          ContainerInfoGerais(widget.estabelecimento),
          if (widget.estabelecimento.produtos != null &&
              widget.estabelecimento.produtos.length > 0)
            ListViewItens(widget.estabelecimento.produtos),
          if ((widget.estabelecimento.imagem1 != null &&
                  widget.estabelecimento.imagem1 != "") ||
              widget.estabelecimento.imagem2 != null &&
                  widget.estabelecimento.imagem2 != "")
            CarrosselImagens(widget.estabelecimento)
        ],
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: Container(
            child: Stack(
          fit: StackFit.expand,
          children: [
            SingleChildScrollView(
                controller: scrollController,
                child: ListView(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  children: [
                    //TODO Colocar um botão de favoritar como um stack sobre a foto
                    Container(
                      width: double.infinity,
                      height: 200,
                      color: Colors.grey[300],
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.network(widget.estabelecimento.imagemUrl,
                              fit: BoxFit.cover),
                          Positioned(
                            top: 20,
                            left: 10,
                            child: Container(
                              height: 45,
                              width: 45,
                              child: IconButton(
                                  icon: Icon(
                                    Icons.arrow_back,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    Get.back();
                                  }),
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20)),
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ContainerInfoGerais(widget.estabelecimento),
                    if (widget.estabelecimento.produtos != null &&
                        widget.estabelecimento.produtos.length > 0)
                      ListViewItens(widget.estabelecimento.produtos),
                    /* Container(
                          height: 500,
                          width: double.infinity,
                          color: Colors.green,
                          margin: EdgeInsets.all(20),
                        ),
                        Container(
                          height: 500,
                          width: double.infinity,
                          color: Colors.blue,
                          margin: EdgeInsets.all(20),
                        ),
                        Container(
                          height: 500,
                          width: double.infinity,
                          color: Colors.blue,
                          margin: EdgeInsets.all(20),
                          key: dataKey,
                        ), */
                  ],
                )),
            Positioned(
              top: 0,
              child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  curve: Curves.linear,
                  color: Colors.grey[300],
                  width: Get.width,
                  height: mostrarAppBar ? 56 : 0,
                  child: AppBar(
                    title: Text(widget.estabelecimento.nome),
                    backgroundColor: Colors.grey,
                  ) /* Material(
                  elevation: 4,
                  child: Column(
                    children: [
                      Expanded(
                          flex: 2,
                          child: Container(
                              padding: EdgeInsets.only(left: 5),
                              width: Get.width,
                              alignment: Alignment.centerLeft,
                              //color: Colors.blue,
                              child: Text(
                                widget.estabelecimento.nome,
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ))),
                      Expanded(flex: 1, child: Container())
                    ],
                  ),
                ), */
                  ),
            ),
          ],
        )),
      ),
      /* bottomNavigationBar: new RaisedButton(
        onPressed: () => Scrollable.ensureVisible(dataKey.currentContext,
            duration: Duration(milliseconds: 500)),
        child: new Text("Scroll to data"),
      ), */
    );
  }
}

class ContainerInfoGerais extends StatelessWidget {
  final Estabelecimento estabelecimento;
  ContainerInfoGerais(this.estabelecimento);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(10, 15, 10, 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            child: Text(estabelecimento.nome,
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w500)),
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text('Lanchonete e hamburgueria'),
          ),
          Container(
            margin: EdgeInsets.only(top: 5, bottom: 5),
            child: Text('Preço de Entrega: R\$5,00'),
          ),
          Divider(
            thickness: 1.5,
          ),
          Container(
            margin: EdgeInsets.only(top: 5),
            child: Text(
              'Informações do estabelecimento',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
          ),
          Container(
            //color: Colors.blue,
            height: 70,
            width: Get.width,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.grey,
                        ),
                        Expanded(
                            child: Container(
                          child: AutoSizeText(
                            estabelecimento.endereco,
                            maxLines: 2,
                          ),
                        )),
                        Container(),
                        if (estabelecimento.localizacao != null)
                          Container(
                              width: 137,
                              child: FlatButton(
                                  onPressed: () async {
                                    final availableMaps =
                                        await MapLauncher.installedMaps;
                                    await availableMaps.first.showMarker(
                                        coords: Coords(
                                            estabelecimento.localizacao.lat,
                                            estabelecimento.localizacao.lng),
                                        title: estabelecimento.nome,
                                        zoom: 15);
                                  },
                                  child: AutoSizeText(
                                    'ABRIR NO MAPA',
                                    maxLines: 1,
                                  )))
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.phone,
                        color: Colors.grey,
                      ),
                      Expanded(child: Text('99999-8877')),
                      Expanded(
                        child: Container(),
                      ),
                      Container(
                          width: 137,
                          child: FlatButton(
                              onPressed: () {},
                              child: AutoSizeText(
                                estabelecimento.telefonePrimarioWhatsapp
                                    ? 'WHATSAPP'
                                    : 'LIGAR',
                                maxLines: 1,
                              )))
                    ],
                  ),
                )
              ],
            ),
          ),
          Divider()
        ],
      ),
    );
  }
}
/* 
class ListViewItens extends StatelessWidget {
  List<ItemCardapio> itensCardapio = List();
  ListViewItens() {
    itensCardapio = [
      ItemCardapio(
          nome: 'X-burguer',
          preco: 11,
          imagemUrl:
              'https://firebasestorage.googleapis.com/v0/b/lanchonetes-al.appspot.com/o/x%20burguer.jpg?alt=media&token=024f8253-88d9-4c25-bdae-5126eed80b9f',
          descricao:
              'Delicioso pão com gergelim, hambúrguer bovino, queijo e salada'),
      ItemCardapio(
          nome: 'X-frango',
          preco: 14.5,
          imagemUrl:
              'https://thumb-cdn.soluall.net/prod/shp_products/sp760fw/5d41e122-07a4-48fe-8eec-5ec7ac1e023c/5d41e122-87b0-4a9c-b513-5ec7ac1e023c.PNG',
          descricao:
              'Frango desfiado, queijo, presunto, salada e molho especial'),
      ItemCardapio(
          nome: 'Artesanal',
          preco: 14.5,
          imagemUrl:
              'https://firebasestorage.googleapis.com/v0/b/lanchonetes-al.appspot.com/o/kindpng_4273772.png?alt=media&token=d63ed7df-8b2f-4ac0-8368-2a13b6e0581b',
          descricao:
              'Pão de brioche, Hambúrguer artesanal de 180g , queijo, picles, salada e molho especial'),
      ItemCardapio(
          nome: 'Artesanal Duplo',
          preco: 17,
          imagemUrl:
              'https://firebasestorage.googleapis.com/v0/b/lanchonetes-al.appspot.com/o/duplo-cheddar-bacon.jpg?alt=media&token=333e3961-06ae-40d6-bf0a-e550a52706ef',
          descricao:
              'Pão de brioche, dois hambúrgueres artesenais de 100g , queijo, picles, salada e molho especial'),
      ItemCardapio(
          nome: 'Artesanal Cheddar',
          preco: 15.5,
          imagemUrl:
              'https://firebasestorage.googleapis.com/v0/b/lanchonetes-al.appspot.com/o/Hob.-Costela-BBQ.jpg?alt=media&token=a4960a51-6ae9-4d55-ae4d-98d03d031ca0',
          descricao:
              'Pão de brioche, Hambúrguer artesanal, cheddar, picles, salada e molho especial'),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 1000,
      width: Get.width,
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: itensCardapio.length,
        itemBuilder: (BuildContext context, int index) {
          ItemCardapio itemCardapio = itensCardapio[index];
          return Container(
            height: 130,
            width: Get.width,
            child: InkWell(
              child: Container(
                padding: EdgeInsets.fromLTRB(5, 10, 5, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  itemCardapio.nome,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                                Container(
                                  margin: EdgeInsets.only(top: 5),
                                  child: AutoSizeText(
                                    itemCardapio.descricao,
                                    maxLines: 2,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w300),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Container(
                              color: Colors.grey[200],
                              child: Image.network(itemCardapio.imagemUrl,
                                  fit: BoxFit.cover),
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 5),
                        child: Text(
                            "R\$${itemCardapio.preco.toStringAsFixed(2)}")),
                    Divider()
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

 */
