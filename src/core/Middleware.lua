-- core/Middleware.lua

Middleware = {}

-- =========================
-- Run Middleware Pipeline
-- =========================
function Middleware.run(middlewares, ctx)
    for _, middleware in ipairs(middlewares or {}) do
        local ok, err = pcall(middleware, ctx)

        if not ok then
            -- Middleware threw
            if Exception.isException(err) then
                error(err)
            end

            error(Exception.Internal(tostring(err)))
        end
    end
end
