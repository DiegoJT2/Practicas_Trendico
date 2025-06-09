package com.tiendadeportiva.model;

import jakarta.persistence.*;

@Entity
@Table(name = "categorias")
public class Categoria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_categoria;

    @Column(nullable = false)
    private String nombre;

    public Categoria() {}

    public Categoria(Long id_categoria) {
        this.id_categoria = id_categoria;
    }
    public Long getId() {
        return id_categoria;
    }
    public void setId(Long id) {
        this.id_categoria = id;
    }
    public String getNombre() {
        return nombre;
    }
    public void setNombre(String nombre) {
        this.nombre = nombre;
    }
}