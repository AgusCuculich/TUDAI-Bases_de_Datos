Ejercicio 1

a) Cómo debería implementar las Restricciones de Integridad Referencial (RIR) si se desea que cada vez que se elimine un registro de la tabla PALABRA , también se eliminen los artículos que la referencian en la tabla CONTIENE.

```SQL
-- Reference: FK_P5P1E1_CONTIENE_PALABRA (table: P5P1E1_CONTIENE)
ALTER TABLE P5P1E1_CONTIENE 
    ADD CONSTRAINT FK_P5P1E1_CONTIENE_PALABRA
    FOREIGN KEY (idioma, cod_palabra)
    REFERENCES P5P1E1_PALABRA (idioma, cod_palabra) 
    ON DELETE CASCADE
    NOT DEFERRABLE 
    INITIALLY IMMEDIATE
;
```

b) Verifique qué sucede con las palabras contenidas en cada artículo, al eliminar una palabra, si definen la Acción Referencial para las bajas (ON DELETE) de la RIR correspondiente como:

ii) **Restrict**
    La eliminación no se permitirá hasta que las filas relacionadas en la tabla hija se eliminen o actualicen para romper la relación.

iii) **Es posible para éste ejemplo colocar SET NULL o SET DEFAULT para ON DELETE y ON UPDATE?**
    No sería posible hacer un SET NULL ya que las FK idioma y cod_palabra no aceptan valores NULL. El SET DEFAULT podría ser posible dependiendo si el tipo de dato DEFAULT son char(2) e int repectivamente (como se los definió en la misma tabla).

[DEFAULT-VALUES](https://www.postgresql.org/docs/current/ddl-default.html)

Ejercicio 2

a)
1. En este caso se podrá eliminar la tupla con id_proyecto = 3 sin ningún problema. Esto se debe a que el mismo no esta referenciado en ninguna otra tabla.
2. Como en el caso del DELETE, se podrá actualizar sin problema ya que la tupla no es referenciada en ninguna otra tabla.
3. No se puede eliminar ya que la el proyecto con id=1 esta refenciado en la tabla _trabaja_en.
4. Este empleado se encuentra refenciado en dos tablas: trabaja_en y auspicia. En el primer caso, la relación PK-FK en la misma tiene la acción referencial CASCADE, con lo que al eliminar el mismo de la tabla referenciada, se elimina de la tabla referenciante. A su vez, la tupla esta refenciada en la tabla "auspicia", teniando como acción referencial ON DELETE SET NULL, con lo que los registros que referencian a empleado quedarán NULL.
5. Al no estarse violando ninguna restricción, el registro se actualizará sin problema.
6. En este caso, el registro es diferenciado en otras dos tablas: auspicio y trabaja_en. La acción fallará en el primer caso, donde no se podrá llevar a cabo ya que la acción referecial ON UPDATE es de tipo RESTRICT; en el segundo caso, la acción referencial ON UPDATE es de tipo CASCADE

b) Ninguna de las respuestas. La consulta no se podrá llevar a cabo por la restricción de tipo RESTRICT para las operaciones ON UPDATE establecidas en las claves referenciadas de ambas tablas.

c) AUSPICIO_EMPLEADO
<table>
    <thead>
        <tr>
            <th>Inciso</th>
            <th>Match Simple</th>
            <th>Match Full</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>a</th>
            <th>:heavy_check_mark:</th>
            <th>:x:</th>
        </tr>
        <tr>
            <th>b</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>c</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>d</th>
            <th>:heavy_check_mark:</th>
            <th>:x:</th>
        </tr>
    </tbody>
</table>

AUSPICIO_PROYECTO
<table>
    <thead>
        <tr>
            <th>Inciso</th>
            <th>Match Simple</th>
            <th>Match Full</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <th>a</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>b</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>c</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
        <tr>
            <th>d</th>
            <th>:heavy_check_mark:</th>
            <th>:heavy_check_mark:</th>
        </tr>
    </tbody>
</table>

Ejercicio 3

a) Sí, en una tabla puedes definir diferentes acciones de referencia para las relaciones de clave externa (RIR) que apuntan a la misma tabla, siempre y cuando las restricciones sean coherentes y no entren en conflicto con la integridad referencial de la base de datos.

```SQL
-- Tabla Ruta
CREATE TABLE Ruta (
    ruta_id integer PRIMARY KEY,
    ciudad_desde_id integer,
    ciudad_hasta_id integer,
    FOREIGN KEY (ciudad_desde_id) REFERENCES Ciudad(ciudad_id) ON DELETE CASCADE,
    FOREIGN KEY (ciudad_hasta_id) REFERENCES Ciudad(ciudad_id) ON DELETE RESTRICT
);
```

b) No es posible porque la columna nro_carretera (FK) de la tabla RUTA no permite valores NULL.