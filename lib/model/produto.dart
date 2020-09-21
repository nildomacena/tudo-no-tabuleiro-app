import 'package:cloud_firestore/cloud_firestore.dart';

class Produto {
  final String id;
  final String nome;
  final String descricao;
  final String imagem;
  final double preco;

  Produto({this.id, this.nome, this.descricao, this.imagem, this.preco});

  factory Produto.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return Produto(
        id: snapshot.id,
        descricao: data['descricao'],
        nome: data['nome'],
        preco: data['preco'].toDouble() ?? 0,
        imagem: data['imagem']);
  }
}
