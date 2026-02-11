-- core/Interceptor.lua

Interceptor = {}

-- =========================
-- Compose Interceptors
-- =========================
local function compose(interceptors, executor)
    return function(ctx)
        local index = 0

        local function dispatch()
            index = index + 1

            local interceptor = interceptors[index]
            if interceptor then
                return interceptor(ctx, dispatch)
            end

            return executor()
        end

        return dispatch()
    end
end

-- =========================
-- Run Interceptor Pipeline
-- =========================
function Interceptor.run(interceptors, executor, ctx)
    local chain = compose(interceptors, executor)

    local ok, result = pcall(function()
        return chain(ctx)
    end)

    if ok then
        return result
    end

    -- If exception object thrown
    if Exception.isException(result) then
        return result
    end

    -- Unknown error → wrap
    return Exception.Internal(tostring(result))
end
