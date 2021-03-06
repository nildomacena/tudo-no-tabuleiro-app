import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/inicio_page/inicio_page_state.dart';
import 'package:tudo_no_tabuleiro_app/pages/pesquisa_page/pesquisa_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/servicos_page/servicos_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/sorteios_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

import '../model/estabelecimento.dart';
import '../services/database_service.dart';
import '../services/util_service.dart';
import '../services/util_service.dart';
import '../services/util_service.dart';
import '../services/util_service.dart';

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
    ServicosPage()
    /* SorteiosPage(), */
  ];

  @override
  void initState() {
    /**Codigo que verifica se chegou alguma notificacao com id de estabelecimento. Caso positivo, vai para a tela do estabelecimento */
    if (widget.selectedTab != null && widget.selectedTab != 0) {
      print('widget.selectedTab != null');
      setState(() {
        selectedIndex = widget.selectedTab;
      });
      return;
    }
    /*print('util service.estabelecimentoId: ${utilService.estabelecimentoId}');
     if (utilService.estabelecimentoId != null) {
      databaseService
          .getEstabelecimentoById(utilService.estabelecimentoId)
          .then((value) {
        utilService.estabelecimentoId = null;
        Get.to(EstabelecimentoPage(value));
      });
    } else if (utilService.getEstabelecimentoId() != null) {
      databaseService
          .getEstabelecimentoById(utilService.estabelecimentoId)
          .then((value) {
        utilService.estabelecimentoId = null;
        Get.to(EstabelecimentoPage(value));
      });
    } else */

    if (widget.estabelecimentoIdNotificacao != null &&
        widget.estabelecimentoIdNotificacao != '') {
      print(
          'Veio de uma notifica????o de estabelecimento ${widget.estabelecimentoIdNotificacao}');
      Estabelecimento estabelecimento = databaseService
          .estabelecimentoById(widget.estabelecimentoIdNotificacao);
      Future.delayed(Duration(seconds: 1))
          .then((value) => Get.to(EstabelecimentoPage(estabelecimento)));
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    utilService.redirectNotification();

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
            label: 'In??cio',
          ),
          BottomNavigationBarItem(
              icon: Icon(FontAwesome.search), label: 'Buscar'),
          BottomNavigationBarItem(
              icon: Icon(FontAwesome.gift), label: 'Sorteios'),
          /*    BottomNavigationBarItem(
              icon: Icon(FontAwesome.handshake_o), label: 'Servi??os'), */
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
