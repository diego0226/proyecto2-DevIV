# Catálogo de productos con Supabase

Proyecto del **Grupo 6** para IF0009 Desarrollo de Software VI (UCR, Sede de Occidente, Recinto de Tacares, II-2026).

Es una página web que guarda y muestra productos en una base de datos PostgreSQL alojada en [Supabase](https://supabase.com). Permite:

- **consultar** los productos guardados y mostrarlos en una tabla;
- **insertar** un producto nuevo desde un formulario;
- **filtrar** los productos por categoría.

Repositorio: https://github.com/diego0226/proyecto2-DevIV (los archivos de la práctica están en la carpeta `supabase-catalogo`)

Para descargarlo sin Git: en GitHub, botón verde **Code → Download ZIP**, descomprimir y abrir la carpeta `supabase-catalogo`.

## Requisitos

| Qué | Para qué | Dónde |
|---|---|---|
| Cuenta gratis de Supabase | Crear el proyecto y la base de datos | https://supabase.com (Start your project → Continue with GitHub) |
| Navegador (Chrome, Edge o Firefox) | Abrir la página | — |
| Editor de texto (recomendado VS Code) | Editar `index.html` | https://code.visualstudio.com |
| Conexión a internet | La librería se descarga de un CDN y los datos viven en Supabase | — |

**No hay que instalar Node.js, npm ni ninguna dependencia.** La librería `supabase-js` (versión 2) se carga desde `https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2` con una etiqueta `<script>`. Se probó con la versión 2.118.0.

## Estructura

```
supabase-catalogo/
├── README.md               este archivo
├── sql/
│   └── 01_crear_tabla.sql  crea la tabla, las políticas de seguridad y 3 productos de ejemplo
├── practica/
│   └── index.html          plantilla para la práctica guiada (con huecos TODO)
└── final/
    └── index.html          versión terminada
```

## Cómo ejecutarlo

### Versión rápida: abrir `final/index.html`

`final/index.html` ya está conectado al proyecto del grupo en Supabase (`catalogo-grupo6`). Basta con hacerle doble clic para ver el catálogo funcionando, sin crear cuenta ni configurar nada. Durante la práctica guiada sirve de respaldo para quien no logre crear su propio proyecto.

La key que aparece en ese archivo es la *publishable key*, que Supabase permite publicar: la página solo puede leer e insertar productos, nada más.

### Con un proyecto propio (lo que se hace en la práctica)

### 1. Crear el proyecto en Supabase

1. Entrar a https://supabase.com/dashboard y hacer clic en **New project**.
2. Nombre: `practica-supabase`. En *Database Password* hacer clic en **Generate a password**. Región: **Americas**, la que aparece por defecto.
3. En *Security* dejar marcada **Enable Data API**. **Automatically expose new tables** puede quedar como venga: el script incluye el `grant`, así que funciona en los dos casos.
4. Clic en **Create new project** y esperar 1–2 minutos a que termine.

### 2. Crear la tabla

1. En el menú izquierdo abrir **SQL Editor**.
2. Copiar todo el contenido de [`sql/01_crear_tabla.sql`](sql/01_crear_tabla.sql), pegarlo y hacer clic en **Run**.
3. Abajo debe aparecer una fila: *Café chorreado*. En **Table Editor → productos** deben verse 3 filas.

### 3. Conectar la página

1. La **Project URL** está en la página principal del proyecto, debajo del nombre, con un botón **Copy**. También es `https://<código-del-proyecto>.supabase.co`, donde el código es el que aparece en la barra de direcciones después de `/project/`.
2. La **publishable key** está en **Project Settings → API Keys**, sección *Publishable key*, botón de copiar (si el proyecto muestra *anon key*, usar esa).
3. Abrir `practica/index.html` en el editor y pegar los valores:

```js
const SUPABASE_URL = 'https://xxxxxxxx.supabase.co';
const SUPABASE_KEY = 'pegar-aquí-la-publishable-key';
```

> Nunca pegar la *secret key* ni la *service_role key* en el HTML: esas ignoran las políticas de seguridad y quedarían visibles para cualquiera.

### 4. Abrir la página

Hacer doble clic en `index.html` para abrirlo en el navegador (o, en VS Code, clic derecho → *Open with Live Server* si tienen esa extensión). Deben aparecer los 3 productos.

## Práctica guiada (archivo `practica/index.html`)

La plantilla ya trae el HTML, los estilos y las funciones `pintarTabla` y `mostrarError`. Solo hay que completar los huecos `TODO`.

**Paso 5. Consultar** — dentro de `cargarProductos()`:

```js
const { data, error } = await cliente
  .from('productos')
  .select('*')
  .order('id');

if (error) { mostrarError(error); return; }
pintarTabla(data);
```

`cliente.from('productos').select('*')` equivale a `select * from productos`. Supabase convierte la llamada en una petición a su API REST y devuelve las filas en `data`.

**Paso 6. Insertar** — dentro de `agregarProducto(evento)`, después de `evento.preventDefault();`:

```js
const nuevo = {
  nombre: formulario.nombre.value,
  precio: Number(formulario.precio.value),
  categoria: formulario.categoria.value
};

const { error } = await cliente.from('productos').insert(nuevo);

if (error) { mostrarError(error); return; }
formulario.reset();
cargarProductos();
```

Agregar un producto llamado **"Producto de \<tu nombre\>"**. Debe aparecer en la página y en el Table Editor de Supabase.

**Paso 7 (opcional). Filtrar por categoría** — reemplazar el contenido de `cargarProductos()` por:

```js
let consulta = cliente
  .from('productos')
  .select('*')
  .order('id');

if (selectCategoria.value !== 'Todas') {
  consulta = consulta.eq('categoria', selectCategoria.value);
}

const { data, error } = await consulta;

if (error) { mostrarError(error); return; }
pintarTabla(data);
```

`.eq('categoria', 'Bebidas')` equivale a `where categoria = 'Bebidas'`.

## Solución de problemas

| Síntoma | Causa | Solución |
|---|---|---|
| `permission denied for table productos` (código 42501) | Falta el `grant`: desde el 30/10/2026 Supabase no da acceso automático a tablas nuevas | Ejecutar `grant select, insert on public.productos to anon;` |
| La tabla dice "No hay productos" pero en Supabase sí hay datos | RLS activo sin política de lectura | Ejecutar las líneas `create policy` de `sql/01_crear_tabla.sql` |
| `new row violates row-level security policy` | Falta la política de insertar | Igual que arriba |
| `Identifier 'supabase' has already been declared` | Se llamó `supabase` a la variable; ese nombre ya lo usa la librería | Usar `cliente` |
| `Invalid API key` | Key mal copiada o con espacios | Volver a copiar la publishable/anon key |
| `relation "public.productos" does not exist` | No se ejecutó el SQL o la tabla tiene otro nombre | Revisar en Table Editor |
| `Failed to fetch` | URL mal copiada o sin internet | Revisar `SUPABASE_URL` |
| No pasa nada al hacer clic | Error de JavaScript | Presionar F12 → pestaña *Console* |
| El proyecto aparece como *Paused* | El plan gratis pausa proyectos sin uso | Clic en **Restore project** en el panel |

## Integrantes

- Diego Zamora Arce C5L139
- Rafael Porras Rakow C5I449
- Jered Arias Avila C5C706
