-- core/Endpoint.lua

Endpoint = {}

-- =========================
-- Path matching
-- =========================
function Endpoint:match(method, url, basePath)
    if method ~= self.method then return nil end

    local fullPath = (basePath or "") .. self.path
    local pattern, keys = Endpoint._compile(fullPath)

    local matches = { url:match(pattern) }
    if not matches[1] then return nil end

    local params = {}
    for i, key in ipairs(keys) do
        params[key] = matches[i]
    end

    return params
end

function Endpoint._compile(path)
    local keys = {}
    local pattern = "^" .. path:gsub("/:(%w+)", function(k)
        table.insert(keys, k)
        return "/([^/]+)"
    end) .. "$"

    return pattern, keys
end

Endpoint.__index = Endpoint

function Endpoint.create(def)
    local self = setmetatable({}, Endpoint)

    self.method = def.method
    self.path = def.path
    self.handler = def.handler
    self.guards = def.guards or {}
    self.middlewares = def.middlewares or {}
    self.interceptors = def.interceptors or {}
    self.dto = def.dto or nil

    self._pattern, self._keys = Endpoint._compile(self.path)

    return self
end

