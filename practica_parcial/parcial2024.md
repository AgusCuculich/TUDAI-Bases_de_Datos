<h1>Consigna 1</h1>

<img src="/img/ej1.png" alt="Consigna 1"/>

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