CREATE TABLESPACE PROY_DEF DATAFILE 'C:\OracleXE184_Win64\oradata\XE\PROY_DEF.DBF'
SIZE 4M AUTOEXTEND ON;

CREATE TEMPORARY TABLESPACE PROY_TEMP TEMPFILE 'C:\OracleXE184_Win64\oradata\XE\PROY_TEMP.DBF'
SIZE 4M AUTOEXTEND ON;

alter session set "_ORACLE_SCRIPT"=true;

CREATE USER ADMPROY IDENTIFIED BY admproy 
DEFAULT TABLESPACE PROY_DEF 
TEMPORARY TABLESPACE PROY_TEMP 
QUOTA 4M ON PROY_DEF 
PASSWORD EXPIRE;

GRANT CONNECT, RESOURCE TO admproy;

GRANT all privileges TO admproy; -- desde system

CONNECT admproy;
-- Password admproy: admproy
-- Password admproy nueva: bd2g3

/*Creacion de roles*/
CREATE ROLE consultor IDENTIFIED BY consultor;
CREATE ROLE gestor_c1 IDENTIFIED BY gestor_c1;
CREATE ROLE gestor_c2 IDENTIFIED BY gestor_c2;
CREATE ROLE supervisor IDENTIFIED BY admproy;

-- Ejecutar ModeloRelacional.sql

REVOKE all ON "RepresentantePeriodo" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Region" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Representante" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Periodo" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "PedidoProducto" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Pedido"FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Inventario"FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Categoria" FROM consultor, gestor_c1, gestor_c2, supervisor;
REVOKE all ON "Cliente" FROM consultor, gestor_c1, gestor_c2, supervisor;

GRANT select ON "Cliente" TO consultor, gestor_c1, gestor_c2, supervisor;
GRANT select ON "Representante" TO consultor, gestor_c1, gestor_c2, supervisor;
GRANT select ON "Periodo" TO gestor_c2, supervisor;
GRANT select ON "Pedido" TO consultor, gestor_c1, gestor_c2, supervisor;
GRANT select ON "Producto" TO gestor_c1, gestor_c2, supervisor;
GRANT select ON "Categoria" TO  gestor_c1, gestor_c2, supervisor;
GRANT select ON "Region" TO gestor_c2, supervisor;
GRANT select ON "PedidoProducto" TO consultor, gestor_c1, gestor_c2, supervisor;
GRANT select ON "RepresentantePeriodo" TO gestor_c2, supervisor;
GRANT select ON "Inventario" TO consultor, gestor_c1, gestor_c2, supervisor;

GRANT update ON "Cliente" TO gestor_c1, gestor_c2, supervisor;
GRANT update ON "Representante" TO  gestor_c2, supervisor;
GRANT update ON "Periodo" TO supervisor;
GRANT update ON "Pedido" TO consultor, gestor_c1, gestor_c2, supervisor;
GRANT update ON "Producto" TO supervisor;
GRANT update ON "Categoria" TO supervisor;
GRANT update ON "Region" TO supervisor;
GRANT update ON "PedidoProducto" TO gestor_c1, gestor_c2, supervisor;
GRANT update ON "RepresentantePeriodo" TO gestor_c2, supervisor;
GRANT update ON "Inventario" TO supervisor;

GRANT insert ON "Cliente" TO gestor_c1, gestor_c2, supervisor;
GRANT insert ON "Representante" TO  gestor_c2, supervisor;
GRANT insert ON "Periodo" TO supervisor;
GRANT insert ON "Pedido" TO gestor_c1, gestor_c2, supervisor;
GRANT insert ON "Producto" TO supervisor;
GRANT insert ON "Categoria" TO supervisor;
GRANT insert ON "Region" TO supervisor;
GRANT insert ON "PedidoProducto" TO gestor_c1, gestor_c2, supervisor;
GRANT insert ON "RepresentantePeriodo" TO gestor_c2, supervisor;
GRANT insert ON "Inventario" TO supervisor;

GRANT delete ON "Cliente" TO gestor_c1, gestor_c2, supervisor;
GRANT delete ON "Representante" TO  gestor_c2, supervisor;
GRANT delete ON "Periodo" TO supervisor;
GRANT delete ON "Pedido" TO gestor_c1, gestor_c2, supervisor;
GRANT delete ON "Producto" TO supervisor;
GRANT delete ON "Categoria" TO supervisor;
GRANT delete ON "Region" TO supervisor;
GRANT delete ON "PedidoProducto" TO gestor_c1, gestor_c2, supervisor;
GRANT delete ON "RepresentantePeriodo" TO gestor_c2, supervisor;
GRANT delete ON "Inventario" TO supervisor;

/*Manejo de objetos*/
GRANT CREATE ANY INDEX TO gestor_c1, gestor_c2, supervisor;
GRANT CREATE SYNONYM TO supervisor;
GRANT CREATE VIEW TO gestor_c2, supervisor;
GRANT ALTER ANY INDEX TO supervisor;
GRANT ALTER ANY TABLE TO supervisor;
GRANT DROP ANY INDEX TO supervisor;
GRANT DROP ANY SYNONYM TO gestor_c2, supervisor;
GRANT DROP PUBLIC SYNONYM TO gestor_c2, supervisor;
GRANT DROP ANY VIEW TO supervisor;
GRANT DROP ANY TABLE TO supervisor;
GRANT SELECT ANY TABLE TO supervisor;
GRANT INSERT ANY TABLE TO supervisor;
GRANT DELETE ANY TABLE TO supervisor;
GRANT ALTER SESSION TO supervisor;
GRANT CREATE SESSION TO consultor, gestor_c1, gestor_c2, supervisor;

/*Gestion de la BD*/
GRANT CREATE PROFILE TO supervisor;
/* GRANT CREATE ROLE TO supervisor; */
GRANT CREATE ROLLBACK SEGMENT TO supervisor;
GRANT CREATE TABLESPACE TO supervisor;
GRANT CREATE USER TO supervisor;
GRANT ALTER PROFILE TO supervisor;
/* GRANT ALTER ROLE TO supervisor; */
GRANT ALTER ROLLBACK SEGMENT TO supervisor;
GRANT ALTER TABLESPACE TO supervisor;
GRANT ALTER USER TO supervisor;
GRANT DROP PROFILE TO supervisor;
/* GRANT DROP ROLE TO supervisor; */
GRANT DROP ROLLBACK SEGMENT TO supervisor;
GRANT DROP TABLESPACE TO supervisor;
GRANT DROP USER TO supervisor;
GRANT ALTER DATABASE TO supervisor;
/* GRANT ANY PRIVILEGE TO supervisor;
GRANT ANY ROLE TO supervisor;
GRANT UNLIMITED TABLESPACE TO consultor, gestor_c1, gestor_c2, supervisor; */

/* Creacion de Usuarios crearusuario.sql*/







