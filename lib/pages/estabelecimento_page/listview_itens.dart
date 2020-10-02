import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:tudo_no_tabuleiro_app/model/produto.dart';

class ListViewItens extends StatelessWidget {
  final List<Produto> produtos;
  ListViewItens(this.produtos);

  @override
  Widget build(BuildContext context) {
    print('produtos');
    return ListView(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        children: produtos.map((p) => TileProduto(p)).toList());
  }
}

class TileProduto extends StatelessWidget {
  final Produto produto;

  TileProduto(this.produto);

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 110,
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
        margin: EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(
                flex: 3,
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        produto.nome,
                        maxLines: 1,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: AutoSizeText(
                          produto.descricao,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 17, fontWeight: FontWeight.w300),
                        ),
                      ),
                      Container(
                          margin: EdgeInsets.only(top: 5),
                          child: Text("R\$${produto.preco.toStringAsFixed(2)}",
                              style: TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w300))),
                    ],
                  ),
                )),
            Expanded(
              flex: 1,
              child: Container(
                height: double.infinity,
                color: Colors.grey[200],
                child: Image.network(
                    produto.imagem ??
                        'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921',
                    fit: BoxFit.cover),
              ),
            )
          ],
        )

        /* Column(
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
                        produto.nome,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500),
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 5),
                        child: AutoSizeText(
                          produto.descricao,
                          maxLines: 2,
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w300),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Colors.grey[200],
                    child: Image.network(
                        produto.imagem ??
                            'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921',
                        fit: BoxFit.cover),
                  ),
                )
              ],
            ),
          ),
          Container(
              margin: EdgeInsets.only(top: 5),
              child: Text("R\$${produto.preco.toStringAsFixed(2)}")),
          Divider()
        ],
      ), */
        );
  }
}
