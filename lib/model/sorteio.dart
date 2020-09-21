import 'package:cloud_firestore/cloud_firestore.dart';

class Sorteio {
  final String id;
  final String imagem;
  final String titulo;
  final DateTime data;
  final bool pendente;
  final String link;
  final String instrucoes;
  final List<dynamic> participantes;
  final String ganhador;
  final String ganhadorEmail;
  final String ganhadorUid;
  final String descricao;
  String estabelecimentoId;
  String estabelecimentoNome;
  Sorteio(
      {this.id,
      this.titulo,
      this.data,
      this.imagem,
      this.pendente,
      this.instrucoes,
      this.link,
      this.participantes,
      this.ganhador,
      this.ganhadorEmail,
      this.ganhadorUid,
      this.estabelecimentoId,
      this.estabelecimentoNome, 
      this.descricao});

  factory Sorteio.fromFirestore(DocumentSnapshot snapshot) {
    Map data = snapshot.data();
    return Sorteio(
        id: snapshot.id,
        titulo: data['titulo'],
        pendente: data['pendente'],
        data: data['data'].toDate(),
        imagem: data['imagem'],
        ganhador: data['ganhador'] ?? '',
        ganhadorEmail: data['ganhadorEmail'] ?? '',
        ganhadorUid: data['ganhadorUid'] ?? '',
        estabelecimentoId: data['estabelecimentoId'],
        estabelecimentoNome: data['estabelecimentoNome'],
        descricao: data['descricao'] ?? '',
        instrucoes: data['instrucoes'] ??
            'Marque três amigos na postagem oficial do sorteio',
        link: data['link'] ?? 'https://www.instagram.com/p/B2kJSBsBdMz/',
        participantes: data['participantes'] ?? []);
  }

  @override
  String toString() {
    return 'ID: $id - Título: $titulo - Data: $data - Pendente: $pendente - Participantes: $participantes';
  }
}
