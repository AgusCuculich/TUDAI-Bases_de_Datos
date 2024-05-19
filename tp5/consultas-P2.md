Ejercicio 3

A. Controlar que las nacionalidades sean 'Argentina', 'Español', 'Inglés', 'Alemán' o 'Chilena'.

```SQL
ALTER TABLE P5P1E1_ARTICULO ADD CONSTRAINT CK_ARTICULO_nacionalidad
    CHECK (UPPER(nacionalidad) IN ('ARGENTINA', 'ESPAÑOL', 'INGLÉS', 'ALEMÁN', 'CHILENA'))
;
```

B. Para las fechas de publicaciones se debe considerar que sean fechas posteriores o iguales al 2010.

```SQL
ALTER TABLE P5P1E1_ARTICULO ADD CONSTRAINT CK_ARTICULO_fecha_limitada
    CHECK (EXTRACT(YEAR FROM fecha_publicacion) >= 2010)
;
```

C. Cada palabra clave puede aparecer como máximo en 5 artículos.

```SQL
ALTER TABLE P5P1E1_CONTIENE ADD CONSTRAINT CK_CONTIENE_palabras_max
    CHECK (NOT EXISTS(SELECT 1 FROM P5P1E1_CONTIENE c GROUP BY c.cod_palabra HAVING COUNT(*) < 5))
;
```

D. Sólo los autores argentinos pueden publicar artículos que contengan más de 10 palabras claves, pero con un tope de 15 palabras, el resto de los autores sólo pueden publicar artículos que contengan hasta 10 palabras claves.

```SQL
;
```

EJERCICIO 4 

A. La modalidad de la imagen médica puede tomar los siguientes valores RADIOLOGIA CONVENCIONAL, FLUOROSCOPIA, ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA, MAMOGRAFIA, SONOGRAFIA.

```SQL
ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD CONSTRAINT CK_IMAGEN_MEDICA_valores_modalidad
    CHECK ( UPPER(modalidad) IN ('RADIOLOGIA CONVENCIONAL', 'FLUOROSCOPIA', 'ESTUDIOS RADIOGRAFICOS CON FLUOROSCOPIA', 'MAMOGRAFIA', 'SONOGRAFIA') )
;
```

B. Cada imagen no debe tener más de 5 procesamientos.

C. Agregue dos atributos de tipo fecha a las tablas Imagen_medica y Procesamiento, una indica la fecha de la imagen y la otra la fecha de procesamiento de la imagen y controle que la segunda no sea menor que la primera.

```SQL
ALTER TABLE P5P2E4_IMAGEN_MEDICA
ADD COLUMN fecha_img date;

ALTER TABLE P5P2E4_PROCESAMIENTO
ADD COLUMN fecha_procesamiento_img date;

CREATE ASSERTION control_fechas
    CHECK(
        NOT EXISTS(
            SELECT 1 FROM P5P2E4_IMAGEN_MEDICA i, P5P2E4_PROCESAMIENTO p
            WHERE i.id_imagen = p.id_imagen
            AND
            i.fecha_img > p.fecha_procesamiento_img
        )
    )
;
```

D. Cada paciente sólo puede realizar dos FLUOROSCOPIA anuales.

```SQL
ALTER TABLE P5P2E4_IMAGEN_MEDICA ADD CONSTRAINT CK_max_fluoroscopia
    CHECK(
        NOT EXISTS(
            SELECT 1 FROM P5P2E4_IMAGEN_MEDICA i
            WHERE modalidad IN ('FLUOROSCOPIA')
            GROUP BY i.id_paciente, EXTRACT(YEAR FROM i.fecha_img)
            HAVING COUNT(*) > 2 
        )
    )
;

/*Esta restricción garantiza que no haya más de dos imágenes de FLUOROSCOPIA para un paciente en un año determinado en la tabla P5P2E4_IMAGEN_MEDICA. Si esta condición se viola para cualquier paciente y año, la operación de inserción o actualización de la tabla se revertirá y se lanzará un error.*/
```

E. No se pueden aplicar algoritmos de costo computacional “O(n)” a imágenes de FLUOROSCOPIA.

```SQL
CREATE ASSERTION costo_computacional_invalido_fluoroscopia
    CHECK(
        NOT EXISTS(
            SELECT 1 FROM P5P2E4_IMAGEN_MEDICA i
            JOIN P5P2E4_PROCESAMIENTO p ON i.id_imagen = p.id_imagen
            JOIN P5P2E4_ALGORITMO a ON p.id_algoritmo = a.id_algoritmo
            WHERE i.modalidad = 'FLUOROSCOPIA'
            AND
            a.costo_computacional = 'O(n)'
        )
    )
;
```

EJERCICIO 5

A. Los descuentos en las ventas son porcentajes y deben estar entre 0 y 100.

```SQL
ALTER TABLE p5p2e5_venta ADD CONSTRAINT CK_porcentaje_venta
    CHECK (descuento BETWEEN 0 AND 100);
```

B. Los descuentos realizados en fechas de liquidación deben superar el 30%.

```SQL
CREATE ASSERTION descuento_liquidacion
       CHECK(
            NOT EXISTS(
                SELECT 1 
                FROM p5p2e5_venta v
                WHERE v.descuento <= 0.3
                AND
                v.id_venta IN(
                    SELECT id_venta
                    FROM venta v
                    WHERE (EXTRACT(MONTH FROM v.fecha), EXTRACT(DAY FROM v.fecha), EXTRACT(YEAR FROM v.fecha)) IN(
                        SELECT TO_DATE(fl.dia_liq||'/'||'/'||fl.mes-liq||'/'||EXTRACT(YEAR FROM v.fecha) 
                        FROM p5p2e5_fecha_liq fl)
                    )
                )
            )
       )
;
```

C. Las liquidaciones de Julio y Diciembre no deben superar los 5 días.

```SQL
CREATE ASSERTION dias_liq_superados
       CHECK(
            NOT EXISTS(
                SELECT 1 FROM p5p2e5_fecha_liq l
                WHERE l.mes_liq IN (7, 12)
                AND
                cant_dias > 5
            )
        )
;
```

D. Las prendas de categoría ‘oferta’ no tienen descuentos.

```SQL
ALTER TABLE p5p2e5_prenda ADD CONSTRAINT CK_prenda_en_oferta
    CHECK(
        NOT EXISTS(
            SELECT 1 
            FROM p5p2e5_prenda p
            JOIN p5p2e5_venta v ON p.id_prenda = v.id_prenda
            WHERE p.categoria = 'oferta'
            AND
            v.descuento > 0
        )
    )
;
```