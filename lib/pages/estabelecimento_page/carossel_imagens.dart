import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tudo_no_tabuleiro_app/model/estabelecimento.dart';
import 'package:tudo_no_tabuleiro_app/pages/visualizar_imagem_page/visualizar_imagem_page.dart';

class CarrosselImagens extends StatelessWidget {
  final Estabelecimento estabelecimento;
  CarrosselImagens(this.estabelecimento);

  bool autoPlay() {
    return estabelecimento.imagem1 != null &&
        estabelecimento.imagem1 != '' &&
        estabelecimento.imagem2 != null &&
        estabelecimento.imagem2 != '';
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
        options: CarouselOptions(
            enlargeCenterPage: true, height: 500, autoPlay: autoPlay()),
        items: [
          if (estabelecimento.imagem1 != null && estabelecimento.imagem1 != '')
            InkWell(
              child: Image.network(estabelecimento.imagem1),
              onTap: () {
                Get.to(VisualizarImagemPage(estabelecimento.imagem1));
              },
            ),
          if (estabelecimento.imagem2 != null && estabelecimento.imagem2 != '')
            InkWell(
              child: Image.network(estabelecimento.imagem2),
              onTap: () {
                Get.to(VisualizarImagemPage(estabelecimento.imagem2));
              },
            ),
        ] /* estabelecimento..map((e) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      e.imagemUrl,
                      fit: BoxFit.fill,
                    ),
                    Positioned.fill(
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.blue.withOpacity(.5),
                          onTap: () {},
                        ),
                      ),
                    )
                  ],
                ));
          },
        );
      }).toList(), */
        );
  }
}
