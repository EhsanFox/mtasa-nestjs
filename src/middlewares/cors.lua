CORSMiddleware = function(ctx)
    ctx.headersOut = ctx.headersOut or {}
    ctx.headersOut["access-control-allow-origin"] = "*"
    ctx.headersOut["access-control-allow-methods"] = "GET,POST,PUT,DELETE,OPTIONS"
end
