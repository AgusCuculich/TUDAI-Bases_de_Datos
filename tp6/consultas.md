<h2>EJERCICIO 1</h2>

3) C. Cada palabra clave puede aparecer como máximo en 5 artículos.

```SQL
CREATE OR REPLACE FUNCTION fn_max_pl_claves() RETURNS Trigger AS $$
DECLARE
    veces_repetida int;
BEGIN
    SELECT COUNT(c.id_articulo) INTO veces_repetida FROM contiene c
    WHERE c.cod_palabra = NEW.cod_palabra
    AND c.idioma = NEW.idioma;
    if (veces_repetida > 4) THEN
        RAISE EXCEPTION 'Esta palabra clave aparece en más de 5 artículos.';
    END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER tr_max_pl_claves
BEFORE INSERT OR UPDATE OF idioma, cod_palabra ON contiene
FOR EACH ROW EXECUTE PROCEDURE fn_max_pl_claves();

-- Codigo añadido para probar la restriccion
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (4, 'es', 1);
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (5, 'es', 1);
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (6, 'es', 1);
```

3) D. Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras claves, pero con un tope de 15 palabras, el resto de los autores sólo pueden publicar artículos que contengan hasta 10 palabras claves.

```SQL
CREATE OR REPLACE FUNCTION fn_contador_pl_clave(art_nuevo integer, max_pl_clave integer) RETURNS void AS $$ -- NEW.id_articulo, max_pl_clave
DECLARE
    cant_palabras int;
BEGIN
    SELECT COUNT(c.id_articulo) INTO cant_palabras FROM contiene c
    WHERE c.id_articulo = art_nuevo;
    IF (cant_palabras > max_pl_clave) THEN
        RAISE EXCEPTION 'El articulo % supera la cantidad de palabras clave permitidas', art_nuevo;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION fn_pl_clave_x_nacionalidad() RETURNS Trigger AS $$
DECLARE
    ciudadania articulo.nacionalidad%type;
BEGIN
    SELECT a.nacionalidad INTO ciudadania FROM articulo a
    WHERE a.id_articulo = NEW.id_articulo;
    IF (ciudadania = 'Argentina') THEN
        PERFORM fn_contador_pl_clave(NEW.id_articulo, 14);
    ELSIF (ciudadania <> 'Argentina') THEN
        PERFORM fn_contador_pl_clave(NEW.id_articulo, 9);
    END IF;
    RETURN NEW;
END $$
LANGUAGE plpgsql;

CREATE TRIGGER tr_pl_clave_x_nacionalidad_articulo
AFTER UPDATE OF id_articulo ON articulo
FOR EACH ROW EXECUTE PROCEDURE fn_pl_clave_x_nacionalidad();

CREATE TRIGGER tr_pl_clave_x_nacionalidad_contiene
BEFORE INSERT OR UPDATE OF id_articulo ON contiene
FOR EACH ROW EXECUTE PROCEDURE fn_pl_clave_x_nacionalidad();

-- Codigo añadido para probar la restriccion
UPDATE articulo set nacionalidad = 'Argentina' WHERE id_articulo = 1;
INSERT INTO contiene (id_articulo, idioma, cod_palabra) VALUES (1, 'es', 1); -- Insertar 1x1 para ver en que momento salta la restricción
```

<h2>EJERCICIO 2</h2>

4) B.

4) c. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle que la segunda no sea menor que la primera.

```SQL
ALTER TABLE IMAGEN_MEDICA
ADD COLUMN fecha_img date;

ALTER TABLE PROCESAMIENTO
ADD COLUMN fecha_procesamiento_img date;
```
Triggers para INSERT o UPDATE de la tabla PROCESAMIENTO

```SQL
CREATE OR REPLACE FUNCTION fn_comparar_con_fecha_imagen() RETURNS Trigger AS $$
    DECLARE
        var_fecha_img imagen_medica.fecha_img%type;
    BEGIN
        -- RAISE NOTICE 'funciona';
        SELECT i.fecha_img INTO var_fecha_img FROM IMAGEN_MEDICA i
        WHERE NEW.id_imagen = i.id_imagen AND NEW.id_paciente = i.id_paciente;
        IF (NEW.fecha_procesamiento_img < var_fecha_img) THEN
            RAISE EXCEPTION 'La fecha de procesamiento de la imagen no puede ser previa a la de la misma imagen.';
        END IF;
        RETURN NEW;
    END $$
    LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_comparar_con_fecha_imagen_update
    BEFORE UPDATE OF fecha_procesamiento_img, id_imagen, id_paciente ON PROCESAMIENTO
    FOR EACH ROW
    WHEN (new.fecha_procesamiento_img > old.fecha_procesamiento_img)
    EXECUTE FUNCTION fn_comparar_con_fecha_imagen();

CREATE OR REPLACE TRIGGER tr_comparar_con_fecha_imagen_insert
    BEFORE INSERT ON PROCESAMIENTO
    FOR EACH ROW
    EXECUTE FUNCTION fn_comparar_con_fecha_imagen();
```

Triggers para INSERT o UPDATE de la tabla IMAGEN_MEDICA

```SQL
CREATE OR REPLACE FUNCTION fn_comparar_con_fecha_procesamiento() RETURNS TRIGGER AS $$
    DECLARE
        var_procesamiento_img procesamiento.fecha_procesamiento_img%type;
    BEGIN
        SELECT p.fecha_procesamiento_img INTO var_procesamiento_img FROM procesamiento p
        WHERE NEW.id_paciente = p.id_paciente AND NEW.id_imagen = p.id_imagen;
        /*Cuando actualizamos un registro de la tabla IMAGEN_MEDICA, buscamos que de todos esos datos, id_imagen e
          id_paciente coincidan con los de algun registro de procesamiento. Cuando haya coincidencia, de ese registro
          se almacenara en una variable la fecha de procesamiento de la imagen (tabla procesamiento)*/
        IF (var_procesamiento_img < NEW.fecha_img) THEN
            RAISE EXCEPTION 'La fecha de la imagen debe ser previa a la de su procesamiento.';
        end if;
        RETURN NEW;
    END $$
    LANGUAGE plpgsql;


CREATE TRIGGER tr_comparar_con_fecha_procesamiento_update
    BEFORE UPDATE OF fecha_img, id_paciente, id_imagen ON IMAGEN_MEDICA
    FOR EACH ROW
    WHEN (old.fecha_img < new.fecha_img)
    EXECUTE FUNCTION fn_comparar_con_fecha_procesamiento();
```

> [!IMPORTANT]
> Si se quisiera asegurar de que luego de añadir la nueva columna (cuando todos los datos de la misma serán NULL) a futuro cuando hagamos una inserción en la tabla, si o si deba ser de un valor válido.
>
> ```SQL
> -- 1. Agregar la nueva columna sin la restricción NOT NULL
> ALTER TABLE IMAGEN_MEDICA
> ADD COLUMN fecha_img date;
> 
> -- 2. Actualizar los registros existentes con un valor no NULL
> UPDATE IMAGEN_MEDICA
> SET fecha_img = CURRENT_DATE
> WHERE fecha_img IS NULL;
> 
> -- 3. Agregar la restricción NOT NULL a la columna
> ALTER TABLE IMAGEN_MEDICA
> ALTER COLUMN fecha_img SET NOT NULL;
> ```

4) D) Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.

```SQL
CREATE OR REPLACE FUNCTION calcular_fluoroscopias_anuales() RETURNS trigger AS $$
    DECLARE
        cant_fluoroscopias_anuales integer;
    BEGIN
        SELECT COUNT(i.modalidad) INTO cant_fluoroscopias_anuales FROM imagen_medica i
        WHERE i.modalidad ilike 'FLUOROSCOPIA' AND i.id_paciente = NEW.id_paciente;
        -- RAISE NOTICE 'cant: %', cant_fluoroscopias_anuales;
        IF (cant_fluoroscopias_anuales > 1) THEN
            RAISE EXCEPTION 'Los pacientes se pueden realizar un máximo de 2 fluorospias anuales.';
        END IF;
        RETURN NEW;
    END$$
    LANGUAGE plpgsql;

    CREATE OR REPLACE TRIGGER max_fluoroscopias
    BEFORE INSERT OR UPDATE OF id_paciente, id_imagen, modalidad ON IMAGEN_MEDICA
    FOR EACH ROW
    WHEN (NEW.modalidad = 'FLUOROSCOPIA')
    EXECUTE PROCEDURE calcular_fluoroscopias_anuales();
```

4) E) No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA.

```SQL
    CREATE OR REPLACE FUNCTION fn_costo_computacional_invalido_para_fluoroscopia_PROCESAMIENTO() RETURNS TRIGGER AS $$
    DECLARE
        var_modalidad imagen_medica.modalidad%type;
        var_costo_computacional algoritmo.costo_computacional%type;
    BEGIN
        IF EXISTS(
            SELECT 1 FROM IMAGEN_MEDICA i
            WHERE NEW.id_paciente = i.id_paciente
            AND NEW.id_imagen = i.id_imagen
            AND i.modalidad ILIKE 'FLUOROSCOPIA'
        ) THEN
            IF EXISTS (
                SELECT 2 FROM ALGORITMO a
                WHERE NEW.id_algoritmo = a.id_algoritmo
                AND a.costo_computacional ILIKE 'O(n)'
            ) THEN
                RAISE EXCEPTION 'No se pueden aplicar algoritmos de costo computacional "O(n)" a imágenes de FLUOROSCOPIA';
            end if;
        end if;
        RETURN NEW;
    END $$
    LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER algoritmo_fluoroscopia
    BEFORE INSERT OR UPDATE OF id_algoritmo, id_paciente, id_imagen ON PROCESAMIENTO
    FOR EACH ROW
    EXECUTE PROCEDURE fn_costo_computacional_invalido_para_fluoroscopia_PROCESAMIENTO();
```


<h2>Posibles mejoras</h2>

- [ ] 3d. El AFTER de nacionalidades se podria haber hecho con un BEFORE y haber comparado con el NEW.dato.
- [ ] 4c. Se podrían intentar usar argumentos para que quede una sola función.
- [ ] 4b. Falta resolver.