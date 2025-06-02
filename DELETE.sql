SET SQL_SAFE_UPDATES = 0;
START TRANSACTION;
DELETE FROM detalles_pedido;
DELETE FROM pedidos;
DELETE FROM clientes;
DELETE FROM productos;
DELETE FROM categorias;
COMMIT;
/*Eliminado más rápido*/
TRUNCATE TABLE detalles_pedido;
TRUNCATE TABLE pedidos;
TRUNCATE TABLE clientes;
TRUNCATE TABLE productos;
TRUNCATE TABLE categorias;
/*Cambiar auto_increment a 1*/
ALTER TABLE detalles_pedido AUTO_INCREMENT = 1;
ALTER TABLE categorias AUTO_INCREMENT = 1;
ALTER TABLE productos AUTO_INCREMENT = 1;
ALTER TABLE pedidos AUTO_INCREMENT = 1;
ALTER TABLE clientes AUTO_INCREMENT = 1;