import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class CadastroCategoriaPage extends StatefulWidget {
  @override
  _CadastroCategoriaPageState createState() => _CadastroCategoriaPageState();
}

class _CadastroCategoriaPageState extends State<CadastroCategoriaPage> {
  TextEditingController textEditingController = new TextEditingController();
  FocusNode nomeFocus = FocusNode();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 19);
  File image;
  bool salvando;

  @override
  void initState() {
    salvando = false;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final salvarButton = Container(
      child: RaisedButton(
          color: Colors.blue,
          onPressed: image == null || salvando
              ? null
              : () async {
                  if (_formKey.currentState.validate())
                    try {
                      setState(() {
                        salvando = true;
                      });
                      await databaseService.cadastrarCategoria(
                          image, textEditingController.text);
                      Get.back();
                    } catch (e) {
                      print('Erro cadastro estabelecimento Temporário: $e');
                      utilService.showSnackBarErro();
                    }
                  setState(() {
                    salvando = false;
                  });
                },
          child: Text(
            salvando ? 'SALVANDO DADOS...' : 'SALVAR CATEGORIA',
            style: TextStyle(color: Colors.white),
          )),
    );

    final nomeField = TextFormField(
        obscureText: false,
        style: style,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
        controller: textEditingController,
        focusNode: nomeFocus,
        textInputAction: TextInputAction.next,
        validator: (value) {
          if (value.isEmpty) return "Digite o nome da categoria";
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Nome da categoria",
            hintStyle:
                TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
            border: UnderlineInputBorder()));

    final containerFoto = AnimatedContainer(
        duration: Duration(seconds: 1),
        height: image != null ? 300 : 50,
        width: Get.width,
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: Column(
          children: [
            if (image != null) Image.file(image, fit: BoxFit.cover),
            RaisedButton(
              onPressed: () async {
                try {
                  File result = await utilService.getImage();
                  setState(() {
                    image = result;
                  });
                } catch (e) {
                  utilService.showSnackBarErro();
                  print(e);
                }
              },
              child: Text('Selecionar Imagem'),
            ),
          ],
        ));

    return Scaffold(
      appBar: AppBar(
        title: Text('Cadastro categoria'),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [nomeField, containerFoto, salvarButton],
          ),
        ),
      ),
    );
  }
}
