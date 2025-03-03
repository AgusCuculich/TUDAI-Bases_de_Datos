### Parte 1

1. Seleccione el identificador y nombre de todas las instituciones que son Fundaciones.
```SQL
SELECT id_institucion, nombre_institucion 
FROM institucion
WHERE nombre_institucion ILIKE 'FUNDACION %';
```
> 10 filas

2. Seleccione el identificador de distribuidor, identificador de departamento y nombre de todos los departamentos.
```SQL
SELECT id_distribuidor, id_departamento, nombre
FROM departamento;
```
> 1054 filas

3. Muestre el nombre, apellido y el teléfono de todos los empleados cuyo id_tarea sea 7231, ordenados por apellido y nombre.
```SQL
SELECT nombre, apellido, telefono
FROM empleado
WHERE id_tarea = '7231'
ORDER BY apellido, nombre;
```
> 6 filas

4. Muestre el apellido e identificador de todos los empleados que no cobran porcentaje de comisión.
```SQL
SELECT apellido, id_empleado 
FROM empleado
WHERE porc_comision = 0 OR porc_comision IS NULL;
```
> 11725 filas

5. Muestre el apellido y el identificador de la tarea de todos los voluntarios que no tienen coordinador.
```SQL
SELECT apellido, id_tarea
FROM voluntario
WHERE id_coordinador IS NULL;
```
> 1 fila

6. Muestre los datos de los distribuidores internacionales que no tienen registrado teléfono.
```SQL
SELECT *
FROM distribuidor
WHERE tipo = 'I' AND telefono IS NULL; 
```
> 1 fila

7. Muestre los apellidos, nombres y mails de los empleados con cuentas de gmail y cuyo sueldo sea superior a $1000.
```SQL
SELECT apellido, nombre, e_mail
FROM empleado
WHERE e_mail LIKE '%gmail%' AND sueldo > 1000;
```
> 25477 filas

8. Seleccione los diferentes identificadores de tareas que se utilizan en la tabla empleado.
```SQL
SELECT DISTINCT id_tarea 
FROM empleado
```
> 7891 filas

9. Muestre el apellido, nombre y mail de todos los voluntarios cuyo teléfono comienza con +51. Coloque el encabezado de las columnas de los títulos 'Apellido y Nombre'; y 'Dirección de mail'.
```SQL
SELECT apellido || ' ' || nombre AS "Apellido y Nombre",  e_mail AS "Dirección de mail"
FROM voluntario
WHERE telefono LIKE '+51%';
```
> 3 filas

10. Hacer un listado de los cumpleaños de todos los empleados donde se muestre el nombre y el apellido (concatenados y separados por una coma) y su fecha de cumpleaños (solo el día y el mes), ordenado de acuerdo al mes y día de cumpleaños en forma ascendente.
```SQL
SELECT apellido || ', ' || nombre AS "Apellido, Nombre", TO_CHAR(fecha_nacimiento, 'DD-MM') AS "Cumpleaños"
FROM empleado
ORDER BY EXTRACT(MONTH FROM fecha_nacimiento), EXTRACT(DAY FROM fecha_nacimiento);
```
> 35081 filas

> [!NOTE]
> * EXTRACT(MONTH FROM fecha_nacimiento), EXTRACT(DAY FROM fecha_nacimiento) --> Devuelve valores numéricos (tipo INTEGER), lo que permite ordenar correctamente.
> * TO_CHAR(fecha_nacimiento, 'DD-MM') --> Devuelve una cadena de texto.

11. Recupere la cantidad mínima, máxima y promedio de horas aportadas por los voluntarios nacidos desde 1990.
```SQL
SELECT min(horas_aportadas) AS "minimo", max(horas_aportadas) AS "maximo", avg(horas_aportadas) AS "promedio"
FROM voluntario
WHERE EXTRACT(YEAR FROM fecha_nacimiento) > 1990;
```

12. Listar la cantidad de películas que hay por cada idioma.
```SQL
SELECT idioma, COUNT(codigo_pelicula)
FROM pelicula
GROUP BY idioma;
```
> 75 filas

13. Calcular la cantidad de empleados por departamento.
```SQL
SELECT id_departamento, COUNT(id_empleado)
FROM empleado
GROUP BY id_departamento;
```
> 100 filas

14. Mostrar los códigos de películas que han recibido entre 3 y 5 entregas. (veces entregadas, NO cantidad de películas entregadas).
```SQL
SELECT codigo_pelicula, COUNT(nro_entrega)
FROM renglon_entrega
GROUP BY codigo_pelicula
HAVING COUNT(nro_entrega) BETWEEN 3 AND 5;
```
> 6317 filas

### Parte 2

#### Ejercicio 1:

1. Listar todas las películas que poseen entregas de películas de idioma inglés durante el año 2006.
```SQL
SELECT *
FROM pelicula p
WHERE EXISTS (
    SELECT 1
    FROM renglon_entrega r
    WHERE p.codigo_pelicula = r.codigo_pelicula
    AND EXISTS(
        SELECT 2
        FROM entrega e
        WHERE r.nro_entrega = e.nro_entrega
        AND EXTRACT(YEAR FROM e.fecha_entrega) = 2006
    ))
AND p.idioma ILIKE 'Inglés';
```
> 44 filas

2. Indicar la cantidad de películas que han sido entregadas en 2006 por un distribuidor nacional. Trate de resolverlo utilizando ensambles.
```SQL
SELECT r.cantidad
FROM renglon_entrega r
JOIN entrega e USING(nro_entrega)
JOIN distribuidor d USING(id_distribuidor)
WHERE EXTRACT(YEAR FROM e.fecha_entrega) = 2006
AND d.tipo = 'N';
```
> 1937 filas

3. Indicar los departamentos que no posean empleados cuya diferencia de sueldo máximo y mínimo (asociado a la tarea que realiza) no supere el 40% del sueldo máximo. (Probar con 10% para que retorne valores).
```SQL
SELECT DISTINCT e.id_departamento
FROM empleado e
WHERE NOT EXISTS (
    SELECT 1
    FROM tarea t
    WHERE e.id_tarea = t.id_tarea
    AND (t.sueldo_maximo - t.sueldo_minimo) > (t.sueldo_maximo * 0.4)
)
```
> 100 filas

4. Liste las películas que nunca han sido entregadas por un distribuidor nacional.
```SQL
SELECT * 
FROM pelicula p
WHERE p.codigo_pelicula NOT IN (
    SELECT r.codigo_pelicula
    FROM renglon_entrega r
    WHERE r.nro_entrega IN (
        SELECT e.nro_entrega 
        FROM entrega e
        WHERE e.id_distribuidor IN (
            SELECT d.id_distribuidor
            FROM distribuidor d
            WHERE d.tipo = 'N'
        )
    )
);
```
> 11444 filas

> [!NOTE]
> 1. Se construye una lista de todas las películas que han sido entregadas por un distribuidor nacional ('N').
> 2. NOT IN se asegura de que esas películas sean excluidas de los resultados.

> [!CAUTION]
> En que se diferencia la resolución propuesta con la siguiente consulta?
> ```SQL
> SELECT * 
> from pelicula p
> JOIN renglon_entrega r USING(codigo_pelicula)
> JOIN entrega e USING(nro_entrega)
> JOIN distribuidor d USING(id_distribuidor)
> WHERE d.tipo != 'N';
> ```
> 16993 filas
> 
> 1. NOT IN elimina completamente cualquier película que haya sido entregada por un distribuidor nacional, mientras que JOIN solo filtra registros específicos.
> 2. JOIN genera múltiples filas por película si tiene varias entregas internacionales, inflando el número total de resultados.
> 3. NOT IN devuelve una lista de películas únicas, mientras que JOIN devuelve una lista de entregas de películas, repitiendo aquellas que han sido entregadas varias veces.

> [!CAUTION]
> En que se diferencia la resolución propuesta con la siguiente consulta?
> ```SQL
> SELECT *
> FROM pelicula p
> WHERE p.codigo_pelicula IN(
>     SELECT r.codigo_pelicula
>     FROM renglon_entrega r
>     WHERE p.codigo_pelicula = r.codigo_pelicula
>     AND r.nro_entrega IN(
>         SELECT e.nro_entrega 
>         FROM entrega e
>         WHERE r.nro_entrega = e.nro_entrega
>         AND id_distribuidor IN(
>             SELECT d.id_distribuidor
>             FROM distribuidor d
>             WHERE e.id_distribuidor = d.id_distribuidor
>             AND tipo != 'N'
>         )
>     )
> );
> ```
> 13094 filas
> 
> :x: ¿Qué hace esta consulta? :arrow_right: Busca todas las películas que fueron entregadas por al menos un distribuidor que NO sea nacional ('N').
> :x: No considera si una película fue entregada por ambos tipos de distribuidores :arrow_right: No excluye las películas que también fueron entregadas por un distribuidor nacional.
> :white_check_mark: Lo que realmente queremos es que ninguna entrega de esa película haya sido hecha por un distribuidor nacional.
> 
> | codigo_pelicula | id_distribuidor | tipo |
> |----------------|---------------|------|
> | P01           | 1             | 'N'  |
> | P01           | 2             | 'I'  |
> | P02           | 2             | 'I'  |
> | P03           | 3             | 'I'  | 
> 
> Si usamos tipo != 'N', la película P01 aparecerá en los resultados, porque fue entregada por un distribuidor internacional ('I'). Pero P01 también fue entregada por un distribuidor nacional ('N'), por lo que NO debería estar en la lista.

5. Determinar los jefes que poseen personal a cargo y cuyos departamentos (los del jefe) se encuentren en la Argentina.
```SQL
SELECT e1.nombre
FROM empleado e1
WHERE EXISTS (
    SELECT 1
    FROM empleado e2
    WHERE e1.id_empleado = e2.id_jefe
)  
AND e1.id_departamento IN (
    SELECT d.id_departamento
    FROM departamento d
    WHERE d.id_ciudad IN (
        SELECT c.id_ciudad
        FROM ciudad c
        WHERE c.id_pais IN (
            SELECT p.id_pais
            FROM pais p
            WHERE p.nombre_pais ILIKE 'ARGENTINA'
        )
    )
);
```
> 61 filas

6. Liste el apellido y nombre de los empleados que pertenecen a aquellos departamentos de Argentina y donde el jefe de departamento posee una comisión de más del 10% de la que posee su empleado a cargo.
```SQL
SELECT e.nombre, e.apellido
FROM empleado e
WHERE e.id_departamento IN(
    SELECT d.id_departamento 
    FROM departamento d
    WHERE d.id_ciudad IN(
        SELECT c.id_ciudad
        FROM ciudad c
        WHERE c.id_pais IN(
            SELECT p.id_pais
            FROM pais p
            WHERE p.nombre_pais ILIKE 'ARGENTINA'
        )
    )
    AND EXISTS(
        SELECT 1
        FROM empleado e2
        WHERE d.jefe_departamento = e2.id_empleado
        AND e2.porc_comision > (e.porc_comision * 1.10)
    )
)
```
> 190 filas

7. Indicar la cantidad de películas entregadas a partir del 2010, por género.
```SQL
SELECT p.genero, COUNT(p.*)
FROM pelicula p
WHERE p.codigo_pelicula IN(
    SELECT r.codigo_pelicula
    FROM renglon_entrega r
    WHERE r.nro_entrega IN(
        SELECT e.nro_entrega
        FROM entrega e
        WHERE EXTRACT(YEAR FROM fecha_entrega) > 2010
    )
)
GROUP BY p.genero;
```
> 23 filas

8. Realizar un resumen de entregas por día, indicando el video club al cual se le realizó la entrega y la cantidad entregada. Ordenar el resultado por fecha.
```SQL
SELECT e.fecha_entrega, e.id_distribuidor, SUM(r.cantidad)
FROM entrega e
JOIN renglon_entrega r USING(nro_entrega)
GROUP BY e.fecha_entrega, id_distribuidor
ORDER BY e.fecha_entrega
```
> 5022 filas