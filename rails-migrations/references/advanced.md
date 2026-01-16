# Advanced Migration Patterns

## Table of Contents
- [Bulk Changes with `change_table`](#bulk-changes-with-change_table)
- [Granular Column Modification](#granular-column-modification)
- [Optimized Join Tables](#optimized-join-tables)
- [Database Constraints](#database-constraints)
- [Raw SQL Execution](#raw-sql-execution)
- [Reversible Blocks](#reversible-blocks)
- [Foreign Key Constraints](#foreign-key-constraints)
- [Transactional Migrations](#transactional-migrations)
- [Reversible Operations](#reversible-operations)
- [Feedback and Messages](#feedback-and-messages)

## Bulk Changes with `change_table`
Perform multiple operations on a single table efficiently.

```ruby
change_table :products do |t|
  t.remove :description, :name
  t.string :part_number
  t.index :part_number
  t.rename :upccode, :upc_code
end
```

## Granular Column Modification
Prefer these over `change_column` when possible, as they don't require re-stating the column type.

```ruby
# Change default value
change_column_default :products, :approved, from: false, to: true

# Change nullability
# Note: Changing to null: false requires all existing records to be valid!
change_column_null :users, :email, false, "temp@example.com" # 4th arg is default for existing nulls
```

## Optimized Join Tables
Always add indexes to join tables for performance. Use the block syntax.
**Note:** Rails comments these out by default. Uncomment the one(s) matching your query patterns:
- `[:a_id, :b_id]` optimizes "Find all B for A".
- `[:b_id, :a_id]` optimizes "Find all A for B".
- Uncomment both if you query in both directions.

```ruby
create_join_table :products, :categories do |t|
  # t.index [:product_id, :category_id]
  # t.index [:category_id, :product_id]
end
```

## Database Constraints
Rails supports native check constraints (Rails 6.1+).

```ruby
# Enforce price is positive
add_check_constraint :products, "price > 0", name: "price_check"

# Enforce zip code format
add_check_constraint :distributors, "zipcode ~ '^[0-9]{5}(-[0-9]{4})?$'", name: "zip_check"
```

## Raw SQL Execution
Use `execute` when Active Record helpers aren't enough (e.g., specific database features, complex updates).

```ruby
def up
  execute "UPDATE products SET price = 'free'"
end

def down
  execute "UPDATE products SET price = 'original_price' WHERE price = 'free'"
end
```

## Reversible Blocks
Handle complex logic that Rails can't auto-reverse.

```ruby
def change
  reversible do |dir|
    dir.up do
      # Custom setup code
      execute "CREATE VIEW active_users AS SELECT * FROM users WHERE active = 1"
    end
    dir.down do
      # Custom teardown code
      execute "DROP VIEW active_users"
    end
  end
end
```

## Foreign Key Constraints
Ensures referential integrity at the database level.
*Note: `references` generator adds this automatically if configured, but `add_foreign_key` is explicit.*

```ruby
# Adds constraint: articles.author_id must exist in authors.id
add_foreign_key :articles, :authors

# With custom column
add_foreign_key :articles, :users, column: :author_id, primary_key: :guid
```

## Transactional Migrations
Migrations run in a transaction by default. Disable this for operations that require it (e.g., PostgreSQL `ALTER TYPE` or adding indexes concurrently).

```ruby
class AddIndexConcurrently < ActiveRecord::Migration[7.1]
  disable_ddl_transaction!

  def change
    add_index :users, :email, algorithm: :concurrently
  end
end
```

## Reversible Operations
For a migration to be reversible with `change`, Rails needs to know how to undo it.

| Operation | Why Reversible? |
|-----------|-----------------|
| `add_column` | `remove_column` is obvious |
| `remove_column` | **Only if type is provided** as 3rd argument |
| `rename_column` | Reverse is swapping names |
| `create_table` | `drop_table` is obvious |

**Example of reversible remove:**
```ruby
def change
  remove_column :posts, :slug, :string # Reversible because type is known
end
```

## Feedback and Messages
Use `say` or `say_with_time` to print progress in the console during migration execution.

```ruby
def change
  say "Updating slug for existing posts..."
  Post.find_each { |p| p.update(slug: p.title.parameterize) }
  say "Done!", true # indented
end
```
```
