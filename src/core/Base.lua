-- core/Base.lua

Base = {}

-- =========================
-- Registration APIs
-- =========================
function Base:use(middleware)
    table.insert(self.middlewares, middleware)
end

function Base:guard(guard)
    table.insert(self.guards, guard)
end

function Base:interceptor(interceptor)
    table.insert(self.interceptors, interceptor)
end

function Base:mount(controller)
    table.insert(self.controllers, controller)
end

-- =========================
-- HTTP Method helpers
-- =========================
local function register(self, method, path, handler, opts)
    local endpoint = Endpoint.create({
        method = method,
        path = path,
        handler = handler,
        guards = opts and opts.guards or {},
        middlewares = opts and opts.middlewares or {},
        interceptors = opts and opts.interceptors or {},
        dto = opts and opts.dto or nil
    })

    table.insert(self.endpoints, endpoint)
    return endpoint
end

function Base:get(path, handler, opts)
    return register(self, "GET", path, handler, opts)
end

function Base:post(path, handler, opts)
    return register(self, "POST", path, handler, opts)
end

function Base:delete(path, handler, opts)
    return register(self, "DELETE", path, handler, opts)
end

-- =========================
-- Request Handling
-- =========================
function Base:handle(req)
    local ctx = self:_prepareContext(req)

    local function executor()
        -- Server-level
        Middleware.run(self.middlewares, ctx)
        Guard.run(self.guards, ctx)

        -- Find endpoint or controller
        local target, endpoint = self:_resolve(ctx)
        if not endpoint then
            error(Exception.NotFound())
        end

        -- Controller-level
        if target ~= self then
            Middleware.run(target.middlewares, ctx)
            Guard.run(target.guards, ctx)
        end

        -- Endpoint-level
        Middleware.run(endpoint.middlewares, ctx)
        Guard.run(endpoint.guards, ctx)

        -- DTO
        if endpoint.dto then
            ctx.body = DTO.validate(endpoint.dto, ctx.body)
        end

        -- Execute handler
        return endpoint.handler(ctx)
    end

    return Interceptor.run(self:_collectInterceptors(ctx), executor, ctx)
end

-- =========================
-- Helpers
-- =========================
function Base:_prepareContext(req)
    return {
        method = req.method,
        path = req.path,
        headers = req.headers or {},
        query = req.query or {},
        body = req.body,
        params = {},
        raw = req
    }
end

function Base:_resolve(ctx)
    -- Check own endpoints
    for _, ep in ipairs(self.endpoints) do
        local params = ep:match(ctx.method, ctx.path, self.basePath)
        if params then
            ctx.params = params
            return self, ep
        end
    end

    -- Check controllers
    for _, ctrl in ipairs(self.controllers) do
        for _, ep in ipairs(ctrl.endpoints) do
            local params = ep:match(ctx.method, ctx.path, ctrl.basePath)
            if params then
                ctx.params = params
                return ctrl, ep
            end
        end
    end
end

function Base:_collectInterceptors()
    local list = {}

    for _, i in ipairs(self.interceptors) do
        table.insert(list, i)
    end

    return list
end

Base.__index = Base

-- =========================
-- Constructor
-- =========================
function Base.create(basePath)
    local self = setmetatable({}, Base)

    self.basePath = basePath or ""
    self.middlewares = {}
    self.guards = {}
    self.interceptors = {}
    self.endpoints = {}
    self.controllers = {}

    setmetatable(self, Base)
    self.__type = "base"

    return self
end