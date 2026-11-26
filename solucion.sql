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