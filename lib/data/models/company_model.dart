class Company {
  int? id;
  final String nombreEmpresa;
  final String correo;
  final String? telefono;
  final String? direccion;
  final String? descripcion;
  final String? rutEmpresa;
  final String? encargado;
  final String? dueno;
  final String? horaApertura;
  final String? horaCierre;
  final List<String>? diasOperacion;
  final int? userId;
  final String? logo;
  final String? sitioWeb;

  Company({
    this.id,
    required this.nombreEmpresa,
    required this.correo,
    this.telefono,
    this.direccion,
    this.descripcion,
    this.rutEmpresa,
    this.encargado,
    this.dueno,
    this.horaApertura,
    this.horaCierre,
    this.diasOperacion,
    this.userId,
    this.logo,
    this.sitioWeb,
  });

  factory Company.fromJson(Map<String, dynamic> json) => Company(
        id: json['id'],
        nombreEmpresa: json['nombreEmpresa'],
        correo: json['correo'],
        telefono: json['telefono'],
        direccion: json['direccion'],
        descripcion: json['descripcion'],
        rutEmpresa: json['rutEmpresa'],
        encargado: json['encargado'],
        dueno: json['dueno'],
        horaApertura: json['horaApertura'],
        horaCierre: json['horaCierre'],
        diasOperacion: json['diasOperacion'] is String
            ? (json['diasOperacion'] as String).split(',')
            : (json['diasOperacion'] ?? []).cast<String>(),
        userId: json['userId'],
        logo: json['logo'],
        sitioWeb: json['sitioWeb'],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombreEmpresa": nombreEmpresa,
        "correo": correo,
        "telefono": telefono,
        "direccion": direccion,
        "descripcion": descripcion,
        "rutEmpresa": rutEmpresa,
        "encargado": encargado,
        "dueno": dueno,
        "horaApertura": horaApertura,
        "horaCierre": horaCierre,
        "diasOperacion": diasOperacion?.join(","),
        "userId": userId,
        "logo": logo,
        "sitioWeb": sitioWeb,
      };
}
