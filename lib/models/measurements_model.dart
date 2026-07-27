// Modelo de datos para almacenar todas las medidas del usuario
// Incluye métodos para serialización/deserialización con JSON
class MeasurementsModel {
  // Contornos
  final double cuello;
  final double busto;
  final double cintura;
  final double cadera;
  final double sisa;
  final double puno;
  final double manga;
  final double rodilla;
  final double tobillo;

  // Largos
  final double largoTalle;
  final double largoBusto;
  final double largoBlusa;
  final double largoCodo;
  final double largoMangaCorta;
  final double largoManga34;
  final double largoEscoteDelantero;
  final double largoEscoteEspalda;
  final double largoCadera;
  final double largoFalda;
  final double largoPantalon;
  final double largoTiro;

  // Otros
  final double caidaBusto;
  final double separacionBusto;
  final double anchoPecho;
  final double anchoHombros;
  final double anchoEspalda;

  MeasurementsModel({
    required this.cuello,
    required this.busto,
    required this.cintura,
    required this.cadera,
    required this.sisa,
    required this.puno,
    required this.manga,
    required this.rodilla,
    required this.tobillo,
    required this.largoTalle,
    required this.largoBusto,
    required this.largoBlusa,
    required this.largoCodo,
    required this.largoMangaCorta,
    required this.largoManga34,
    required this.largoEscoteDelantero,
    required this.largoEscoteEspalda,
    required this.largoCadera,
    required this.largoFalda,
    required this.largoPantalon,
    required this.largoTiro,
    required this.caidaBusto,
    required this.separacionBusto,
    required this.anchoPecho,
    required this.anchoHombros,
    required this.anchoEspalda,
  });

  // Convierte el modelo a un mapa JSON para guardar en SharedPreferences
  Map<String, dynamic> toJson() {
    return {
      'cuello': cuello,
      'busto': busto,
      'cintura': cintura,
      'cadera': cadera,
      'sisa': sisa,
      'puño': puno,
      'manga': manga,
      'rodilla': rodilla,
      'tobillo': tobillo,
      'largoTalle': largoTalle,
      'largoBusto': largoBusto,
      'largoBlusa': largoBlusa,
      'largoCodo': largoCodo,
      'largoMangaCorta': largoMangaCorta,
      'largoManga34': largoManga34,
      'largoEscoteDelantero': largoEscoteDelantero,
      'largoEscoteEspalda': largoEscoteEspalda,
      'largoCadera': largoCadera,
      'largoFalda': largoFalda,
      'largoPantalon': largoPantalon,
      'largoTiro': largoTiro,
      'caidaBusto': caidaBusto,
      'separacionBusto': separacionBusto,
      'anchoPecho': anchoPecho,
      'anchoHombros': anchoHombros,
      'anchoEspalda': anchoEspalda,
    };
  }

  // Crea una instancia de MeasurementsModel desde un mapa JSON
  factory MeasurementsModel.fromJson(Map<String, dynamic> json) {
    return MeasurementsModel(
      cuello: json['cuello']?.toDouble() ?? 0.0,
      busto: json['busto']?.toDouble() ?? 0.0,
      cintura: json['cintura']?.toDouble() ?? 0.0,
      cadera: json['cadera']?.toDouble() ?? 0.0,
      sisa: json['sisa']?.toDouble() ?? 0.0,
      puno: json['puño']?.toDouble() ?? 0.0,
      manga: json['manga']?.toDouble() ?? 0.0,
      rodilla: json['rodilla']?.toDouble() ?? 0.0,
      tobillo: json['tobillo']?.toDouble() ?? 0.0,
      largoTalle: json['largoTalle']?.toDouble() ?? 0.0,
      largoBusto: json['largoBusto']?.toDouble() ?? 0.0,
      largoBlusa: json['largoBlusa']?.toDouble() ?? 0.0,
      largoCodo: json['largoCodo']?.toDouble() ?? 0.0,
      largoMangaCorta: json['largoMangaCorta']?.toDouble() ?? 0.0,
      largoManga34: json['largoManga34']?.toDouble() ?? 0.0,
      largoEscoteDelantero: json['largoEscoteDelantero']?.toDouble() ?? 0.0,
      largoEscoteEspalda: json['largoEscoteEspalda']?.toDouble() ?? 0.0,
      largoCadera: json['largoCadera']?.toDouble() ?? 0.0,
      largoFalda: json['largoFalda']?.toDouble() ?? 0.0,
      largoPantalon: json['largoPantalon']?.toDouble() ?? 0.0,
      largoTiro: json['largoTiro']?.toDouble() ?? 0.0,
      caidaBusto: json['caidaBusto']?.toDouble() ?? 0.0,
      separacionBusto: json['separacionBusto']?.toDouble() ?? 0.0,
      anchoPecho: json['anchoPecho']?.toDouble() ?? 0.0,
      anchoHombros: json['anchoHombros']?.toDouble() ?? 0.0,
      anchoEspalda: json['anchoEspalda']?.toDouble() ?? 0.0,
    );
  }

  // Convierte el modelo a una cadena JSON para guardar en SharedPreferences
  String toJsonString() {
    return toJson().toString();
  }
}
