import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:location/location.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:maps_toolkit/maps_toolkit.dart';
import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:url_launcher/url_launcher.dart';

class UtilService {
  File _image;
  int indexAuxImage; //Variável para incrementar a cada link temporário. Se usar o mesmo link, a imagem continua sempre a mesma
  final picker = ImagePicker();
  Location location = Location();
  bool
      exibiuSnackLocalizacaoTemp; //Variável para não exibir vários snackbars se a localização for temporária
  LocationData locationData;
  UtilService() {
    Location.instance.onLocationChanged.listen((event) {});
  }

  initSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    if (sharedPreferences.getBool('nao_exibir_mensagem_localizacao') == null) {
      await sharedPreferences.setBool('nao_exibir_mensagem_localizacao', false);
    }
    if (sharedPreferences.getBool('localizacao_ja_exibida') == null) {
      await sharedPreferences.setBool('localizacao_ja_exibida', false);
    }
    return;
  }

  resetSharedPreferences() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setBool('nao_exibir_mensagem_localizacao', false);
    await sharedPreferences.setBool('localizacao_ja_exibida', false);
    return;
  }

  Future<bool> initLocation() async {
    print('função initLocation');
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    await initSharedPreferences(); // Função que previne de carregar algum valor null
    await resetSharedPreferences(); //Resetar variáveis locais
    if (await requestPermissionLocation()) {
      return true;
    } else if (sharedPreferences.getBool('nao_exibir_mensagem_localizacao') ??
        false) {
      return false;
    } else {
      print('entrou no else');
      //Verifica se o app tem permissão para pegar a localização do usuário

      bool result = await Get.dialog(AlertDialog(
            title: Text('Compartilhar localização'),
            content: Text(
                'Para melhorar sua experiência, você pode compartilhar sua localização.\nDeseja fazer isso agora?'),
            actions: [
              //Botão "Não exibir mais" para o caso de o usuário já ter visualizado essa mensagem
              if (sharedPreferences.getBool('localizacao_ja_exibida'))
                FlatButton(
                  child: Text('Não exibir mais essa mensagem'),
                  onPressed: () async {
                    await sharedPreferences.setBool(
                        'nao_exibir_mensagem_localizacao', true);
                    Get.back(result: false);
                  },
                ),
              //Botão caso ele não tenha visto essa mensagem
              if (!sharedPreferences.getBool('localizacao_ja_exibida'))
                FlatButton(
                  child: Text('Não, obrigado'),
                  onPressed: () async {
                    await sharedPreferences.setBool(
                        'localizacao_ja_exibida', true);
                    Get.back(result: false);
                  },
                ),
              FlatButton(
                child: Text('Quero compartilhar'),
                onPressed: () {
                  Get.back(result: true);
                },
              )
            ],
          )) ??
          false;
      if (!result ?? false) {
        //Se retornou false, saia da função
        return false;
      }

      return requestPermissionLocation();
    }
    //IFs para verificar se o usuário quer ou não exibir localização e se essa ui
  }

  Future<bool> requestPermissionLocation() async {
    PermissionStatus _permissionGranted = await location.hasPermission();

    if (_permissionGranted == PermissionStatus.granted) {
      return true;
    } else
      _permissionGranted = await location.requestPermission();
    return _permissionGranted == PermissionStatus.granted;
  }

  num distancia(Estabelecimento estabelecimento, LocationData locationData) {
    if (estabelecimento.localizacao == null ||
        estabelecimento.localizacao.lat == null ||
        estabelecimento.localizacao.lng == null ||
        locationData == null) return -1;
    return SphericalUtil.computeDistanceBetween(
        LatLng(locationData.latitude, locationData.longitude),
        LatLng(
            estabelecimento.localizacao.lat, estabelecimento.localizacao.lng));
  }

  String calcDistancia(
      Estabelecimento estabelecimento, LocationData locationData) {
    if (estabelecimento.localizacao == null) return null;
    return ((distancia(estabelecimento, locationData) / 1000))
        .toStringAsFixed(2);
  }

  Future<num> calcularDistancia(Estabelecimento estabelecimento,
      [LocationData _locationData]) async {
    LocationData currentLocation;
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    try {
      if (_locationData != null) {
        currentLocation = _locationData;
      } else if (locationData != null)
        currentLocation = locationData;
      else if (sharedPreferences.getDouble('ultima_lat') != null &&
          sharedPreferences.getDouble('ultima_lng') != null) {
        currentLocation = LocationData.fromMap({
          'latitude': sharedPreferences.getDouble('ultima_lat'),
          'longitude': sharedPreferences.getDouble('ultima_lng')
        });
        if (!exibiuSnackLocalizacaoTemp) {
          Get.snackbar('Localização não atual',
              'Estamos utilizando sua última localização conhecida');
          exibiuSnackLocalizacaoTemp = true;
        }
      }
      if (currentLocation == null || estabelecimento.localizacao == null)
        return -1;
      return SphericalUtil.computeDistanceBetween(
          LatLng(currentLocation.latitude, currentLocation.longitude),
          LatLng(estabelecimento.localizacao.lat,
              estabelecimento.localizacao.lng));
    } catch (e) {
      print('Erro: $e');
      return -1;
    }
  }

  Stream<String> streamLocationData(Estabelecimento estabelecimento) {
    if (locationData != null)
      return Stream.value(
          (distancia(estabelecimento, locationData) / 1000).toStringAsFixed(2));
    return Location.instance.onLocationChanged.map((onLocation) {
      locationData = onLocation;
      return (distancia(estabelecimento, onLocation) / 1000).toStringAsFixed(2);
    });
  }

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

  ligarEstabelecimento(Estabelecimento estabelecimento) async {
    if (estabelecimento.telefonePrimarioWhatsapp == null ||
        estabelecimento.telefonePrimario == null) return Future.value();
    String link = estabelecimento.telefonePrimarioWhatsapp
        ? "https://api.whatsapp.com/send?phone=55${estabelecimento.telefonePrimario}&text=Ol%C3%A1%2C%20te%20achei%20no%20aplicativo%20Tudo%20no%20Tabuleiro"
        : "tel://${estabelecimento.telefonePrimario}";
    if (await canLaunch(link)) {
      return launch(link);
    }
  }

  contatoAdmin([String mensagem]) async {
    String link =
        "https://api.whatsapp.com/send?phone=5582998252806&text=${mensagem ?? ''}";

    if (await canLaunch(link)) {
      return launch(link);
    }
  }

  abrirLocalizacao(Estabelecimento estabelecimento) async {
    final availableMaps = await MapLauncher.installedMaps;
    await availableMaps.first.showMarker(
        coords: Coords(
            estabelecimento.localizacao.lat, estabelecimento.localizacao.lng),
        title: estabelecimento.nome,
        zoom: 15);
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

  entrarEmContato([String mensagem]) async {
    String link =
        'https://api.whatsapp.com/send?phone=5582998252806&text=Ol%C3%A1%2C%20gostaria%20de%20mais%20informa%C3%A7%C3%B5es%20sobre%20o%20aplicativo%20Tudo%20no%20Tabuleiro';
    if (await canLaunch(link)) {
      return launch(link);
    }
  }
}

UtilService utilService = UtilService();
