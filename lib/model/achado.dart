import 'package:cloud_firestore/cloud_firestore.dart';

class Achado {
  final String id;
  final String imagem;
  final String achadoPor;
  final String contato;
  final String descricao;

  Achado({this.id, this.imagem, this.achadoPor, this.contato, this.descricao});

  factory Achado.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return Achado(
        id: snapshot.id,
        achadoPor: data['achadoPor'],
        imagem: data['imagem'],
        descricao: data['descricao'],
        contato: data['contato'] ?? '');
  }
}
