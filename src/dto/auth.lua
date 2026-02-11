AuthOTPRequest = {
    phone = {
        type = "number",
        required = true,
        validators = {
            function(v)
                return v >= 1000000000
            end
        }
    }
}

RegisterDTO = {
    username = {
        type = "string",
        required = true,
        validators = {
            function(v)
                return #v >= 3
            end
        }
    },

    fname = {
        type = "string",
        required = true
    },

    lname = {
        type = "string",
        required = true
    },

    password = {
        type = "string",
        required = true
    },

    confirmPassword = {
        type = "string",
        required = true
    },

    phone = {
        type = "number",
        required = true,
        validators = {
            function(v)
                return v >= 1000000000
            end
        }
    },

    code = {
        type = "number",
        required = true,
        validators = {
            function(v)
                if v == nil then return false end

                local str = tostring(v)
                return str:match("^%d%d%d%d%d%d$") ~= nil
            end
        }
    }
}

LoginDto = {
    username = {
        type = "string",
        required = false,
        validators = {
            function(v)
                return #v >= 3
            end
        }
    },
    password = {
        type = "string",
        required = false
    },

    phone = {
        type = "number",
        required = false,
        validators = {
            function(v)
                return v >= 1000000000
            end
        }
    },

    code = {
        type = "number",
        required = false,
        validators = {
            function(v)
                if v == nil then return false end

                local str = tostring(v)
                return str:match("^%d%d%d%d%d%d$") ~= nil
            end
        }
    }
}