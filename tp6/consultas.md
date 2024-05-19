<h4>Ejercicio 1</h4>

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

> [!IMPORTANT]
> CREATE TRIGGER tr_pl_clave_x_nacionalidad_articulo
>
> AFTER UPDATE OF id_articulo ON articulo
>
> FOR EACH ROW EXECUTE PROCEDURE fn_pl_clave_x_nacionalidad();
>
> Es importante que el trigger del código anterior se active AFTER el update para que se considere el nuevo valor.
>
> ej: El limite para la ciudadanias extranjeras es de 2 palabras claves, y el de las arg es de 3. Para este caso tenemos un articulo escrito por un autor de ciudadania extranjera, el cual ya cumplio con el limite de palabras claves. Al querer hacer un update de la ciudadania asociada al id del mismo articulo (cambiandola por la arg) se podrian presentar los sig casos:
>
> --> BEFORE UPDATE
>
> Se ejecuta la función tomando en cuenta el registro original y si el mismo cumple o no con la condición. En caso de que sea así, concreta el update.
>
> --> AFTER UPDATE
>
> Se ejecuta la función tomando en cuenta el valor que intentamos reemplazar en el registro para luego verificar si el mismo cumple o no con la condición. En caso de que sea así, concreta el update.