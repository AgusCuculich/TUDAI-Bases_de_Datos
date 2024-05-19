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