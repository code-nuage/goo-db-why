local fs = require("coro-fs")
local json = require("json")

--+ LOCAL UTILS FUNCTIONS +--

local function dir_exists(path)
    local stat = fs.stat(path)
    return stat and stat.type == "directory"
end

local function read_file(path)
    local data, err = fs.readFile(path)
    if not data then
        print("Error reading file: ", err)
        return nil
    end
    return data
end

local function write_file(path, data)
    local ok, err = fs.writeFile(path, data)
    if not ok then
        print("Error writing file: ", err)
        return false
    end
    return true
end

local function read_decoded(path)
    local json_data = read_file(path)
    return json.decode(json_data)
end

local function get_ids(path)
    local get_next_file = fs.scandir(path)
    local ids = {}

    while true do
        local entry = get_next_file()

        if not entry then break end                                            -- Break loop if we can't find a file

        table.insert(ids, entry.name:sub(0, #entry.name - 5))
    end

    table.sort(ids)
    return ids
end

--+ GOODBWHY +--

local goodbwhy = {}
goodbwhy.container = nil

goodbwhy.dir = {}
goodbwhy.dir.__index = goodbwhy.dir

function goodbwhy.select_db(path)
    if dir_exists(path) then
        goodbwhy.container = path
    end
end

function goodbwhy.select(path)
    local instance = setmetatable({}, goodbwhy.dir)

    instance.path = path                                                       -- Equivalent to tables in SQL

    return instance
end

function goodbwhy.dir:insert(data, id)
    assert(type(data) == "table", "Data must be a table")

    local json_data = json.encode(data)

    if id then
        write_file(goodbwhy.container .. "/" .. self.path .. "/" .. id .. ".json", json_data)
    else
        local next_id = get_ids()[#get_ids(goodbwhy.container .. "/" .. self.path)] + 1

        write_file(goodbwhy.container .. "/" .. self.path .. "/" .. next_id .. ".json", json_data)
    end
end

function goodbwhy.dir:get_by_id(id)
    assert(type(id) == "number", "ID must be a number")

    local data = read_decoded(goodbwhy.container .. "/" .. self.path .. "/" .. id .. ".json")
    if data then
        return data
    end
    return false
end

function goodbwhy.dir:get_by_value(key, value)
    assert(type(key) == "string", "Key must be a string")

    local existing_ids = get_ids(goodbwhy.container .. "/" .. self.path)
    local parsed_ids = {}

    for _, id in pairs(existing_ids) do
        local data = read_decoded(goodbwhy.container .. "/" .. self.path .. "/" .. id .. ".json")

        if data[key] == value then
            table.insert(parsed_ids, data)
        end
    end

    return parsed_ids
end

function goodbwhy.dir:delete(id)
    fs.rmrf(goodbwhy.container .. "/" .. self.path .. "/" .. id .. ".json")
end

function goodbwhy.dir:update(id, data)
    self:delete(id)
    self:insert(data, id)
end

return goodbwhy
