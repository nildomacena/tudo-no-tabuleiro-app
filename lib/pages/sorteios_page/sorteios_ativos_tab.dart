import 'package:flutter/material.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/sorteio_card_state.dart'; //Trocado para testar o card sem usar getWidget
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class SorteiosAtivosTab extends StatefulWidget {
  @override
  _SorteiosAtivosTabState createState() => _SorteiosAtivosTabState();
}

class _SorteiosAtivosTabState extends State<SorteiosAtivosTab> {
  List<Sorteio> _sorteiosAtivos;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Como participar',
                    style: TextStyle(
                        color: _primaryColor,
                        fontSize: 26,
                        fontWeight: FontWeight.w400),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                  ),
                  Text(
                    'Para participar é simples: Basta clicar no botão Participar, fazer o login com sua conta do Google e cumprir as regras no post oficial do Instagram. E pronto! Você já está concorrendo!',
                    style: TextStyle(
                      fontSize: 19,
                    ),
                  )
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(12),
          ),
          Container(
            child: StreamBuilder(
                stream: databaseService.getSorteiosPendentes(),
                builder: (BuildContext context,
                    AsyncSnapshot<List<Sorteio>> snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return Center(child: CircularProgressIndicator());
                    default:
                      if (snapshot.data == null)
                        return Container(
                          height: 21,
                          width: 32,
                          color: Colors.black,
                        );
                      else if (snapshot.data.length == 0)
                        return Container(
                          padding: EdgeInsets.fromLTRB(15, 15, 15, 15),
                          height: 200,
                          width: MediaQuery.of(context).size.width,
                          child: Text(
                            "No momento não há nenhum sorteio ativo. Mas fique atento, em breve novidades!!",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w400),
                          ),
                        );
                      return Container(
                        child: Column(
                          children: snapshot.data
                              .map((sorteio) => SorteioCard(sorteio))
                              .toList(),
                        ),
                      );
                  }
                }),
          ),
          //Padding(padding: EdgeInsets.all(10),)
        ],
      ),
    );
  }
}
