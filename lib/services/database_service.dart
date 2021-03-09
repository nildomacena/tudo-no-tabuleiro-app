import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/achado.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/model/categoriaEstabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/model/oferta_emprego.dart';
import 'package:tudo_no_tabuleiro_app/model/sorteio.dart';
import 'package:tudo_no_tabuleiro_app/pages/estabelecimento_page/estabelecimento_page.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  List<Estabelecimento> estabelecimentosFinal = List();
  List<Categoria> categoriasFinal = List();
  bool backgroundMessage = false;

  final String nophoto =
      'https://firebasestorage.googleapis.com/v0/b/tradegames-2dff6.appspot.com/o/no-image-amp.jpg?alt=media&token=85ccd97e-7a19-4649-9ddf-51c78f75b921';

  int get randomNumber {
    var rng = new Random();
    for (var i = 0; i < 10; i++) {
      return rng.nextInt(100);
    }
  }

  DatabaseService();
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

  Future<dynamic> inicializarFirebase() async {
    estabelecimentosFinal = await getEstabelecimentos();
    categoriasFinal = await getCategorias();
    return;
  }

  Future<User> getUser() async {
    User user;
    await Future.delayed(Duration(seconds: 1), () {
      user = _auth.currentUser;
    });
    return user;
  }

  /// CATEGORIAS */

  Future<List<Categoria>> getCategorias() async {
    QuerySnapshot snapshot =
        await _firestore.collection('categorias').orderBy('nome').get();
    return snapshot.docs
        .map((QueryDocumentSnapshot snapshot) =>
            Categoria.fromFirestore(snapshot))
        .toList();
  }

  Stream<List<Categoria>> streamCategorias() {
    return _firestore.collection('categorias').orderBy('nome').snapshots().map(
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
    getCategoriasComEstabelecimentosModel();
    return map;
  }

  Future<dynamic> futureCategoriasComEstabelecimentos() async {
    List<Estabelecimento> estabelecimentos = List();
    if (estabelecimentosFinal == null || estabelecimentosFinal.isEmpty) {
      estabelecimentos = await getEstabelecimentos();
      estabelecimentosFinal = estabelecimentos;
    } else {
      estabelecimentos = estabelecimentosFinal;
    }
    print('estabelecimentos: $estabelecimentos');
    Map map = {};
    estabelecimentos.forEach((e) {
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

  List<CategoriaEstabelecimento> getCategoriasComEstabelecimentosModel() {
    List<CategoriaEstabelecimento> categoriasEstabelecimentos = List();

    /* Este bloco cria as CategoriaEstabelecimento únicos por categoria */
    estabelecimentosFinal.forEach((e) {
      if (categoriasEstabelecimentos.isEmpty) {
        categoriasEstabelecimentos.add(CategoriaEstabelecimento(e));
      } else {
        bool checkCategoria = false;
        categoriasEstabelecimentos.forEach((c) {
          if (e.categoria.id.contains(c.categoria.id)) checkCategoria = true;
        });
        if (!checkCategoria)
          categoriasEstabelecimentos.add(CategoriaEstabelecimento(e));
      }
    });

/* Este bloco adiciona o estabelecimento às respectivas categorias */
    estabelecimentosFinal.forEach((e) {
      categoriasEstabelecimentos.forEach((c) {});
    });

    return categoriasEstabelecimentos;
    /*  estabelecimentosFinal.forEach((e) {
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
    return map; */
  }

  Future cadastrarCategoria(File imagem, String nome) async {
    DocumentReference ref;
    try {
      ref = await _firestore
          .collection('categorias')
          .add({'ativo': true, 'imagemUrl': '', 'nome': nome});
      TaskSnapshot taskSnapshot = await storage
          .ref()
          .child('estabelecimentos-temporarios/$nome')
          .putFile(imagem)
          .snapshot;
      return ref.update({'imagemUrl': await taskSnapshot.ref.getDownloadURL()});
    } catch (e) {
      await ref.delete();
      throw e;
    }
  }

  bool categoriaPossuiEstabelecimento(Categoria categoria) {
    bool possuiEstabelecimento = false;
    estabelecimentosFinal.forEach((e) {
      if (categoria.id.contains(e.categoria.id)) possuiEstabelecimento = true;
    });
    return possuiEstabelecimento;
  }

  /// SORTEIOS */

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

  /// ESTABELECIMENTOS */

  bool get estabelecimentosCarregados =>
      estabelecimentosFinal != null && estabelecimentosFinal.isNotEmpty;

  Future<bool> carregarEstabelecimentos() async {
    estabelecimentosFinal = await getEstabelecimentos();
    return estabelecimentosFinal.length > 0;
  }

  Estabelecimento estabelecimentoById(String id) {
    return estabelecimentosFinal.where((e) => e.id == id).toList()[0];
  }

  Future<Estabelecimento> getEstabelecimentoById(String id) async {
    DocumentSnapshot estabelecimentoSnapshot =
        await _firestore.doc('estabelecimentos/$id').get();

    return Estabelecimento.fromFirestore(estabelecimentoSnapshot,
        await estabelecimentoSnapshot.reference.collection('produtos').get());
  }

  Future<List<Estabelecimento>> getEstabelecimentos() async {
    List<Estabelecimento> estabelecimentos = [];

    QuerySnapshot querySnapshot = await _firestore
        .collection('estabelecimentos')
        .where('ativo', isEqualTo: true)
        .orderBy('plano', descending: true)
        .get();
    //Estabelecimento.fromFirestore(snapshot, produtos)
    querySnapshot.docs.forEach((estabSnap) async {
      Estabelecimento estabelecimento = Estabelecimento.fromFirestore(
          estabSnap, await estabSnap.reference.collection('produtos').get());
      estabelecimentos.add(estabelecimento);
    });
    //GAMBIARRA PARA QUE A FUNÇÃO NÃO FINALIZE ANTES DE ATUALIZAR OS ESTABELECIMENTOS
    await Future.delayed(Duration(seconds: 1));
    estabelecimentosFinal = estabelecimentos;
    return estabelecimentos;
  }

  reportarErro(Estabelecimento estabelecimento, String problema) async {
    await _firestore.collection('reportErros').add({
      'estabelecimentoId': estabelecimento.id,
      'estabelecimentoNome': estabelecimento.nome,
      'timestamp': FieldValue.serverTimestamp(),
      'problema': problema
    });
    Get.snackbar('Feedback enviado',
        'Já salvamos seu feedback, iremos tentar solucionar da melhor maneira. Obrigado!',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.only(bottom: 10));
    return;
  }

  getEstabelecimentoPorCategoria(Categoria categoria) {
    return estabelecimentosFinal
        .where((estab) => estab.categoria.id.contains(categoria.id ?? 'sem-id'))
        .toList();
  }

  Future<List<Estabelecimento>> futureEstabelecimentosDestaque() async {
    List<Estabelecimento> estabelecimentos = await getEstabelecimentos();
    return estabelecimentos
        .where((estab) => estab.destaque && estab.imagemUrl != null)
        .toList();
  }

  List<Estabelecimento> getEstabelecimentosDestaque() {
    return estabelecimentosFinal
        .where((estab) => estab.destaque && estab.imagemUrl != null)
        .toList();
  }

  salvarEstabelecimentoTemporario(
      String nome,
      String descricao,
      String endereco,
      String telefone,
      Categoria categoria,
      bool telefonePrimarioWhatsapp,
      File imagem) async {
    TaskSnapshot taskSnapshot = await storage
        .ref()
        .child('estabelecimentos-temporarios/$nome')
        .putFile(imagem)
        .snapshot;

    await _firestore.collection('estabelecimentos').add({
      'ativo': true,
      'categoriaId': categoria.id,
      'categoriaNome': categoria.nome,
      'descricao': descricao ?? '',
      'destaque': false,
      'endereco': endereco,
      'horarioFuncionamento': '',
      'imagem1': '',
      'imagem2': '',
      'imagemUrl': await taskSnapshot.ref.getDownloadURL(),
      //localização
      'plano': 0,
      'nome': nome,
      'telefonePrimario': telefone,
      'telefonePrimarioWhatsapp': telefonePrimarioWhatsapp
    });
    return carregarEstabelecimentos();
  }

  /// EMPREGOS E ACHADOS E PERDIDOS */

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
