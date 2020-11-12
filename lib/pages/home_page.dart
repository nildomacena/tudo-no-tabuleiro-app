import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/inicio_page/inicio_page_streams.dart';
import 'package:tudo_no_tabuleiro_app/pages/pesquisa_page/pesquisa_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/sorteios_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class HomePage extends StatefulWidget {
  bool itemAdicionado;
  int selectedTab;
  String estabelecimentoIdNotificacao;
  HomePage(
      {this.itemAdicionado,
      this.selectedTab,
      this.estabelecimentoIdNotificacao});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;
  List<Widget> _tabs = [
    InicioPage(),
    PesquisaPage(),
    SorteiosPage(),
    /* SorteiosPage(), */
  ];

  @override
  void initState() {
    if (widget.selectedTab != null && widget.selectedTab != 0) {
      print('widget.selectedTab != null');
      setState(() {
        selectedIndex = widget.selectedTab;
      });
    }
    if (widget.itemAdicionado != null && widget.itemAdicionado) {
      Future.delayed(Duration(milliseconds: 500)).then((value) => Get.snackbar(
          'Item Adicionado ao carrinho',
          'Confira o cardápio pra completar seu pedido',
          backgroundColor: Colors.black,
          colorText: Colors.white,
          mainButton: FlatButton(
              onPressed: () {},
              child: Text(
                'CARRINHO',
                style: TextStyle(color: Colors.purpleAccent),
              )),
          snackPosition: SnackPosition.BOTTOM,
          margin: EdgeInsets.only(bottom: 30, left: 10, right: 10)));
    }
    if (widget.estabelecimentoIdNotificacao != null &&
        widget.estabelecimentoIdNotificacao != '') {
      print(
          'Veio de uma notificação de estabelecimento ${widget.estabelecimentoIdNotificacao}');
      Estabelecimento estabelecimento = databaseService
          .estabelecimentoById(widget.estabelecimentoIdNotificacao);
      Future.delayed(Duration(seconds: 1))
          .then((value) => Get.to(EstabelecimentoPage(estabelecimento)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: WillPopScope(
        onWillPop: () {
          if (selectedIndex != 0) {
            setState(() {
              selectedIndex = 0;
            });
            return Future.value(false);
          } else
            return Future.value(true);
        },
        child: Container(
          child: _tabs[selectedIndex],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesome5Solid.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
              icon: Icon(FontAwesome.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesome.gift), label: 'Sorteios'),
          /* BottomNavigationBarItem(
              icon: Icon(FontAwesome5.handshake), title: Text('Social')), */
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: (int index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),
    );
  }
}
