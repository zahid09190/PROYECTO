CREATE TABLE `Usuario` (
  `ID_Usuario` int PRIMARY KEY AUTO_INCREMENT,
  `Nombre` varchar(100),
  `Apellidos` varchar(100),
  `Correo` varchar(150),
  `Fecha_Registro` date,
  `contraseña` varchar(200)
);

CREATE TABLE `Hogar` (
  `ID_Hogar` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Usuario` int,
  `Dirección` varchar(200),
  `tipo_Hogar` varchar(100)
);

CREATE TABLE `Dispositivo` (
  `ID_Dispositivo` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Hogar` int,
  `nombre` varchar(100),
  `tipo` varchar(100),
  `Consumo_Promedio` decimal(10,4),
  `Estado_ONOFF` boolean
);

CREATE TABLE `Medicion` (
  `ID_Medicion` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Dispositivo` int,
  `fecha_Hora` datetime,
  `Consumo_Instantaneo` decimal(10,4)
);

CREATE TABLE `Configuración_Umbral` (
  `ID_Umbral` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Dispositivo` int,
  `limite_Maximo` decimal(10,4)
);

CREATE TABLE `Alerta` (
  `ID_Alerta` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Dispositivo` int,
  `ID_Umbral` int,
  `tipo` varchar(50),
  `mensaje` varchar(200),
  `fechaHora` datetime
);

CREATE TABLE `Reporte` (
  `ID_Reporte` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Usuario` int,
  `tipo_reporte` varchar(100),
  `fecha_Generación` datetime
);

CREATE TABLE `Control_Remoto` (
  `ID_Control` int PRIMARY KEY AUTO_INCREMENT,
  `ID_Dispositivo` int,
  `ID_Usuario` int,
  `accion` varchar(50),
  `fechaHora` datetime
);

ALTER TABLE `Hogar` ADD FOREIGN KEY (`ID_Usuario`) REFERENCES `Usuario` (`ID_Usuario`);

ALTER TABLE `Dispositivo` ADD FOREIGN KEY (`ID_Hogar`) REFERENCES `Hogar` (`ID_Hogar`);

ALTER TABLE `Medicion` ADD FOREIGN KEY (`ID_Dispositivo`) REFERENCES `Dispositivo` (`ID_Dispositivo`);

ALTER TABLE `Configuración_Umbral` ADD FOREIGN KEY (`ID_Dispositivo`) REFERENCES `Dispositivo` (`ID_Dispositivo`);

ALTER TABLE `Alerta` ADD FOREIGN KEY (`ID_Dispositivo`) REFERENCES `Dispositivo` (`ID_Dispositivo`);

ALTER TABLE `Alerta` ADD FOREIGN KEY (`ID_Umbral`) REFERENCES `Configuración_Umbral` (`ID_Umbral`);

ALTER TABLE `Reporte` ADD FOREIGN KEY (`ID_Usuario`) REFERENCES `Usuario` (`ID_Usuario`);

ALTER TABLE `Control_Remoto` ADD FOREIGN KEY (`ID_Dispositivo`) REFERENCES `Dispositivo` (`ID_Dispositivo`);

ALTER TABLE `Control_Remoto` ADD FOREIGN KEY (`ID_Usuario`) REFERENCES `Usuario` (`ID_Usuario`);
