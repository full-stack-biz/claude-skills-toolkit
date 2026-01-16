# Schema Management

Rails maintains a representation of your database schema in a file to allow for quick database setup without running all migrations from scratch.

## `db/schema.rb` vs `db/structure.sql`

| Feature | `db/schema.rb` | `db/structure.sql` |
|---------|----------------|--------------------|
| **Format** | Ruby DSL | Database-specific SQL |
| **Portability** | High (Works across DB types) | Low (Specific to PostgreSQL, MySQL, etc.) |
| **Completeness** | Limited (Basic types, indexes) | Full (Triggers, views, procedures) |
| **Default** | Yes | No |

### Changing the format
In `config/application.rb`:
```ruby
config.active_record.schema_format = :sql # or :ruby (default)
```

## Common Schema Commands

| Command | Purpose |
|---------|---------|
| `db:schema:dump` | Update the schema file from the current database state |
| `db:schema:load` | Load the schema file into the database (ERASES DATA) |
| `db:structure:dump` | Update `db/structure.sql` from the database |
| `db:structure:load` | Load `db/structure.sql` into the database |

## Why use Schema Load?
Running `bin/rails db:schema:load` is much faster than `bin/rails db:migrate` for fresh environments (like CI or new developers) because it executes a single schema definition instead of replaying years of migration history.

## Source Control
ALWAYS commit `db/schema.rb` or `db/structure.sql` to your version control system. It should reflect the current state of the database after a successful migration.
