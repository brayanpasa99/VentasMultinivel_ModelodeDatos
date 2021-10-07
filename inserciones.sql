/* -- Insertar Regiones
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Caribe');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Amazonia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Andina');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Insular');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Orinoquia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE) VALUES (NULL, 'Pacifica');

-- Insertar Representantes
INSERT into "Representante" (CEDULA, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, GRADO, ESTADO, CIUDAD, DIRECCION)
                    VALUES (1193220649, 1, NULL, 'Arley', 'Esteban', 'Quintero', 'Amaya', 'prueba@gmail.com', 'M', '30-08-2000', '22-08-2021', 3006485671, 'master', 'A', 'Santa Marta', 'Calle 1');

INSERT into "Representante" (CEDULA, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, GRADO, ESTADO, CIUDAD, DIRECCION)
                    VALUES (1234567890, 3, 1193220649, 'Mateo', NULL, 'Yate', 'Gonzalez', 'prueba2@gmail.com', 'M', '01-02-1999', '22-08-2021', 3006485672, 'beginner', 'A', 'Bogotá', 'Calle 2');

INSERT into "Representante" (CEDULA, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, GRADO, ESTADO, CIUDAD, DIRECCION)
                    VALUES (2345678901, 3, 1193220649, 'Kevin', 'Andres', 'Borda', 'Penagos', 'prueba3@gmail.com', 'M', '03-04-2000', '22-08-2021', 3006485673, 'beginner', 'A', 'Bogotá', 'Calle 3');

INSERT into "Representante" (CEDULA, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, GRADO, ESTADO, CIUDAD, DIRECCION)
                    VALUES (3456789012, 2, NULL, 'Brayan', 'Alexander', 'Paredes', 'Sanchez', 'prueba4@gmail.com', 'M', '20-09-1999', '22-08-2021', 3006485674, 'senior', 'A', 'Leticia', 'Calle 4');

INSERT into "Representante" (CEDULA, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, GRADO, ESTADO, CIUDAD, DIRECCION)
                    VALUES (4567890123, 4, NULL, 'Diego', 'Alejandro', 'Gonzalez', NULL, 'prueba5@gmail.com', 'M', '20-09-1999', '22-08-2021', 3006485675, 'junior', 'A', 'San Andrés', 'Calle 5');

-- Insertar Clientes

INSERT into "Cliente" (CEDULA, FK_CEDULA_REPRESENTANTE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO, ESTADO, CIUDAD, DIRECCION)
            VALUES (9283748392, 1193220649, 'Alba', 'Consuelo', 'Nieto', 'Lemus', 'prueba7@gmail.com', 'F', '03-03-1968', 3009456852, 'A', 'Bogotá', 'Calle 7');

INSERT into "Cliente" (CEDULA, FK_CEDULA_REPRESENTANTE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO, ESTADO, CIUDAD, DIRECCION)
            VALUES (9283748391, 1193220649, 'Andres', 'Manuel', 'Lopez', 'Obrador', 'prueba6@gmail.com', 'M', '03-03-2003', 3009456851, 'A', 'Bogotá', 'Calle 6');

-- Insertar Periodos
INSERT INTO "Periodo" (ID_PERIODO, FECHA_INICIO, FECHA_FIN) VALUES (1, '01-01-2021', '31-01-2021');
INSERT INTO "Periodo" (ID_PERIODO, FECHA_INICIO, FECHA_FIN) VALUES (2, '01-02-2021', '28-02-2021');

-- Insertar en RepresentantePeriodo
INSERT INTO "RepresentantePeriodo" (FK_CEDULA_REPRESENTANTE, FK_ID_PERIODO, MONTO, GRADO, PORCENTAJE)
                        VALUES (1193220649, 1, 2000000, 'master', 8);

INSERT INTO "RepresentantePeriodo" (FK_CEDULA_REPRESENTANTE, FK_ID_PERIODO, MONTO, GRADO, PORCENTAJE)
                        VALUES (1193220649, 2, 3000000, 'master', 8);

-- Insertar Categorias
INSERT INTO "Categoria" (NOMBRE) VALUES ('Hogar');
INSERT INTO "Categoria" (NOMBRE) VALUES ('Belleza');

-- Insertar Productos
INSERT INTO "Producto" (ID_PRODUCTO, FK_ID_CATEGORIA, NOMBRE) VALUES (1, 1, 'Detergente');
INSERT INTO "Producto" (ID_PRODUCTO, FK_ID_CATEGORIA, NOMBRE) VALUES (2, 2, 'Labial');

-- Insertar Inventario
INSERT INTO "Inventario" VALUES (1, 1, 4500);
INSERT INTO "Inventario" VALUES (2, 1, 5000);
INSERT INTO "Inventario" VALUES (2, 2, 3500);
 */

-- Insertar Regiones
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Caribe', 'Colombia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Amazonia', 'Colombia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Andina', 'Colombia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Insular', 'Colombia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Orinoquia', 'Colombia');
INSERT INTO "Region" (FK_ID_DIRECTOR, NOMBRE, PAIS) VALUES (NULL, 'Pacifica', 'Colombia');

-- Insertar Categorias
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (NULL, 'Hogar');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (NULL, 'Nutricion');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (NULL, 'Cuidado Personal');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (NULL, 'Belleza');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (1, 'Sala');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (1, 'Cocina');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (2, 'Suplementos Dietarios');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (2, 'Alimentos Orgánicos');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (3, 'Cremas para el rostro');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (3, 'Cremas para el cuerpo');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (4, 'Labiales');
INSERT INTO "Categoria" (FK_CATEGORIA_PADRE, NOMBRE) VALUES (4, 'Tinturas');

-- Insertar Periodos
INSERT INTO "Periodo" (FECHA_INICIO, FECHA_FIN) VALUES ('01-01-2021', '31-03-2021');
INSERT INTO "Periodo" (FECHA_INICIO, FECHA_FIN) VALUES ('01-04-2021', '30-06-2021');
INSERT INTO "Periodo" (FECHA_INICIO, FECHA_FIN) VALUES ('01-07-2021', '30-09-2021');
INSERT INTO "Periodo" (FECHA_INICIO, FECHA_FIN) VALUES ('01-10-2021', '31-12-2021');

-- Insertar Grados
INSERT INTO "Grado" (NOMBRE_GRADO, PORCENTAJE_COMISION, CALIFICACION_MINIMA, VENTA_MINIMA) VALUES ('Beginner', 2, 3, 0);
INSERT INTO "Grado" (NOMBRE_GRADO, PORCENTAJE_COMISION, CALIFICACION_MINIMA, VENTA_MINIMA) VALUES ('Junior', 4, 3.5, 10000);
INSERT INTO "Grado" (NOMBRE_GRADO, PORCENTAJE_COMISION, CALIFICACION_MINIMA, VENTA_MINIMA) VALUES ('Senior', 6, 4, 20000);
INSERT INTO "Grado" (NOMBRE_GRADO, PORCENTAJE_COMISION, CALIFICACION_MINIMA, VENTA_MINIMA) VALUES ('Master', 8, 4.5, 30000);

-- Insertar Productos
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (5, 'Sala ecológica');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (5, 'Comedor ecológico');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (6, 'Filtro de agua ecológico');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (6, 'Cocina integral ecológica');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (7, 'Vitaminas orgánicas');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (7, 'Omega 3 orgánico');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (8, 'Huevos de gallina sin enjaular');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (8, 'Tomates sin insecticidas');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (9, 'Crema desmanchadora');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (9, 'Crema hidratante');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (10, 'Crema humectante');
INSERT INTO "Producto" (FK_ID_CATEGORIA, NOMBRE) VALUES (10, 'Crema anti-estrias');

-- Insertar Representantes
INSERT INTO "Representante" (CEDULA, TIPO_IDENTIFICACION, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO,
                             GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, FK_ID_GRADO, PROM_CALIFICACION, TOTAL_VENTA, ESTADO, CIUDAD, DIRECCION) 
                             VALUES (1193220649, 'CC', 3, NULL, 'Arley', 'Esteban', 'Quintero', 'Amaya', 'aeqa200@gmail.com', 'M', '30-08-2000', '01-01-2021', 1234567890, 4, 0, 0, 'A', 'Bogotá', 'Cra. 78');
INSERT INTO "Representante" (CEDULA, TIPO_IDENTIFICACION, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO,
                             GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, FK_ID_GRADO, PROM_CALIFICACION, TOTAL_VENTA, ESTADO, CIUDAD, DIRECCION) 
                             VALUES (1235478943, 'CC', 3, NULL, 'Pedro', NULL, 'Picapiedra', 'Quintero', 'pedro@gmail.com', 'M', '10-10-1950', '01-01-2021', 9876543210, 1, 0, 0, 'A', 'Zipaquira', 'Cra. 25');

INSERT INTO "Representante" (CEDULA, TIPO_IDENTIFICACION, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO,
                             GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, FK_ID_GRADO, PROM_CALIFICACION, TOTAL_VENTA, ESTADO, CIUDAD, DIRECCION) 
                             VALUES (6487548324, 'CC', 3, NULL, 'Andrea', NULL, 'Gonzalez', 'Norrea', 'andrea@gmail.com', 'F', '30-11-1990', '01-01-2021', 6559873215, 2, 0, 0, 'A', 'Soachakistan', 'Calle 70');

INSERT INTO "Representante" (CEDULA, TIPO_IDENTIFICACION, FK_ID_REGION, FK_ID_REP_PADRE, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO,
                             GENERO, FECHA_NACIMIENTO, FECHA_CONTRATO, TEL_CONTACTO, FK_ID_GRADO, PROM_CALIFICACION, TOTAL_VENTA, ESTADO, CIUDAD, DIRECCION) 
                             VALUES (3579518521, 'CC', 3, NULL, 'Carla', 'Silvia', 'Giraldo', 'Alzaceres', 'carla@gmail.com', 'F', '30-11-1995', '01-01-2021', 8526547190, 3, 0, 0, 'A', 'Usmekistan', 'Diagonal 3');

-- Insertar Cliente
INSERT INTO "Cliente" (CEDULA, TIPO_IDENTIFICACION, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO,
                       ESTADO, CIUDAD, DIRECCION) VALUES (1234567590, 'CC', 'Gabriel', 'Esteban', 'Castillo', 'Ramirez', 'gabelonio@gmail.com', 'M', '01-04-1998', 6464646464, 'A', 'Bogotá', 'Cll. 1');
INSERT INTO "Cliente" (CEDULA, TIPO_IDENTIFICACION, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO,
                       ESTADO, CIUDAD, DIRECCION) VALUES (1234567591, 'CC', 'Andres', 'Mateo', 'Narino', 'Rodriguez', 'mateo3@gmail.com', 'M', '02-06-1999', 6464646463, 'A', 'Bogotá', 'Cll. 2');
INSERT INTO "Cliente" (CEDULA, TIPO_IDENTIFICACION, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO,
                       ESTADO, CIUDAD, DIRECCION) VALUES (1234567592, 'CC', 'Brayan', 'Andres', 'Noguera', 'Ayala', 'brayan2@gmail.com', 'M', '05-10-1999', 6464646462, 'A', 'Bogotá', 'Cll. 3');
INSERT INTO "Cliente" (CEDULA, TIPO_IDENTIFICACION, PRIMER_NOMBRE, SEGUNDO_NOMBRE, PRIMER_APELLIDO, SEGUNDO_APELLIDO, CORREO_ELECTRONICO, GENERO, FECHA_NACIMIENTO, TEL_CONTACTO,
                       ESTADO, CIUDAD, DIRECCION) VALUES (1234567593, 'CC', 'Andrea', NULL, 'Rengifo', 'Ayala', 'andrea4@gmail.com', 'F', '05-11-2000', 6464646461, 'A', 'Bogotá', 'Cll. 3');

-- Insertar RepresentanteCliente
INSERT INTO "RepresentanteCliente" (FK_ID_REPRESENTANTE, FK_ID_CLIENTE, FECHA_INICIO, FECHA_FIN) VALUES (1193220649, 1234567590, '01-01-2021', NULL);
INSERT INTO "RepresentanteCliente" (FK_ID_REPRESENTANTE, FK_ID_CLIENTE, FECHA_INICIO, FECHA_FIN) VALUES (1235478943, 1234567591, '01-04-2021', NULL);
INSERT INTO "RepresentanteCliente" (FK_ID_REPRESENTANTE, FK_ID_CLIENTE, FECHA_INICIO, FECHA_FIN) VALUES (6487548324, 1234567592, '01-07-2021', NULL);
INSERT INTO "RepresentanteCliente" (FK_ID_REPRESENTANTE, FK_ID_CLIENTE, FECHA_INICIO, FECHA_FIN) VALUES (3579518521, 1234567593, '01-10-2021', NULL);

-- Insertar Inventario
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 1, 2000, 20);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 2, 1000, 30);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 3, 3000, 10);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 4, 500, 50);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 5, 4000, 5);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 6, 1500, 13);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 7, 3400, 11);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 8, 2300, 15);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 9, 1700, 34);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 10, 2800, 49);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 11, 5600, 27);
INSERT INTO "Inventario" (FK_ID_REGION, FK_ID_PRODUCTO, PRECIO, CANTIDAD) VALUES (3, 12, 1200, 3);

-- Insertar Pedidos
INSERT INTO "Pedido" (FK_CEDULA_CLIENTE, MONTO, FECHA_PEDIDO) VALUES (1234567590, 0, '29-09-2021');
INSERT INTO "Pedido" (FK_CEDULA_CLIENTE, MONTO, FECHA_PEDIDO) VALUES (1234567591, 0, '02-10-2021');
INSERT INTO "Pedido" (FK_CEDULA_CLIENTE, MONTO, FECHA_PEDIDO) VALUES (1234567592, 0, '10-05-2021');
INSERT INTO "Pedido" (FK_CEDULA_CLIENTE, MONTO, FECHA_PEDIDO) VALUES (1234567593, 0, '30-08-2021');

-- Insertar PedidoProducto
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (1, 3, 3);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (1, 5, 2);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (1, 2, 1);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (2, 6, 4);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (2, 2, 1);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (3, 11, 3);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (3, 1, 1);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (4, 4, 8);
INSERT INTO "PedidoProducto" (FK_ID_PEDIDO, FK_ID_PRODUCTO, CANTIDAD) VALUES (4, 9, 2);

-- Insertar Pago
INSERT INTO "Pago" (FK_ID_PEDIDO, FRANQUICIA, MEDIO_PAGO, NUM_TARJETA, CVV, FECHA_VENCIMIENTO) VALUES (1, 'Visa', 'T', 4316322145342198, 666, '10-11-2025');
INSERT INTO "Pago" (FK_ID_PEDIDO, MEDIO_PAGO, ID_PSE, CORREO_PSE) VALUES (2, 'P', 4316322145, 'gabelonio@gmail.com');
INSERT INTO "Pago" (FK_ID_PEDIDO, MEDIO_PAGO, ID_TRANSFERENCIA) VALUES (3, 'TR', 4316322123);

-- Insertar Calificacion
--INSERT INTO "Calificacion" ()
-- Insertar RepresentantePeriodo

