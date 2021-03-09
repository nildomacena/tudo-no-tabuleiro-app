import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/pages/sorteios_page/sorteio_card_state.dart'; //Trocado para testar o card sem usar getWidget
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';

class ResultadosSorteiosTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color _primaryColor = Theme.of(context).primaryColor;

    return Container(
      padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 15, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(12),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Text(
                      'Resultados dos sorteios',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: _primaryColor,
                          fontSize: 26,
                          fontWeight: FontWeight.w400),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(3),
                  ),
                  AutoSizeText(
                    'Se você foi um dos ganhadores, apresente o aplicativo no estabelecimento e retire o seu prêmio.',
                    textAlign: TextAlign.center,
                    minFontSize: 20,
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
                stream: databaseService.getSorteiosRealizados(),
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
                      if (snapshot.data.length == 0)
                        return Container(
                          padding: EdgeInsets.all(15),
                          child: Text(
                            'Ainda não há resultados para os sorteios, mas aguarde novidades em breve!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 23, fontWeight: FontWeight.w400),
                          ),
                        );
                      else
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
