class DatosPersonales {
  int? id;
  String? createdAt;
  String? nombre;
  String? apellidoPaterno;
  String? apellidoMaterno;
  String? ownerId;
  String? fotografia;

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
    apellidoPaterno = json['apellido_paterno'];
    apellidoMaterno = json['apellido_materno'];
    ownerId = json['owner_id'];
    fotografia = json['fotografia'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['apellido_paterno'] = apellidoPaterno;
    data['apellido_materno'] = apellidoMaterno;
    data['owner_id'] = ownerId;
    data['fotografia'] = fotografia;
    return data;
  }
}

class Documento {
  int? id;
  String? createdAt;
  String? imagenUno;
  String? imagenDos;
  int? tipoDocumentoId;
  String? ownerId;
  Map<String, dynamic>? tipo;

  Documento({
    this.id,
    this.createdAt,
    this.imagenUno,
    this.imagenDos,
    this.tipoDocumentoId,
    this.ownerId,
    this.tipo,
  });

  Documento.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    imagenUno = json['imagen_uno'];
    imagenDos = json['imagen_dos'];
    tipoDocumentoId = (json['tipo_documento_id'] is String)
        ? int.tryParse(json['tipo_documento_id'])
        : json['tipo_documento_id'];
    ownerId = json['owner_id'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['imagen_uno'] = imagenUno;
    data['imagen_dos'] = imagenDos;
    data['tipo_documento_id'] = tipoDocumentoId;
    data['owner_id'] = ownerId;
    data['tipo'] = tipo;
    return data;
  }
}

class Tipo {
  int? id;
  String? createdAt;
  String? nombre;
  String? color;

  Tipo({this.id, this.createdAt, this.nombre, this.color});

  Tipo.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['color'] = color;
    return data;
  }
}

class Medio {
  int? id;
  String? createdAt;
  String? nombre;
  String? color;

  Medio({this.id, this.createdAt, this.nombre, this.color});

  Medio.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['color'] = color;
    return data;
  }
}

class Compra {
  int? id;
  String? createdAt;
  int? medioId;
  int? statusId;
  double? cantidad;
  String? descripcion;
  String? firma;
  int? cuentaId;
  int? merchantId;
  Map<String, dynamic>? medio;
  Map<String, dynamic>? status;

  Compra({
    this.id,
    this.createdAt,
    this.medioId,
    this.statusId,
    this.cantidad,
    this.descripcion,
    this.firma,
    this.cuentaId,
    this.merchantId,
    this.medio,
    this.status,
  });

  Compra.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    medioId = (json['medio_id'] is String)
        ? int.tryParse(json['medio_id'])
        : json['medio_id'];
    statusId = (json['status_id'] is String)
        ? int.tryParse(json['status_id'])
        : json['status_id'];
    cantidad = json['cantidad'] != null
        ? (json['cantidad'] is int
              ? (json['cantidad'] as int).toDouble()
              : json['cantidad'])
        : null;
    descripcion = json['descripcion'];
    firma = json['firma'];
    cuentaId = (json['cuenta_id'] is String)
        ? int.tryParse(json['cuenta_id'])
        : json['cuenta_id'];
    merchantId = (json['merchant_id'] is String)
        ? int.tryParse(json['merchant_id'])
        : json['merchant_id'];
    medio = json['medio'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['medio_id'] = medioId;
    data['status_id'] = statusId;
    data['cantidad'] = cantidad;
    data['descripcion'] = descripcion;
    data['firma'] = firma;
    data['cuenta_id'] = cuentaId;
    data['merchant_id'] = merchantId;
    data['medio'] = medio;
    data['status'] = status;
    return data;
  }
}

class Cuenta {
  int? id;
  String? createdAt;
  int? tipoId;
  String? apodo;
  double? saldo;
  double? recompensas;
  String? ownerId;
  String? attendantId;
  Map<String, dynamic>? tipo;

  Cuenta({
    this.id,
    this.createdAt,
    this.tipoId,
    this.apodo,
    this.saldo,
    this.recompensas,
    this.ownerId,
    this.attendantId,
    this.tipo,
  });

  Cuenta.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    tipoId = (json['tipo_id'] is String)
        ? int.tryParse(json['tipo_id'])
        : json['tipo_id'];
    apodo = json['apodo'];
    saldo = json['saldo'] != null
        ? (json['saldo'] is int
              ? (json['saldo'] as int).toDouble()
              : json['saldo'])
        : null;
    recompensas = json['recompensas'] != null
        ? (json['recompensas'] is int
              ? (json['recompensas'] as int).toDouble()
              : json['recompensas'])
        : null;
    ownerId = json['owner_id'];
    attendantId = json['attendant_id'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['tipo_id'] = tipoId;
    data['apodo'] = apodo;
    data['saldo'] = saldo;
    data['recompensas'] = recompensas;
    data['owner_id'] = ownerId;
    data['attendant_id'] = attendantId;
    data['tipo'] = tipo;
    return data;
  }
}

class PreMovimiento {
  int? id;
  String? createdAt;
  int? tipoId;
  double? cantidad;
  String? descripcion;
  int? medioId;
  int? cuentaId;
  int? statusId;
  Map<String, dynamic>? tipo;
  Map<String, dynamic>? medio;
  Map<String, dynamic>? status;

  PreMovimiento({
    this.id,
    this.createdAt,
    this.tipoId,
    this.cantidad,
    this.descripcion,
    this.medioId,
    this.cuentaId,
    this.statusId,
    this.tipo,
    this.medio,
    this.status,
  });

  PreMovimiento.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    tipoId = (json['tipo_id'] is String)
        ? int.tryParse(json['tipo_id'])
        : json['tipo_id'];
    cantidad = json['cantidad'] != null
        ? (json['cantidad'] is int
              ? (json['cantidad'] as int).toDouble()
              : json['cantidad'])
        : null;
    descripcion = json['descripcion'];
    medioId = (json['medio_id'] is String)
        ? int.tryParse(json['medio_id'])
        : json['medio_id'];
    cuentaId = (json['cuenta_id'] is String)
        ? int.tryParse(json['cuenta_id'])
        : json['cuenta_id'];
    statusId = (json['status_id'] is String)
        ? int.tryParse(json['status_id'])
        : json['status_id'];
    tipo = json['tipo'];
    medio = json['medio'];
    status = json['status'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['tipo_id'] = tipoId;
    data['cantidad'] = cantidad;
    data['descripcion'] = descripcion;
    data['medio_id'] = medioId;
    data['cuenta_id'] = cuentaId;
    data['status_id'] = statusId;
    data['tipo'] = tipo;
    data['medio'] = medio;
    data['status'] = status;
    return data;
  }
}

class StatusModel {
  int? id;
  String? createdAt;
  String? nombre;
  String? color;

  StatusModel({this.id, this.createdAt, this.nombre, this.color});

  StatusModel.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
    color = json['color'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    data['color'] = color;
    return data;
  }
}

class SalidaDinero {
  int? id;
  String? createdAt;
  int? medioId;
  int? statusId;
  double? cantidad;
  String? descripcion;
  String? firma;
  int? cuentaId;
  int? tipoId;
  Map<String, dynamic>? medio;
  Map<String, dynamic>? status;
  Map<String, dynamic>? tipo;

  SalidaDinero({
    this.id,
    this.createdAt,
    this.medioId,
    this.statusId,
    this.cantidad,
    this.descripcion,
    this.firma,
    this.cuentaId,
    this.tipoId,
    this.medio,
    this.status,
    this.tipo,
  });

  SalidaDinero.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    medioId = (json['medio_id'] is String)
        ? int.tryParse(json['medio_id'])
        : json['medio_id'];
    statusId = (json['status_id'] is String)
        ? int.tryParse(json['status_id'])
        : json['status_id'];
    cantidad = json['cantidad'] != null
        ? (json['cantidad'] is int
              ? (json['cantidad'] as int).toDouble()
              : json['cantidad'])
        : null;
    descripcion = json['descripcion'];
    firma = json['firma'];
    cuentaId = (json['cuenta_id'] is String)
        ? int.tryParse(json['cuenta_id'])
        : json['cuenta_id'];
    tipoId = (json['tipo_id'] is String)
        ? int.tryParse(json['tipo_id'])
        : json['tipo_id'];
    medio = json['medio'];
    status = json['status'];
    tipo = json['tipo'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['medio_id'] = medioId;
    data['status_id'] = statusId;
    data['cantidad'] = cantidad;
    data['descripcion'] = descripcion;
    data['firma'] = firma;
    data['cuenta_id'] = cuentaId;
    data['tipo_id'] = tipoId;
    data['medio'] = medio;
    data['status'] = status;
    data['tipo'] = tipo;
    return data;
  }
}

class Permiso {
  int? id;
  String? createdAt;
  String? userId;
  int? cuentaId;
  int? parentescoId;
  Parentesco? parentesco;

  Permiso({
    this.id,
    this.createdAt,
    this.userId,
    this.cuentaId,
    this.parentescoId,
    this.parentesco,
  });

  Permiso.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    userId = json['user_id'];
    cuentaId = (json['cuenta_id'] is String)
        ? int.tryParse(json['cuenta_id'])
        : json['cuenta_id'];
    parentescoId = (json['parentesco_id'] is String)
        ? int.tryParse(json['parentesco_id'])
        : json['parentesco_id'];
    parentesco = json['parentesco'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['user_id'] = userId;
    data['cuenta_id'] = cuentaId;
    data['parentesco_id'] = parentescoId;
    data['parentesco'] = parentesco;
    return data;
  }
}

class Parentesco {
  int? id;
  String? createdAt;
  String? nombre;

  Parentesco({this.id, this.createdAt, this.nombre});

  Parentesco.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    nombre = json['nombre'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['nombre'] = nombre;
    return data;
  }
}

class Direccion {
  int? id;
  String? createdAt;
  String? calle;
  String? colonia;
  double? codigoPostal;
  String? numInt;
  String? numExt;
  String? municipio;
  String? pais;
  String? estado;
  String? ownerId;

  Direccion({
    this.id,
    this.createdAt,
    this.calle,
    this.colonia,
    this.codigoPostal,
    this.numInt,
    this.numExt,
    this.municipio,
    this.pais,
    this.estado,
    this.ownerId,
  });

  Direccion.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    calle = json['calle'];
    colonia = json['colonia'];
    codigoPostal = json['codigo_postal'] != null
        ? (json['codigo_postal'] is int
              ? (json['codigo_postal'] as int).toDouble()
              : json['codigo_postal'])
        : null;
    numInt = json['num_int'];
    numExt = json['num_ext'];
    municipio = json['municipio'];
    pais = json['pais'];
    estado = json['estado'];
    ownerId = json['owner_id'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['calle'] = calle;
    data['colonia'] = colonia;
    data['codigo_postal'] = codigoPostal;
    data['num_int'] = numInt;
    data['num_ext'] = numExt;
    data['municipio'] = municipio;
    data['pais'] = pais;
    data['estado'] = estado;
    data['owner_id'] = ownerId;
    return data;
  }
}

class Movimiento {
  int? id;
  String? createdAt;
  int? tipoId;
  double? cantidad;
  String? descripcion;
  int? medioId;
  int? cuentaId;
  Map<String, dynamic>? tipo;
  Map<String, dynamic>? medio;

  Movimiento({
    this.id,
    this.createdAt,
    this.tipoId,
    this.cantidad,
    this.descripcion,
    this.medioId,
    this.cuentaId,
    this.tipo,
    this.medio,
  });

  Movimiento.fromJson(Map<String, dynamic> json) {
    id = (json['id'] is String) ? int.tryParse(json['id']) : json['id'];
    createdAt = json['created_at'];
    tipoId = (json['tipo_id'] is String)
        ? int.tryParse(json['tipo_id'])
        : json['tipo_id'];
    cantidad = json['cantidad'] != null
        ? (json['cantidad'] is int
              ? (json['cantidad'] as int).toDouble()
              : json['cantidad'])
        : null;
    descripcion = json['descripcion'];
    medioId = (json['medio_id'] is String)
        ? int.tryParse(json['medio_id'])
        : json['medio_id'];
    cuentaId = (json['cuenta_id'] is String)
        ? int.tryParse(json['cuenta_id'])
        : json['cuenta_id'];
    tipo = json['tipo'];
    medio = json['medio'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['tipo_id'] = tipoId;
    data['cantidad'] = cantidad;
    data['descripcion'] = descripcion;
    data['medio_id'] = medioId;
    data['cuenta_id'] = cuentaId;
    data['tipo'] = tipo;
    data['medio'] = medio;
    return data;
  }
}
