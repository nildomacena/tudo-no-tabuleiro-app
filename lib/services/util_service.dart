import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class UtilService {
  File _image;
  int indexAuxImage; //Variável para incrementar a cada link temporário. Se usar o mesmo link, a imagem continua sempre a mesma
  final picker = ImagePicker();

  showSnackBarErro({String titulo, String mensagem}) {
    Get.snackbar(
        titulo != null ? titulo : 'Erro durante a operação',
        mensagem != null
            ? mensagem
            : 'Ocorreu um erro durante o processo. Tente novamente.',
        colorText: Colors.white,
        backgroundColor: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(bottom: 10));
  }

  showSnackBarSucesso({String titulo, String mensagem}) {
    Get.snackbar(titulo != null ? titulo : 'Sucesso',
        mensagem != null ? mensagem : 'Os dados foram salvos com sucesso',
        colorText: Colors.white,
        backgroundColor: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        margin: EdgeInsets.only(bottom: 10));
  }

  Future getImage() async {
    _image = null;
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
    //return compressAndGetFile(File(pickedFile.path));
    return File(pickedFile.path);
  }

  Future<File> compressAndGetFile(File file) async {
    //TODO app não está permitindo alterar a imagem uma vez selecionada. Consertar isso.

    final dir = await path_provider.getTemporaryDirectory();
    var result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        dir.path + "/temp" + indexAuxImage.toString() + ".jpg",
        quality: 70,
        minWidth: 1080,
        minHeight: 1080);
    return result;
  }
}

UtilService utilService = UtilService();
