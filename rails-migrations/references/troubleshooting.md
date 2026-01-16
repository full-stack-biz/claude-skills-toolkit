# Migration Troubleshooting & Testing

## Table of Contents
- [Debugging Failed Migrations](#debugging-failed-migrations)
- [Testing Migrations Before Running](#testing-migrations-before-running)
- [Common Scenarios](#common-scenarios)
- [Handling Data Migrations](#handling-data-migrations)
- [Version Mismatch Issues](#version-mismatch-issues)
- [Testing in CI/CD](#testing-in-cicd)

## Debugging Failed Migrations

### Step 1: Check Status
```bash
bin/rails db:migrate:status
```
Look for migrations with status `down` (not executed) or check the timestamp of the last successful migration.

### Step 2: Check the Error
Review the full error output. Common failures:

| Error | Cause | Solution |
|-------|-------|----------|
| `Column already exists` | Column was added in a different migration or manually | Use conditional logic or check `schema.rb` |
| `NULL values exist` | Adding `null: false` to column with existing NULLs | Remove `null: false` and backfill data first |
| `Foreign key constraint fails` | Referenced record doesn't exist | Ensure parent records exist before adding constraint |
| `Table is locked` | Another process has a lock on the table | Wait or restart database process |
| `Syntax error near...` | Typo in raw SQL via `execute` | Review the SQL in the migration file carefully |

### Step 3: Fix and Rollback Safely
```bash
# Rollback to specific version
bin/rails db:migrate VERSION=20240101000000

# OR rollback N steps (less safe, but quick)
bin/rails db:rollback STEP=1

# Verify rollback worked
bin/rails db:migrate:status
```

### Step 4: Edit & Re-run
1. Fix the migration file
2. Re-run: `bin/rails db:migrate`

**Important:** Only edit migrations that haven't been committed or pushed. Otherwise, create a new migration to fix the issue.

## Testing Migrations Before Running

### Unit Testing (Rails 6.0+)
Create test files in `test/migrations/`:

```ruby
require "test_helper"

class AddDetailsToProductsTest < ActiveSupport::TestCase
  def test_migration_up
    # Use migration testing utilities
    migration = AddDetailsToProducts.new
    migration.migrate(:up)

    assert Product.column_names.include?("sku")
  end

  def test_migration_down
    migration = AddDetailsToProductsTest.new
    migration.migrate(:down)

    assert_not Product.column_names.include?("sku")
  end
end
```

### Manual Testing (Development)
```bash
# Run migration
bin/rails db:migrate

# Check schema.rb was updated
git diff db/schema.rb

# Manually query to verify
bin/rails dbconsole
SELECT * FROM products LIMIT 5;

# Rollback if needed
bin/rails db:rollback

# Run in test environment
RAILS_ENV=test bin/rails db:migrate
```

## Common Scenarios

### Adding a Column to a Large Table (Production)
**Safe approach:**
```ruby
# Migration 1: Add column with null: true
add_column :products, :sku, :string, null: true

# Separate maintenance task or migration 2: Backfill
# Use background job or rake task for this
Product.find_each { |p| p.update(sku: generate_sku(p)) }

# Migration 3: Add null: false constraint
change_column_null :products, :sku, false
```

### Removing a Column (High Risk)
**Before removing:**
1. Verify no code references the column
2. Check `grep -r "column_name"` in codebase
3. Backfill or archive data if needed

**Safe removal:**
```ruby
remove_column :products, :old_field, :string
# Always provide type as 3rd arg for reversibility
```

### Fixing a Typo in an Uncommitted Migration
```bash
# Edit the migration file
vim db/migrate/20240115120000_create_products.rb

# Rollback
bin/rails db:rollback

# Re-run
bin/rails db:migrate
```

### Migration Stuck in Pending State
If a migration shows as `down` but you want to skip it:
```bash
# Manual skip (advanced, use carefully)
bin/rails runner "ActiveRecord::SchemaMigration.create!(version: '20240115000000')"

# Or rollback everything and start fresh (dev only)
bin/rails db:reset
```

## Handling Data Migrations

Avoid changing data in schema migrations. Instead:

1. **Use separate maintenance tasks:**
   ```bash
   bin/rails generate maintenance:task update_product_prices
   # Edit and run: bin/rails maintenance:update_product_prices
   ```

2. **Or use `db/seeds.rb` for initial data:**
   ```bash
   bin/rails db:seed
   ```

3. **Or use a background job in production** to backfill safely without locking tables.

## Version Mismatch Issues

If you see "NO FILE" in `db:migrate:status`:
```bash
# A migration file was deleted but not rolled back from schema_migrations table
# Option 1: Recreate the deleted file
# Option 2: Manually remove from schema_migrations table
bin/rails runner "ActiveRecord::SchemaMigration.where(version: '20240115000000').delete_all"
```

## Testing in CI/CD

```bash
# In CI pipeline, test migrations in clean database
RAILS_ENV=test bin/rails db:drop db:create db:migrate

# Run tests
bin/rails test

# Verify schema matches schema.rb
RAILS_ENV=test bin/rails db:schema:load
RAILS_ENV=test bin/rails db:migrate:status
```
