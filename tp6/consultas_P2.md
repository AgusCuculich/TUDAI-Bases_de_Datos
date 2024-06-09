```SQL
CREATE TABLE TAREA AS SELECT * FROM unc_esq_voluntario.tarea;

ALTER TABLE TAREA
ADD CONSTRAINT PK_id_tarea PRIMARY KEY (id_tarea);

CREATE TABLE HIS_TAREA (
    nro_registro integer CONSTRAINT PK_nro_registro PRIMARY KEY NOT NULL,
    fecha timestamp NOT NULL,
    operacion char(2) NOT NULL,
    usuario integer CONSTRAINT UK_usuario UNIQUE NOT NULL);

ALTER TABLE HIS_TAREA
    ALTER COLUMN usuario TYPE varchar(80);

ALTER TABLE HIS_TAREA
DROP CONSTRAINT UK_usuario;

CREATE TABLE NOMBRES_COMUNES (
    nombre varchar(80) CONSTRAINT PK_nombre PRIMARY KEY NOT NULL
);

INSERT INTO NOMBRES_COMUNES (nombre) VALUES
('María'), ('Juan'), ('Laura'), ('José'), ('Carmen'), ('Carlos'), ('Ana'), ('Miguel'), ('Patricia'), ('David'),
('Isabel'), ('Luis'), ('Rosa'), ('Alejandro'), ('Elena'), ('Daniel'), ('Marta'), ('Javier'), ('Sonia'), ('Manuel');

ALTER TABLE HIS_TAREA
ADD CONSTRAINT FK_usuario FOREIGN KEY(usuario) REFERENCES NOMBRES_COMUNES(nombre);
```