import 'package:cloud_firestore/cloud_firestore.dart';

class Categoria {
  final String id;
  final String nome;
  bool destaque;
  String icone;
  String imagemUrl;

  Categoria({this.id, this.nome, this.imagemUrl, this.destaque, this.icone}) {
    if (imagemUrl == null) this.imagemUrl = '';
    if (icone == null) this.icone = '';
    if (destaque == null) this.destaque = false;
  }

  factory Categoria.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return Categoria(
        id: snapshot.id,
        nome: data['nome'],
        imagemUrl: data['imagemUrl'],
        icone: data['icone'] ?? '',
        destaque: data['destaque'] ?? false);
  }

  @override
  String toString() {
    return '$nome';
  }
}
