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

    // Find products by name (case-insensitive, partial match)
    List<Producto> findByNombreContainingIgnoreCase(String nombre);

    // Find products with stock less than a given amount
    List<Producto> findByStockLessThan(int stock);

    // Find products within a price range
    List<Producto> findByPrecioBetween(Double minPrecio, Double maxPrecio);

    // Find top N most expensive products
    @Query("SELECT p FROM Producto p ORDER BY p.precio DESC")
    List<Producto> findTopNMostExpensiveProducts(@Param("n") int n);

    // Find products by multiple categories
    @Query("SELECT p FROM Producto p WHERE p.categoria.nombre IN :categorias")
    List<Producto> findByCategorias(@Param("categorias") List<String> categorias);

    // Find products with stock greater than or equal to a given amount
    List<Producto> findByStockGreaterThanEqual(int stock);

    // Find products ordered by price (ascending or descending)
    List<Producto> findAllByOrderByPrecioAsc();
    List<Producto> findAllByOrderByPrecioDesc();

    // Find products by name and category
    List<Producto> findByNombreContainingIgnoreCaseAndCategoriaNombre(String nombre, String categoriaNombre);

    // Find products with price greater than average price
    @Query("SELECT p FROM Producto p WHERE p.precio > (SELECT AVG(p2.precio) FROM Producto p2)")
    List<Producto> findProductsAboveAveragePrice();

    // Count products by category
    @Query("SELECT p.categoria.nombre, COUNT(p) FROM Producto p GROUP BY p.categoria.nombre")
    List<Object[]> countProductsByCategory();
}