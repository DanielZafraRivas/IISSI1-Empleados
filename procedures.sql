--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Procedimientos de employees_db
-- Se incluye en: iissi1/teoria/t11 y iissi1/ejercicios/req2sql/5_Empleados
--

-- #region p_insert_department
DELIMITER //
CREATE OR REPLACE PROCEDURE p_insert_department(
	p_name_dep VARCHAR(32),
	p_city VARCHAR(64))
BEGIN
	INSERT INTO departments (name_dep, city)
		VALUES (p_name_dep, p_city);
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- CALL p_insert_department('Economía', 'Almería');

-- Insertar un departamento duplicado:
-- CALL p_insert_department('Economía', 'Almería');

-- #region p_insert_employee
DELIMITER //
CREATE OR REPLACE PROCEDURE p_insert_employee(
	p_employee_id INT,
	p_department_id INT,
	p_boss_id INT,
	p_name_emp VARCHAR(64),
	p_start_date DATE,
	p_end_date DATE,
	p_salary DOUBLE,
	p_fee DOUBLE)
BEGIN
	IF p_start_date IS NULL THEN
		SET p_start_date = CURDATE();
	END IF;
	INSERT INTO employees (employee_id, department_id, boss_id, name_emp, salary, start_date, end_date, fee)
	VALUES (p_employee_id, p_department_id, p_boss_id, p_name_emp, p_salary, p_start_date, p_end_date, p_fee);
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- CALL p_insert_employee(NULL, 3, NULL, 'Gabriel', NULL, NULL, 2500.0, 0.2);

-- #region p_equate_fees
-- Igualar la comisión de TODOS al valor de la comisión media
DELIMITER //
CREATE OR REPLACE PROCEDURE p_equate_fees()
BEGIN
	DECLARE v_avg_fee DOUBLE;
	SET v_avg_fee = (SELECT AVG(e.fee) FROM employees e);
	-- Modifica TODOS los empleados: no tiene WHERE
	UPDATE employees SET fee = v_avg_fee;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- Con los datos de p_populate, Jose pasaría de 0.5 a 0.19 y saltaría RN06;
-- antes se baja su comisión dentro del margen permitido:
-- UPDATE employees SET fee = 0.3 WHERE employee_id = 2;
-- CALL p_equate_fees();

-- #region p_raise_fee
-- Procedimiento para aplicar un aumento en la comisión de un empleado
DELIMITER //
CREATE OR REPLACE PROCEDURE p_raise_fee(p_employee_id INT, p_amount DOUBLE)
BEGIN
	DECLARE v_employee ROW TYPE OF employees;
	DECLARE v_new_fee DOUBLE;
	SELECT * INTO v_employee -- el resultado del SELECT se almacena en la variable
		FROM employees e
		WHERE e.employee_id = p_employee_id;
	SET v_new_fee = v_employee.fee + p_amount;
	UPDATE employees
		SET fee = v_new_fee
		WHERE employee_id = p_employee_id;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- CALL p_raise_fee(4, 0.1);
