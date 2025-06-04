package com.tiendadeportiva.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import com.tiendadeportiva.model.Producto;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import java.util.List;

public interface ProductoRepository extends JpaRepository<Producto, Long>{
    List<Producto> findByCategoriaNombre(String nombre);

    @Query("SELECT p FROM Producto p WHERE p.categoria.nombre = :nombre")
    List<Producto> findByCategoria(@Param("nombre") String nombre);
}