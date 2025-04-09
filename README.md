# goo-db-why
A JSON-based database engine for Lua using coro-fs and rxi's JSON libraries

## Documentation
`goo-db-why` is pretty straight forward, you select a main database, a table and you can insert, get, update and delete elements.
As `goo-db-why` uses JSON and Filesystem to create an SQL-like ORM, tables will be directories, or dir, in this documentation.

### Installation

Install `coro-fs` and `json`, require it as a module and you're good to go!
```lua
local goodbwhy = require("path/to/goo-db-why")
```

### Configuration

Select a global database file first, every actions on it will execute inside of it.
```lua
goodbwhy.select_db("path/to/your/database")
```

### Usage

#### Directory selection
Select a dir that returns a representation of your children database directory.
```lua
goodbwhy.select(dir)
```

#### `insert`
You can create an element with `insert` directory-related method.
```lua
goodbwhy.select(dir):insert(data)
```

#### `get_by_id`
You can get element's data with an ID with `get_by_id` directory-related method.
Returns the data as a Lua table.
```lua
local data = goodbwhy.select(dir):get_by_id(id)
```

#### `get_by_value`
You can get element's data with a key-value pair with `get_by_value` directory-related method.
Returns the data as a Lua table.
```lua
local data = goodbwhy.select(dir):get_by_value(key, value)
```

#### `delete`
You can delete an element with an ID with `delete` directory-related method.
```lua
local data = goodbwhy.select(dir):delete(id)
```

#### `update`
You can override element's data with `update` directory-related method.
```lua
local data = goodbwhy.select(dir):update(id, data)
```

### Exemple
Now we will setup a database, select a directory, insert some users in it, read one of them, update an other and delete the last. We will also manage products.

#### Filesystem
```
db_app
└─ Users
   └─ Empty direcory
└─ Products
   └─ 1.json
   └─ 2.json
```

#### Code
```lua
local goodbwhy = require("goo-db-why")

goodbwhy.select_db("db_app")

-- Products
goodbwhy.select("Products").get_by_id(1) -- {name = "T-Shirt", size = "L", price = 24.99, in_stock = true, brand = "Niak"}
goodbwhy.select("Products").get_by_value("name", "Sweat-Shirt") -- { {name = "Sweat-Shirt", size = "XL", price = 44.99, in_stock = false, brand = "Idadis"} }

-- Users
goodbwhy.select("Users").insert({name="John Doe", age="42", size=1.84, phone="474-881-7631", email="john.doe@example.com"})
goodbwhy.select("Users").insert({name="Roger Alexander", age="37", size=1.71, phone="(532) 493-2054", email="roger.alexander@little-company.com"})
goodbwhy.select("Users").insert({name="Miriam Ruiz", age="32", size=1.84, phone="(692) 889-8297", email="miriam.ruiz@some-mega-brand.com"})

goodbwhy.select("Users").get_by_value("size", 1.84) -- { {name="John Doe", age="42", size=1.84, phone="474-881-7631", email="john.doe@example.com"}, {name="Miriam Ruiz", age="32", size=1.84, phone="(692) 889-8297", email="miriam.ruiz@some-mega-brand.com"} }

goodbwhy.select("Users").delete(2)

goodbwhy.select("Users").update(3, {name="Miriam Ruiss", age="110", size=1.80, phone="(797) 569-5910", email="miriam.ruiz@retired.com"})
goodbwhy.select("Users").insert({name="Roger Alexander", age="37", size=1.71, phone="(532) 493-2054", email="roger.alexander@little-company.com"})

goodbwhy.select("Users").get_by_id(4) -- {name="Roger Alexander", age="37", size=1.71, phone="(532) 493-2054", email="roger.alexander@little-company.com"}
```
