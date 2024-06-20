<h1>Consigna 1</h1>

<img src="./img/ej1.png" alt="Consigna 1"/>

```SQL
CREATE ASSERTION control_modalidades
    CHECK(
        NOT EXIST(
            SELECT 1
            FROM provee
            WHERE (CUIT, cod_tipo_sum, id_suministro) IN(
                SELECT CUIT, cod_tipo_sum, id_suministro
                FROM uni_suministro
            )
        )
    )
```

La restricción anterior verifica que los datos (columnas que conforman la pk) que se encuentran en la tabla provee (relación entre suministro y multi_suministro) no se encuentren también en la tabla uni_suministro, garantizando que un mismo suministro no sea ofrecido en sus dos modalidades por una misma empresa.

```SQL
CREATE OR REPLACE FUNCTION fn_control_modalidades_provee() RETURNS TRIGGER AS $$
    BEGIN
        IF EXISTS(
            SELECT 1
            FROM uni_suministro un
            WHERE NEW.cod_tipo_sum = un.cod_tipo_sum
            AND NEW.id_suministro = un.id_suministro
            AND NEW.CUIT = un.id_CUIT
        ) THEN
            RAISE EXCEPTION 'El suministro ya es ofrecido en su modalidad uni_suministro por la empresa con CUIT %', NEW.CUIT;
    END $$
    LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_control_modalidades_provee
    BEFORE INSERT OR UPDATE OF cod_tipo_sum, id_suministro, CUIT ON provee
    FOR EACH ROW
    EXECUTE FUNCTION fn_control_modalidades_provee();

CREATE OR REPLACE FUNCTION fn_control_modalidades_uni_suministro() RETURNS TRIGGER AS $$
    BEGIN
        IF EXISTS(
            SELECT 1
            FROM provee p
            WHERE NEW.cod_tipo_sum = p.cod_tipo_sum
            AND NEW.id_suministro = P.id_suministro
            AND NEW.CUIT = p.id_CUIT
        ) THEN
            RAISE EXCEPTION 'El suministro ya es ofrecido en su modalidad multi_suministro por la empresa con CUIT %', NEW.CUIT;
    END $$
    LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_control_modalidades_uni_suministro
    BEFORE INSERT OR UPDATE OF CUIT, cod_tipo_sum, id_suministro ON uni_suministro
    FOR EACH ROW
    EXECUTE FUNCTION fn_control_modalidades_uni_suministro();
```

<h1>Consigna 2</h1>

<img src="./img/ej2_1.png" alt="Consigna 2"/>
<img src="./img/ej2_2.png" alt="Consigna 2"/>

<h3>Ayuda visual</h3>
Imagen con cada tabla y las definiciones dadas por la cátedra para ver más claramente las claves faltantes.

<img src="./img/claves_tablas.jpg" alt="Tablas y declaraciones de claves de la cátedra"/>

```SQL
-- Declaración de claves faltantes para tabla "directivo".
ALTER TABLE directivo   --tabla sobre la que actua la RI
ADD CONSTRAINT FK_directivo_empleado    -- Tablas involucradas (por relación PK-FK)
FOREIGN KEY (DNI)
REFERENCES empleado (DNI)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Declaración de claves faltantes para tabla "técnico".
ALTER TABLE tecnico
ADD CONSTRAINT FK_tecnico_empleado
FOREIGN KEY (DNI)
REFERENCES empleado (DNI)
ON UPDATE CASCADE
ON DELETE CASCADE;

-- Declaración de claves faltantes para tabla "trabaja_en".
ALTER TABLE trabaja_en
ADD CONSTRAINT PK_trabaja_en
PRIMARY KEY (id_proyecto, cod_tipo_proyecto, DNI);

-- Declaración de claves faltantes para tabla "proyecto".
ALTER TABLE proyecto
ADD CONSTRAINT PK_proyecto
PRIMARY KEY (cod_tipo_proy, id_proyecto);

ALTER TABLE proyecto
ADD CONSTRAINT AK_proyecto
UNIQUE (nombre_proyecto);
```

> [!IMPORTANT]
> En las tablas "directivo" y "tecnico" la columna "DNI" hace referencia a la columna (PK) "DNI" de la tabla "empleado". Como la consigna nos pide que ante una modificación o update en la tabla "empleado", los mismos se vean reflejados en la tablas que la referencian, utilizamos CASCADE al definir las contraints FK_directivo_empleado y FK_tecnico_empleado.

<h1>Extras</h1>

Script de creacion de tablas

```SQL
-- tables
-- Table: EMPRESA
CREATE TABLE EMPRESA (
    CUIT varchar(11)  NOT NULL,
    razon_social varchar(120)  NOT NULL,
    nombre_comercial varchar(120)  NOT NULL,
    e_mail varchar(120)  NOT NULL,
    fecha_inicio_actividades date  NOT NULL,
    CONSTRAINT AK_EMPRESA UNIQUE (e_mail) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: MULTI_SUMINISTRO
CREATE TABLE MULTI_SUMINISTRO (
    CUIT varchar(11)  NOT NULL
);

-- Table: PROVEE
CREATE TABLE PROVEE (
    cod_tipo_sum int  NOT NULL,
    id_suministro int  NOT NULL,
    CUIT varchar(11)  NOT NULL
);

-- Table: SUMINISTRO
CREATE TABLE SUMINISTRO (
    cod_tipo_sum int  NOT NULL,
    id_suministro int  NOT NULL,
    nombre_suministro varchar(20)  NOT NULL
);

-- Table: TIPO_SUMINISTRO
CREATE TABLE TIPO_SUMINISTRO (
    cod_tipo_sum int  NOT NULL,
    nombre_tipo_sum varchar(120)  NOT NULL,
    descripcion_tipo_sum text  NOT NULL,
    CONSTRAINT AK_TIPO_SUMINISTRO UNIQUE (nombre_tipo_sum) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: UNI_SUMINISTRO
CREATE TABLE UNI_SUMINISTRO (
    CUIT varchar(11)  NOT NULL,
    cod_tipo_sum int  NOT NULL,
    id_suministro int  NOT NULL,
    fecha_inicio date  NOT NULL,
    fecha_fin date  NULL
);
```

```SQL
-- tables
-- Table: DIRECTIVO
CREATE TABLE DIRECTIVO (
    DNI int  NOT NULL,
    cod_tipo_proy int  NOT NULL,
    id_proyecto int  NOT NULL,
    fecha_inicio date  NOT NULL,
    fecha_fin date  NULL
);

-- Table: EMPLEADO
CREATE TABLE EMPLEADO (
    DNI int  NOT NULL,
    e_mail varchar(120)  NOT NULL,
    apellido varchar(40)  NOT NULL,
    nombre varchar(40)  NOT NULL,
    fecha_nac date  NOT NULL,
    CONSTRAINT AK_EMPLEADO UNIQUE (e_mail) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: PROYECTO
CREATE TABLE PROYECTO (
    cod_tipo_proy int  NOT NULL,
    id_proyecto int  NOT NULL,
    nombre_proyecto varchar(120)  NOT NULL    
);

-- Table: TECNICO
CREATE TABLE TECNICO (
    DNI int  NOT NULL    
);

-- Table: TIPO_PROYECTO
CREATE TABLE TIPO_PROYECTO (
    cod_tipo_proy int  NOT NULL,
    nombre_tipo_proy varchar(40)  NOT NULL,
    descripcion_tipo_proy text  NOT NULL,
    CONSTRAINT AK_TIPO_PROYECTO UNIQUE (nombre_tipo_proy) NOT DEFERRABLE  INITIALLY IMMEDIATE
);

-- Table: TRABAJA_EN
CREATE TABLE TRABAJA_EN (
    cod_tipo_proy int  NOT NULL,
    id_proyecto int  NOT NULL,
    DNI int  NOT NULL
);
```