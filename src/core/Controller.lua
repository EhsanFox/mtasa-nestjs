-- Controller.lua

Controller = {}
Controller.__index = Controller

-- =========================
-- Safety Guards (Optional but recommended)
-- =========================

function Controller:mount()
    error("Controllers cannot mount other controllers")
end

function Controller:handle()
    error("Controllers cannot handle requests directly")
end

function Controller.create(basePath)
    assert(type(basePath) == "string", "Controller basePath must be a string")

    local self = Base.create(basePath)
    setmetatable(self, Controller)
    self.__type = "controller"

    return self
end

-- THIS is inheritance
setmetatable(Controller, Base)