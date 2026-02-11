JsonBodyMiddleware = function(ctx)
    if type(ctx.body) == "string"
        and ctx.headers["content-type"] == "application/json" then

        local ok, decoded = pcall(fromJSON, ctx.body)
        if not ok then
            error(Exception.BadRequest("Invalid JSON body"))
        end

        ctx.body = decoded
    end
end
