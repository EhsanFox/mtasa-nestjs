-- core/Exception.lua

Exception = {}

-- =========================
-- Serialization
-- =========================
function Exception:toResponse()
    local body = {
        ok = false
    }
    
    if self.isOkay then
        body.ok = true
    end

    if self.data ~= nil then
        body.data = self.data
    end

    if self.message ~= nil then
        body.message = self.message
    end

    local baseHeader = {
            ["content-type"] = "application/json",
            ["access-control-allow-origin"] = "*",
            ["access-control-allow-methods"] = "GET,POST,PUT,DELETE,OPTIONS"
        }

    --local headers = exports.utils:mergeTable(baseHeader, self._headers)
    return {
        status = self.status,
        body = toJSON(body),
        headers = baseHeader
    }
end

-- =========================
-- Built-in HTTP Exceptions
-- =========================
function Exception.BadRequest(message, data)
    return Exception.create(400, message or "Bad Request", data)
end

function Exception.Unauthorized(message, data)
    return Exception.create(401, message or "Unauthorized", data)
end

function Exception.Forbidden(message, data)
    return Exception.create(403, message or "Forbidden", data)
end

function Exception.NotFound(message, data)
    return Exception.create(404, message or "Not Found", data)
end

function Exception.Conflict(message, data)
    return Exception.create(409, message or "Conflict", data)
end

function Exception.UnprocessableEntity(message, data)
    return Exception.create(422, message or "Unprocessable Entity", data)
end

function Exception.Internal(message, data)
    return Exception.create(500, message or "Internal Server Error", data)
end

function Exception.Result(message, data, ctxHeaders)
    return Exception.create(200, message or nil, data, ctxHeaders or nil, true)
end

-- =========================
-- Type Guard
-- =========================
function Exception.isException(obj)
    return type(obj) == "table" and obj.__exception == true
end

Exception.__index = Exception

-- =========================
-- Base Exception
-- =========================
function Exception.create(status, message, data, headers, isOkay)
    local self = setmetatable({}, Exception)

    self.__exception = true
    self.status = status or 500
    self.message = message
    self.data = data
    self._headers = headers or nil
    self.isOkay = isOkay or false

    return self
end