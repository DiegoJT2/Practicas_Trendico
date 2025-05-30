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
START TRANSACTION;

-- Insertar nuevo pedido
INSERT INTO pedidos (id_cliente, estado, total, metodo_pago)
VALUES (1, 'pending', 199.98, 'tarjeta');

-- Obtener el ID del pedido recién creado
SET @nuevo_pedido_id = LAST_INSERT_ID();

-- Verificar stock antes de continuar
SELECT stock INTO @stock1 FROM productos WHERE id_producto = 2;
SELECT stock INTO @stock2 FROM productos WHERE id_producto = 5;

-- Manejo de stock sin `IF`
SET @stock_valido = CASE
    WHEN @stock1 >= 1 AND @stock2 >= 1 THEN 1
    ELSE 0
END;
-- Si hay stock suficiente, continuar con la transacción
SELECT @stock_valido AS stock_disponible;

/*2. Actualizar puntos de fidelidad:*/
START TRANSACTION;

-- Actualizar puntos de fidelidad
UPDATE clientes
SET puntos_fidelidad = puntos_fidelidad + (FLOOR(
    (SELECT SUM(total) FROM pedidos WHERE pedidos.id_cliente = clientes.id_cliente AND estado = 'entregado') / 50) * 10)
WHERE id_cliente IN(
    SELECT DISTINCT id_cliente FROM pedidos WHERE estado = 'entregado' AND total >= 50);

-- Verificar si se actualizaron filas
SET @filas_afectadas = ROW_COUNT();

-- Mostrar mensaje de validación
SELECT CASE 
    WHEN @filas_afectadas = 0 THEN 'Error: No se pudo actualizar los puntos de fidelidad. Transacción revertida.'
    ELSE 'Puntos de fidelidad actualizados correctamente.'
END AS mensaje;

/*3. Borrado seguro de clientes:*/
START TRANSACTION;

-- Paso 1: Eliminar los detalles de los pedidos del cliente
DELETE FROM detalles_pedido WHERE id_pedido IN(
    SELECT id_pedido FROM pedidos WHERE id_cliente = 3);

-- Paso 2: Eliminar los pedidos del cliente
DELETE FROM pedidos WHERE id_cliente = 3;

-- Paso 3: Eliminar el cliente
DELETE FROM clientes WHERE id_cliente = 3;

-- Paso 4: Verificar si se eliminaron filas en la última operación
SET @filas_afectadas = ROW_COUNT();

-- Paso 5: Mostrar mensaje de validación
SELECT CASE 
    WHEN @filas_afectadas = 0 THEN 'Error: No se pudo eliminar el cliente. Transacción revertida.'
    ELSE 'Cliente y sus pedidos eliminados correctamente.'
END AS mensaje;

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

/*2. Registro de pedido en dos pasos:*/
START TRANSACTION;

-- Paso 1: Insertar pedido
INSERT INTO pedidos (id_cliente, estado, total, metodo_pago)
VALUES (1, 'pending', 199.98, 'tarjeta');

-- Crear SAVEPOINT después de insertar el pedido
SAVEPOINT sp_pedido;

-- Obtener el ID del pedido recién creado
SET @nuevo_pedido_id = LAST_INSERT_ID();

-- Paso 2: Añadir detalles del pedido
INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (@nuevo_pedido_id, 2, 1, 129.99);

INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES (@nuevo_pedido_id, 5, 1, 24.99);

-- Verificar si la actualización afectó filas
SET @filas_detalles = ROW_COUNT();

-- Manejo del error en pasos separados
SELECT CASE
    WHEN @filas_detalles = 0 THEN 'Error: No se pudieron insertar los detalles del pedido.'
    ELSE 'Pedido y detalles registrados correctamente.'
END AS mensaje;
-- Ejecutar rollback o commit manualmente según el resultado de la consulta anterior