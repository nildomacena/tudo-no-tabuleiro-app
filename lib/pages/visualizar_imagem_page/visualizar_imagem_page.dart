import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pinch_zoom_image_last/pinch_zoom_image_last.dart';

class VisualizarImagemPage extends StatelessWidget {
  final String urlImagem;

  VisualizarImagemPage(this.urlImagem);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Container(
        alignment: Alignment.center,
        height: Get.height,
        width: Get.width,
        child: PinchZoomImage(
          image: Image.network(urlImagem),
        ),
      )),
    );
  }
}
