export async function fetchProductos(force = false) {
  // Añadir cacheo simple en memoria para evitar llamadas repetidas en la misma sesión (opcional)
  if (!force && productosCache && Date.now() - cacheTimestamp < CACHE_DURATION) {
    return productosCache;
  }
  const res = await fetch('/api/productos');
  if (!res.ok) throw new Error(await parseError(res, 'Error al obtener productos'));
  const data = await res.json();
  productosCache = data;
  cacheTimestamp = Date.now();
  return data;
}

export async function crearProducto(producto) {
  if (!producto || !producto.nombre || !producto.precio) {
    throw new Error("Producto inválido");
  }
  const res = await fetch('/api/productos', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(producto)
  });
  if (!res.ok) throw new Error(await parseError(res, 'Error al crear producto'));
  return res.json();
}

export async function actualizarProducto(id, datos) {
  if (!id) throw new Error("ID requerido");
  const res = await fetch('/api/actualizarProducto', {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ id, ...datos })
  });
  if (!res.ok) throw new Error(await parseError(res, 'Error al actualizar producto'));
  return res.json();
}

export async function actualizarStock(id, stock) {
  if (!id) throw new Error("ID requerido");
  if (typeof stock !== "number") throw new Error("Stock inválido");
  const res = await fetch(`/api/productos/${id}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ stock })
  });
  if (!res.ok) throw new Error(await parseError(res, 'Error al actualizar stock'));
  return res.json();
}

export async function eliminarProducto(id) {
  if (!id) throw new Error("ID requerido");
  const res = await fetch(`/api/productos/${id}`, {
    method: 'DELETE'
  });
  if (!res.ok) throw new Error(await parseError(res, 'Error al eliminar producto'));
  return res.json();
}

// Sugerencias adicionales para optimización y robustez:

// 1. Manejo de errores más detallado
function parseError(res, defaultMsg) {
  return res.json().then(
    (data) => data?.error || defaultMsg,
    () => defaultMsg
  );
}

// 2. Validación de parámetros antes de enviar peticiones

// 3. Mejor manejo de errores en fetch

// Utilidad para limpiar el cache si se necesita desde fuera
export function limpiarCacheProductos() {
  productosCache = null;
  cacheTimestamp = 0;
}

// Añadir cacheo simple en memoria para evitar llamadas repetidas en la misma sesión (opcional)
let productosCache = null;
let cacheTimestamp = 0;
const CACHE_DURATION = 1000 * 30; // 30 segundos