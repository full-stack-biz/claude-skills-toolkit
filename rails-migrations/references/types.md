# Column Types and Options

## Supported Types
These work across most supported databases (PostgreSQL, MySQL, SQLite).

- `binary`
- `boolean`
- `date`
- `datetime`
- `decimal` (use for currency)
- `float`
- `integer`
- `bigint` (default PK in Rails 5.1+)
- `primary_key`
- `references` (aliases: `belongs_to`)
- `string` (limited length, usually 255)
- `text` (unlimited length)
- `time`
- `timestamp`
- `virtual` (Generated columns, Rails 7.0+)

## Common Options
Passed as the last argument to `add_column`, `create_table`, etc.

```ruby
add_column :products, :price, :decimal, precision: 8, scale: 2, default: 0, null: false
```

| Option | Description |
|--------|-------------|
| `limit` | Sets max characters (string) or bytes (text/binary) |
| `precision` | Total digits (decimal) |
| `scale` | Digits after decimal point (decimal) |
| `default` | Default value (e.g., `default: 0`, `default: true`) |
| `null` | Allow NULLs? `true` (default) or `false` |
| `index` | Create index? `true` or `{ unique: true }` |
| `comment` | Add column comment (PostgreSQL/MySQL) |
| `array` | Array type (PostgreSQL only) |
| `stored` | For `virtual` columns, whether to store on disk (`true`) or compute on read (`false`) |
| `as` | The SQL expression for `virtual` columns |

### Advanced References
When the association name differs from the table name, specify the table explicitly.

```ruby
# Creates 'author_id' pointing to 'users' table
add_reference :posts, :author, foreign_key: { to_table: :users }
```

## PostgreSQL Specific
If using PostgreSQL, additional types are available:

- `hstore`
- `json` / `jsonb`
- `uuid`
- `inet` / `cidr` / `macaddr`

Example:
```ruby
add_column :users, :settings, :jsonb, default: {}
```
