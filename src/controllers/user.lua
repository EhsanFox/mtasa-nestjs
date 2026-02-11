UserController = Controller.create("/user")

UserController:get("/@me", function(ctx)
    return Exception.Result(nil, ctx.user)
end, {
    guards = { AuthGuard }
})