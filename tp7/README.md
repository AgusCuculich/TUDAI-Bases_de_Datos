<h3>WITH CHECK OPTION(WCO)</h3>
This option controls the behavior of automatically updatable views. When this option is specified, INSERT and UPDATE commands on the view will be checked to ensure that new rows satisfy the view-defining condition (that is, the new rows are checked to ensure that they are visible through the view). If they are not, the update will be rejected. If the CHECK OPTION is not specified, INSERT and UPDATE commands on the view are allowed to create rows that are not visible through the view.

```SQL
CREATE VIEW nombre AS
SELECT * FROM tabla
WHERE ciudad = 'Tandil'
WITH [ CASCADED | LOCAL ] CHECK OPTION;
```

* **LOCAL**: New rows are only checked against the conditions defined directly in the view itself. Any conditions defined on underlying base views are not checked (unless they also specify the CHECK OPTION).

* **CASCADED**: New rows are checked against the conditions of the view and all underlying base views.

> [!IMPORTANT]
>  If the CHECK OPTION is specified, and neither LOCAL nor CASCADED is specified, then CASCADED is assumed.

[CREATE_VIEW(DocSQL)](https://www.postgresql.org/docs/current/sql-createview.html)


**Vista definida sobre más de una tabla (vistas de ensamble o Selección-Proyección-Ensamble)**
La vista debe incluir las claves primarias de las tablas base involucradas para que las operaciones INSERT, UPDATE y DELETE puedan identificar unívocamente las filas afectadas.

La vista obtenida a partir de varias tablas básicas es actualizable si altera la tabla correspondiente a la Key Preserved.