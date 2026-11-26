USE employees_db;

-- Archivo para los ejs 1 y 2 

-- ===============================================================================================================================
-- EJERCICIO 1 : Procedimiento que ponga la fecha de fin del contrato de un empleado y asigna sus subordinados activos a su jefe
-- ===============================================================================================================================
DELIMITER // 
CREATE OR REPLACE PROCEDURE p_end_contract(
	IN p_employee_id INT,
	IN p_end_date DATE
) 
BEGIN 
	
	DECLARE v_end_date DATE DEFAULT NULL;
	DECLARE v_jefe INT DEFAULT NULL;
	DECLARE v_employee_id INT DEFAULT NULL;
	
	SELECT employee_id INTO v_employee_id FROM employees WHERE employee_id = p_employee_id;
	IF v_employee_id IS NULL THEN 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Este empleado no existe';
	END IF;
	
	SELECT end_date INTO v_end_date FROM employees WHERE employee_id = p_employee_id;
	
	IF v_end_date < CURRENT_DATE THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El contrato de este empleado ya ha terminado';
	END IF;
	
	SELECT boss_id INTO v_jefe FROM employees WHERE employee_id = p_employee_id;
	
	UPDATE employees SET end_date = p_end_date WHERE employee_id = p_employee_id;
	
	UPDATE employees SET boss_id = v_jefe  WHERE boss_id = p_employee_id;
	
END //
DELIMITER ;

DELIMITER //
CREATE OR REPLACE PROCEDURE p_end_contract_tx(
	IN p_employee_id INT,
	IN p_end_date DATE
) 
BEGIN 
	
	BEGIN 
		DECLARE exit handler FOR SQLEXCEPTION 
			ROLLBACK;
			RESIGNAL;
	END;
	
	START TRANSACTION;
	
		CALL p_end_contract(p_employee_id, p_end_date);
	
	COMMIT; 
	
END //
DELIMITER ;
-- ===============================================================================================================================
-- EJERCICIO 1 : Función que devuelva el número de subordinados activos de un empleado
-- ===============================================================================================================================
DELIMITER //
CREATE OR REPLACE FUNCTION f_num_subordinates (p_employee_id INT) 
	RETURNS INT
READS SQL DATA 
BEGIN 
	DECLARE v_contador_subordinados INT;
	
	SELECT COUNT(*) INTO v_contador_subordinados FROM employees WHERE boss_id = p_employee_id;
	
	RETURN v_contador_subordinados;
END //
DELIMITER ;
	
-- VAMOS A PROBARLO
CALL p_populate();

-- Pedro(1) tiene tres subordinados (Luis, Ana y Daniel), pero solo Daniel está activo
SELECT f_num_subordinates(1);

CALL p_end_contract(1, '2026-12-31');
-- Pedro tiene fecha de fin y Daniel pasa a su jefe (Pedro no tiene: se queda sin jefe)
SELECT * FROM employees;
SELECT f_num_subordinates(1);   -- 0
-- Deben fallar 
CALL p_end_contract(4, '2026-12-31');  -- Luis ya terminó
CALL p_end_contract(99, '2026-12-31'); -- No existe



-- ===============================================================================================================================
-- EJERCICIO 2 : Procedimiento que suba un porcentaje (mayor que 0 y como mucho 10) el salario de los empleados activos en el departamento
--						 y que rechace los departamentos sin empleados activos
-- ===============================================================================================================================
DELIMITER //
CREATE OR REPLACE PROCEDURE p_raise_department_salaries(
	IN p_department_id INT,
	IN p_percentaje INT
) 
BEGIN 
	
	DECLARE v_active_employees INT;
	
	SELECT COUNT(*) FROM employees WHERE department_id = p_department_id AND (end_date > CURRENT_DATE OR end_date is NULL) INTO v_active_employees;
	
	IF v_active_employees = 0 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Este departamento no tiene empleados activos';
	END IF;
	
	IF (p_percentaje > 0 AND p_percentaje <= 10) THEN
		UPDATE employees SET salary = salary * (1 + p_percentaje/100) WHERE department_id = p_department_id AND (end_date > CURRENT_DATE OR end_date is NULL);
	ELSE 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'El porcentaje de subida debe estar entre 0 y 10';
	END IF;
	
END // 
DELIMITER ;

-- ===============================================================================================================================
-- EJERCICIO 2 : Función que devuelva los años de antigüedad de un empleado
-- ===============================================================================================================================
DELIMITER //
CREATE OR REPLACE FUNCTION f_seniority(p_employee_id INT) RETURNS INT 
READS SQL DATA 
BEGIN 
	DECLARE v_years INT;
	DECLARE v_start_date DATE;
	
	SELECT start_date INTO v_start_date FROM employees WHERE employee_id = p_employee_id;
	
	SET v_years = TIMESTAMPDIFF(YEAR, v_start_date, CURRENT_DATE);    -- Es necesaria la llamada a TIMESTAMPDIFF para que sea exacto (tiene en cuenta los meses
	
	RETURN  v_years;
END //
DELIMITER ;


-- VAMOS A PROBARLO: 
CALL p_populate();

-- En Arte (1) suben Pedro (2300 -> 2415) , Jose (2500 -> 2625) y Daniel (1500 -> 1575) ; Luis y Ana ya terminaron y no cambian (se quedan en 1300)
CALL p_raise_department_salaries(1, 5);
SELECT * FROM employees;

-- Deben fallar
CALL p_raise_department_salaries(1, 15);  -- mas del 10%
CALL p_raise_department_salaries(3, 5) -- Informática no tiene empleados activos

-- Antigüedad de Pedro (depende del día en que se ejecute)
SELECT f_seniority(1);

	 