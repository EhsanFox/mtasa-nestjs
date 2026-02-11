InfoController = Controller.create("")

-- Public endpoint
InfoController:get("/info", function(ctx)
    return Exception.Result(nil, {
        players = {
            online = exports.config:get("connectedClients") or 0,
            total = 0
        },
        version = "0.0.1"
    })
end)