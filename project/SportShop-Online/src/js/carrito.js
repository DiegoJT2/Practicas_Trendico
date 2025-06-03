let carrito = [];

// Cargar carrito desde cookies al iniciar
if (Cookies.get('carrito')) {
    carrito = JSON.parse(Cookies.get('carrito'));
}

function añadirProducto(id) {
    const producto = productos.find(p => p.id === id);
    const item = carrito.find(p => p.id === id);
    if (item) {
        item.cantidad += 1;
    } else {
        carrito.push({ ...producto, cantidad: 1 });
    }
    guardarEnCookies();
    actualizarCarrito();
}

function eliminarProducto(id) {
    carrito = carrito.filter(p => p.id !== id);
    guardarEnCookies();
    actualizarCarrito();
}

function cambiarCantidad(id, delta) {
    const item = carrito.find(p => p.id === id);
    if (item) {
        item.cantidad += delta;
        if (item.cantidad <= 0) {
            eliminarProducto(id);
        } else {
            guardarEnCookies();
            actualizarCarrito();
        }
    }
}

function actualizarCarrito() {
    let total = 0;
    let cantidadTotal = 0;
    $('#lista-carrito').empty();
    carrito.forEach(producto => {
        total += producto.precio * producto.cantidad;
        cantidadTotal += producto.cantidad;
        $('#lista-carrito').append(`
            <li class="flex justify-between items-center mb-2">
                <span>${producto.nombre} (${producto.cantidad}) - ${(producto.precio * producto.cantidad).toFixed(2)}€</span>
                <div>
                    <button class="btn-menos bg-gray-300 px-2 rounded" data-id="${producto.id}">-</button>
                    <button class="btn-mas bg-gray-300 px-2 rounded" data-id="${producto.id}">+</button>
                    <button class="btn-eliminar bg-red-500 text-white px-2 rounded" data-id="${producto.id}">Eliminar</button>
                </div>
            </li>
        `);
    });
    $('#total').text(total.toFixed(2) + '€');
    // Actualiza el contador del icono del carrito
    $('#icono-carrito span').text(cantidadTotal);
}

function guardarEnCookies() {
    Cookies.set('carrito', JSON.stringify(carrito), { expires: 7 });
}