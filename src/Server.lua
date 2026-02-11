MyServer = Server.create("")

-- Global middleware
MyServer:use(CORSMiddleware)
MyServer:use(JsonBodyMiddleware)

-- Global interceptor
--MyServer:interceptor(ResponseInterceptor)

-- Mount controllers
MyServer:mount(InfoController)
MyServer:mount(AuthController)
MyServer:mount(UserController)

-- HTTP Router entry
function httpRouter(request)
    return MyServer:handle(request)
end
