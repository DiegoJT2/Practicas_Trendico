$(document).ready(function() {
    cargarProductos();
    actualizarCarrito();

    // Delegación de eventos para botones dinámicos
    $(document).on('click', '.btn-add', function() {
        const id = $(this).data('id');
        añadirProducto(id);
    });

    $(document).on('click', '.btn-eliminar', function() {
        const id = $(this).data('id');
        eliminarProducto(id);
    });

    $(document).on('click', '.btn-mas', function() {
        const id = $(this).data('id');
        cambiarCantidad(id, 1);
    });

    $(document).on('click', '.btn-menos', function() {
        const id = $(this).data('id');
        cambiarCantidad(id, -1);
    });

    // Mostrar/ocultar carrito
    $('#icono-carrito').click(function() {
        $('#carrito').toggle();
        actualizarCarrito();
    });
});

function cargarProductos() {
    $('#productos').empty();
    productos.forEach(producto => {
        $('#productos').append(`
            <div class="producto">
                <img src="${producto.imagen}" alt="${producto.nombre}">
                <h3>${producto.nombre}</h3>
                <p>${producto.precio}€</p>
                <button class="btn-add bg-blue-500 hover:bg-blue-700 text-white font-bold py-2 px-4 rounded" data-id="${producto.id}">Añadir al carrito</button>
            </div>
        `);
    });
}