import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  final String id;
  final String nome;
  String imagemUrl;

  Categoria({this.id, this.nome, this.imagemUrl}) {
    if (this.imagemUrl == null) this.imagemUrl = '';
  }

  factory Categoria.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return Categoria(
        id: snapshot.id, nome: data['nome'], imagemUrl: data['imagemUrl']);
  }

  @override
  String toString() {
    return '$nome';
  }
}
