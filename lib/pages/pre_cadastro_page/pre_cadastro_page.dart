import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tudo_no_tabuleiro_app/model/categoria.dart';
import 'package:tudo_no_tabuleiro_app/pages/home_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/pre_cadastro_page/google_maps_page.dart';
import 'package:tudo_no_tabuleiro_app/pages/pre_cadastro_page/select_categoria_page.dart';
import 'package:tudo_no_tabuleiro_app/services/database_service.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:tudo_no_tabuleiro_app/services/util_service.dart';

class PreCadastroPage extends StatefulWidget {
  @override
  _PreCadastroPageState createState() => _PreCadastroPageState();
}

class _PreCadastroPageState extends State<PreCadastroPage> {
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 19);
  final picker = ImagePicker();
  bool telefoneWhatsapp = false;

  TextEditingController nomeController = TextEditingController();
  TextEditingController descricaoController = TextEditingController();
  TextEditingController enderecoController = TextEditingController();
  TextEditingController telefoneController = TextEditingController();

  FocusNode nomeFocus = FocusNode();
  FocusNode descricaoFocus = FocusNode();
  FocusNode enderecoFocus = FocusNode();
  FocusNode telefoneFocus = FocusNode();
  bool salvando;
  File _image;
  Categoria categoriaSelecionada;
  Location location = new Location();
  LocationData _locationData;
  LatLng latLng; // Variável que armazena a localização do estabelecimento

  @override
  void initState() {
    salvando = false;
    super.initState();
  }

  Future getImage() async {
    _image = null;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    /*   compressAndGetFile(File(pickedFile.path)).then((result) {
      setState(() {
        if (pickedFile != null) {
          _image = result;
        }
      });
    }); */

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<File> compressAndGetFile(File file) async {
    //TODO app não está permitindo alterar a imagem uma vez selecionada. Consertar isso.

    final dir = await path_provider.getTemporaryDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path, dir.path + "/temp.jpg",
        quality: 70, minWidth: 1080, minHeight: 1080);
    return result;
  }

  buscarLocalizacao([LocationData locationData]) async {
    Get.to(GoogleMapsPage(
      locationData: locationData,
    )).then((value) {
      setState(() {
        latLng = value;
      });
    });

    print('latLng pre cadastro: $latLng');
  }

  checkCadastrarNovo() async {
    //VERIFICA SE O USUÁRIO QUER CADASTRAR OUTRO ESTABELECIMENTO
    bool result = await Get.dialog(AlertDialog(
      title: Text('Estabelecimento Cadastrado'),
      content: Text('Deseja cadastrar um novo estabelecimento?'),
      actions: [
        TextButton(
          child: Text('NÃO'),
          onPressed: () {
            Get.back(result: false);
          },
        ),
        TextButton(
          child: Text('SIM'),
          onPressed: () {
            Get.back(result: true);
          },
        ),
      ],
    ));
    if (result) {
      nomeController.clear();
      descricaoController.clear();
      enderecoController.clear();
      telefoneController.clear();
      setState(() {
        _image = null;
      });
    } else {
      Get.offAll(HomePage());
    }
  }

  @override
  Widget build(BuildContext context) {
    void enviarFormulario() async {
      setState(() {
        salvando = true;
      });
      if (_formKey.currentState.validate() && _image != null) {
        try {
          await databaseService.salvarEstabelecimentoTemporario(
              nomeController.text,
              descricaoController.text,
              enderecoController.text,
              telefoneController.text,
              categoriaSelecionada,
              telefoneWhatsapp,
              _image);
          setState(() {
            salvando = false;
          });
          Get.back(result: true);
          print('formulario correto');
        } catch (e) {
          print('Erro: $e');
          setState(() {
            salvando = false;
          });
          Get.snackbar('Erro durante a operação',
              'Ocorreu um erro durante o processo. Tente novamente.',
              colorText: Colors.white,
              backgroundColor: Colors.red,
              snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        setState(() {
          salvando = false;
        });
        Get.snackbar('Formulário',
            'Preencha todos os dados para salvar o cadastro do bem',
            colorText: Colors.white,
            backgroundColor: Colors.red,
            snackPosition: SnackPosition.BOTTOM);
      }
    }

    final nomeField = TextFormField(
        obscureText: false,
        style: style,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
        controller: nomeController,
        focusNode: nomeFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) {
          nomeFocus.unfocus();
          FocusScope.of(context).requestFocus(descricaoFocus);
        },
        validator: (value) {
          if (value.isEmpty) return "Digite a descrição do bem";
        },
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Nome do estabelecimento",
            hintStyle:
                TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
            border: UnderlineInputBorder()));

    final descricaoField = TextFormField(
        obscureText: false,
        style: style,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
        controller: descricaoController,
        focusNode: descricaoFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) {
          descricaoFocus.unfocus();
          FocusScope.of(context).requestFocus(enderecoFocus);
        },
        /* validator: (value) {
          if (value.isEmpty) return "Digite a descrição do bem";
        }, */
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Descrição",
            hintStyle:
                TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
            border: UnderlineInputBorder()));

    final enderecoField = TextFormField(
        obscureText: false,
        style: style,
        textCapitalization: TextCapitalization.sentences,
        keyboardType: TextInputType.text,
        controller: enderecoController,
        focusNode: enderecoFocus,
        textInputAction: TextInputAction.next,
        onFieldSubmitted: (value) {
          enderecoFocus.unfocus();
          FocusScope.of(context).requestFocus(telefoneFocus);
        },
        /* validator: (value) {
          if (value.isEmpty) return "Digite a descrição do bem";
        }, */
        decoration: InputDecoration(
            contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
            hintText: "Endereço",
            hintStyle:
                TextStyle(color: Colors.grey[400], fontWeight: FontWeight.w400),
            border: UnderlineInputBorder()));
    final telefoneField = Container(
      height: 50,
      width: Get.width,
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
                obscureText: false,
                style: style,
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.phone,
                controller: telefoneController,
                focusNode: telefoneFocus,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (value) {
                  telefoneFocus.unfocus();
                  //FocusScope.of(context).requestFocus(numeroSerieFocus);
                },
                /* validator: (value) {
            if (value.isEmpty) return "Digite a descrição do bem";
        }, */
                decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                    hintText: "Telefone Estabelecimento",
                    hintStyle: TextStyle(
                        color: Colors.black26, fontWeight: FontWeight.w400),
                    border: UnderlineInputBorder())),
          ),
          Checkbox(
              value: telefoneWhatsapp,
              onChanged: (value) {
                setState(() {
                  telefoneWhatsapp = value;
                });
              }),
          GestureDetector(
            onTap: () {
              setState(() {
                telefoneWhatsapp = !telefoneWhatsapp;
              });
            },
            child: AutoSizeText(
              'WhatsApp?',
              maxLines: 1,
              style: TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );

    final botaoLocalizacao = Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: RaisedButton(
          onPressed: () async {
            if (await location.serviceEnabled()) {
              buscarLocalizacao(await location.getLocation());
            } else {
              bool continuar = await Get.dialog(AlertDialog(
                title: Text('GPS desligado'),
                content: Text('Deseja continuar?'),
                actions: [
                  TextButton(
                    child: Text('Sim'),
                    onPressed: () {
                      Get.back(result: true);
                    },
                  ),
                  TextButton(
                    child: Text('Não'),
                    onPressed: () {
                      Get.back(result: false);
                    },
                  )
                ],
              ));
              if (!continuar)
                return;
              else {
                buscarLocalizacao();
              }
            }
          },
          child: Text(
              'Localização | ${latLng?.latitude?.toStringAsFixed(4)}, ${latLng?.longitude?.toStringAsFixed(4)} '),
        ));

    final fotoContainer = Container(
      margin: EdgeInsets.only(bottom: 10),
      height: 200,
      width: Get.width,
      child: Column(
        children: [
          if (_image != null)
            Expanded(
              child: Image.file(
                _image,
                fit: BoxFit.cover,
              ),
            ),
          RaisedButton(
            child: Text('SELECIONAR IMAGEM'),
            onPressed: getImage,
          )
        ],
      ),
    );

    final selectCategoriaContainer = Container(
        margin: EdgeInsets.only(top: 10, bottom: 10),
        child: RaisedButton(
          onPressed: () async {
            Categoria result = await Get.to(SelectCategoriaPage());
            if (result != null && result.runtimeType == Categoria) {
              setState(() {
                categoriaSelecionada = result;
              });
              print('categoria Selecionada: ${categoriaSelecionada.nome}');
            }
          },
          child: Text(categoriaSelecionada != null
              ? 'CATEGORIA: ${categoriaSelecionada.nome.toUpperCase()}'
              : 'SELECIONAR CATEGORIA'),
        ));

    final salvarButton = Container(
      child: RaisedButton(
          color: Colors.blue,
          onPressed: salvando || _image == null || categoriaSelecionada == null
              ? null
              : () async {
                  if (_formKey.currentState.validate())
                    try {
                      setState(() {
                        salvando = true;
                      });
                      await databaseService.salvarEstabelecimentoTemporario(
                          nomeController.text,
                          descricaoController.text,
                          enderecoController.text,
                          telefoneController.text,
                          categoriaSelecionada,
                          telefoneWhatsapp,
                          _image);
                      checkCadastrarNovo(); // Pergunta ao usuário se ele vai cadastrar mais algum estabelecimento
                    } catch (e) {
                      print('Erro cadastro estabelecimento Temporário: $e');
                      utilService.showSnackBarErro();
                    }
                  setState(() {
                    salvando = false;
                  });
                },
          child: Text(
            salvando ? 'SALVANDO DADOS...' : 'SALVAR ESTABELECIMENTO',
            style: TextStyle(color: Colors.white),
          )),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Pré cadastro'),
      ),
      body: Container(
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              nomeField,
              descricaoField,
              enderecoField,
              telefoneField,
              selectCategoriaContainer,
              botaoLocalizacao,
              fotoContainer,
              salvarButton
            ],
          ),
        ),
      ),
    );
  }
}
