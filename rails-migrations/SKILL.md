---
name: rails-migrations
description: >-
  Manage Ruby on Rails Active Record migrations. Use when generating, running,
  rolling back, or debugging migrations; modifying database schema; adding/removing
  columns or tables; or testing migrations in team/production environments.
  Triggers on: "create table", "add column", "remove column", "db:migrate",
  "migration generator", "rollback", "undo migration", "data migration", "add reference",
  "zero-downtime", "migration failed".
version: 1.2.0
allowed-tools: Read,Write,Bash(rails:*,bundle:*)
---

# Rails Migrations

## When to Use This Skill

**Use this skill when:**
- Generating new migrations to modify database structure.
- Running, rolling back, or checking the status of migrations.
- Setting up or resetting the database environment.
- Modifying column types, names, or adding indexes/constraints.

**Key areas covered:**
- **Generation** (CRITICAL): Using `bin/rails generate migration` with magic names.
- **Operations** (HIGH): Running `db:migrate`, `db:rollback`, `db:migrate:status`.
- **Types & Constraints** (MEDIUM): Handling column types, indexes, and foreign keys.

## Quick Start

**Generate a migration:**
```bash
# Add column
bin/rails generate migration AddPartNumberToProducts part_number:string:index

# Create new table
bin/rails generate migration CreateProducts name:string price:decimal{10,2}

# Add reference (foreign key)
bin/rails generate migration AddUserRefToProducts user:references
```

**Run migrations:**
```bash
bin/rails db:migrate
```

**Check status:**
```bash
bin/rails db:migrate:status
```

**Undo last migration:**
```bash
bin/rails db:rollback
```

## Core Workflows

### 1. Generating Migrations
Use the generator to create the file. Rails infers actions from names:
- `Add[Column]To[Table]` -> Adds columns
- `Remove[Column]From[Table]` -> Removes columns
- `Create[Table]` -> Creates table
- `Add[Ref]To[Table]` -> Adds foreign key reference

**Syntax:**
```bash
bin/rails g migration [Name] [field]:[type]:[index] [field]:[type]
```

### 2. Editing Migration Files
Open the generated file in `db/migrate/`. Prefer the `change` method for reversible operations.

```ruby
class AddDetailsToProducts < ActiveRecord::Migration[8.1]
  def change
    add_column :products, :part_number, :string
    add_index :products, :part_number
  end
end
```

For complex edits (SQL, bulk changes, constraints), see `references/advanced.md`.

### 3. Managing Database State
- **Status:** Check pending migrations
  ```bash
  bin/rails db:migrate:status
  ```
- **Redo:** Rollback and re-run (good for dev iteration)
  ```bash
  bin/rails db:migrate:redo
  ```
- **Environment:** Run in specific env
  ```bash
  RAILS_ENV=test bin/rails db:migrate
  ```

## Common Production Patterns

### Rollback Safety
```bash
# Check status before rolling back
bin/rails db:migrate:status

# Rollback to specific version (safer than STEP)
bin/rails db:migrate VERSION=20240101000000

# Redo last migration (dev only)
bin/rails db:migrate:redo
```

### Zero-Downtime Migrations (Large Tables)
For operations on large tables that might lock in production:
1. Add new column with `null: true`
2. Backfill data in batches (via separate task, not migration)
3. Add `null: false` constraint in separate migration
4. For indexes: use `algorithm: :concurrently` (PostgreSQL) + `disable_ddl_transaction!`

## Key Notes

- **Database Independence:** These commands work for PostgreSQL, MySQL, SQLite, etc.
- **Source of Truth:** The database is the truth. `schema.rb` or `structure.sql` is just a snapshot.
- **Reversibility:** Always check if your change is reversible. If not, write explicit `up`/`down`.
- **Existing Data:** Adding `NOT NULL` to an existing column with nulls will fail. Add column -> Fill data -> Add constraint.
- **Performance:** Use `disable_ddl_transaction!` for concurrent index creation (PostgreSQL).
- **Shared Repos:** Never edit committed migrations. Create new ones to fix issues.

## References
- **Generators:** Syntax for columns, modifiers, and shortcuts -> [references/generators.md](references/generators.md)
- **Commands:** Full list of `db:*` tasks -> [references/commands.md](references/commands.md)
- **Types:** Available column types and options -> [references/types.md](references/types.md)
- **Advanced:** Raw SQL, constraints, bulk changes -> [references/advanced.md](references/advanced.md)
- **Schema:** Schema management (`schema.rb` vs `structure.sql`) -> [references/schema-management.md](references/schema-management.md)
- **Best Practices:** Reversibility, `up`/`down`, and workflow -> [references/best-practices.md](references/best-practices.md)
- **Troubleshooting:** Debugging failed migrations, testing, production patterns -> [references/troubleshooting.md](references/troubleshooting.md)
