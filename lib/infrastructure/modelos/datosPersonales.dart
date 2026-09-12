class DatosPersonales {
  int? id;
  String? createdAt;
  String? nombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  String? ownerId;
  int? fotografia;

  DatosPersonales({
    this.id,
    this.createdAt,
    this.nombre,
    this.apellidoPaterno,
    this.apellidoMaterno,
    this.ownerId,
    this.fotografia,
  });

  DatosPersonales.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
    apellidoPaterno = json['apellidoPaterno'];
    apellidoMaterno = json['apellidoMaterno'];
    ownerId = json['owner_id'];
    fotografia = json['fotografia'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['apellidoPaterno'] = apellidoPaterno;
    data['apellidoMaterno'] = apellidoMaterno;
    data['owner_id'] = ownerId;
    data['fotografia'] = fotografia;
    return data;
  }
}
