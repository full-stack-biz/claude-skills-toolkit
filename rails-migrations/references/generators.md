# Generator Syntax Reference

## Basic Syntax
```bash
bin/rails generate migration [MigrationName] [field]:[type]:[index] ...
```
Alias: `rails g migration`

## Magic Names
Rails infers actions from the migration name:

| Pattern | Action | Example |
|---------|--------|---------|
| `Add...To[Table]` | Adds columns to `[Table]` | `AddAgeToUsers` |
| `Remove...From[Table]` | Removes columns from `[Table]` | `RemoveAgeFromUsers` |
| `Create[Table]` | Creates `[Table]` | `CreateUsers` |
| `Add...RefTo[Table]` | Adds a reference to `[Table]` | `AddUserRefToProducts` |
| `JoinTable[Table1][Table2]` | Creates join table | `CreateJoinTableUsersProducts` |

## Column Modifiers
Add constraints directly in the generator command.

| Modifier | Syntax | Example |
|----------|--------|---------|
| **Limit** | `{N}` | `description:string{20}` |
| **Precision/Scale** | `{P,S}` | `price:decimal{10,2}` |
| **Index** | `:index` | `email:string:index` |
| **Unique Index** | `:uniq` | `email:string:uniq` |
| **Not Null** | `!` | `email:string!` (unsupported by some shells, verify) |

*Note: If specific modifiers like `!` cause shell issues, edit the migration file manually.*

## Examples

### Create Table with options
```bash
bin/rails g migration CreateProducts name:string description:text price:decimal{8,2}
```

### Add References (Foreign Keys)
Adds `user_id` column + index.
```bash
bin/rails g migration AddUserToProducts user:references
```
Polymorphic reference (`imageable_id`, `imageable_type`):
```bash
bin/rails g migration AddImageableToPictures imageable:references{polymorphic}
```

### Join Table
Creates `products_users` table with `product_id` and `user_id`.
```bash
bin/rails g migration CreateJoinTableProductsUsers products users
```
