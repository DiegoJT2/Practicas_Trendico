const carrito = Cookies.get('carrito') ? JSON.parse(Cookies.get('carrito')) : [];

function actualizarCarrito() {
  let total = 0;
  $('#lista-carrito').empty();
  carrito.forEach(producto => {
    total += producto.precio * producto.cantidad;
    $('#lista-carrito').append(
      `<li class="flex justify-between items-center mb-2">
        <span>${producto.nombre} x ${producto.cantidad}</span>
        <button class="text-red-500" onclick="eliminarProducto(${producto.id})">Eliminar</button>
      </li>`
    );
  });
  $('#total').text(total.toFixed(2) + '€');
  $('#contador-carrito').text(carrito.reduce((acc, p) => acc + p.cantidad, 0));
  Cookies.set('carrito', JSON.stringify(carrito));
}

function añadirProducto(producto) {
  const existente = carrito.find(p => p.id === producto.id);
  if (existente) {
    existente.cantidad++;
  } else {
    carrito.push({ ...producto, cantidad: 1 });
  }
  actualizarCarrito();
}

function eliminarProducto(id) {
  const index = carrito.findIndex(p => p.id === id);
  if (index !== -1) {
    carrito.splice(index, 1);
    actualizarCarrito();
  }
}

function cargarProductos() {
  fetch('http://localhost:8080/api/productos')
    .then(res => res.json())
    .then(data => {
      data.forEach(prod => {
        const imagen = prod.imagen ? `img/${prod.imagen}` : 'img/default.webp';
        const stockBajo = prod.stock < 5
          ? `<p class="text-red-500 font-semibold">¡Últimas unidades!</p>`
          : '';

        $('#productos').append(`
          <div class="bg-white shadow p-4 rounded">
            <img src="${imagen}" alt="${prod.nombre}" class="mb-2 w-full h-40 object-contain"
              onerror="this.onerror=null;this.src='img/default.webp'">

            <h3 class="text-lg font-bold">${prod.nombre}</h3>
            <p class="text-sm text-gray-600 mb-1">${prod.descripcion}</p>
            <p class="text-sm text-gray-500 mb-1">Marca: ${prod.marca}</p>
            <p class="text-sm text-gray-500 mb-1">Categoría: ${prod.categoria?.nombre || 'N/A'}</p>
            ${stockBajo}
            <p class="text-md font-semibold mb-2">${prod.precio} €</p>
            <button class="mt-2 bg-blue-600 text-white px-3 py-1 rounded"
              onclick='añadirProducto({ id: ${prod.id}, nombre: "${prod.nombre}", precio: ${prod.precio} })'>
              Añadir al carrito
            </button>
          </div>
        `);
      });
    });
}

$('#icono-carrito').on('click', () => $('#carrito').toggleClass('hidden'));

$(document).ready(() => {
  cargarProductos();
  actualizarCarrito();
});