-- =============================================================
-- Catálogo de productos · Grupo 6 · Supabase
-- Ejecutar completo en: Supabase → SQL Editor → New query → Run
-- =============================================================

-- 1. Crear la tabla (PostgreSQL)
--    id: número que PostgreSQL genera solo (1, 2, 3, ...) y es la llave primaria
--    numeric(10,2): número con hasta 2 decimales, ideal para precios
create table productos (
  id        bigint generated always as identity primary key,
  nombre    text not null,
  precio    numeric(10,2) not null check (precio >= 0),
  categoria text not null
);

-- 2. Seguridad: activar RLS (Row Level Security)
--    Con RLS activo nadie puede leer ni escribir hasta que una política lo permita.
alter table productos enable row level security;

--    Permitir que la página (rol "anon", el de la publishable key) lea productos
create policy "Leer productos" on productos
  for select to anon using (true);

--    Permitir que la página agregue productos
--    (en un sistema real esto se limita a usuarios autenticados)
create policy "Agregar productos" on productos
  for insert to anon with check (true);

-- 3. Datos de ejemplo (precios en colones)
insert into productos (nombre, precio, categoria) values
  ('Café chorreado', 1200, 'Bebidas'),
  ('Gallo pinto',    2500, 'Comidas'),
  ('Tres leches',    1800, 'Postres');

-- 4. Consulta de prueba: el resultado aparece abajo del editor
select * from productos where categoria = 'Bebidas';
