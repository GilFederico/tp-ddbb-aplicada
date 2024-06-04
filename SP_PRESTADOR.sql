

DROP TABLE IF EXISTS multas2
GO
CREATE TABLE multas2 (nombre_prestador VARCHAR(50), nombre VARCHAR(50));
 GO
 
 BULK INSERT multas2
 FROM 'C:\Users\Akroma\Documents\Facu\Actuales\Base de Datos Aplicada\TP\Data\Dataset\Prestador.csv'
 WITH
 (
	 FIELDTERMINATOR = ';',-- Especifica el delimitador de campo (coma en un archivo CSV)
	 ROWTERMINATOR = '\n',-- Especifica el terminador de fila (salto de línea en un archivo CSV)
	 CODEPAGE = 'ACP'
 )
 GO

 SELECT *
 FROM multas2;