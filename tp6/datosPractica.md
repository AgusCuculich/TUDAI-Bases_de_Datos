<h2>EJERCICIO 1</h2>

> Tabla "contiene" corregida + inserts para practicar

```SQL
CREATE TABLE articulo (
    id_articulo int  NOT NULL,
    titulo varchar(120)  NOT NULL,
    autor varchar(30)  NOT NULL,
    nacionalidad varchar(15) NOT NULL,
    fecha_publicacion date NOT NULL,
    CONSTRAINT P5P1E1_ARTICULO_pk PRIMARY KEY (id_articulo)
);

-- Table: P5P1E1_CONTIENE
CREATE TABLE contiene (
    id_articulo int  NOT NULL,
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    CONSTRAINT P5P1E1_CONTIENE_pk PRIMARY KEY (id_articulo,idioma,cod_palabra)
);

-- Table: P5P1E1_PALABRA
CREATE TABLE palabra (
    idioma char(2)  NOT NULL,
    cod_palabra int  NOT NULL,
    descripcion varchar(25)  NOT NULL,
    CONSTRAINT P5P1E1_PALABRA_pk PRIMARY KEY (idioma,cod_palabra)
);

-- foreign keys
-- Reference: FK_P5P1E1_CONTIENE_ARTICULO (table: P5P1E1_CONTIENE)
ALTER TABLE contiene ADD CONSTRAINT FK_P5P1E1_CONTIENE_ARTICULO
    FOREIGN KEY (id_articulo)
    REFERENCES P5P1E1_ARTICULO (id_articulo)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P1E1_CONTIENE_PALABRA (table: P5P1E1_CONTIENE)
ALTER TABLE contiene ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

INSERT INTO articulo (id_articulo, titulo, autor, nacionalidad, fecha_publicacion) VALUES
(1, 'La sombra del viento', 'Carlos Ruiz Zafón', 'Española', '2001-04-01'),
(2, 'Cien años de soledad', 'Gabriel García Márquez', 'Colombiana', '1967-06-05'),
(3, 'Don Quijote de la Mancha', 'Miguel de Cervantes', 'Española', '1605-01-16');
(4, 'Cien años de soledad', 'Gabriel García Márquez', 'Colombia', '1967-01-01'),
(5, 'Orgullo y prejuicio', 'Jane Austen', 'Reino Unido', '1813-01-01'),
(6, 'Crimen y castigo', 'Fyodor Dostoevsky', 'Rusia', '1866-01-01');

INSERT INTO palabra (idioma, cod_palabra, descripcion) VALUES
('es', 1, 'libro'),
('es', 2, 'novela'),
('es', 3, 'autor'),
('es', 4, 'publicacion'),
('es', 5, 'ficcion');

INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES
(1, 'es', 1),
(1, 'es', 2),
(1, 'es', 3),
(1, 'es', 4),
(1, 'es', 5),
(2, 'es', 1),
(2, 'es', 2),
(2, 'es', 3),
(3, 'es', 1),
(3, 'es', 3),
(3, 'es', 4);
```

```SQL
-- Añadidos extras
INSERT INTO articulo (id_articulo, titulo, autor, nacionalidad, fecha_publicacion) VALUES
(4, 'Cien años de soledad', 'Gabriel García Márquez', 'Colombia', '1967-01-01');

INSERT INTO articulo (id_articulo, titulo, autor, nacionalidad, fecha_publicacion) VALUES
(5, 'Orgullo y prejuicio', 'Jane Austen', 'Reino Unido', '1813-01-01');

INSERT INTO articulo (id_articulo, titulo, autor, nacionalidad, fecha_publicacion) VALUES
(6, 'Crimen y castigo', 'Fyodor Dostoevsky', 'Rusia', '1866-01-01');

INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (4, 'es', 1);
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (5, 'es', 1);
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (6, 'es', 1);

INSERT INTO palabra (idioma, cod_palabra, descripcion) VALUES ('fr', 6, 'amour');
INSERT INTO palabra (idioma, cod_palabra, descripcion) VALUES ('jp', 7, '日本');
```

```SQL
--DROPS
DROP TRIGGER IF EXISTS tr_pl_clave_x_nacionalidad on contiene;
DROP TRIGGER IF EXISTS tr_pl_clave_x_nacionalidad_articulo on articulo;
DROP FUNCTION IF EXISTS fn_pl_clave_x_nacionalidad();
DROP FUNCTION IF EXISTS fn_contador_pl_clave(integer, integer);
```

<h2>EJERCICIO 2</h2>

```SQL
-- tables
-- Table: P5P2E4_ALGORITMO
CREATE TABLE ALGORITMO (
    id_algoritmo int  NOT NULL,
    nombre_metadata varchar(40)  NOT NULL,
    descripcion varchar(256)  NOT NULL,
    costo_computacional varchar(15)  NOT NULL,
    CONSTRAINT PK_P5P2E4_ALGORITMO PRIMARY KEY (id_algoritmo)
);

-- Table: P5P2E4_IMAGEN_MEDICA
CREATE TABLE IMAGEN_MEDICA (
    id_paciente int  NOT NULL,
    id_imagen int  NOT NULL,
    modalidad varchar(80)  NOT NULL,
    descripcion varchar(180)  NOT NULL,
    descripcion_breve varchar(80)  NULL,
    CONSTRAINT PK_P5P2E4_IMAGEN_MEDICA PRIMARY KEY (id_paciente,id_imagen)
);

-- Table: P5P2E4_PACIENTE
CREATE TABLE PACIENTE (
    id_paciente int  NOT NULL,
    apellido varchar(80)  NOT NULL,
    nombre varchar(80)  NOT NULL,
    domicilio varchar(120)  NOT NULL,
    fecha_nacimiento date  NOT NULL,
    CONSTRAINT PK_P5P2E4_PACIENTE PRIMARY KEY (id_paciente)
);

-- Table: P5P2E4_PROCESAMIENTO
CREATE TABLE PROCESAMIENTO (
    id_algoritmo int  NOT NULL,
    id_paciente int  NOT NULL,
    id_imagen int  NOT NULL,
    nro_secuencia int  NOT NULL,
    parametro decimal(15,3)  NOT NULL,
    CONSTRAINT PK_P5P2E4_PROCESAMIENTO PRIMARY KEY (id_algoritmo,id_paciente,id_imagen,nro_secuencia)
);

-- foreign keys
-- Reference: FK_P5P2E4_IMAGEN_MEDICA_PACIENTE (table: P5P2E4_IMAGEN_MEDICA)
ALTER TABLE IMAGEN_MEDICA ADD CONSTRAINT FK_P5P2E4_IMAGEN_MEDICA_PACIENTE
    FOREIGN KEY (id_paciente)
    REFERENCES PACIENTE (id_paciente)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E4_PROCESAMIENTO_ALGORITMO (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE PROCESAMIENTO ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_ALGORITMO
    FOREIGN KEY (id_algoritmo)
    REFERENCES ALGORITMO (id_algoritmo)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;

-- Reference: FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA (table: P5P2E4_PROCESAMIENTO)
ALTER TABLE PROCESAMIENTO ADD CONSTRAINT FK_P5P2E4_PROCESAMIENTO_IMAGEN_MEDICA
    FOREIGN KEY (id_paciente, id_imagen)
    REFERENCES IMAGEN_MEDICA (id_paciente, id_imagen)
    NOT DEFERRABLE
    INITIALLY IMMEDIATE
;
```

```SQL
-- Inserts inventados

INSERT INTO ALGORITMO (id_algoritmo, nombre_metadata, descripcion, costo_computacional) VALUES
(1, 'Algoritmo A', 'Algoritmo para procesamiento de imágenes A', 'Bajo'),
(2, 'Algoritmo B', 'Algoritmo para análisis de datos médicos B', 'Medio'),
(3, 'Algoritmo C', 'Algoritmo de reconocimiento de patrones C', 'Alto'),
(4, 'Algoritmo D', 'Algoritmo de segmentación D', 'Bajo'),
(5, 'Algoritmo E', 'Algoritmo de filtrado E', 'Medio'),
(6, 'Algoritmo F', 'Algoritmo de compresión F', 'Alto'),
(7, 'Algoritmo G', 'Algoritmo de optimización G', 'Bajo'),
(8, 'Algoritmo H', 'Algoritmo de detección de anomalías H', 'Medio'),
(9, 'Algoritmo I', 'Algoritmo de predicción I', 'Alto'),
(10, 'Algoritmo J', 'Algoritmo de análisis de texto J', 'Bajo');

INSERT INTO IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve) VALUES
(1, 101, 'Radiografía', 'Radiografía de tórax', 'Tórax'),
(2, 102, 'RMN', 'Resonancia magnética de cerebro', 'Cerebro'),
(3, 103, 'Tomografía', 'Tomografía computarizada de abdomen', 'Abdomen'),
(4, 104, 'Ultrasonido', 'Ultrasonido abdominal', 'Abdomen'),
(5, 105, 'Radiografía', 'Radiografía de pierna', 'Pierna'),
(6, 106, 'RMN', 'Resonancia magnética de columna', 'Columna'),
(7, 107, 'Tomografía', 'Tomografía computarizada de tórax', 'Tórax'),
(8, 108, 'Ultrasonido', 'Ultrasonido pélvico', 'Pélvico'),
(9, 109, 'Radiografía', 'Radiografía de brazo', 'Brazo'),
(10, 110, 'RMN', 'Resonancia magnética de rodilla', 'Rodilla');

INSERT INTO PACIENTE (id_paciente, apellido, nombre, domicilio, fecha_nacimiento) VALUES
(1, 'González', 'Juan', 'Calle Falsa 123', '1980-01-01'),
(2, 'Martínez', 'Ana', 'Avenida Siempre Viva 742', '1985-02-02'),
(3, 'Rodríguez', 'Carlos', 'Boulevard de los Sueños 456', '1990-03-03'),
(4, 'López', 'María', 'Pasaje Estrecho 789', '1975-04-04'),
(5, 'Pérez', 'Jorge', 'Calle Ancha 101', '1982-05-05'),
(6, 'Sánchez', 'Lucía', 'Avenida Amplia 202', '1995-06-06'),
(7, 'Ramírez', 'Pedro', 'Calle Curva 303', '1978-07-07'),
(8, 'Torres', 'Laura', 'Avenida Recta 404', '1988-08-08'),
(9, 'Flores', 'Miguel', 'Pasaje Largo 505', '1992-09-09'),
(10, 'Rivera', 'Sofía', 'Calle Corta 606', '1999-10-10');

INSERT INTO PROCESAMIENTO (id_algoritmo, id_paciente, id_imagen, nro_secuencia, parametro) VALUES
(1, 1, 101, 1, 0.123),
(2, 2, 102, 1, 1.234),
(3, 3, 103, 1, 2.345),
(4, 4, 104, 1, 3.456),
(5, 5, 105, 1, 4.567),
(6, 6, 106, 1, 5.678),
(7, 7, 107, 1, 6.789),
(8, 8, 108, 1, 7.890),
(9, 9, 109, 1, 8.901),
(10, 10, 110, 1, 9.012);
```

<h2>Ejercicio 2</h2>

4) c.

```SQL
/*Cargar fechas en imagen_medica: */
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-01-01' WHERE id_imagen = 101;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-02-01' WHERE id_imagen = 102;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-03-01' WHERE id_imagen = 103;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-04-01' WHERE id_imagen = 104;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-05-01' WHERE id_imagen = 105;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-06-01' WHERE id_imagen = 106;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-07-01' WHERE id_imagen = 107;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-08-01' WHERE id_imagen = 108;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-09-01' WHERE id_imagen = 109;
UPDATE IMAGEN_MEDICA SET fecha_img = '2024-10-01' WHERE id_imagen = 110;


/*Cargar fechas en procesamiento: */
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-01-05' WHERE id_imagen = 101 AND id_paciente = 1;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-02-05' WHERE id_imagen = 102 AND id_paciente = 2;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-03-05' WHERE id_imagen = 103 AND id_paciente = 3;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-04-05' WHERE id_imagen = 104 AND id_paciente = 4;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-05-05' WHERE id_imagen = 105 AND id_paciente = 5;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-06-05' WHERE id_imagen = 106 AND id_paciente = 6;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-07-05' WHERE id_imagen = 107 AND id_paciente = 7;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-08-05' WHERE id_imagen = 108 AND id_paciente = 8;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-09-05' WHERE id_imagen = 109 AND id_paciente = 9;
UPDATE PROCESAMIENTO SET fecha_procesamiento_img = '2024-10-05' WHERE id_imagen = 110 AND id_paciente = 10;
```

```SQL
SELECT p.id_paciente, p.fecha_procesamiento_img, i.fecha_img FROM procesamiento p
JOIN IMAGEN_MEDICA i on p.id_imagen = i.id_imagen;

DELETE FROM IMAGEN_MEDICA WHERE id_paciente = 10;
DELETE FROM PROCESAMIENTO WHERE id_paciente = 10;

INSERT INTO IMAGEN_MEDICA (id_paciente, id_imagen, modalidad, descripcion, descripcion_breve, fecha_img) VALUES (10, 110, 'RMN', 'Resonancia magnética de rodilla', 'Rodilla' '2024-10-01');
INSERT INTO PROCESAMIENTO (id_algoritmo, id_paciente, id_imagen, nro_secuencia, parametro, fecha_procesamiento_img) VALUES (10, 10, 110, 1, 9.012, '2024-10-01');

UPDATE IMAGEN_MEDICA SET fecha_img = '2024-12-01' WHERE id_paciente = 10 AND id_imagen = 110;
```