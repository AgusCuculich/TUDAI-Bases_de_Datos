<h2>Ejercicio 1</h2>

Eventos: 
* INSERT: se añade un distribuidor más para un video.
* UPDATE: al modificar el id_distribuidor o id_video de la tabla entrega, puede 
cambiar el valor en dif_distribuidores (video)
* DELETE: un distribuidor menos para un video (si no era el único registro de ese
id_video en la tabla entrega)

```SQL
-- Importamos las tablas a nuestra base:

CREATE TABLE video AS
    SELECT *
    FROM unc_esq_peliculas.video
    WHERE id_video IN(
        SELECT id_video
        FROM entrega
        WHERE id_video < 100
        )
    ORDER BY video.id_video;

CREATE TABLE entrega AS
    SELECT *
    FROM unc_esq_peliculas.entrega
    WHERE id_video < 100
    ORDER BY entrega.id_video;

-- Añadimos la nueva columna que menciona el enunciado

ALTER TABLE video
ADD COLUMN dif_distribuidores int;  -- Con esto añadimos la columna

UPDATE video
SET dif_distribuidores = 0
WHERE dif_distribuidores IS NULL; -- Cambiamos todos los valores 'null' de la ccolumna por ceros.

ALTER TABLE video
ALTER COLUMN dif_distribuidores SET NOT NULL; -- Indicamos que la columna no puede contener valores null.

-- Creamos el trigger que cumpla con lo especificado.

CREATE OR REPLACE FUNCTION fn_actualizacion_distribuidores() RETURNS TRIGGER AS $$
    DECLARE cant_distribuidores int;
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            SELECT COALESCE(COUNT(DISTINCT e.id_distribuidor), 0) INTO cant_distribuidores  -- Como el trigger es AFTER ya se inserto el nuevo y nomas hace falta calcular la cantidad que hay en la tabla sin sumar nada.
            FROM entrega e
            WHERE e.id_video = NEW.id_video;
            RAISE NOTICE 'cant_distribuidores: %', cant_distribuidores;
            UPDATE video SET dif_distribuidores = cant_distribuidores WHERE id_video = NEW.id_video;
            RETURN NEW;
        END IF;
        RETURN NULL;
    END $$
    LANGUAGE plpgsql;

CREATE OR REPLACE TRIGGER tr_actualizacion_distribuidores
    AFTER INSERT OR UPDATE OF id_video, id_distribuidor ON entrega
    FOR EACH ROW
    EXECUTE FUNCTION fn_actualizacion_distribuidores();

CREATE OR REPLACE TRIGGER tr_delete_distribuidores
AFTER DELETE ON entrega
FOR EACH ROW
EXECUTE FUNCTION fn_delete_distribuidores();

-- Datos para probar el correcto funcionamiento:

-- Insert que hará saltar el trigger.
INSERT INTO entrega (nro_entrega, fecha_entrega, id_video, id_distribuidor)
VALUES(101, '2011-07-26', 1, 20);

-- Esta consulta nos muestra la cantidad de distribuidores que hay para un mismo video.
SELECT e.id_video, COALESCE(COUNT(e.id_distribuidor), 0) AS cant_distribuidores
FROM entrega e
WHERE e.id_video = 1    -- Aquí iría el nuevo registro que se esta insertando
```

<h2>EJERCICIO 2</h2>

```SQL
CREATE OR REPLACE TRIGGER tr_borrar_vista3
INSTEAD OF DELETE ON VISTA_3
FOR EACH ROW
EXECUTE FUNCTION fn_propagar_borrado();

CREATE OR REPLACE FUNCTION fn_propagar_borrado() RETURNS TRIGGER AS $$
    BEGIN
        RAISE NOTICE 'Llame al trigger';
        --Si no existe el adjunto que queremos borrar
        IF NOT EXISTS(
            SELECT 1
            FROM adjunto
            WHERE id_adjunto = OLD.id_adjunto
        )THEN

            RAISE EXCEPTION 'No existe el adjunto con la id: %', OLD.id_adjunto;

        ELSE

            RAISE NOTICE 'Existe el adjunto que queremos borrar';

            --Si el adjunto es de tipo imagen, lo borramos de la tabla imagen
            IF (OLD.tipo_adj ILIKE 'I') THEN
                RAISE NOTICE 'Borrada imagen';
                DELETE FROM imagen WHERE id_adjunto = OLD.id_adjunto;

            --Si el adjunto es de tipo audio, lo borramos de la tabla audio
            ELSIF (OLD.tipo_adj ILIKE 'A') THEN
                RAISE NOTICE 'Borrado audio';
                DELETE FROM audio WHERE id_adjunto = OLD.id_adjunto;
            end if;

            -- Elinamos la referencia por FK del id_adjunto de la tabla contiene
            DELETE FROM contiene WHERE id_adjunto = OLD.id_adjunto;

            --Una vez que todas las foreign keys fueron borradas, borramos de la tabla referenciada
            DELETE FROM adjunto WHERE id_adjunto = OLD.id_adjunto;
        END IF;
        RETURN OLD;
    END;
    $$ LANGUAGE plpgsql;
```