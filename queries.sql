--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Consultas SQL de Empleados (las del tema 10, en el mismo orden)
-- Se incluye en: iissi1/teoria/t10
--

USE employees_db;

-- RF01: Empleados con un sueldo inferior a 2000 euros
-- #region consulta-1
SELECT *
FROM employees e
WHERE e.salary < 2000;
-- #endregion

-- Nombre y sueldo de los empleados con un sueldo inferior a 2000 euros
-- #region consulta-2
SELECT e.name_emp, e.salary
FROM employees e
WHERE e.salary < 2000;
-- #endregion

-- RF02: Fechas de alta y baja de los empleados como una lista
-- #region consulta-3
SELECT ALL e.start_date, e.end_date
FROM employees e;
-- #endregion

-- RF02: Fechas de alta y baja de los empleados como un conjunto
-- #region consulta-4
SELECT DISTINCT e.start_date, e.end_date
FROM employees e;
-- #endregion

-- RF03: Empleados con un sueldo en [2000, 3000]
-- Opción 1
-- Opción 2
-- #region consulta-5
-- Con DISTINCT nos aseguramos de que no haya duplicados en el resultado
SELECT DISTINCT e.name_emp, e.salary
FROM employees e
WHERE e.salary >= 2000 AND e.salary <= 3000;
-- equivalente
SELECT DISTINCT e.name_emp, e.salary
FROM employees e
WHERE e.salary BETWEEN 2000 AND 3000;
-- #endregion

-- Empleados con un sueldo de 1000, 2500 o 3000 euros
-- #region consulta-6
SELECT DISTINCT e.name_emp, e.salary
FROM employees e
WHERE e.salary IN (1000, 2500, 3000);
-- #endregion

-- Empleados de los departamentos de Cádiz (IN con una subconsulta)
-- #region consulta-7
-- Empleados de los departamentos de Cádiz
SELECT e.name_emp, e.salary
FROM employees e
WHERE e.department_id IN (
	SELECT d.department_id
	FROM departments d
	WHERE d.city = 'Cádiz'
);
-- #endregion

-- #region consulta-8
-- Empleados con una 'o' en la segunda posición de su nombre
-- o que no tienen jefe
SELECT *
FROM employees e
WHERE e.name_emp LIKE '_o%' OR e.boss_id IS NULL;
-- #endregion

-- Empleados ordenados por departamento y luego por nombre
-- #region consulta-9
-- Ordena por departamento ascendente y, a igual
-- departamento, por nombre del empleado alfabético
SELECT *
FROM employees e
ORDER BY e.department_id, e.name_emp ASC;
-- #endregion

-- Producto cartesiano de empleados y departamentos
-- #region consulta-10
SELECT *
FROM employees e, departments d;
-- 7 empleados x 3 departamentos = 21 filas
-- #endregion

-- Empleados con su departamento
-- Opción 1: producto cartesiano y selección
-- #region consulta-11
SELECT e.name_emp, e.salary, e.start_date, d.name_dep
FROM employees e, departments d
WHERE e.department_id = d.department_id;
-- #endregion
-- Opción 2: JOIN … ON
-- Opción 3: NATURAL JOIN (combina por todas las columnas con el mismo nombre)
-- #region consulta-12
SELECT e.name_emp, e.salary, e.start_date, d.name_dep
FROM employees e
JOIN departments d ON d.department_id = e.department_id;
-- también, pero menos recomendable
SELECT name_emp, salary, start_date, name_dep
FROM employees NATURAL JOIN departments;
-- #endregion

-- LEFT JOIN conserva todos los empleados, incluso si no tienen departamento
-- #region consulta-13
SELECT e.employee_id, e.name_emp,
  d.department_id, d.name_dep
FROM employees e
LEFT JOIN departments d
  ON d.department_id = e.department_id;
-- #endregion

-- RIGHT JOIN conserva todos los departamentos, incluso si no tienen empleados
-- #region consulta-14
SELECT e.employee_id, e.name_emp,
  d.department_id, d.name_dep
FROM employees e
RIGHT JOIN departments d
  ON d.department_id = e.department_id;
-- #endregion

-- Unión de LEFT JOIN y RIGHT JOIN: equivale al FULL JOIN
-- #region consulta-15
SELECT e.employee_id, e.name_emp,
  d.department_id, d.name_dep
FROM employees e
LEFT JOIN departments d
  ON d.department_id = e.department_id
UNION
SELECT e.employee_id, e.name_emp,
  d.department_id, d.name_dep
FROM employees e
RIGHT JOIN departments d
  ON d.department_id = e.department_id;
-- #endregion

-- RF05: Departamentos sin empleados
-- Opción 1: EXCEPT (calca la diferencia del AR)
SELECT d.*
FROM departments d
JOIN (
	SELECT d.department_id
	FROM departments d
	EXCEPT
	SELECT e.department_id
	FROM employees e
) s ON s.department_id = d.department_id;
-- Opción 2: NOT EXISTS
-- #region consulta-17
-- Departamentos sin empleados
SELECT *
FROM departments d
WHERE NOT EXISTS (
	SELECT *
	FROM employees e
	WHERE e.department_id = d.department_id
);
-- #endregion

-- RF04: Departamentos con empleados
-- #region consulta-16
-- Departamentos con empleados
SELECT *
FROM departments d
WHERE EXISTS (
	SELECT *
	FROM employees e
	WHERE e.department_id = d.department_id
);
-- #endregion

-- RF06: Estadísticas de los salarios de los empleados
-- #region consulta-18
-- Estadísticas de los salarios de los empleados
SELECT COUNT(*) AS tot, MIN(e.salary) AS min, MAX(e.salary) AS max,
	AVG(e.salary) AS med, SUM(e.salary) AS sum
FROM employees e;
-- #endregion

-- RF07: Estadísticas de los salarios por departamento
-- (mcc: salario medio con la comisión). El JOIN con departments descarta los
-- empleados sin departamento, que si no formarían un grupo con department_id NULL
-- #region consulta-19
SELECT e.department_id,
	COUNT(*) AS tot,
	AVG(e.salary) AS med,
	AVG(e.salary * (1 + e.fee)) AS mcc,
	SUM(e.salary) AS sum
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY e.department_id;
-- #endregion

-- RF08: Estadísticas de los salarios por departamento con al menos dos empleados
-- #region consulta-20
SELECT e.department_id,
	COUNT(*) AS tot,
	AVG(e.salary) AS med,
	AVG(e.salary * (1 + e.fee)) AS mcc,
	SUM(e.salary) AS sum
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY e.department_id
HAVING COUNT(*) > 1;
-- #endregion
-- Opción 2: usando la vista v_employees_departments
CREATE OR REPLACE VIEW v_employees_departments AS
SELECT e.*, d.name_dep, d.city
FROM employees e
JOIN departments d ON d.department_id = e.department_id;

SELECT ed.name_dep,
	COUNT(*) AS tot,
	AVG(ed.salary) AS med,
	AVG(ed.salary * (1 + ed.fee)) AS mcc,
	SUM(ed.salary) AS sum
FROM v_employees_departments ed
GROUP BY ed.department_id, ed.name_dep
HAVING COUNT(*) > 1;
-- Opción 3: sin HAVING, con una subconsulta en el FROM
-- #region consulta-21
-- Consulta equivalente sin HAVING
SELECT *
FROM (
	SELECT e.department_id,
		COUNT(*) AS tot,
		AVG(e.salary) AS med,
		AVG(e.salary * (1 + e.fee)) AS mcc,
		SUM(e.salary) AS sum
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	GROUP BY e.department_id
) st
WHERE st.tot > 1;
-- #endregion

-- Opción 4: sin HAVING, con WITH (la subconsulta, antes y con nombre)
-- #region consulta-22
-- Con WITH
WITH st AS (
	SELECT e.department_id,
		COUNT(*) AS tot,
		AVG(e.salary) AS med,
		AVG(e.salary * (1 + e.fee)) AS mcc,
		SUM(e.salary) AS sum
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	GROUP BY e.department_id
)
SELECT *
FROM st
WHERE st.tot > 1;
-- #endregion

-- Empleados con un sueldo mayor que la media de todos los departamentos
-- (mayor que cada una de las medias)
-- #region consulta-23
SELECT e.name_emp, e.salary
FROM employees e
WHERE e.salary > ALL (
	SELECT AVG(e2.salary)
	FROM employees e2
	JOIN departments d2
	  ON d2.department_id = e2.department_id
	GROUP BY e2.department_id
);
-- Jose (2500)
-- #endregion

-- Empleados con un sueldo mayor que la media de algún departamento
-- (mayor que la menor de las medias)
-- #region consulta-27
SELECT e.name_emp, e.salary
FROM employees e
WHERE e.salary > ANY (
	SELECT AVG(e2.salary)
	FROM employees e2
	JOIN departments d2 ON d2.department_id = e2.department_id
	GROUP BY e2.department_id
);
-- Pedro (2300), Jose (2500) y Lola (2300)
-- #endregion

-- Departamento con más empleados
-- Opción 1
-- #region consulta-24
-- Departamento con más empleados (opción 1)
SELECT e.department_id
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY e.department_id
HAVING COUNT(*) >= ALL (
	SELECT COUNT(*)
	FROM employees e2
	JOIN departments d2 ON d2.department_id = e2.department_id
	GROUP BY e2.department_id
);
-- 1 (Arte)
-- #endregion
-- Opción 2
-- #region consulta-25
-- Departamento con más empleados (opción 2)
SELECT e.department_id
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY e.department_id
HAVING COUNT(*) = (
	SELECT MAX(ne.total)
	FROM (
		SELECT COUNT(*) AS total
		FROM employees e2
		JOIN departments d2 ON d2.department_id = e2.department_id
		GROUP BY e2.department_id
	) ne
);
-- 1 (Arte), como en la opción 1
-- #endregion

-- #region consulta-26
-- Departamento con más empleados (opción 3)
WITH n AS (
	SELECT e.department_id, COUNT(*) AS tot
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	GROUP BY e.department_id
),
m AS (
	SELECT MAX(n.tot) AS max
	FROM n
)
SELECT n.department_id
FROM n, m
WHERE n.tot = m.max;
-- 1 (Arte), como en las opciones 1 y 2
-- #endregion
-- Opción 3: con WITH (n, los empleados de cada departamento; m, el máximo)
WITH n AS (
	SELECT e.department_id, COUNT(*) AS tot
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	GROUP BY e.department_id
),
m AS (
	SELECT MAX(n.tot) AS max
	FROM n
)
SELECT n.department_id
FROM n, m
WHERE n.tot >= m.max;

-- #region consulta-28
-- Vista con las estadísticas de los empleados por departamento
CREATE OR REPLACE VIEW v_stat_employees AS
SELECT e.department_id,
	COUNT(*) AS tot,
	AVG(e.salary) AS med,
	AVG(e.salary * (1 + e.fee)) AS mcc,
	SUM(e.salary) AS sum
FROM employees e
JOIN departments d ON d.department_id = e.department_id
GROUP BY e.department_id;
-- Número de empleados del departamento con más empleados
SELECT MAX(s.tot) AS max
FROM v_stat_employees s;
-- 5
-- #endregion

-- Lo mismo con WITH (no crea la vista)
-- #region consulta-29
-- Lo mismo con WITH
WITH s AS (
	SELECT e.department_id,
		COUNT(*) AS tot,
		AVG(e.salary) AS med,
		AVG(e.salary * (1 + e.fee)) AS mcc,
		SUM(e.salary) AS sum
	FROM employees e
	JOIN departments d ON d.department_id = e.department_id
	GROUP BY e.department_id
)
SELECT MAX(s.tot) AS max
FROM s;
-- 5
-- #endregion
