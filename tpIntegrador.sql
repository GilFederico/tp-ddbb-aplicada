
-- Creacion de la db
DROP DATABASE IF EXISTS Turnos
GO

CREATE DATABASE Turnos
GO

USE Turnos
GO

-- Creamos el schema 'turno'
DROP SCHEMA IF EXISTS turno
GO
CREATE SCHEMA turno
GO

-- Creamos el schema 'infoPaciente'
DROP SCHEMA IF EXISTS infoPaciente
GO
CREATE SCHEMA infoPaciente
GO

DROP TABLE IF EXISTS infoPaciente.Prestador
CREATE TABLE infoPaciente.Prestador (
	id_prestador INT IDENTITY(1,1) PRIMARY KEY,
	nombre_prestador VARCHAR(50),
	estado_alianza BIT --estado de la alianaza con el hospital activa o terminalada
);

-- Creacion de la tabla PlanPrestador, planes de los prestadores.
DROP TABLE IF EXISTS infoPaciente.PlanPrestador
CREATE TABLE infoPaciente.PlanPrestador (
	id_plan INT IDENTITY(1,1),
	nombre VARCHAR(50),
	id_prestador INT,
	FOREIGN KEY (id_prestador) REFERENCES infoPaciente.Prestador(id_prestador),
	PRIMARY KEY (id_plan, id_prestador)
);

DROP TABLE IF EXISTS infoPaciente.Cobertura
CREATE TABLE infoPaciente.Cobertura(
	id_cobertura INT IDENTITY(1,1) PRIMARY KEY,
	imagen_credencial VARCHAR(max),
	numero_socio INT,
	fecha_registro DATETIME,
	id_prestador INT,
	FOREIGN KEY (id_prestador) REFERENCES infoPaciente.Prestador(id_prestador)
);

DROP TABLE IF EXISTS infoPaciente.Domicilio
CREATE TABLE infoPaciente.Domicilio(
	id_domicilio INT IDENTITY(1,1) PRIMARY KEY,
	calle VARCHAR(25),
	numero SMALLINT,
	piso TINYINT,
	departamento VARCHAR(10),
	codigo_postal SMALLINT,
	pais VARCHAR(30),
	provincia VARCHAR(30),
	localidad VARCHAR(30) -- deberiamos sacar todo esto en otra tabla?
);

DROP TABLE IF EXISTS infoPaciente.Paciente
CREATE TABLE infoPaciente.Paciente(
	id_historia_clinica INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(30),
	apellido VARCHAR(20),
	apellido_materno VARCHAR(20),
	fecha_nacimiento DATETIME,
	tipo_documento VARCHAR(9),
	numero_documento INT,
	sexo_biologico VARCHAR(8),
	genero VARCHAR(10),
	nacionalidad VARCHAR(30),
	mail VARCHAR(max),
	telefono_fijo CHAR(15),
	telefono_alternativo CHAR(15),
	telefono_laboral CHAR(15),
	fecha_registro DATETIME,
	id_domicilio INT,
	FOREIGN KEY (id_domicilio) REFERENCES infoPaciente.Domicilio(id_domicilio),
	id_cobertura INT,
	FOREIGN KEY (id_cobertura) REFERENCES infoPaciente.Cobertura(id_cobertura),
	--fecha_act datetime,       ver depues
	--usuario_act int
);

DROP TABLE IF EXISTS infoPaciente.Usuario
CREATE TABLE infoPaciente.Usuario(
	id_usuario INT PRIMARY KEY,
	contrasenia VARCHAR(20),
	fecha_creacion DATETIME,
	id_historia_clinica INT,
	FOREIGN KEY (id_historia_clinica) REFERENCES infoPaciente.paciente(id_historia_clinica)
);

DROP TABLE IF EXISTS infoPaciente.Estudio
CREATE TABLE infoPaciente.Estudio(
	id_estudio INT PRIMARY KEY,
	fecha DATETIME,
	nombre_estudio VARCHAR(30),
	autorizado BIT,
	documento_resultado VARCHAR(max),
	imagen_resultado VARCHAR(max),
	id_historia_clinica INT,
	FOREIGN KEY (id_historia_clinica) REFERENCES infoPaciente.paciente(id_historia_clinica)
);

DROP TABLE IF EXISTS turno.Especialidad
CREATE TABLE turno.Especialidad(
	id_especialidad INT IDENTITY(1,1) PRIMARY KEY,
	nombre_especialidad VARCHAR(50)
);

DROP TABLE IF EXISTS turno.Medico
CREATE TABLE turno.Medico(
	id_medico INT PRIMARY KEY,
	nombre VARCHAR(20),
	apellido VARCHAR(20),
	nro_matricula SMALLINT,
	id_especialidad INT,
	FOREIGN KEY (id_especialidad) REFERENCES turno.Especialidad(id_especialidad),
);

DROP TABLE IF EXISTS turno.Sede
CREATE TABLE turno.Sede(
	id_sede INT IDENTITY(1,1) PRIMARY KEY,
	nombre VARCHAR(40),
	direccion VARCHAR(40)
);

DROP TABLE IF EXISTS turno.Dias_Sede
CREATE TABLE turno.Dias_Sede(
	id_sede INT,
	id_medico INT,
	dia DATETIME, -- aca no se, real que deberiamos ponernos de acuerdo que seria dia
	horario_inicio TIME, --creo que aca hay que hacer algo para que solo se puedan poner cada 15 (ej: 00:00, 00:15, 00:30, 00:45)
	estado varchar(10) check (estado like 'disponible' or estado like 'reservado') -- esto no me gusta, creo deberia ir a estado turno
	PRIMARY KEY (id_sede, id_medico, dia, horario_inicio), -- chequear despues
	FOREIGN KEY (id_sede) REFERENCES turno.Sede(id_sede),
	FOREIGN KEY (id_medico) REFERENCES turno.Medico(id_medico)
);

DROP TABLE IF EXISTS turno.Estado_Turno
CREATE TABLE turno.Estado_Turno(
	id_estado_turno INT IDENTITY(1,1) PRIMARY KEY,
	nombre_estado_turno VARCHAR(9)
);

-- creo que en vez de check, hay que hacer inserts de esto. Y TAMBIEN CREO, que hay que hacerlo con un SP pero no se porque no entendi si
-- es para TODO o solo para los datos que se van a ingresar cada tanto.
INSERT INTO turno.Estado_Turno (nombre_estado_turno) VALUES ('Atendido');
INSERT INTO turno.Estado_Turno (nombre_estado_turno) VALUES ('Ausente');
INSERT INTO turno.Estado_Turno (nombre_estado_turno) VALUES ('Cancelado');

DROP TABLE IF EXISTS turno.Tipo_Turno
CREATE TABLE turno.Tipo_Turno(
	id_tipo_turno INT IDENTITY(1,1) PRIMARY KEY,
	nombre_tipo_turno VARCHAR(10) --check (nombr_tip like 'presencial' or nombr_tip like 'virtual')
);

-- lo mismo, creo que no va check.
INSERT INTO turno.Tipo_Turno (nombre_tipo_turno) VALUES ('Presencial');
INSERT INTO turno.Tipo_Turno (nombre_tipo_turno) VALUES ('Virtual');

DROP TABLE IF EXISTS turno.Reserva_Turno
CREATE TABLE turno.Reserva_Turno(
	id_turno INT IDENTITY(1,1) PRIMARY KEY,
	id_direccion_atencion INT, -- nadie sabe que diantres es esto.
	id_esp INT, -- esto tambien, no se por que esta aca...

	id_medico INT,
	id_sede INT,
	fecha DATETIME, -- chequear que sea lo mismo que Dias_Sede
	hora TIME, -- chequear que sea lo mismo que Dias_Sede
	FOREIGN KEY (id_sede, id_medico, fecha, hora) REFERENCES turno.Dias_Sede(id_sede, id_medico, dia, horario_inicio),

	id_estado_turno INT,
	FOREIGN KEY (id_estado_turno) REFERENCES turno.Estado_Turno(id_estado_turno),
	id_tipo_turno INT,
	FOREIGN KEY (id_tipo_turno) REFERENCES turno.Tipo_Turno(id_tipo_turno),
	
	id_historia_clinica INT,
	FOREIGN KEY (id_historia_clinica) REFERENCES infoPaciente.paciente(id_historia_clinica)
);