package com.tiendadeportiva.controller;

import com.tiendadeportiva.model.Producto;
import com.tiendadeportiva.repository.ProductoRepository;
import jakarta.validation.Valid;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.*;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/productos")
public class ProductoController {

    @Autowired
    private ProductoRepository productoRepository;

    @GetMapping
    public ResponseEntity<List<Producto>> listar() {
        List<Producto> productos = productoRepository.findAll();
        return ResponseEntity.ok(productos);
    }

    @PostMapping
    public ResponseEntity<Producto> crearProducto(@Valid @RequestBody Producto producto) {
        if (producto.getCategoria() == null || producto.getCategoria().getId() == null) {
            return ResponseEntity.badRequest().build();
        }

        Producto nuevoProducto = productoRepository.save(producto);
        return ResponseEntity.status(HttpStatus.CREATED).body(nuevoProducto);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Producto> actualizarProducto(@PathVariable Long id, @Valid @RequestBody Producto productoActualizado) {
        return productoRepository.findById(id).map(producto -> {
            producto.setNombre(productoActualizado.getNombre());
            producto.setDescripcion(productoActualizado.getDescripcion());
            producto.setPrecio(productoActualizado.getPrecio());
            producto.setStock(productoActualizado.getStock());
            producto.setMarca(productoActualizado.getMarca());
            producto.setCategoria(productoActualizado.getCategoria());
            // fecha_creacion no se modifica
            Producto actualizado = productoRepository.save(producto);
            return ResponseEntity.ok(actualizado);
        }).orElse(ResponseEntity.notFound().build());
    }

    @PatchMapping("/{id}/stock")
    public ResponseEntity<Producto> actualizarStock(@PathVariable Long id, @RequestBody Map<String, Integer> body) {
        Integer nuevoStock = body.get("stock");
        if (nuevoStock == null) {
            return ResponseEntity.badRequest().build();
        }

        return productoRepository.findById(id).map(producto -> {
            producto.setStock(nuevoStock);
            Producto actualizado = productoRepository.save(producto);
            return ResponseEntity.ok(actualizado);
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarProducto(@PathVariable Long id) {
        if (!productoRepository.existsById(id)) {
            return ResponseEntity.notFound().build();
        }
        productoRepository.deleteById(id);
        return ResponseEntity.noContent().build();
    }

    @RequestMapping(value = "", method = RequestMethod.OPTIONS)
    public ResponseEntity<Void> opciones() {
        HttpHeaders headers = new HttpHeaders();
        headers.add("Allow", "GET,POST,PUT,PATCH,DELETE,OPTIONS");
        return ResponseEntity.ok().headers(headers).build();
    }

    @RequestMapping(value = "/{id}", method = RequestMethod.HEAD)
    public ResponseEntity<Void> head(@PathVariable Long id) {
        if (productoRepository.existsById(id)) {
            return ResponseEntity.ok().build();
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}