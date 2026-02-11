-- core/Guard.lua

Guard = {}

-- =========================
-- Run Guard Pipeline
-- =========================
function Guard.run(guards, ctx)
    for _, guard in ipairs(guards or {}) do
        local ok, result = pcall(guard, ctx)

        if not ok then
            -- Guard threw something
            if Exception.isException(result) then
                error(result)
            end

            error(Exception.Internal(tostring(result)))
        end

        -- Explicit deny
        if result == false then
            error(Exception.Forbidden("Access denied by guard"))
        end

        -- Guard returned exception
        if Exception.isException(result) then
            error(result)
        end

        -- Update CTX
        if ok and result then
            ctx = result
        end
    end
end
