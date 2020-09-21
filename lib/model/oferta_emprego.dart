import 'package:cloud_firestore/cloud_firestore.dart';

class OfertaEmprego {
  final String id;
  final String nomeEmpresa;
  final String descricao;
  final String email;
  final String horario;


  OfertaEmprego({this.id, this.nomeEmpresa, this.descricao, this.horario, this.email});

  factory OfertaEmprego.fromFirestore(DocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data();
    return OfertaEmprego(
        id: snapshot.id,
        descricao: data['descricao'],
        nomeEmpresa: data['nomeEmpresa'],
        horario: data['horario']?? '',
        email: data['email']);
  }
}
