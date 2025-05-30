-- Insertar categorías
INSERT INTO categorias (nombre, descripcion) VALUES
('Running', 'Zapatillas y ropa para correr'),
('Fútbol', 'Balones, botas y equipamiento para fútbol'),
('Fitness', 'Accesorios para gimnasio y entrenamiento'),
('Natación', 'Bañadores, gafas y material para piscina'),
('Ciclismo', 'Bicicletas y componentes');
-- Insertar productos
INSERT INTO productos (nombre, descripcion, precio, stock, id_categoria, marca)
VALUES
('Zapatillas Run Fast', 'Zapatillas ligeras para corredores', 89.99, 50, 1,
'Nike'),
('Balón Adidas Champions', 'Balón oficial de la Champions League', 129.99, 30, 2,
'Adidas'),
('Mancuernas 5kg', 'Par de mancuernas de neopreno', 29.99, 100, 3, 'Decathlon'),
('Gafas de Natación Speed', 'Gafas de competición', 24.99, 40, 4, 'Speedo'),
('Bicicleta MTB Pro', 'Bicicleta montaña 21 velocidades', 599.99, 15, 5, 'Trek');
-- Insertar clientes
INSERT INTO clientes (nombre, apellidos, email, telefono, puntos_fidelidad) VALUES
('Juan', 'García', 'juan@email.com', '611223344', 100),
('María', 'López', 'maria@email.com', '655667788', 50),
('Carlos', 'Martínez', 'carlos@email.com', '699112233', 200);
-- Insertar pedidos
INSERT INTO pedidos (id_cliente, estado, total, metodo_pago) VALUES
(1, 'entregado', 219.98, 'tarjeta'),
(2, 'procesado', 59.98, 'paypal'),
(3, 'pendiente', 599.99, 'transferencia');
-- Insertar detalles de pedido
INSERT INTO detalles_pedido (id_pedido, id_producto, cantidad, precio_unitario)
VALUES
(1, 1, 1, 89.99), -- Pedido 1: Zapatillas Run Fast
(1, 3, 1, 29.99), -- Pedido 1: Mancuernas 5kg
(2, 4, 2, 24.99), -- Pedido 2: 2x Gafas de Natación
(3, 5, 1, 599.99); -- Pedido 3: Bicicleta MTB Pro