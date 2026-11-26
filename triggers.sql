--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Triggers de employees_db
-- Se incluye en: iissi1/teoria/t11 y iissi1/ejercicios/req2sql/5_Empleados
--

-- #region t_biu_employees_rn04_self_boss
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_employees_rn04_self_boss
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
	IF NEW.employee_id = NEW.boss_id THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RN04: Un empleado no puede ser su propio jefe';
	END IF;
END //
DELIMITER ;
-- #endregion

-- En un INSERT sin id, el BEFORE no lo detecta: AUTO_INCREMENT aún no ha asignado
-- el id (NEW.employee_id vale 0). En AFTER INSERT el id ya está asignado; si el
-- disparador lanza un error, se deshace la inserción.
-- #region t_ai_employees_rn04_self_boss
DELIMITER //
CREATE OR REPLACE TRIGGER t_ai_employees_rn04_self_boss
AFTER INSERT ON employees
FOR EACH ROW
BEGIN
	IF NEW.employee_id = NEW.boss_id THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RN04: Un empleado no puede ser su propio jefe';
	END IF;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- UPDATE employees SET boss_id = 1 WHERE employee_id = 1;
-- El siguiente id es 8: Y sería su propio jefe
-- INSERT INTO employees (department_id, boss_id, name_emp, salary, start_date, fee)
-- 	VALUES (2, 8, 'Y', 1500, '2024-01-01', 0.1);

-- OPCIÓN 1: No se permite realizar el cambio en la comisión
-- #region t_bu_employees_rn06_fee_change
DELIMITER //
CREATE OR REPLACE TRIGGER t_bu_employees_rn06_fee_change
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
	IF ABS(NEW.fee - OLD.fee) > 0.2 THEN
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RN06: La diferencia absoluta de comisión no puede superar 0.2';
	END IF;
END //
DELIMITER ;
-- #endregion

-- OPCIÓN 2: Se permite realizar el cambio, limitado al valor máximo permitido
/*
-- #region t_bu_employees_rn06_fee_change-2
DELIMITER //
CREATE OR REPLACE TRIGGER t_bu_employees_rn06_fee_change
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
	IF NEW.fee - OLD.fee > 0.2 THEN
		SET NEW.fee = LEAST(OLD.fee + 0.2, 1);
	ELSEIF NEW.fee - OLD.fee < -0.2 THEN
		SET NEW.fee = GREATEST(OLD.fee - 0.2, 0);
	END IF;
END //
DELIMITER ;
-- #endregion
*/

-- CALL p_populate();
-- UPDATE employees SET fee = 0.9 WHERE employee_id = 1;

-- #region t_biu_employees_rn02_max_employees
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_employees_rn02_max_employees
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN
	DECLARE v_employee_count INT DEFAULT 0;

	-- Se comprueba solo si el empleado entra en un departamento:
	-- - en INSERT, OLD.department_id vale NULL: entra si NEW.department_id no es NULL
	-- - en UPDATE, entra si cambia de departamento (<=> trata NULL como un valor)
	IF NOT (NEW.department_id <=> OLD.department_id) THEN
		SELECT COUNT(*) INTO v_employee_count
		FROM employees e
		WHERE e.department_id = NEW.department_id;

		IF v_employee_count >= 5 THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'RN02: Un departamento no puede tener más de cinco empleados';
		END IF;
	END IF;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- El departamento 1 ya tiene cinco empleados:
-- CALL p_insert_employee(NULL, 1, NULL, 'Sexto empleado', NULL, NULL, 1500, 0);

-- #region t_bi_employees_ri02_default_start_date
DELIMITER //
CREATE OR REPLACE TRIGGER t_bi_employees_ri02_default_start_date
BEFORE INSERT ON employees
FOR EACH ROW
BEGIN
	IF NEW.start_date IS NULL THEN
		SET NEW.start_date = CURDATE();
	END IF;
END //
DELIMITER ;
-- #endregion

-- CALL p_populate();
-- INSERT INTO employees (department_id, boss_id, name_emp, start_date, end_date, salary, fee)
-- 	VALUES (3, NULL, 'Gabriel', NULL, NULL, 1000, 0.4);

-- Para hacer la RA03, necesitamos hacer un trigger.   RA03: El salario de un empleado está entre el mínimo y el máximo de su categoría
DELIMITER //
CREATE OR REPLACE TRIGGER t_biu_employees_ra03
BEFORE INSERT OR UPDATE ON employees
FOR EACH ROW
BEGIN 
	
	DECLARE v_min_salary INT;
	DECLARE v_max_salary INT;
	
	SELECT min_salary, max_salary into v_min_salary, v_max_salary FROM categories WHERE category_id = NEW.category_id;
	
	IF (NEW.salary > v_max_salary OR NEW.salary < v_min_salary) THEN 
		SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'RA03: El salario es inferior al minimo o superior al máximo';
	END IF;
END //
DELIMITER ;

-- VAMOS A PROBAR EL EJERCICIO 3:
CALL p_populate();

-- Daniel (6) es Junior: puede cobrar hasta 1999
UPDATE employees SET salary = 1900 WHERE employee_id = 6;
SELECT * FROM employees WHERE employee_id = 6; -- (cobraba 1500)

-- Deben fallar:
INSERT INTO categories (name_cat, min_salary, max_salary) VALUES ('Junior', 1500, 2500);  -- RA01 : no se pueden repetir los nombres
INSERT INTO categories (name_cat, min_salary, max_salary) VALUES ('Directivo', 4000, 3000);  -- RA02 : el salario minimo no puede ser mayor que el maximo
UPDATE employees SET salary = 2100 WHERE employee_id = 6;  -- RA03 : Daniel es junior (no puede cobrar mas de 1999)
UPDATE categories SET max_salary = 2400 WHERE category_id = 2;  -- RA03: Jose es Senior (cobra 2500)