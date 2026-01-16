# Rails DB Commands Reference

## Migration Control

| Command | Purpose |
|---------|---------|
| `db:migrate` | Run all pending migrations |
| `db:rollback` | Revert the last migration step |
| `db:rollback STEP=3` | Revert the last 3 migration steps |
| `db:migrate:redo` | Rollback then Migrate (last step) |
| `db:migrate:status` | Show IDs, Status (up/down), and Name of all migrations |
| `db:migrate:up VERSION=x` | Run specific migration (UP) |
| `db:migrate:down VERSION=x` | Run specific migration (DOWN) |
| `db:version` | Show current database schema version |

## Setup & Reset

| Command | Purpose |
|---------|---------|
| `db:setup` | Create DB + Load Schema + Seed (No migrations run) |
| `db:reset` | Drop DB + Setup (Fast reset from schema) |
| `db:prepare` | Create + Load Schema if not exists, otherwise Migrate |
| `db:seed` | Run `db/seeds.rb` to populate initial data |
| `db:seed:replant` | Truncate tables and reload seeds (Rails 6.0+) |
| `db:migrate:reset` | Drop DB + Create DB + Migrate (Re-run all migrations) |

## Environment Specific

Run commands in other environments (default is `development`):

```bash
# Run in Test
RAILS_ENV=test bin/rails db:migrate

# Run in Production
RAILS_ENV=production bin/rails db:migrate
```

## Schema Management

| Command | Purpose |
|---------|---------|
| `db:schema:dump` | Update `db/schema.rb` from current DB state |
| `db:schema:load` | Load `db/schema.rb` into DB. **FASTER** than migrating from scratch. Erases data. |
| `db:structure:dump` | Dump SQL structure (for SQL specific features) |
