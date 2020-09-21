import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/resultados_sorteios_tab.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/sorteios_ativos_tab.dart';

class SorteiosPage extends StatefulWidget {
  @override
  _SorteiosPageState createState() => _SorteiosPageState();
}

class _SorteiosPageState extends State<SorteiosPage>
    with TickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: 2);
    /* if(authService.currentUser != null){
      print('user: ${authService.currentUser}');
      Fluttertoast.showToast(
        msg: "Você está logado com o email: ${authService.currentUser.email}",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIos: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0
    );

    } */
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: Container(
          color: Theme.of(context).primaryColor,
          child: SafeArea(
            child: TabBar(
              indicatorWeight: 3,
              indicatorColor: Colors.white,
              controller: _tabController,
              tabs: <Widget>[
                Tab(
                  child: Text(
                    "Sorteios",
                  ),
                ),
                Tab(child: Text("Resultados")),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        //padding: EdgeInsets.all(10),
        child: TabBarView(
          controller: _tabController,
          children: <Widget>[SorteiosAtivosTab(), ResultadosSorteiosTab()],
        ),
      ),
    );
  }
}
