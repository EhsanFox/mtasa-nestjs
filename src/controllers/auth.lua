AuthController = Controller.create("/auth")

-- Public endpoint
AuthController:post("/otp/request", function(ctx)
    local dto = ctx.body
    --local userExists = exports.database:call("users.findByPhone", dto.phone)
    --local otpExists = exports.database:call("otps.findByPhone", dto.phone)
    --if userExists then
        --if otpExists then
            --local now = getRealTime().timestamp
            --local elapsed = now - otpExists.updated_at
            --local cooldown = 120
            -- TODO: Un-comment below codes on production
            --if elapsed < cooldown then
            --    outputDebugString("Cooldown, must wait another " ..(cooldown - elapsed))
            --    return Exception.Conflict(
            --        "You have to wait " .. (cooldown - elapsed) .. " more seconds to request an OTP again."
            --    )
            --end
        --end
    --end

    -- local upsertOTP = exports.database:call("otps.upsert", { phone = dto.phone })
    -- TODO: Call API to Send OTP
    -- TODO: Remove below if (it's only for development)
    --if upsertOTP then
        --local otpCode = exports.database:call("otps.findByPhone", dto.phone)
        --return Exception.Result(nil, otpCode.code)
    --end


    return Exception.Result(nil, dto)
end, {
    dto = AuthOTPRequest
})

AuthController:post("/register", function(ctx)
    local dto = ctx.body
    if dto.password ~= dto.confirmPassword then
        return Exception.UnprocessableEntity("Passwords do not match")
    end

    --local userExists = exports.database:call("users.findByUsername", dto.username)
    --if userExists then
        --return Exception.Conflict("This username is already taken, Please login or register via another username.")
    --end

    --local otpCode = exports.database:call("otps.findByPhone", dto.phone)
    --if not otpCode then
        --return Exception.Unauthorized("Request an OTP First before registering.")
    --end

    --if dto.code ~= otpCode.code then
        --return Exception.BadRequest("Wrong OTP Code, try again later.")
    --end

    --local now = getRealTime().timestamp
    --local elapsed = now - otpCode.updated_at
    --local cooldown = 240

    --if elapsed > cooldown then
        --return Exception.BadRequest("OTP Code is not valid, Request another one and try again.")
    --end

    dto.password = passwordHash(dto.confirmPassword, "bcrypt", {})
    --local createUser = exports.database:call("users.register", dto)
    --if not createUser then return Exception.Internal("User couldn't be registered, Please try again later or contact support.") end
    --local userData = exports.database:call("users.findByUsername", dto.username)
    
    local accessToken = jwt.encode({ id = "some-id", username = "some-usewrnae", fname = "some-firstname", lname = "some-lastname", phone = 09000000000, exp = os.time() + 3600 },
            "Secret")
    local refreshToken = jwt.encode({ id = "some-id", username = "some-username", exp = os.time() + 3600 },
        "MY-Secret-KEY")
    --local isTokenSet = exports.database:call("users.setTokens", userData.id, accessToken, refreshToken)
    return Exception.Result(nil, { accessToken = accessToken, refreshToken = refreshToken, tokeResult = isTokenSet })
    
end, {
    dto = RegisterDTO
})

AuthController:post("/login", function(ctx)
    local dto = ctx.body
    if dto.username and dto.password then
        --local userExists = exports.database:call("users.findByUsername")
        --if not userExists then return Exception.BadRequest("Username is invalid, or you can register via this username.") end

        
        if not passwordVerify(dto.password, "some-stored-hashed-password") then return Exception.Forbidden("Incorrect password, Please try again.") end
        
        local accessToken = jwt.encode({ id = "some-id", username = "some-usewrnae", fname = "some-firstname", lname = "some-lastname", phone = 09000000000, exp = os.time() + 3600 },
            "Secret")
        local refreshToken = jwt.encode({ id = "some-id", username = "some-username", exp = os.time() + 3600 },
            "MY-Secret-KEY")
        --local isTokenSet = exports.database:call("users.setTokens", userExists.id, accessToken, refreshToken)
        return Exception.Result(nil, { accessToken, refreshToken })
    elseif dto.phone and dto.code then
        --local userExists = exports.database:call("users.findByPhone", dto.phone)
        --if not userExists then return Exception.NotFound("This phone is not registered, Please register first.") end

        --local otpCode = exports.database:call("otps.findByPhone", dto.phone)
        --if not otpCode then return Exception.Unauthorized("Request an OTP First before registering.") end
        --if dto.code ~= otpCode.code then return Exception.BadRequest("Wrong OTP Code, try again later.") end

        --local now = getRealTime().timestamp
        --local elapsed = now - otpCode.updated_at
        --local cooldown = 240

        --if elapsed > cooldown then return Exception.BadRequest(
        --"OTP Code is not valid, Request another one and try again.") end
        
        local accessToken = jwt.encode({ id = "some-id", username = "some-usewrnae", fname = "some-firstname", lname = "some-lastname", phone = 09000000000, exp = os.time() + 3600 },
            "Secret")
        local refreshToken = jwt.encode({ id = "some-id", username = "some-username", exp = os.time() + 3600 },
            "MY-Secret-KEY")
        --local isTokenSet = exports.database:call("users.setTokens", userExists.id, accessToken, refreshToken)
        return Exception.Result(nil, { accessToken = accessToken, refreshToken = refreshToken })
    end

    return Exception.BadRequest("Wrong DTO is provided for login.")
end, {
    dto = LoginDto
})