--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Funciones de employees_db (f_avg_fee, con un procedimiento que la usa)
-- Se incluye en: iissi1/teoria/t11 y iissi1/ejercicios/req2sql/5_Empleados
--

-- #region f_num_employees
-- Devuelve el número de empleados de una localidad
DELIMITER //
CREATE OR REPLACE FUNCTION f_num_employees(p_city VARCHAR(64)) RETURNS INT
BEGIN
	RETURN (
		SELECT COUNT(*)
		FROM employees e
		JOIN departments d ON d.department_id = e.department_id
		WHERE d.city = p_city
	);
END //
DELIMITER ;
-- #endregion

-- Sin la función, agrupando por localidad (el grupo NULL cuenta a Lola):
-- SELECT d.city, COUNT(*) AS num_employees
-- FROM employees e
-- JOIN departments d ON d.department_id = e.department_id
-- GROUP BY d.city;

-- Con la función (f_num_employees(NULL) = 0 para Historia):
-- SELECT *, f_num_employees(d.city) AS num_employees
-- FROM departments d;

-- #region f_avg_fee
DELIMITER //
CREATE OR REPLACE FUNCTION f_avg_fee() RETURNS DOUBLE
BEGIN
	RETURN (
		SELECT AVG(e.fee)
		FROM employees e
	);
END //
DELIMITER ;

-- El procedimiento usa la función
DELIMITER //
CREATE OR REPLACE PROCEDURE p_equate_fees_with_function()
BEGIN
	DECLARE v_avg_fee DOUBLE;
	SET v_avg_fee = f_avg_fee();
	UPDATE employees SET fee = v_avg_fee;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- Como en p_equate_fees, antes se baja la comisión de Jose para no saltar RN06:
-- UPDATE employees SET fee = 0.3 WHERE employee_id = 2;
-- CALL p_equate_fees_with_function();

-- #region f_sum_salaries
-- Obtiene la suma de todos los salarios sin usar directamente SUM() en un SELECT
DELIMITER //
CREATE OR REPLACE FUNCTION f_sum_salaries() RETURNS DECIMAL(12, 2)
BEGIN
	DECLARE v_total DECIMAL(12, 2);
	DECLARE v_employee ROW TYPE OF employees;
	DECLARE v_done BOOLEAN DEFAULT FALSE;
	DECLARE cur_employees CURSOR FOR
		SELECT *
		FROM employees;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done := TRUE;
	SET v_total = 0;
	OPEN cur_employees;
	readLoop: LOOP
		FETCH cur_employees INTO v_employee;
		IF v_done THEN
			LEAVE readLoop;
		END IF;
		SET v_total = v_total + v_employee.salary;
	END LOOP;
	CLOSE cur_employees;
	RETURN v_total;
END //
DELIMITER ;
-- #endregion

-- SELECT f_sum_salaries();
