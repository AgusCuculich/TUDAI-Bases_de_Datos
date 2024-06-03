<h2>Subconsulta anidada</h2>
Permite traer datos de UN registro sobre los que trabajará una consulta externa.

> [!CAUTION]
> Este tipo de consultas debe devolver un solo resultado o dará un error.

```SQL
SELECT * FROM A WHERE cantidad_a = (SELECT MIN(cantidad_b) FROM B);
```

<h2>Operadores de comparación:</h2>

<table style="margin-left:auto; margin-right:auto;">
    <thead>
        <tr>
            <td>Operador</td>
            <td>Significado</td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>=</td>
            <td>Igual que</td>
        </tr>
        <tr>
            <td>></td>
            <td>Mayor que</td>
        </tr>
        <tr>
            <td>>=</td>
            <td>Mayor o igual que</td>
        </tr>
        <tr>
            <td><</td>
            <td>Menor que</td>
        </tr>
        <tr>
            <td><=</td>
            <td>Menor o igual que</td>
        </tr>
        <tr>
            <td><></td>
            <td>Distinto a</td>
        </tr>
    </tbody>
</table>

<h2>Operadores de subqueries que permiten el retorno de varios registros</h2>

* **[NOT] IN**

Al obtener los resultados de la subconsulta, compara los mismos con el campo deseado de la consulta externa. Los que coincidan con uno u otro valor, serán los resultados de la consulta.

```SQL
SELECT * FROM A WHERE cant_a IN (SELECT cant_b FROM B)
```
```SQL
SELECT * FROM A WHERE cant_a IN (val1, val2, val3...)
```

> Two rows are considered equal if all their corresponding members are non-null and equal; the rows are unequal if any corresponding members are non-null and unequal; otherwise the result of that row comparison is unknown (null). If all the per-row results are either unequal or null, with at least one null, then the result of IN is null.

* **ANY**

Se comporta igual que si fuera un IN, con la diferencia de que el anterior solo evalua igualdad, mientras que en este se pueden utilizar los operadores =, < y >.

```SQL
SELECT * FROM A WHERE cant_a < ANY (SELECT cant_b FROM B)
```
```SQL
SELECT * FROM A WHERE cant_a < ANY (val1, val2, val3...)
```

* **ALL**

Se utiliza para comparar un valor con todos los valores de una lista de valores resultante de una subconsulta.

```SQL
SELECT * FROM A WHERE cant_a > ALL (SELECT cant_b FROM B)
```
```SQL
SELECT * FROM A WHERE cant_a > ALL (val1, val2, val3...)
```

<h2>Consultas de más de una tabla y subconsulta correlacionada</h2>
La subconsulta se ejecuta repetidamente, una vez por cada fila procesada por la consulta externa, utilizando valores de esa fila para filtrar los resultados de la subconsulta.
Ej: Selecciona los nombres de los clientes que han realizado más pedidos que el promedio del número de pedidos por cliente.

```SQL
SELECT c.Nombre FROM Clientes c
WHERE (SELECT COUNT(*) FROM Pedidos p 
WHERE p.ClienteID = c.ID) > (SELECT AVG(COUNT(*)) FROM Pedidos GROUP BY ClienteID);
```

<h4>[NOT] EXISTS</h4>
Verifica si una subconsulta devuelve algún resultado. Si al menos un elemento cumple la condición, retornará un true, y en caso contrario, un false.

```SQL
SELECT * FROM A WHERE EXISTS(SELECT 1 FROM B WHERE x)
```

> The subquery will generally only be executed long enough to determine whether at least one row is returned, not all the way to completion.

> Since the result depends only on whether any rows are returned, and not on the contents of those rows, the output list of the subquery is normally unimportant. A common coding convention is to write all EXISTS tests in the form EXISTS(SELECT 1 WHERE ...).

<h2>Clausulas</h2>

* **DISTINCT**
Elimina los registros duplicados de los resultados de una consulta.

```SQL
SELECT DISTINCT Categoria FROM Productos;
```
> Se aplica a todas las columnas de la lista en el SELECT

* **UNION**

Se utiliza para combinar los resultados de dos o más consultas en una sola lista de resultados (eliminando duplicados).

```SQL
SELECT columna1 FROM tabla1
UNION
SELECT columna1 FROM tabla2;
```

* **INTERSECT**

Devuelve los registros que aparecen en ambas consultas.

```SQL
SELECT columna1 FROM tabla1
INTERSECT
SELECT columna1 FROM tabla2;
```
* **EXCEPT**

Devuelve los registros que están presentes en la primera consulta pero no en la segunda consulta.

```SQL
SELECT columna1 FROM tabla1
EXCEPT
SELECT columna1 FROM tabla2;
```
> [!CAUTION]
> Las consultas combinadas (UNION, INTERSECT Y EXCEPT) deben tener el mismo número de columnas y tipos de datos compatibles.

<h2>JOIN</h2>

> Todas las operaciones de JOIN se realizan de izquierda a derecha.

* **INNER JOIN / JOIN**

Combina filas de dos o más tablas en función de una condición de unión especificada en la cláusula ON.

```SQL
SELECT columnas
FROM tabla1
INNER JOIN tabla2
ON tabla1.columna = tabla2.columna;
```
**Multiple join**

```SQL
SELECT v.apellido, v.nombre FROM voluntario v 
INNER JOIN tarea t ON v.id_tarea = t.id_tarea
INNER JOIN institucion i ON v.id_institucion = i.id_institucion;
```

1. Las tablas del primer JOIN coinciden (tablas voluntario y tarea). Como resultado, se crea una tabla intermedia.
2. Esta tabla intermedia (tratada como la tabla izquierda) se une con la otra tabla (tabla institución) utilizando el segundo JOIN.

* **NATURAL JOIN**

Combina filas de dos tablas basándose en todas las columnas que tienen el mismo nombre y tipo de datos en ambas tablas.

```SQL
SELECT columnas
FROM tabla1
NATURAL JOIN tabla2;
```

* **RIGHT JOIN**

First, an inner join is performed. Then, for each row in T2 that does not satisfy the join condition with any row in T1, a joined row is added with null values in columns of T1. The result table will always have a row for each row in T2.

```SQL
SELECT columna1, columna2
FROM tabla1
RIGHT JOIN tabla2 ON tabla1.columna = tabla2.columna;
```

* **LEFT JOIN**

First, an inner join is performed. Then, for each row in T1 that does not satisfy the join condition with any row in T2, a joined row is added with null values in columns of T2. Thus, the joined table always has at least one row for each row in T1.

```SQL
SELECT columna1, columna2
FROM tabla1
LEFT JOIN tabla2 ON tabla1.columna = tabla2.columna;
```

* **FULL JOIN**

First, an inner join is performed. Then, for each row in T1 that does not satisfy the join condition with any row in T2, a joined row is added with null values in columns of T2. Also, for each row of T2 that does not satisfy the join condition with any row in T1, a joined row with null values in the columns of T1 is added.

```SQL
SELECT columna1, columna2
FROM tabla1
FULL JOIN tabla2 ON tabla1.columna = tabla2.columna;
```

Temas faltantes
- [ ] Funciones de grupo
- [ ] GROUP BY
- [ ] ORDER BY
- [ ] HAVING COUNT en lugar de GROUP BY
- [ ] LIMIT y OFFSET
- [ ] LIKE e ILIKE
- [ ] BETWEEN
- [ ] AS (renombrar)
- [ ] Añadir a la tabla de operadores los lógicos y aritméticos