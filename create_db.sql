--
-- Autor: David Ruiz
-- Fecha: Octubre de 2026
-- Descripción: Script para crear la BD de Empleados
-- Se incluye en: iissi1/teoria/t10 (DDL) y t11
--

DROP DATABASE IF EXISTS employees_db;
CREATE DATABASE employees_db;
USE employees_db;

-- #region departments
CREATE OR REPLACE TABLE departments (
	department_id INT NOT NULL AUTO_INCREMENT,
	name_dep VARCHAR(32) NOT NULL,
	city VARCHAR(64),
	PRIMARY KEY (department_id),
	CONSTRAINT uq_departments_rn03_name_city UNIQUE (name_dep, city)
);
-- #endregion

-- AÑADIR TABLA CATEGORIES (EJERCICIO 3) 
CREATE OR REPLACE TABLE categories (
	category_id INT NOT NULL AUTO_INCREMENT,
	name_cat VARCHAR(32) NOT NULL,
	min_salary INT NOT NULL,
	max_salary INT NOT NULL,
	
	PRIMARY KEY (category_id),
	CONSTRAINT uq_categories_ra01_name UNIQUE(name_cat),  												-- RA01: El nombre de la categoría no se puede repetir
	CONSTRAINT ck_categories_ra02_min_salary CHECK (min_salary BETWEEN 0 AND max_salary)		-- RA02: El salario minimo de una categoria es positivo y menor que el maximo
);

-- Para hacer la RA03, necesitamos hacer un trigger.   RA03: El salario de un empleado está entre el mínimo y el máximo de su categoría

-- #region employees
CREATE OR REPLACE TABLE employees (
	employee_id INT NOT NULL AUTO_INCREMENT,
	department_id INT,
	category_id INT NOT NULL,
	boss_id INT,
	name_emp VARCHAR(64) NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE,
	salary DOUBLE NOT NULL DEFAULT 2000,
	fee DOUBLE NOT NULL,
	PRIMARY KEY (employee_id),
	FOREIGN KEY (department_id) REFERENCES departments (department_id)
		ON DELETE RESTRICT,
	FOREIGN KEY (category_id) REFERENCES categories (category_id)
		ON DELETE RESTRICT,
	FOREIGN KEY (boss_id) REFERENCES employees (employee_id),
	CONSTRAINT uq_employees_rn01_name UNIQUE (name_emp),
	CONSTRAINT ck_employees_rn05_fee CHECK (fee >= 0 AND fee <= 1),
	CONSTRAINT ck_employees_dates CHECK (start_date < end_date),
	CONSTRAINT ck_employees_salary CHECK (salary > 0)
);
-- #endregion



	
	