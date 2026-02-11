AuthGuard = function(ctx)
    local authHeader = ctx.headers["authorization"]
    if not authHeader then
        return false, Exception.Unauthorized("Missing Authorization header")
    end

    -- Extract token from "Bearer <token>"
    local token = authHeader:match("^Bearer%s+(.+)$")
    if not token then
        return false, Exception.Unauthorized("Invalid Authorization format")
    end

    -- Verify JWT
    local payload = jwt.decode(token, exports.config:get("jwt_secret"), false)
    if not payload then
        return false, Exception.Unauthorized("Invalid or expired token")
    end

    -- Optional: manual exp check (if your verify doesn't already do it)
    if payload.exp and os.time() > payload.exp then
        return false, Exception.Unauthorized("Token expired")
    end

    -- Attach user to request context
    ctx.payload = payload -- Does this do anything? I don't think so.
    ctx.user = exports.database:call("users.findByUsername", payload.username)

    return true, ctx
end
