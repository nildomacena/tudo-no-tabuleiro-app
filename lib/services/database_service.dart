import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/model/oferta_emprego.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Estabelecimento> estabelecimentosFinal;
  bool backgroundMessage = false;

  final String nophoto =
      'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921';

  Future<void> checkUserBDInfo(User user) async {
    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .get();
    if (snapshot.docs.length > 0)
      return Future.value();
    else
      return _firestore.doc('users/${user.uid}').set({
        'uid': user.uid,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'email': user.email,
        'admin': false
      });
  }

  /// CATEGORIAS */

  Stream<List<Categoria>> streamCategorias() {
    return _firestore.collection('categorias').snapshots().map(
        (QuerySnapshot querySnapshot) => querySnapshot.docs
            .map((QueryDocumentSnapshot snapshot) =>
                Categoria.fromFirestore(snapshot))
            .toList());
  }

  dynamic getCategoriasComEstabelecimentos() {
    Map map = {};
    estabelecimentosFinal.forEach((e) {
      if (map[e.categoria.id] == null) {
        map[e.categoria.id] = {
          'nome': e.categoria.id,
          'estabelecimentos': [e],
          'categoria': e.categoria
        };
      } else {
        map[e.categoria.id]['estabelecimentos'].add(e);
      }
    });
    return map;
  }

  bool categoriaPossuiEstabelecimento(Categoria categoria) {
    bool possuiEstabelecimento = false;
    estabelecimentosFinal.forEach((e) {
      if (categoria.id.contains(e.categoria.id)) possuiEstabelecimento = true;
    });
    return possuiEstabelecimento;
  }

  /**SORTEIOS */

  Stream<List<Sorteio>> getSorteiosRealizados() {
    return _firestore
        .collection('sorteios')
        .where('pendente', isEqualTo: false)
        .orderBy('dataSorteio')
        .snapshots()
        .map((snapshot) {
      List<Sorteio> sorteios = [];
      snapshot.docs.forEach((docSnap) {
        sorteios.add(Sorteio.fromFirestore(docSnap));
      });
      return sorteios;
    });
  }

  Stream<List<Sorteio>> getSorteiosPendentes() {
    return _firestore
        .collection('sorteios')
        .where('pendente', isEqualTo: true)
        .orderBy('data')
        .snapshots()
        .map((snapshot) {
      List<Sorteio> sorteios = [];
      snapshot.docs.forEach((docSnap) {
        sorteios.add(Sorteio.fromFirestore(docSnap));
      });
      return sorteios;
    });
  }

  Future<dynamic> inscreverSorteio(Sorteio sorteio) async {
    User _user = FirebaseAuth.instance.currentUser;
    DocumentSnapshot _atualSnapshot =
        await _firestore.doc('sorteios/${sorteio.id}').get();
    List<dynamic> _listaParticipantes = List();
    if (_atualSnapshot.data()['participantes'] != null) {
      _atualSnapshot.data()['participantes'].forEach((p) {
        _listaParticipantes.add(p);
      });
    }
    _listaParticipantes.add(_user.uid);
    await _firestore
        .doc('sorteios/${sorteio.id}')
        .update({'participantes': _listaParticipantes});

    return;
    //return _firebaseMessaging.subscribeToTopic('${sorteio.id}_${_user.uid}');
  }

  /**ESTABELECIMENTOS */

  Future<bool> carregarEstabelecimentos() async {
    estabelecimentosFinal = await getEstabelecimentos();
    return estabelecimentosFinal.length > 0;
  }

  Future<List<Estabelecimento>> getEstabelecimentos() async {
    List<Estabelecimento> estabelecimentos = [];

    QuerySnapshot querySnapshot = await _firestore
        .collection('estabelecimentos')
        .where('ativo', isEqualTo: true)
        .get();
    //Estabelecimento.fromFirestore(snapshot, produtos)
    querySnapshot.docs.forEach((estabSnap) async {
      Estabelecimento estabelecimento = Estabelecimento.fromFirestore(
          estabSnap, await estabSnap.reference.collection('produtos').get());
      estabelecimentos.add(estabelecimento);
    });
    //GAMBIARRA PARA QUE A FUNÇÃO NÃO FINALIZE ANTES DE ATUALIZAR OS ESTABELECIMENTOS
    await Future.delayed(Duration(seconds: 1));
    return estabelecimentos;
  }

  getEstabelecimentoPorCategoria(Categoria categoria) {
    return estabelecimentosFinal
        .where((estab) => estab.categoria.id.contains(categoria.id ?? 'sem-id'))
        .toList();
  }

  List<Estabelecimento> getEstabelecimentosDestaque() {
    return estabelecimentosFinal.where((estab) => estab.destaque).toList();
  }

  /**EMPREGOS E ACHADOS E PERDIDOS */

  Future<List<OfertaEmprego>> getOfertasEmprego() async {
    QuerySnapshot querySnapshot =
        await this._firestore.collection('ofertas_emprego').get();
    return querySnapshot.docs
        .map((s) => OfertaEmprego.fromFirestore(s))
        .toList();
  }

  Future<List<Achado>> getAchados() async {
    QuerySnapshot querySnapshot =
        await this._firestore.collection('achados').get();
    return querySnapshot.docs.map((s) => Achado.fromFirestore(s)).toList();
  }
}

DatabaseService databaseService = DatabaseService();
