class Localizacao {
  final double lat;
  final double lng;
  String placeId;
  Localizacao(this.lat, this.lng, {this.placeId});

  factory Localizacao.fromFirestore(Map map) {
    if (map == null) return null;
    return Localizacao(map['lat'], map['lng'], placeId: map['placeId']);
  }
}
