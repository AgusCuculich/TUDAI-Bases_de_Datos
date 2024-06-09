<h2>EJERCICIO 1</h2>

1) a) Ambas vistas (definidas sobre una sola tabla) cumplen con las carácteristicas que debe tener una vista actualizable:
    1. El SELECT contiene todas las columnas de la PK (Suponiendo que las mismas sean id_distribuidor para la tabla Distribuidor_200, e id_departamento para Departamento_dist_200).
    2. No contiene funciones de agregación o información derivada.
    3. No incluye las cláusulas DISTINCT, GROUP BY ni HAVING.
    4. No contiene subconsultas anidadas complejas o múltiples niveles de subconsultas. Tampoco contiene JOINS.

El úncio problema que podría llegar a surgir es que la condición WHERE id_distribuidor > 200 hace referencia a una columna que no está seleccionada en la vista Departamento_dist_200. Si id_distribuidor pertenece a la tabla departamento, entonces la vista podría ser actualizable. Sin embargo, si id_distribuidor pertenece a otra tabla (lo que no se menciona en el contexto dado), la vista no sería actualizable debido a la referencia externa.

> [!NOTE]
> **Subconsulta compleja**: involucra múltiples tablas, operaciones de unión (JOIN), agregaciones (SUM(), COUNT(), etc.), o subconsultas anidadas. Otros casos son las subconsultas en la cláusula 'SELECT', y subconsultas en la cláusula 'FROM'.
>
> Ejemplos de subconsultas complejas:
>
> ```SQL
> CREATE VIEW VistaSubconsultaCompleja AS
> SELECT e.id, e.nombre, (SELECT AVG(salario) FROM empleados WHERE departamento_id = e.departamento_id) AS salario_promedio
> FROM empleados e;
> -- Subconsulta en la clásula SELECT
> ```
>
> ```SQL
> CREATE VIEW VistaJoinComplejo AS
> SELECT e.id, e.nombre
> FROM empleados e, (SELECT id, nombre FROM departamentos) d
> WHERE e.departamento_id = d.id;
> -- Subconsulta en la cláusula FROM
> ```
>
> Ejemplos de subconsultas simples:
> 
> ```SQL
> CREATE VIEW EMPL_PROY AS
> SELECT id_empleado, id_proyecto, cantidad_horas, tarea
> FROM TRABAJA T
> WHERE id_empleado IN
>     (SELECT id_empleado
>      FROM EMPLEADO E
>      WHERE E.ciudad = 'TANDIL');
> -- La subconsulta no afecta directamente las columnas seleccionadas, solo se utiliza para filtrar los resultados de la tabla TRABAJA.
> -- La subconsulta devuelve una lista de id_empleado y no incluye operaciones de agregación, joins, ni otras operaciones complejas.
> ```

b) 

A. La vista es actualizable ya que cumple con todas las caracteristicas mencionadas anteriormente.
B. Ningún dato pareciera ser una FK, con lo que creería que no se viola ese tipo de restricción.
C. La restricción de PK no se cumple ya que el id_distribuidor del nuevo registro que se esta queriendo insertar ya existe dentro de esa tabla, con lo que no cumple con ser un identificador único.
D. yyyy no.

<h2>EJERCICIO 2</h2>

1. Cree una vista EMPLEADO_DIST que liste el nombre, apellido, sueldo, y fecha_nacimiento de los empleados que pertenecen al distribuidor cuyo identificador es 20.

```SQL
CREATE VIEW EMPLEADO_DIST AS 
SELECT nombre, apellido, sueldo, fecha_nacimiento 
FROM empleado
WHERE id_distribuidor = 20;
```

No es una vista actualizable ya que el SELECT no contiene la columna de la PK de la tabla base.

2. Sobre la vista anterior defina otra vista EMPLEADO_DIST_2000 con el nombre, apellido y sueldo de los empleados que cobran más de 2000.

```SQL
CREATE VIEW EMPLEADO_DIST_2000 AS
SELECT nombre, apellido, sueldo
FROM EMPLEADO_DIST
WHERE sueldo > 2000;
```

Este punto arrastra el problema de la vista de la que esta seleccionando las columnas, no tiene la columna de la PK, con lo que no es una vista actualizable.

3. Sobre la vista EMPLEADO_DIST cree la vista EMPLEADO_DIST_20_70 con aquellos empleados que han nacido en la década del 70 (entre los años 1970 y 1979).

```SQL

```

4. Cree una vista PELICULAS_ENTREGADA que contenga el código de la película y la cantidad de unidades entregadas.

```SQL
CREATE VIEW PELICULAS_ENTREGADA AS
SELECT p.codigo_pelicula, (
    SELECT COALESCE(SUM(r.cantidad), 0) 
    FROM renglon_entrega r 
    WHERE p.codigo_pelicula = r.codigo_pelicula) 
AS unidades_entregadas
FROM pelicula p LIMIT 50;
```

Esta vista no es actualizable ya que tiene subconsulta compleja.

5. Cree una vista ACCION_2000 con el código, el titulo, el idioma y el formato de las películas del género ‘Acción’ entregadas en el año 2006.

```SQL
CREATE VIEW ACCION_2000 AS
SELECT p.codigo_pelicula, p.titulo, p.idioma
FROM pelicula p
WHERE genero ILIKE 'Accion'
AND codigo_pelicula IN (
    SELECT r.codigo_pelicula
    FROM renglon_entrega r
    WHERE r.nro_entrega IN (
        SELECT e.nro_entrega
        FROM entrega e
        WHERE EXTRACT(YEAR FROM e.fecha_entrega) = 2006
    ));
```

La vista contiene múltiples niveles de subconsulta, con lo que no es actualizable.

6. Cree una vista DISTRIBUIDORAS_ARGENTINA con los datos completos de las distribuidoras nacionales y sus respectivos departamentos.

```SQL
CREATE VIEW DISTRIBUIDORAS_ARGENTINAS AS
SELECT * FROM distribuidor d
JOIN nacional n ON d.id_distribuidor = n.id_distribuidor
JOIN departamento dp ON d.id_distribuidor = dp.id_distribuidor;
```

La vista no es actualizable ya que lo JOINS producen que haya repeticiones de la PK, lo que rompe con el requisito para que sea key-preserved.
La manera de reescribirlo sin que se produzca este error sería utilizando WHERE IN de la siguiente manera:

```SQL
CREATE VIEW DISTRIBUIDORAS_ARGENTINAS AS
SELECT * FROM distribuidor d
WHERE d.id_distribuidor IN(
    SELECT n.id_distribuidor FROM nacional n)
AND d.id_distribuidor IN(
    SELECT dp.id_distribuidor FROM departamento dp
    )
LIMIT 50;
```

El problema de la consulta de la vista anterior es que no trae todas las columnas de cada tabla como se pide en el enunciado.

7. De la vista anterior cree la vista Distribuidoras_mas_2_emp con los datos completos de las distribuidoras cuyos departamentos tengan más de 2 empleados.

```SQL
CREATE VIEW Distribuidoras_mas_2_emp AS
SELECT *
FROM distribuidor d
WHERE d.id_distribuidor IN (
    SELECT e.id_distribuidor
    FROM empleado e
    WHERE e.id_departamento IN (
        SELECT e.id_departamento
        FROM empleado e
        GROUP BY e.id_departamento
        HAVING COUNT(e.id_empleado) > 2
    )
);
```

No es una vista actualizable ya que contiene múltiples niveles de subconsulta, un GROUP BY, y también contiene funciones agregadas.

8. Cree la vista PELI_ARGENTINA con los datos completos de las productoras y las películas que fueron producidas por empresas productoras de nuestro país.

```SQL
CREATE VIEW PELI_ARGENTINA AS
    SELECT ep.nombre_productora, ep.id_ciudad, ep.codigo_productora, p.codigo_pelicula, p.titulo, p.idioma, p.formato, p.genero, p.codigo_productora
    FROM empresa_productora ep
    JOIN pelicula p ON ep.codigo_productora = p.codigo_productora
    JOIN ciudad c ON ep.id_ciudad = c.id_ciudad
    WHERE c.id_pais = 'AR'
```

No es actualizable ya que hay JOIN's de tablas.

9. De la vista anterior cree la vista ARGENTINAS_NO_ENTREGADA para las películas producidas por empresas argentinas pero que no han sido entregadas.

```SQL
CREATE VIEW ARGENTINAS_NO_ENTREGADAS
    SELECT codigo_pelicula, titulo, idioma, formato, genero, codigo_productora
    FROM PELI_ARGENTINA
        WHERE codigo_pelicula NOT IN(
            SELECT r.codigo_pelicula
            FROM renglon_entrega r
        );
```

Esta vista no es actualizable ya que se basa en una vista que no es actualizable.

10. Cree una vista PRODUCTORA_MARKETINERA con las empresas productoras que hayan entregado películas a TODOS los distribuidores.

``SQL

```