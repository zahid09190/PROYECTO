SELECT * FROM demo;
-- TABLA USUARIO
CREATE TABLE Usuario (
  ID_Usuario INTEGER PRIMARY KEY AUTOINCREMENT,
  Nombre TEXT NOT NULL,
  Apellidos TEXT,
  Correo TEXT UNIQUE NOT NULL,
  Fecha_Registro TEXT,
  Contraseña TEXT NOT NULL
);
CREATE INDEX idx_usuario_nombre ON Usuario(Nombre);
CREATE INDEX idx_usuario_correo ON Usuario(Correo);
-- TABLA HOGAR
CREATE TABLE Hogar (
  ID_Hogar INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Usuario INTEGER NOT NULL,
  Direccion TEXT,
  Tipo_Hogar TEXT,
  FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
);
CREATE INDEX idx_hogar_usuario ON Hogar(ID_Usuario);
-- TABLA DISPOSITIVO
CREATE TABLE Dispositivo (
  ID_Dispositivo INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Hogar INTEGER NOT NULL,
  Nombre TEXT NOT NULL,
  Tipo TEXT,
  Consumo_Promedio NUMERIC,
  Estado_ONOFF INTEGER DEFAULT 0,
  FOREIGN KEY (ID_Hogar) REFERENCES Hogar(ID_Hogar)
);
CREATE INDEX idx_dispositivo_hogar ON Dispositivo(ID_Hogar);
CREATE INDEX idx_dispositivo_tipo ON Dispositivo(Tipo);
-- TABLA MEDICION
CREATE TABLE Medicion (
  ID_Medicion INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Dispositivo INTEGER NOT NULL,
  Fecha_Hora TEXT NOT NULL,
  Consumo_Instantaneo NUMERIC NOT NULL,
  FOREIGN KEY (ID_Dispositivo) REFERENCES Dispositivo(ID_Dispositivo)
);
CREATE INDEX idx_medicion_fecha ON Medicion(Fecha_Hora);
CREATE INDEX idx_medicion_dispositivo ON Medicion(ID_Dispositivo);
-- TABLA CONFIGURACIÓN UMBRAL
CREATE TABLE Configuracion_Umbral (
  ID_Umbral INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Dispositivo INTEGER NOT NULL,
  Limite_Maximo NUMERIC NOT NULL,
  FOREIGN KEY (ID_Dispositivo) REFERENCES Dispositivo(ID_Dispositivo)
);
CREATE INDEX idx_umbral_dispositivo ON Configuracion_Umbral(ID_Dispositivo);
-- TABLA ALERTA
CREATE TABLE Alerta (
  ID_Alerta INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Dispositivo INTEGER NOT NULL,
  ID_Umbral INTEGER NOT NULL,
  Tipo TEXT,
  Mensaje TEXT,
  Fecha_Hora TEXT NOT NULL,
  FOREIGN KEY (ID_Dispositivo) REFERENCES Dispositivo(ID_Dispositivo),
  FOREIGN KEY (ID_Umbral) REFERENCES Configuracion_Umbral(ID_Umbral)
);
CREATE INDEX idx_alerta_dispositivo ON Alerta(ID_Dispositivo);
CREATE INDEX idx_alerta_fecha ON Alerta(Fecha_Hora);
-- TABLA REPORTE
CREATE TABLE Reporte (
  ID_Reporte INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Usuario INTEGER NOT NULL,
  Tipo_Reporte TEXT,
  Fecha_Generacion TEXT NOT NULL,
  FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
);
CREATE INDEX idx_reporte_usuario ON Reporte(ID_Usuario);
-- TABLA CONTROL REMOTO
CREATE TABLE Control_Remoto (
  ID_Control INTEGER PRIMARY KEY AUTOINCREMENT,
  ID_Dispositivo INTEGER NOT NULL,
  ID_Usuario INTEGER NOT NULL,
  Accion TEXT,
  Fecha_Hora TEXT NOT NULL,
  FOREIGN KEY (ID_Dispositivo) REFERENCES Dispositivo(ID_Dispositivo),
  FOREIGN KEY (ID_Usuario) REFERENCES Usuario(ID_Usuario)
);
CREATE INDEX idx_control_dispositivo ON Control_Remoto(ID_Dispositivo);
CREATE INDEX idx_control_usuario ON Control_Remoto(ID_Usuario);
-- TRIGGER ALERTA AUTOMÁTICA
CREATE TRIGGER GenerarAlerta
AFTER INSERT ON Medicion
BEGIN
  INSERT INTO Alerta (ID_Dispositivo, ID_Umbral, Tipo, Mensaje, Fecha_Hora)
  SELECT 
    NEW.ID_Dispositivo,
    cu.ID_Umbral,
    'Consumo Excedido',
    'El consumo instantáneo superó el umbral configurado.',
    datetime('now')
  FROM Configuracion_Umbral cu
  WHERE cu.ID_Dispositivo = NEW.ID_Dispositivo
    AND NEW.Consumo_Instantaneo > cu.Limite_Maximo
  LIMIT 1;
CREATE TRIGGER GenerarAlertaConsumo
AFTER INSERT ON Consumo
FOR EACH ROW
WHEN (
    -- Verificar si existe configuración de umbral para este dispositivo
    -- y si el consumo supera el límite configurado
    SELECT COUNT(*) 
    FROM Configuracion_Umbral 
    WHERE dispositivo_id = NEW.dispositivo_id 
    AND NEW.kwh_consumido > limite_maximo
) > 0
BEGIN
    -- Insertar alerta automáticamente cuando se supera el límite
    INSERT INTO Alerta (
        alerta_id, 
        dispositivo_id, 
        umbral_id,
        tipo, 
        mensaje, 
        fecha_hora, 
        prioridad,
        estado  )
    SELECT 
        -- Generar ID único para la alerta
        'ALT_' || substr(hex(randomblob(8)), 1, 12) || '_' || strftime('%Y%m%d%H%M%S'),                
        -- Dispositivo que generó la alerta
        NEW.dispositivo_id,   
        -- Umbral que se superó
        cu.umbral_id,
        -- Tipo de alerta
        'CONSUMO_EXCESIVO',     
        -- Mensaje descriptivo de la alerta
        'Alerta: El dispositivo [' || d.nombre || 
        '] ha consumido ' || NEW.kwh_consumido || 
        ' kWh, superando el límite de ' || cu.limite_maximo || ' kWh',      
        -- Fecha y hora actual
        datetime('now'),        
        -- Prioridad de la alerta
        'ALTA',        
        -- Estado inicial
        'PENDIENTE'  
    FROM Configuracion_Umbral cu
    JOIN Dispositivo d ON cu.dispositivo_id = d.dispositivo_id
    WHERE cu.dispositivo_id = NEW.dispositivo_id
    AND NEW.kwh_consumido > cu.limite_maximo;




