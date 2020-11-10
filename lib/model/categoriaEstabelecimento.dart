import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';

class CategoriaEstabelecimento {
  Categoria categoria;
  List<Estabelecimento> estabelecimentos;

  CategoriaEstabelecimento(Estabelecimento estabelecimento) {
    categoria = estabelecimento.categoria;
  }

  void addEstabelecimento(Estabelecimento estabelecimento) {
    if (!estabelecimentos.contains(estabelecimento))
      estabelecimentos.add(estabelecimento);
    return;
  }

  @override
  String toString() {
    return 'Categoria: ${categoria.nome} - Estabelecimentos: ${estabelecimentos?.length}';
  }

  factory CategoriaEstabelecimento.checkListAndCreateCategoria(
      List<CategoriaEstabelecimento> categoriasEstabelecimentos,
      estabelecimento) {}
}
