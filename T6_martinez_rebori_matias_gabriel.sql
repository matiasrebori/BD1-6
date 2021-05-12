--@C:\sql\T6_martinez_rebori_matias_gabriel.sql
--conexion al sistema
CONN system/admin;
-- Si existe el usuario matias, lo elimino con todos sus objetos para probar una y otra vez;
DROP USER matias CASCADE;
--crear usuario
CREATE USER matias IDENTIFIED BY admin DEFAULT TABLESPACE users TEMPORARY TABLESPACE temp QUOTA UNLIMITED ON users;
--dar privilegio/permiso de inicio de sesion y de crear tablas
GRANT CREATE SESSION, CREATE TABLE, CREATE SEQUENCE, CREATE TRIGGER, CREATE VIEW TO matias;
--salir de system
DISC;
--entrar en matias
CONN matias/admin;

--crear tabla regiones

CREATE TABLE regiones (
	region_id number,
	region_nombre varchar2(25),
	constraint REG_ID_PK primary key (region_id)
);

--crear secuencia regiones

CREATE SEQUENCE SEQ_REGIONES_PK start with 1;

--crear tabla paises

CREATE TABLE paises(
	pais_id CHAR(2),
	pais_nombre VARCHAR2(40),
	region_id NUMBER,
	CONSTRAINT PAIS_ID_PK PRIMARY KEY ( pais_id ),
	CONSTRAINT PAIS_REG_FK FOREIGN KEY ( region_id ) REFERENCES regiones ( region_id )
); 

--crear secuencia paises

CREATE SEQUENCE SEQ_PAISES_PK;

--crear tabla ubicaciones

CREATE TABLE ubicaciones(
	ubicacion_id NUMBER(4),
	ubicacion_direccion VARCHAR2(30),
	ubicacion_postal VARCHAR(12),
	ubicacion_ciudad VARCHAR(30) NOT NULL,
	ubicacion_estado VARCHAR(25),
	pais_id CHAR(2),
	CONSTRAINT ubicacion_id_pk PRIMARY KEY ( ubicacion_id ),
	CONSTRAINT ubicacion_pais_fk FOREIGN KEY ( pais_id ) REFERENCES paises ( pais_id )
);

--crear secuencia ubicaciones
CREATE SEQUENCE SEQ_UBICACIONES_PK;

--crear tabla trabajos

CREATE TABLE trabajos(
	trabajo_id VARCHAR2(10),
	trabajo_titulo VARCHAR2(35) NOT NULL,
	trabajo_salario_max NUMBER(6),
	trabajo_salario_min NUMBER(6),
	CONSTRAINT trabajo_id_pk PRIMARY KEY ( trabajo_id )
);

--crear secuencia

CREATE SEQUENCE SEQ_TRABAJOS_PK;

--crear tabla departamentos sin fk empleado

CREATE TABLE departamentos(
	departamento_id NUMBER(4),
	departamento_nombre VARCHAR2(30) NOT NULL,
	gerente_id NUMBER(6),
	ubicacion_id NUMBER(6),
	CONSTRAINT departamento_id_pk PRIMARY KEY ( departamento_id ),
	CONSTRAINT departamento_ubicacion_fk FOREIGN KEY ( ubicacion_id ) REFERENCES ubicaciones ( ubicacion_id )
);
--secuencia

CREATE SEQUENCE SEQ_DEPARTAMENTOS_PK;

--crear tabla empleados

CREATE TABLE empleados(
	empleado_id NUMBER(6),
	empleado_nombre VARCHAR2(20),
	empleado_apellido VARCHAR2(25) NOT NULL,
	empleado_email VARCHAR(25) NOT NULL,
	empleado_telefono VARCHAR(20),
	empleado_fecha_contratado DATE NOT NULL,
	empleado_salario NUMBER(8,2),
	empleado_comision_pct NUMBER(2,2),
	trabajo_id VARCHAR2(10) NOT NULL,
	departamento_id NUMBER(4),
	gerente_id NUMBER(6),
	CONSTRAINT empleado_id_pk PRIMARY KEY ( empleado_id ),
	CONSTRAINT empleado_trabajo_fk FOREIGN KEY ( trabajo_id) REFERENCES trabajos ( trabajo_id ),
	CONSTRAINT empleado_departamento_fk FOREIGN KEY ( departamento_id ) REFERENCES departamentos ( departamento_id ),
	CONSTRAINT empleado_gerente_fk FOREIGN KEY ( gerente_id ) REFERENCES empleados ( empleado_id )
);

--secuencia

CREATE SEQUENCE SEQ_EMPLEADOS_PK;

--fk empleado para departamento

ALTER TABLE departamentos ADD CONSTRAINT departamento_empleado_fk FOREIGN KEY ( gerente_id ) REFERENCES empleados ( empleado_id);

--crear historial trabajos

CREATE TABLE historial_trabajos(
	empleado_id NUMBER(6),
	empleado_fecha_inicio DATE,
	empleado_fecha_fin DATE NOT NULL,
	trabajo_id VARCHAR2(10) NOT NULL,
	departamento_id NUMBER(4),
	CONSTRAINT historial_trabajo_id_pk PRIMARY KEY ( empleado_id, empleado_fecha_inicio ),
	CONSTRAINT historial_trabajo_trabajo_fk FOREIGN KEY ( trabajo_id ) REFERENCES trabajos ( trabajo_id ),
	CONSTRAINT historial_trabajo_depart_fk FOREIGN KEY ( departamento_id ) REFERENCES departamentos ( departamento_id),
	CONSTRAINT historial_trabajo_empleado_fk FOREIGN KEY ( empleado_id ) REFERENCES empleados ( empleado_id )
);

--trigger historial_trabajos
CREATE TRIGGER "tr_historial_trabajos"
AFTER UPDATE OF trabajo_id, departamento_id ON empleados
FOR EACH ROW 
BEGIN
INSERT INTO historial_trabajos VALUES( :old.empleado_id, :old.empleado_fecha_contratado, sysdate, :old.trabajo_id, :old.departamento_id);
END "tr_historial_trabajos";
/  

--5 Crear vista	

CREATE VIEW VISTA_EMPLEADOS ( ID_EMPLEADO, NOMBRES , TRABAJO_ACTUAL, JEFE, LOCALIDAD, REGION )
AS
SELECT
	E.EMPLEADO_ID,
	E.EMPLEADO_NOMBRE || ' ' || E.EMPLEADO_APELLIDO,
	T.TRABAJO_TITULO,
	E2.EMPLEADO_NOMBRE || ' ' || E2.EMPLEADO_APELLIDO,
	U.UBICACION_ESTADO,
	R.REGION_NOMBRE
FROM EMPLEADOS E
INNER JOIN TRABAJOS T ON E.TRABAJO_ID=T.TRABAJO_ID
--empleado con jefe null
LEFT JOIN EMPLEADOS E2 ON E.GERENTE_ID=E2.EMPLEADO_ID
INNER JOIN DEPARTAMENTOS D ON E.DEPARTAMENTO_ID = D.DEPARTAMENTO_ID
INNER JOIN UBICACIONES U ON D.UBICACION_ID=U.UBICACION_ID
INNER JOIN PAISES P ON P.PAIS_ID=U.PAIS_ID
INNER JOIN REGIONES R ON R.REGION_ID=P.REGION_ID
ORDER BY E.EMPLEADO_ID ASC;

-----------------insertar datos---------------------
----------------------------------------------------
INSERT INTO REGIONES VALUES(SEQ_REGIONES_PK.NEXTVAL,'SUDAMERICA');
INSERT INTO REGIONES VALUES(SEQ_REGIONES_PK.NEXTVAL,'CENTROAMERICA');
INSERT INTO REGIONES VALUES(SEQ_REGIONES_PK.NEXTVAL,'NORTEAMERICA');
INSERT INTO REGIONES VALUES(SEQ_REGIONES_PK.NEXTVAL,'EUROPA');
INSERT INTO REGIONES VALUES(SEQ_REGIONES_PK.NEXTVAL,'ASIA');
----------------------------------------------------
INSERT INTO PAISES VALUES(SEQ_PAISES_PK.NEXTVAL,'PARAGUAY',1);
INSERT INTO PAISES VALUES(SEQ_PAISES_PK.NEXTVAL,'ESTADOS UNIDOS',3);
INSERT INTO PAISES VALUES(SEQ_PAISES_PK.NEXTVAL,'NICARAGUA',2);
INSERT INTO PAISES VALUES(SEQ_PAISES_PK.NEXTVAL,'ESPAÑA',4);
INSERT INTO PAISES VALUES(SEQ_PAISES_PK.NEXTVAL,'COLOMBIA',1);
----------------------------------------------------
INSERT INTO UBICACIONES VALUES(SEQ_UBICACIONES_PK.NEXTVAL,'12 DE OCTUBRE 2344','1119','ASUNCION','CENTRAL',1);
INSERT INTO UBICACIONES VALUES(SEQ_UBICACIONES_PK.NEXTVAL,'AV DEFENSORES DEL CHACO 1234','1119','ASUNCION','CENTRAL',1);
INSERT INTO UBICACIONES VALUES(SEQ_UBICACIONES_PK.NEXTVAL,'12 AVE 5TH STREET 1232','1111','MIAMI','FLORIDA',2);
INSERT INTO UBICACIONES VALUES(SEQ_UBICACIONES_PK.NEXTVAL,'SAN JUAN ESQ LIBERTADOR 1111','1012','POMPOSA','CALI',5);
INSERT INTO UBICACIONES VALUES(SEQ_UBICACIONES_PK.NEXTVAL,'AVE MARIA 7843','7354','SAN PABLO','SEVILLA',4);
----------------------------------------------------
INSERT INTO TRABAJOS VALUES(SEQ_TRABAJOS_PK.NEXTVAL,'DESARROLLADOR JUNIOR',1000,3000);
INSERT INTO TRABAJOS VALUES(SEQ_TRABAJOS_PK.NEXTVAL,'DEV OPS',5000,10000);
INSERT INTO TRABAJOS VALUES(SEQ_TRABAJOS_PK.NEXTVAL,'SCRUM MANAGER',3000,4000);
INSERT INTO TRABAJOS VALUES(SEQ_TRABAJOS_PK.NEXTVAL,'DESARROLLADOR SENIOR',8000,10000);
INSERT INTO TRABAJOS VALUES(SEQ_TRABAJOS_PK.NEXTVAL,'LIDER DE PROYECTOS',1000,12000);
----------------------------------------------------
INSERT INTO DEPARTAMENTOS VALUES(SEQ_DEPARTAMENTOS_PK.NEXTVAL,'DESARROLLO','',1);
INSERT INTO DEPARTAMENTOS VALUES(SEQ_DEPARTAMENTOS_PK.NEXTVAL,'DEV OPS','',5);
INSERT INTO DEPARTAMENTOS VALUES(SEQ_DEPARTAMENTOS_PK.NEXTVAL,'PROYECTOS','',3);
INSERT INTO DEPARTAMENTOS VALUES(SEQ_DEPARTAMENTOS_PK.NEXTVAL,'ADMINISTRACION','',1);
INSERT INTO DEPARTAMENTOS VALUES(SEQ_DEPARTAMENTOS_PK.NEXTVAL,'RRHH','',1);
----------------------------------------------------
INSERT INTO EMPLEADOS VALUES(SEQ_EMPLEADOS_PK.NEXTVAL,'TONY','SAMPERE','TMRRAZI@GMAIL.COM','0981745625',TO_DATE('2019/04/04', 'YYYY/MM/DD'),7000,0.5,1,1,'');
UPDATE EMPLEADOS SET GERENTE_ID = 1 WHERE EMPLEADO_ID=1;
INSERT INTO EMPLEADOS VALUES(SEQ_EMPLEADOS_PK.NEXTVAL,'KIKE','SALCEDO','KIKEC@GMAIL.COM','+587745625',TO_DATE('2019/08/04', 'YYYY/MM/DD'),2000,0.5,1,2,1);
INSERT INTO EMPLEADOS VALUES(SEQ_EMPLEADOS_PK.NEXTVAL,'ROY','MARSHALL','MATHERS@GMAIL.COM','+187745625',TO_DATE('2019/06/03', 'YYYY/MM/DD'),8000,0.5,4,1,1);
INSERT INTO EMPLEADOS VALUES(SEQ_EMPLEADOS_PK.NEXTVAL,'JOHN','TINSEL','TINSEL@GMAIL.COM','+187235525',TO_DATE('2019/04/12', 'YYYY/MM/DD'),11000,0.5,5,3,'');
INSERT INTO EMPLEADOS VALUES(SEQ_EMPLEADOS_PK.NEXTVAL,'ROBERTO','GONZALEZ','TITOG@GMAIL.COM','+595981475852',TO_DATE('2019/04/20', 'YYYY/MM/DD'),4000,0.5,3,3,'');
----------------CAMBIO DE JEFE
UPDATE EMPLEADOS SET GERENTE_ID=4 WHERE EMPLEADO_ID=1;
UPDATE EMPLEADOS SET GERENTE_ID=4 WHERE EMPLEADO_ID=2;
UPDATE EMPLEADOS SET GERENTE_ID=4 WHERE EMPLEADO_ID=3;
UPDATE EMPLEADOS SET GERENTE_ID=5 WHERE EMPLEADO_ID=4;
--- PRUEBA DE TRIGGER
UPDATE empleados SET trabajo_id = 4 WHERE empleado_id=1;
UPDATE empleados SET trabajo_id = 2 WHERE empleado_id=2;
UPDATE departamentos SET gerente_id = 1 where departamento_id = 1;

--6 CONSULTA
SELECT 
	H.EMPLEADO_ID,
	E.EMPLEADO_NOMBRE || ' ' || E.EMPLEADO_APELLIDO AS NOMBRES,
	H.EMPLEADO_FECHA_INICIO AS FECHA_INICIO_CONTRATACION,
	H.EMPLEADO_FECHA_FIN AS FECHA_FIN_CONTRATACION,
	D.DEPARTAMENTO_NOMBRE AS DEPARTAMENTO,
	T.TRABAJO_TITULO AS PUESTO
FROM HISTORIAL_TRABAJOS H
INNER JOIN EMPLEADOS E ON H.EMPLEADO_ID=E.EMPLEADO_ID
INNER JOIN DEPARTAMENTOS D ON H.DEPARTAMENTO_ID=D.DEPARTAMENTO_ID
INNER JOIN TRABAJOS T ON T.TRABAJO_ID=H.TRABAJO_ID
ORDER BY H.EMPLEADO_ID ASC; 


COMMIT;