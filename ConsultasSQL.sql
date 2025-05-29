/*1. Mostrar todos los productos de la tienda.*/
SELECT nombre, descripcion, precio, stock, marca, fecha_creacion FROM tienda_deportiva.productos;
/*2. Listar nombre y precio de los productos con stock mayor a 10 unidades.*/
SELECT nombre, precio FROM tienda_deportiva.productos WHERE stock > 10;
/*3. Contar el número total de clientes registrados.*/
SELECT count(*) AS total_clientes FROM clientes;
/*4. Mostrar los pedidos realizados hoy.*/
SELECT id_pedido, id_cliente, fecha_pedido, estado, total, metodo_pago FROM pedidos WHERE DATE(fecha_pedido) = curdate();
/*5. Ordenar los productos por precio (de mayor a menor).*/
SELECT id_producto, nombre, descripcion, precio, stock, id_categoria, marca, fecha_creacion FROM productos ORDER BY precio ASC;

/*1. Mostrar productos con su categoría correspondiente.*/
SELECT id_producto, A.nombre, A.descripcion, precio, stock, B.nombre AS categoria, marca, fecha_creacion FROM productos AS A JOIN categorias AS B ON A.id_categoria = B.id_categoria;
/*2. Listar detalles de pedidos incluyendo nombre del producto comprado.*/
SELECT cantidad, precio_unitario, nombre, descripcion, precio, stock, marca, fecha_creacion FROM detalles_pedido AS A JOIN productos AS B ON A.id_producto =B.id_producto;
/*3. Mostrar pedidos con información del cliente (nombre, apellidos).*/
SELECT fecha_pedido, estado, total, metodo_pago, nombre, apellidos FROM pedidos AS A JOIN clientes AS B ON A.id_cliente_fk = B.id_cliente;
/*4. Identificar productos vendidos en pedidos ya entregados.*/
SELECT C.nombre FROM pedidos AS A JOIN detalles_pedido AS B ON B.id_pedido = A.id_Pedido JOIN productos AS C ON B.id_producto = C.id_producto WHERE A.estado = 'entregado';
/*5. Encontrar clientes que han comprado productos de la categoría "running".*/
SELECT DISTINCT A.id_cliente, A.nombre, A.apellidos, email, telefono FROM clientes AS A JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk JOIN detalles_pedido AS C ON B.id_pedido = C.id_pedido JOIN productos AS D ON C.id_producto = D.id_producto JOIN categorias AS E ON D.id_categoria = E.id_categoria WHERE E.nombre = 'running';

/*1. Mostrar todas las categorías, incluso las sin productos asociados.*/
SELECT A.nombre, A.descripcion FROM categorias AS A LEFT JOIN productos AS B ON A.id_categoria = B.id_categoria ORDER BY A.id_categoria;
/*2. Listar clientes que nunca han realizado un pedido.*/
SELECT A.id_cliente, A.nombre, A.apellidos FROM clientes AS A LEFT JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk WHERE B.id_cliente_fk IS NULL;
/*3. Identificar productos que nunca han sido vendidos.*/
SELECT A.id_producto, A.nombre, A.stock FROM productos AS A LEFT JOIN detalles_pedido AS B ON A.id_producto = B.id_producto WHERE B.id_producto IS NULL;
/*4. Mostrar todos los pedidos, incluyendo clientes (aunque no debería haber pedidos sin cliente).*/
SELECT A.id_pedido, A.fecha_pedido, A.estado, A.total, A.metodo_pago, B.nombre, B.apellidos, B.email, B.telefono, B.fecha_registro, B.puntos_fidelidad
FROM pedidos AS A LEFT JOIN clientes AS B ON A.id_cliente_fk = B.id_cliente;
/*5. Listar productos y sus categorías, mostrando también productos sin categoría asignada.*/
SELECT A.nombre, A.descripcion, A.precio, B.nombre FROM productos AS A, categorias AS B WHERE A.id_categoria = B.id_categoria;

/*1. Calcular el total de ventas por categoría (solo pedidos entregados).*/
SELECT C.id_categoria, D.nombre AS categoria, SUM(B.cantidad*B.precio_unitario) AS total_ventas FROM pedidos AS A JOIN detalles_pedido AS B ON A.id_pedido = B.id_pedido JOIN productos AS C ON B.id_producto = C.id_producto JOIN categorias AS D ON C.id_categoria = D.id_categoria WHERE A.estado = 'confirm' GROUP BY C.id_categoria, C.nombre;
/*2. Contar el número de pedidos por cliente y su total gastado.*/
SELECT COUNT(A.id_cliente_fk) AS 'pedidos por cliente', SUM(A.total) AS total FROM pedidos AS A JOIN clientes AS B ON A.id_cliente_fk = B.id_cliente GROUP BY A.id_cliente_fk, B.nombre;
/*3 . Calcular el promedio de gasto por pedido (entregados).*/
SELECT AVG(total) FROM pedidos WHERE estado = 'confirm';
/*4. Identificar los 5 productos más vendidos (por cantidad).*/
SELECT A.id_producto, B.nombre , SUM(A.cantidad) AS total_vendido FROM detalles_pedido AS A JOIN productos AS B ON A.id_producto = B.id_producto GROUP BY A.id_producto, B.nombre ORDER BY total_vendido DESC LIMIT 5;
/*5. Generar un informe de ventas mensuales.*/
SELECT DATE_FORMAT(A.fecha_pedido, '%Y-%m') AS mes, SUM(B.cantidad * B.precio_unitario) AS total_ventas FROM pedidos AS A JOIN detalles_pedido AS B ON A.id_pedido = B.id_pedido WHERE A.estado = 'confirm' GROUP BY mes ORDER BY mes;

/*1. Listar productos con precio superior al promedio.*/
SELECT A.nombre, A.descripcion, A.precio, A.stock FROM productos AS A WHERE A.precio > (SELECT AVG(B.precio) FROM productos AS B);
/*2. Identificar clientes que han gastado más que el promedio.*/
SELECT A.nombre, SUM(B.total) AS total_gastado FROM clientes AS A JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk GROUP BY A.id_cliente, A.nombre HAVING SUM(B.total) > (SELECT AVG(total) FROM pedidos);
/*3. Mostrar productos nunca vendidos (usando NOT IN).*/
SELECT * FROM productos AS A WHERE A.id_producto NOT IN (SELECT DISTINCT B.id_producto FROM detalles_pedido AS B);
/*4. Encontrar categorías con menos productos que la media.*/
SELECT A.nombre FROM categorias AS A
WHERE (SELECT COUNT(*) FROM productos AS B WHERE B.id_categoria = A.id_categoria)<(SELECT AVG(productos_por_categoria)FROM
(SELECT COUNT(*) AS productos_por_categoria FROM productos GROUP BY id_categoria) AS C);
/*5. Listar pedidos con valor superior al 90% de los pedidos.*/
SELECT id_Pedido, fecha_pedido, estado, total, metodo_pago FROM pedidos WHERE total > (SELECT total FROM pedidos ORDER BY total DESC LIMIT 1 OFFSET 10);

/*1.Combinar productos de las categorías "running" y "fitness" (usando UNION ).*/
SELECT id_producto, nombre, precio, stock, id_categoria FROM productos 
WHERE id_categoria IN (SELECT id_categoria FROM categorias WHERE nombre = 'running')
UNION
SELECT id_producto, nombre, precio, stock, id_categoria FROM productos 
WHERE id_categoria IN (SELECT id_categoria FROM categorias WHERE nombre = 'fitness');
/*2.Identificar clientes que han comprado tanto en "running" como "fitness" (simular INTERSECT).*/
SELECT DISTINCT A.id_cliente, A.nombre, A.apellidos, A.email, A.telefono, A.fecha_registro FROM clientes AS A
JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk JOIN detalles_pedido AS C ON B.id_pedido = C.id_pedido
JOIN productos AS D ON C.id_producto = D.id_producto JOIN categorias AS E ON D.id_categoria = E.id_categoria
WHERE E.nombre = 'running' AND A.id_cliente IN (SELECT DISTINCT A.id_cliente FROM clientes AS A
JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk JOIN detalles_pedido AS C ON B.id_pedido = C.id_pedido
JOIN productos AS D ON C.id_producto = D.id_producto JOIN categorias AS E ON D.id_categoria = E.id_categoria WHERE E.nombre = 'fitness');
/*3. Mostrar productos de "running" que no están en "fitness" (simular EXCEPT).*/
SELECT A.id_producto, A.nombre, A.descripcion, A.id_categoria FROM productos AS A
JOIN categorias AS B ON A.id_categoria = B.id_categoria LEFT JOIN productos AS C ON A.id_producto = C.id_producto 
AND C.id_categoria = (SELECT id_categoria FROM categorias WHERE nombre = 'fitness') 
WHERE B.nombre = 'running' AND C.id_producto IS NULL;
/*4. Combinar productos con stock bajo y productos con precio alto en un solo listado (UNION
 ALL).*/
SELECT id_producto, nombre, precio, stock, id_categoria FROM productos WHERE stock < 10 UNION ALL
SELECT id_producto, nombre, precio, stock, id_categoria FROM productos WHERE precio > (SELECT AVG(precio) FROM productos);

/*1. Crear índices en campos de búsqueda frecuente(nombre, id_categoria, fecha_pedido).*/
CREATE INDEX idx_nombre ON productos(nombre);
CREATE INDEX idx_id_categoria ON categorias(id_categoria);
CREATE INDEX idx_fecha_pedido ON pedidos(fecha_pedido);
/*2. Reescribir una consulta usando EXISTS en lugar de IN para mejorar rendimiento.*/
SELECT DISTINCT A.id_cliente, A.nombre, A.apellidos, A.email, A.telefono, A.fecha_registro FROM clientes AS A
JOIN pedidos AS B ON A.id_cliente = B.id_cliente_fk JOIN detalles_pedido AS C ON B.id_pedido = C.id_pedido
JOIN productos AS D ON C.id_producto = D.id_producto JOIN categorias AS E ON D.id_categoria = E.id_categoria
WHERE E.nombre = 'running' AND EXISTS(SELECT 1 FROM pedidos AS B2 JOIN detalles_pedido AS C2 ON B2.id_pedido = C2.id_pedido
JOIN productos AS D2 ON C2.id_producto = D2.id_producto JOIN categorias AS E2 ON D2.id_categoria = E2.id_categoria
WHERE E2.nombre = 'fitness' AND B2.id_cliente_fk = A.id_cliente);
/*3. Evitar SELECT * y especificar solo columnas necesarias.*/
SELECT id_producto, nombre, descripcion, precio, stock, marca FROM productos;
/*4. Comparar dos versiones de una consulta(con JOIN vs. subconsulta) y analizar cuál es más eficiente.*/
EXPLAIN
SELECT p.nombre, c.nombre AS categoria
FROM Productos p
JOIN Categorias c ON p.id_categoria = c.id_categoria;

EXPLAIN
SELECT nombre, 
       (SELECT nombre FROM Categorias WHERE id_categoria = p.id_categoria) AS categoria
FROM Productos p;

EXPLAIN FORMAT=JSON 
SELECT p.nombre, c.nombre AS categoria
FROM Productos p
JOIN Categorias c ON p.id_categoria = c.id_categoria;
