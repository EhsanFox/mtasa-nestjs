-- Server.lua

Server = {}

-- =========================
-- HTTP Router Entry
-- =========================
function Server:handle(request)
    local ok, result = pcall(function()
        return Base.handle(self, request)
    end)

    if ok then
        -- Success wrapper (default)
        if result and result.__exception then
            return result:toResponse()
        end

        return {
            status = 200,
            body = result,
            headers = {
                ["content-type"] = "application/json"
            }
        }
    else
        -- Unhandled exception fallback
        return {
            status = 500,
            body = toJSON({
                ok = false,
                error = tostring(result)
            }),
            headers = {
                ["content-type"] = "application/json"
            }
        }
    end
end

Server.__index = Server

function Server.create(basePath)
    local self = Base.create(basePath or "")
    setmetatable(self, Server)

    self.__type = "server"

    return self
end

-- THIS is inheritance
setmetatable(Server, Base)