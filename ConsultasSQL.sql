/*1. Mostrar todos los productos de la tienda.*/
SELECT * FROM tienda_deportiva.productos;
/*2. Listar nombre y precio de los productos con stock mayor a 10 unidades.*/
SELECT nombre, precio FROM tienda_deportiva.productos WHERE stock > 10;
/*3. Contar el número total de clientes registrados.*/
SELECT count(*) AS total_clientes FROM clientes;
/*4. Mostrar los pedidos realizados hoy.*/
SELECT * FROM pedidos WHERE DATE(fecha_pedido) = curdate();
/*5. Ordenar los productos por precio (de mayor a menor).*/
SELECT * FROM productos ORDER BY precio ASC;

/*1. Mostrar productos con su categoría correspondiente.*/
SELECT * FROM productos AS A JOIN categorias AS B ON A.id_categoria = B.id_categoria;
/*2. Listar detalles de pedidos incluyendo nombre del producto comprado.*/
SELECT cantidad, precio_unitario, nombre, descripcion, precio, stock, marca, fecha_creacion FROM detalles_pedido AS A JOIN productos AS B ON A.id_producto =B.id_producto;
/*3. Mostrar pedidos con información del cliente (nombre, apellidos).*/
SELECT fecha_pedido, estado, total, metodo_pago, nombre, apellidos FROM pedidos AS A JOIN clientes AS B ON A.id_cliente = B.id_cliente;
/*4. Identificar productos vendidos en pedidos ya entregados.*/
SELECT C.nombre FROM pedidos AS A JOIN detalles_pedido AS B ON B.id_pedido = A.id_Pedido JOIN productos AS C ON B.id_producto = C.id_producto WHERE A.estado = 'entregado';
/*5. Encontrar clientes que han comprado productos de la categoría "running".*/
SELECT DISTINCT A.id_cliente, A.nombre, A.apellidos, email, telefono FROM clientes AS A JOIN pedidos AS B ON A.id_cliente = B.id_cliente JOIN detalles_pedido AS C ON B.id_pedido = C.id_pedido JOIN productos AS D ON C.id_producto = D.id_producto JOIN categorias AS E ON D.id_categoria = E.id_categoria WHERE E.nombre = 'running';

/*1. Mostrar todas las categorías, incluso las sin productos asociados.*/
SELECT * FROM categorias;
/*2. Listar clientes que nunca han realizado un pedido.*/
SELECT * FROM clientes AS A LEFT JOIN pedidos AS B ON A.id_cliente = B.id_cliente WHERE B.id_cliente IS NULL;
/*3. Identificar productos que nunca han sido vendidos.*/
SELECT * FROM productos AS A LEFT JOIN detalles_pedido AS B ON A.id_producto = B.id_producto WHERE B.id_producto IS NULL;
/*4. Mostrar todos los pedidos, incluyendo clientes (aunque no debería haber pedidos sin cliente).*/
SELECT * FROM pedidos AS A LEFT JOIN clientes AS B ON A.id_cliente = B.id_cliente;
/*5. Listar productos y sus categorías, mostrando también productos sin categoría asignada.*/
SELECT A.nombre, A.descripcion, A.precio, B.nombre FROM productos AS A, categorias AS B WHERE A.id_categoria = B.id_categoria;

/*1. Calcular el total de ventas por categoría (solo pedidos entregados).*/
SELECT C.id_categoria, D.nombre AS categoria, SUM(B.cantidad*B.precio_unitario) AS total_ventas FROM pedidos AS A JOIN detalles_pedido AS B ON A.id_pedido = B.id_pedido JOIN productos AS C ON B.id_producto = C.id_producto JOIN categorias AS D ON C.id_categoria = D.id_categoria WHERE A.estado = 'entregado' GROUP BY C.id_categoria, C.nombre;
/*2. Contar el número de pedidos por cliente y su total gastado.*/
SELECT COUNT(A.id_cliente) AS 'pedidos por cliente', SUM(A.total) AS total FROM pedidos AS A JOIN clientes AS B ON A.id_cliente = B.id_cliente GROUP BY A.id_cliente, B.nombre;
