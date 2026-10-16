# Bizzu

**Bizzu** es una aplicación móvil tipo marketplace universitario que permite a los estudiantes publicar, consultar y marcar como favoritos productos disponibles dentro de la comunidad universitaria.

La aplicación busca facilitar el intercambio de productos entre estudiantes, ofreciendo una interfaz visual organizada y un flujo básico de publicación y consulta.

## Funcionalidades principales

* **Catálogo principal:** Muestra productos destacados, categorías y una barra de búsqueda.
* **Publicación de productos:** Permite registrar nombre, descripción, precio, imagen y categoría.
* **Validación de formularios:** Verifica campos obligatorios, precio numérico y selección de categoría.
* **Consulta de productos:** Presenta imagen, precio, descripción, vendedor, horarios de entrega y calificación.
* **Favoritos:** Permite marcar o desmarcar productos.
* **Navegación:** Conecta el catálogo, el formulario de publicación y el detalle del producto.
* **Gestión en memoria:** Los productos se almacenan temporalmente mediante `ProductService`, sin base de datos ni backend.

## Componentes reutilizables

* `CustomTextField`
* `CustomAppBar`
* `ProductCard`
* `CategoryIcon`

