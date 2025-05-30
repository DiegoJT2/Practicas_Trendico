/*1. Ejercicios de INSERT, UPDATE y DELETE*/
INSERT INTO categorias(nombre, descripcion) VALUES ('Tenis', 'Raquetas y calzado para tenis');
INSERT INTO productos(nombre, descripcion, precio, stock, categoria, marca) VALUES ('Raqueta Pro Tour', 'Raqueta profesional para competición', 199.99, 20, 12, 'Wilson');
INSERT INTO clientes(nombre, apellidos, email, telefono, fecha_registro, puntos_fidelidad) VALUES ('Laura', 'Fernández', 'laura@email.com', 644556677, '0000-00-00', 0);
/*1. Actualizar el precio de las "Zapatillas Run Fast" a 79.99.*/
UPDATE productos SET precio = 79.99 WHERE nombre = 'Zapatillas Run Fast';
/*2. Incrementar el stock de todos los productos de la categoría "Fitness" en 10 unidades.*/
UPDATE productos SET stock = stock + 10 WHERE id_categoria IN (SELECT id_categoria FROM categorias WHERE nombre ='fitness');
/*3. Sumar 50 puntos a los clientes que han realizado pedidos superiores a 100€.*/
UPDATE clientes AS A, pedidos AS B SET puntos_fidelidad = puntos_fidelidad + 50 WHERE A.id_cliente = B.id_cliente AND B.total > 100;
/*1. Borrar los productos con stock menor a 5.*/
DELETE FROM productos WHERE stock < 5;
/*2. Eliminar pedidos cancelados (estado = 'canceled').*/
DELETE FROM pedidos WHERE estado = 'canceled';
/*3. Borrar clientes inactivos (sin pedidos registrados).*/
DELETE FROM clientes WHERE id_cliente NOT IN (SELECT id_cliente FROM pedidos);

/*2. Ejercicios con TRANSACCIONES y ROLLBACK

1. Realizar una compra con verificación de stock:*/
DELIMITER //
CREATE PROCEDURE realizar_compra(
    IN id_cliente INT,
    IN id_producto1 INT,
    IN cantidad1 INT,
    IN id_producto2 INT,
    IN cantidad2 INT
)
BEGIN
    -- Iniciar transacción
    START TRANSACTION;

    -- Verificar stock de los productos
    IF (SELECT stock FROM productos WHERE id_producto = id_producto1) < cantidad1 OR
       (SELECT stock FROM productos WHERE id_producto = id_producto2) < cantidad2 THEN
        -- Si no hay suficiente stock, cancelar la transacción
        ROLLBACK;
        SELECT 'Error: No hay stock suficiente para uno o ambos productos. Transacción cancelada.' AS mensaje;
    ELSE
        -- Paso 1: Insertar pedido
        INSERT INTO pedidos (id_cliente, estado, total, metodo_pago)
        VALUES (id_cliente, 'pendiente', 0, 'tarjeta');

        -- Guardar SAVEPOINT después de insertar el pedido
        SAVEPOINT sp_pedido;

        -- Obtener el ID del pedido recién creado
        SET @nuevo_pedido_id = LAST_INSERT_ID();

        -- Paso 2: Insertar detalles del pedido
        INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
        VALUES (@nuevo_pedido_id, id_producto1, cantidad1, (SELECT precio FROM productos WHERE id_producto = id_producto1));

        INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
        VALUES (@nuevo_pedido_id, id_producto2, cantidad2, (SELECT precio FROM productos WHERE id_producto = id_producto2));

        -- Actualizar stock de los productos
        UPDATE productos SET stock = stock - cantidad1 WHERE id_producto = id_producto1;
        UPDATE productos SET stock = stock - cantidad2 WHERE id_producto = id_producto2;

        -- Confirmar la transacción
        COMMIT;
        SELECT 'Compra realizada correctamente.' AS mensaje;
    END IF;
END //
DELIMITER ;

/*2. Actualizar puntos de fidelidad:*/
DELIMITER //
CREATE PROCEDURE actualizar_puntos_fidelidad()
BEGIN
    -- Iniciar transacción
    START TRANSACTION;

    -- Guardar SAVEPOINT antes de actualizar puntos
    SAVEPOINT sp_puntos;

    -- Actualizar puntos de fidelidad: sumar 10 puntos por cada 50€ gastados en pedidos entregados
    UPDATE clientes 
    SET puntos_fidelidad = puntos_fidelidad + (SELECT FLOOR(total / 50) * 10 
                                               FROM pedidos 
                                               WHERE pedidos.id_cliente = clientes.id_cliente 
                                               AND pedidos.estado = 'entregado');

    -- Verificar si la actualización afectó filas
    IF ROW_COUNT() = 0 THEN
        -- Si hubo error, revertir los cambios
        ROLLBACK TO sp_puntos;
        SELECT 'Error: No se pudo actualizar los puntos de fidelidad. Se ha revertido la operación.' AS mensaje;
    ELSE
        -- Si todo está correcto, confirmar la transacción
        COMMIT;
        SELECT 'Puntos de fidelidad actualizados correctamente.' AS mensaje;
    END IF;
END //
DELIMITER ;

/*3. Borrado seguro de clientes:*/
DELIMITER //
CREATE PROCEDURE borrar_cliente_seguro(IN id_cliente INT)
BEGIN
    -- Iniciar transacción
    START TRANSACTION;

    -- Guardar SAVEPOINT antes de eliminar datos
    SAVEPOINT sp_cliente;

    -- Paso 1: Eliminar detalles de pedidos del cliente
    DELETE FROM detalles_pedido WHERE id_pedido IN (SELECT id_pedido FROM pedidos WHERE id_cliente = id_cliente);

    -- Paso 2: Eliminar pedidos del cliente
    DELETE FROM pedidos WHERE id_cliente = id_cliente;

    -- Paso 3: Eliminar el cliente
    DELETE FROM clientes WHERE id_cliente = id_cliente;

    -- Verificar si la eliminación afectó filas
    IF ROW_COUNT() = 0 THEN
        -- Si hubo error, revertir la operación
        ROLLBACK TO sp_cliente;
        SELECT 'Error: No se pudo eliminar el cliente. Se ha revertido la operación.' AS mensaje;
    ELSE
        -- Si todo está correcto, confirmar la transacción
        COMMIT;
        SELECT 'Cliente eliminado correctamente junto con sus pedidos.' AS mensaje;
    END IF;
END //
DELIMITER ;

/*4. Ejercicios de SAVEPOINT

1. Actualizar múltiples productos:*/
START TRANSACTION;

-- Actualizar el primer producto
UPDATE productos SET stock = stock + 5 WHERE id_producto = 2;

-- Crear SAVEPOINT
SAVEPOINT sp_primer_producto;

-- Intentar actualizar el segundo producto
UPDATE productos SET stock = stock + 5 WHERE id_producto = 5;

-- Verificar si la actualización del segundo producto afectó filas
SET @filas_afectadas = ROW_COUNT();

-- Mostrar mensaje de validación
SELECT CASE 
    WHEN @filas_afectadas = 0 THEN 'Error: No se pudo actualizar el segundo producto.'
    ELSE 'Productos actualizados correctamente.'
END AS mensaje;

/*1.Actualizar múltiples productos:*/
DELIMITER //
CREATE PROCEDURE actualizar_productos()
BEGIN
    -- Iniciar transacción
    START TRANSACTION;

    -- Paso 1: Actualizar el primer producto
    UPDATE productos SET stock = stock + 10 WHERE id_producto = 1;

    -- Guardar SAVEPOINT después de la primera actualización
    SAVEPOINT sp_primer_producto;

    -- Paso 2: Intentar actualizar el segundo producto
    UPDATE productos SET stock = stock + 5 WHERE id_producto = 5;

    -- Verificar si la actualización afectó filas
    IF ROW_COUNT() = 0 THEN
        -- Si hubo error, revertir solo el segundo producto
        ROLLBACK TO sp_primer_producto;
        SELECT 'Error: No se pudo actualizar el segundo producto. Se ha revertido solo esa parte.' AS mensaje;
    ELSE
        -- Si todo está correcto, confirmar la transacción
        COMMIT;
        SELECT 'Productos actualizados correctamente.' AS mensaje;
    END IF;
END //
DELIMITER ;

/*2.Registro de pedido en dos pasos*/
DELIMITER //
CREATE PROCEDURE registrar_pedido()
BEGIN
    -- Iniciar transacción
    START TRANSACTION;

    -- Paso 1: Insertar nuevo pedido
    INSERT INTO pedidos (id_cliente, estado, total, metodo_pago)
    VALUES (1, 'pendiente', 199.98, 'tarjeta');

    -- Guardar SAVEPOINT después de insertar el pedido
    SAVEPOINT sp_pedido;

    -- Obtener el ID del pedido recién creado
    SET @nuevo_pedido_id = LAST_INSERT_ID();

    -- Paso 2: Insertar detalles del pedido
    INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    VALUES (@nuevo_pedido_id, 2, 1, 129.99);

    INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
    VALUES (@nuevo_pedido_id, 4, 1, 24.99);

    -- Verificar si los detalles se insertaron correctamente
    IF ROW_COUNT() = 0 THEN
        -- Si hubo error, revertir solo los detalles y mantener el pedido
        ROLLBACK TO sp_pedido;
        SELECT 'Error: No se pudo añadir detalles al pedido. Solo se ha revertido esa parte.' AS mensaje;
    ELSE
        -- Si todo está correcto, confirmar la transacción
        COMMIT;
        SELECT 'Pedido registrado correctamente con sus detalles.' AS mensaje;
    END IF;
END //
DELIMITER ;