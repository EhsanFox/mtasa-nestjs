-- core/DTO.lua

DTO = {}

-- =========================
-- Validate DTO Schema
-- =========================
function DTO.validate(schema, input, ctx)
    if type(input) ~= "table" then
        error(Exception.BadRequest("Request body must be an object"))
    end

    local output = {}

    for field, rules in pairs(schema) do
        local value = input[field]

        -- Required check
        if value == nil then
            if rules.required then
                error(Exception.BadRequest("Missing field: " .. field))
            end

            if rules.default ~= nil then
                value = rules.default
            end
        end

        -- Type check
        if value ~= nil and rules.type then
            if type(value) ~= rules.type then
                error(Exception.BadRequest(
                    "Invalid type for field '" .. field ..
                    "', expected " .. rules.type
                ))
            end
        end

        -- Custom validators
        if value ~= nil and rules.validators then
            for _, validator in ipairs(rules.validators) do
                local ok, result = pcall(validator, value, ctx)

                if not ok then
                    error(Exception.BadRequest(
                        "Validation failed for field '" .. field .. "': " .. tostring(result)
                    ))
                end

                if result == false then
                    error(Exception.BadRequest(
                        "Validation failed for field '" .. field .. "'"
                    ))
                end
            end
        end

        -- Transform
        if value ~= nil and rules.transform then
            local ok, transformed = pcall(rules.transform, value, ctx)

            if not ok then
                error(Exception.BadRequest(
                    "Transform failed for field '" .. field .. "'"
                ))
            end

            value = transformed
        end

        output[field] = value
    end

    return output
end
