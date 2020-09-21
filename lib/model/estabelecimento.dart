import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/localizacao.dart';
import 'package:tudo_no_tabuleiro_app/model/produto.dart';

enum Plano { basico, inter, top }

class Estabelecimento {
  final String id;
  final bool ativo;
  final String nome;
  final String uidUser;
  final String endereco;
  final String descricao;
  final String imagemUrl;
  final Categoria categoria;
  final String horarioFuncionamento;
  final String telefonePrimario;
  final bool telefonePrimarioWhatsapp;
  final String telefoneSecundario;
  final String nomeResponsavel;
  final String telefoneResponsavel;
  final String imagem1;
  final String imagem2;
  final Plano plano;
  final Localizacao localizacao;
  List<Produto> produtos;
  final bool destaque;
  List<String> tags;
  Estabelecimento(
      {this.nome,
      this.imagemUrl,
      this.endereco,
      this.categoria,
      this.ativo,
      this.descricao,
      this.destaque,
      this.horarioFuncionamento,
      this.id,
      this.imagem1,
      this.imagem2,
      this.nomeResponsavel,
      this.plano,
      this.produtos,
      this.telefonePrimario,
      this.telefonePrimarioWhatsapp,
      this.telefoneResponsavel,
      this.telefoneSecundario,
      this.uidUser,
      this.localizacao,
      this.tags}) {
    if (tags == null) tags = [];
  }

  @override
  String toString() {
    return '$nome - $endereco - produtos cadastrados: ${produtos.length} - Plano: $plano';
  }

  bool search(String str) {
    String stringTags = '';
    str = str.toLowerCase();
    tags.forEach((t) => stringTags += t.toLowerCase());
    return nome.toLowerCase().contains(str) ||
        stringTags.contains(str) ||
        categoria.nome.toLowerCase().contains(str);
  }

  factory Estabelecimento.fromFirestore(
      DocumentSnapshot snapshot, QuerySnapshot snapshotProdutos) {
    List<Produto> produtos = [];
    List<String> tagsAux =
        []; //Variavel pra auxiliar num bug ao trazer as tags do banco de dados

    Map<String, dynamic> data = snapshot.data();
    Categoria categoria =
        Categoria(id: data['categoriaId'], nome: data['categoriaNome']);
    Plano plano = data['plano'] == 'basico'
        ? Plano.basico
        : data['plano'] == 'inter' ? Plano.inter : Plano.top;
    if (snapshotProdutos != null && snapshotProdutos.docs.length > 0)
      produtos = snapshotProdutos.docs
          .map((snapProduto) => Produto.fromFirestore(snapProduto))
          .toList();

    if (data['tags'] != null) {
      data['tags'].forEach((t) {
        tagsAux.add(t.toString());
      });
    }

    return Estabelecimento(
      id: snapshot.id,
      descricao: data['descricao'],
      nome: data['nome'],
      ativo: data['ativo'] ?? false,
      categoria: categoria,
      produtos: produtos,
      destaque: data['destaque'] ?? false,
      endereco: data['endereco'],
      horarioFuncionamento: data['horarioFuncionamento'],
      imagem1: data['imagem1'],
      imagem2: data['imagem2'],
      imagemUrl: data['imagemUrl'],
      localizacao: Localizacao.fromFirestore(data['localizacao']),
      plano: plano,
      nomeResponsavel: data['nomeResponsavel'],
      telefonePrimario: data['telefonePrimario'],
      telefoneSecundario: data['telefoneSecundario'],
      telefonePrimarioWhatsapp: data['telefonePrimarioWhatsapp'],
      telefoneResponsavel: data['telefoneResponsavel'],
      tags: tagsAux ?? [],
      uidUser: data['uidUser'],
    );
  }
}
