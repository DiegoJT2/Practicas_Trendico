package com.tiendadeportiva.controller;

import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.tiendadeportiva.model.Producto;
import com.tiendadeportiva.repository.ProductoRepository;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    @Autowired
    private ProductoRepository productoRepository;

    // Obtener todos los productos
    @GetMapping
    public List<Producto> listarProductos() {
        return productoRepository.findAll();
    }

    // Crear un nuevo producto
    @PostMapping
    public Producto crearProducto(@RequestBody Producto producto) {
        return productoRepository.save(producto);
    }

    // Actualizar el stock de un producto
    @PutMapping("/{id}/stock")
    public ResponseEntity<Producto> actualizarStock(
            @PathVariable Long id,
            @RequestBody Map<String, Integer> body
    ) {
        Producto producto = productoRepository.findById(id).orElseThrow();
        int nuevoStock = producto.getStock() + body.get("cantidad");
        if (nuevoStock < 0) {
            return ResponseEntity.badRequest().build();
        }
        producto.setStock(nuevoStock);
        return ResponseEntity.ok(productoRepository.save(producto));
    }
}