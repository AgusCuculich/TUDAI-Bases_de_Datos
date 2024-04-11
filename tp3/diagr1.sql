-- Created by Vertabelo (http://vertabelo.com)
-- Last modification date: 2024-04-11 15:42:06.309

-- Ejercicios 1 y 3

-- drops
DROP TABLE IF EXISTS AUDIO CASCADE;
DROP TABLE IF EXISTS COLECCION CASCADE;
DROP TABLE IF EXISTS DOCUMENTO CASCADE;
DROP TABLE IF EXISTS OBJETO CASCADE;
DROP TABLE IF EXISTS REPOSITORIO CASCADE;
DROP TABLE IF EXISTS VIDEO CASCADE;

-- tables
-- Table: AUDIO
CREATE TABLE IF NOT EXISTS AUDIO (
    formato varchar(20)  NOT NULL,
    duracion int  NOT NULL,
    id_objeto int  NOT NULL,
    id_coleccion int  NOT NULL,
    CONSTRAINT AUDIO_pk PRIMARY KEY (id_objeto,id_coleccion)
);

INSERT INTO AUDIO (formato, duracion, id_coleccion, id_objeto) VALUES 
('mp4', 3, 2, 3),
('mp3', 3, 2, 9);

-- Table: COLECCION
CREATE TABLE IF NOT EXISTS COLECCION (
    id_coleccion serial  NOT NULL,
    titulo varchar(20)  NOT NULL,
    descripcion varchar(40)  NOT NULL,
    CONSTRAINT COLECCION_pk PRIMARY KEY (id_coleccion)
);

INSERT INTO COLECCION (id_coleccion, titulo, descripcion) VALUES 
(1, 'Video', 'Esta es una coleccion de arte moderno'), 
(2, 'Musica', 'Una seleccion de obras clasicas'), 
(3, 'Documentos', 'Recopilacion de fotografias historicas');


-- Table: DOCUMENTO
CREATE TABLE IF NOT EXISTS DOCUMENTO (
    tipo_publicacion varchar(20)  NOT NULL,
    modos_color int  NOT NULL,
    resolucion_captura int  NOT NULL,
    id_objeto int  NOT NULL,
    id_coleccion int  NOT NULL,
    CONSTRAINT DOCUMENTO_pk PRIMARY KEY (id_objeto,id_coleccion)
);

INSERT INTO DOCUMENTO (tipo_publicacion, modos_color, resolucion_captura, id_coleccion, id_objeto) VALUES 
('Doc', 1, 1920, 3, 1),
('Doc', 1, 1920, 3, 4),
('Doc', 1, 1920, 3, 5),
('Doc', 1, 1920, 3, 6),
('Doc', 1, 1920, 3, 10),
('Doc', 1, 1920, 3, 11);

-- Table: OBJETO
CREATE TABLE IF NOT EXISTS OBJETO (
    id_objeto serial  NOT NULL,
    id_coleccion int  NOT NULL,
    id_repositorio int  NOT NULL,
    titulo varchar(20)  NOT NULL,
    descripcion varchar(40)  NOT NULL,
    fuente int  NOT NULL,
    fecha date  NOT NULL,
    tipo char(1)  NOT NULL,
    CONSTRAINT OBJETO_pk PRIMARY KEY (id_objeto,id_coleccion)
);

INSERT INTO OBJETO (id_objeto, id_coleccion, id_repositorio, titulo, descripcion, fuente, fecha, tipo) VALUES
(1, 3, 1, 'Ideal Husband, An', 'lorem ipsum dolor sit amet', 1, '2023/12/14', 'd'),
(2, 1, 1, 'Apollo Zero', 'lorem ipsum dolor sit amet', 2, '2023/05/30', 'v'),
(3, 2, 1, 'Spring', 'lorem ipsum dolor sit amet', 3, '2023/10/10', 'a'),
(4, 3, 1, 'We Are The Night', 'lorem ipsum dolor sit amet', 4, '2023/10/25', 'd'),
(5, 3, 1, 'Monster', 'lorem ipsum dolor sit amet', 5, '2023/11/23', 'd'),
(6, 3, 1, 'Daylight', 'lorem ipsum dolor sit amet', 6, '2023/06/23', 'd'),
(7, 1, 1, 'Shatter Me', 'lorem ipsum dolor sit amet', 7, '2023/05/22', 'v'),
(8, 1, 1, 'Lemon', 'lorem ipsum dolor sit amet', 8, '2023/04/07', 'v'),
(9, 2, 1, 'One last time', 'lorem ipsum dolor sit amet', 9, '2023/05/16', 'a'),
(10, 3, 1, 'Gods', 'lorem ipsum dolor sit amet', 10, '2024-02-28', 'd'),
(11, 3, 1, 'Suzume', 'lorem ipsum dolor sit amet', 11, '2024-02-28', 'd');

-- Table: REPOSITORIO
CREATE TABLE IF NOT EXISTS REPOSITORIO (
    id_repositorio serial  NOT NULL,
    nombre varchar(20)  NOT NULL,
    publico boolean  NOT NULL,
    descripcion varchar(40)  NOT NULL,
    duenio varchar(20)  NULL,
    CONSTRAINT REPOSITORIO_pk PRIMARY KEY (id_repositorio)
);

INSERT INTO REPOSITORIO (id_repositorio, nombre, publico, descripcion, duenio) VALUES
(1, 'Repo', TRUE, 'lorem ipsum dolor sit amet', 'Justo Bolsa');

-- Table: VIDEO
CREATE TABLE IF NOT EXISTS VIDEO (
    resolucion int  NOT NULL,
    frames_x_segundo int  NOT NULL,
    id_objeto int  NOT NULL,
    id_coleccion int  NOT NULL,
    CONSTRAINT VIDEO_pk PRIMARY KEY (id_objeto,id_coleccion)
);

INSERT INTO VIDEO (resolucion, frames_x_segundo, id_coleccion, id_objeto) VALUES 
(1920, 24, 1, 2),
(1920, 24, 1, 7),
(1920, 24, 1, 8);

-- foreign keys
-- Reference: AUDIO_OBJETO (table: AUDIO)
ALTER TABLE AUDIO ADD CONSTRAINT AUDIO_OBJETO
    FOREIGN KEY (id_objeto, id_coleccion)
    REFERENCES OBJETO (id_objeto, id_coleccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: COLECCION_OBJETO (table: OBJETO)
ALTER TABLE OBJETO ADD CONSTRAINT COLECCION_OBJETO
    FOREIGN KEY (id_coleccion)
    REFERENCES COLECCION (id_coleccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: DOCUMENTO_OBJETO (table: DOCUMENTO)
ALTER TABLE DOCUMENTO ADD CONSTRAINT DOCUMENTO_OBJETO
    FOREIGN KEY (id_objeto, id_coleccion)
    REFERENCES OBJETO (id_objeto, id_coleccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: OBJETO_REPOSITORIO (table: OBJETO)
ALTER TABLE OBJETO ADD CONSTRAINT OBJETO_REPOSITORIO
    FOREIGN KEY (id_repositorio)
    REFERENCES REPOSITORIO (id_repositorio)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- Reference: VIDEO_OBJETO (table: VIDEO)
ALTER TABLE VIDEO ADD CONSTRAINT VIDEO_OBJETO
    FOREIGN KEY (id_objeto, id_coleccion)
    REFERENCES OBJETO (id_objeto, id_coleccion)  
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;

-- End of file.

