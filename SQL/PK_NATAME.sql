CREATE OR REPLACE PACKAGE PK_NATAME AS 

/*-----------------------------------------------------------------------------------
  Proyecto   : Tienda de productos naturales NaTaMe - Grupo 6 BD II
  Descripcion: Paquete que contiene los procedimientos y funciones descritos en
               el Taller de Seguridad - Pt. 2
  Autores:     Arley Esteban Quintero - 20171020022
               Mateo Yate Gonzalez - 20171020087
               Brayan A. Paredes - 20171020106
               Kevin A. Borda - 20171020088
--------------------------------------------------------------------------------------*/

/*------------------------------------------------------------------------------
     (1) Funcion totalizar el carrito, incluyendo el cálculo del IVA
     Parametros de Entrada: id_pedido       Identificación del pedido a liquidar
                            id_region       Identificación de la región donde se realiza el
     Retorna:               El total del pedido con el IVA incluido
    */    
    FUNCTION TOTALIZAR_CARRITO(id_pedido IN "Pedido".ID_PEDIDO % TYPE,
                               id_region IN "Region".ID_REGION % TYPE) RETURN NUMBER;

/*------------------------------------------------------------------------------
     (2) Función para pagar en línea el carrito luego de la comunicación con la API del banco.
     Parametros de Entrada: 
     Retorna:               El id. del pago registrado.           
    */ 


/*------------------------------------------------------------------------------
     (3) Funcion para Generar la factura de venta mediante un archivo PL/SQL y retornarla a la app para mostrarla.
     Parametros de Entrada: id_pedido       Identificación del pedido al cual se le desea realizar facturación.
                            id_region       Identificacion de la región para el llamado de la func. TOTALIZAR_CARRITO
     Retorna:               Cadena de texto de tipo VARCHAR que contiene la factura para ser ilustrada en la App.
    */ 
    FUNCTION PR_GENERAR_FACTURA(id_pedido IN "Pedido".id_pedido%TYPE,
                                id_region IN "Region".id_region%TYPE) RETURN VARCHAR;

/*------------------------------------------------------------------------------
     (4) Procedimiento que Implementa la funcionalidad que permite al cliente calificar a su representante de ventas
     Parametros de Entrada: id_pedido       Identificación del pedido a liquidar
                            nota            Calificacion de 0 a 5 del cliente al representante
                            observacion     Anotacion dada por el cliente referente al desempeño del representante
     Parametros de Salida:  Ninguno.
    */
    PROCEDURE CALIFICAR_REPRESENTANTE(id_pedido     IN "Pedido".ID_PEDIDO % TYPE,
                                      nota          IN NUMBER,
                                      observacion   IN VARCHAR
    );

/*------------------------------------------------------------------------------
     (5) Procedimiento para Calcular el promedio de las calificaciones periódicas de cada representante
     Parametros de Entrada: id_region       Identificación de la región de los representantes cuyos promedios
                                            de calificación se desean calcular.
     Parametros de Salida:  Ninguno.
     Particularidad:        El procedimiento emplea polimorfismo para contemplar el caso en el que se desee calcular 
                            únicamente el promedio de calificaciones de representantes de una región.
    */
    PROCEDURE CALCULO_PROMEDIO_CALIFICACION;
    PROCEDURE CALCULO_PROMEDIO_CALIFICACION(id_region IN "Region".id_region%TYPE);

/*------------------------------------------------------------------------------
     (6) Función para calificar periódicamente a los representantes de ventas y generar un resumen con los datos
     corresppndientes al total de ventas de cada representante, representante a cargo y acumulado de ventas de cada
     uno; promedio de calificación, categoría anterior y categoría asignada.
     Parametros de Entrada: id_region       Identificación de la región de los representantes cuyos reportes
                                            y calificaciones periódicas se desean generar.
     Retorna:               El resumen en formato VARCHAR de cada uno de los representantes con los
                            parámetros descritos en el alcance del taller para ser impreso o ilustrado
                            en la aplicación.
     Particularidad:        El procedimiento emplea funciones que retornan cursores de manera 
                            polimorfica descritas abajo.
                            Se emplea una función en vez de un procedimiento puesto que se requiere
                            realizar un retorno a la aplicación para ilustrar el resumen.
    */     
    FUNCTION PR_REPORTE_REPRESENTANTE RETURN VARCHAR;
    FUNCTION PR_REPORTE_REPRESENTANTE(id_region IN "Region".id_region%TYPE) RETURN VARCHAR;

/*------------------------------------------------------------------------------
     (7) Procedimiento para calcular al final de cada periodo la comisión de los represenantes de ventas. 
     (Se ejecuta en el trigger TG_FINAL_PERIODO).
     Parametros de Entrada: id_region           Identificación de la región de los representantes a los cuales
                                                se les desea calcular la comisión en el periodo actual.
     Parametros de Salida:  Ninguno.
     Particularidad:        Emplea polimorfismo por si se desea calcular la comisión de todos los representantes
                            o únicamente los representantes de una región en particular.
    */   
    PROCEDURE CALCULAR_COMISION_PERIODICA;
    PROCEDURE CALCULAR_COMISION_PERIODICA(id_region IN "Region".id_region%TYPE);     

/*------------------------------------------------------------------------------
     * Procedimiento para buscar el periodo que se encuentra actualmente en vigencia (Empleado por otros procedimientos)
     Parametros de Entrada: Ninguno.
     Parametros de Salida:  fecha_inicio    Fecha de inicio del periodo actual.
                            fecha_fin       Fecha final del periodo actual. (Los periodos duran 3 meses).
                            id_periodo      Identifación del periodo actual.
    */    
    PROCEDURE PR_BUSCAR_PERIODO_ACTIVO(fecha_inicio OUT DATE,
                                      fecha_fin     OUT DATE,
                                      id_periodo    OUT NUMBER
    );
    
/*------------------------------------------------------------------------------
     * Funcion para listar los representantes de la empresa o asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_region       Identificación de la región de los representantes que se
                                            desean listar.
     Retorna:               Cursor con los representantes de la empresa o asociados a una región particular.
    */ 
    FUNCTION LISTAR_REPRESENTANTES RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES(id_region IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;

/*------------------------------------------------------------------------------
     * Funcion para listar los representantes ordenados de la empresa o asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_region       Identificación de la región de los representantes que se
                                            desean listar.
     Retorna:               Cursor con los representantes de la empresa o asociados a una región particular ordenados.
    */ 
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_ORDENADOS(id_region IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;

/*------------------------------------------------------------------------------
     * Funcion para listar los representantes a cargo de un representante particular en la 
     empresa o de los representantes asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: id_representante    Identificación del representante cuyos representantes a cargo
                                                se desean filtrar.
                            id_region           Identificación de la región de los representantes que se
                                                desean listar.
     Retorna:               Cursor con los representantes que estan a cargo de un representante en particular
                            (teniendo en cuenta o no la región del representante si se desea listar por región
                            o por empresa). 
    */    
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE) RETURN SYS_REFCURSOR;
    FUNCTION LISTAR_REPRESENTANTES_A_CARGO(id_representante IN "Representante".cedula%TYPE,
                                          id_region         IN "Region".id_region%TYPE) RETURN SYS_REFCURSOR;
    
/*------------------------------------------------------------------------------
     * Funcion para listar los grados que se encuentran almacenados previamente en la tabla de Grados. 
     (Usado en CALCULAR_COMISION_PERIODICA).
     empresa o de los representantes asociados a una región en particular. (Usado en PR_REPORTE_REPRESENTANTE)
     Parametros de Entrada: Ninguno.
     Retorna:               Cursor con los grados almacenados en la BD.
    */ 
    FUNCTION LISTAR_GRADOS RETURN SYS_REFCURSOR;

/*------------------------------------------------------------------------------
     * Procedimiento para Insertar productos a un pedido en particular.
     Parametros de Entrada: id_region       Identificación de la región del producto a añadir.
                            id_producto     Identificación del producto a añadir.
                            id_pedido       Identificación del pedido al cual se añadirá el producto.
                            cantidad        Cantidad de unidades del producto que se añadirán al pedido.
     Parametros de Salida:  Ninguno.
    */
    PROCEDURE PR_INSERTAR_PRODUCTO(id_region    IN "Inventario".fk_id_region%TYPE,
                                   id_producto  IN "Inventario".fk_id_producto%TYPE,
                                   id_pedido    IN "Pedido".id_pedido%TYPE,
                                   cantidad     IN NUMBER
                                    );

/*------------------------------------------------------------------------------
     * Procedimiento para Realizar el cambio de representante a un cliente.
     Parametros de Entrada: id_cliente          Identificación del cliente al cual se le desea realizar el cambio.
                            id_representante    Identificación del nuevo representante asociado a un cliente.
     Parametros de Salida:  Ninguno.
    */
    PROCEDURE PR_CAMBIAR_REPRESENTANTE(id_cliente           IN "Cliente".cedula%TYPE,
                                        id_representante    IN "Representante".cedula%TYPE);

END PK_NATAME;
/