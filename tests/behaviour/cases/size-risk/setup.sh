# A repo with a production schema migration folder. The data folder has no overlays/ directory.
mkdir -p migrations && echo 'CREATE TABLE orders (id bigint primary key);' > migrations/001_orders.sql
echo 'Migrations in migrations/ are applied to the production database on merge.' > README.md
git add -A && git_q commit -qm init
