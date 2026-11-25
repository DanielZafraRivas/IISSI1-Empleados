--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Carga la BD de Empleados (esquema, rutinas, triggers y datos)
--

SELECT '>>> Creando BD employees_db';
SOURCE create_db.sql
SOURCE procedures.sql
SOURCE triggers.sql
SOURCE functions.sql
SOURCE populate_db.sql
