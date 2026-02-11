-- jwt.lua
-- Pure Lua JWT library for MTA:SA (no dependencies)

jwt = {}

-- =====================
-- Pure Lua bitwise ops
-- =====================
-- Right shift
local function rshift(x, n)
    return math.floor(x / 2^n)
end

-- Left shift
local function lshift(x, n)
    return (x * 2^n) % 2^32
end

-- Bitwise AND
local function band(a, b)
    local res = 0
    for i = 0, 31 do
        local bit = (rshift(a, i) % 2) * (rshift(b, i) % 2)
        res = res + bit * 2^i
    end
    return res
end

-- Bitwise OR
local function bor(a, b)
    local res = 0
    for i = 0, 31 do
        local bit = math.min(1, (rshift(a, i) % 2) + (rshift(b, i) % 2))
        res = res + bit * 2^i
    end
    return res
end

-- Bitwise XOR
local function bxor(a, b)
    local res = 0
    for i = 0, 31 do
        local bit = ((rshift(a, i) % 2) + (rshift(b, i) % 2)) % 2
        res = res + bit * 2^i
    end
    return res
end

-- Bitwise NOT
local function bnot(x)
    return 2^32 - 1 - x
end

-- Right rotate
local function rrotate(x, n)
    n = n % 32
    local right = rshift(x, n)
    local left = lshift(x, 32 - n)
    return (right + left) % 2^32
end


-- =====================
-- Base64 URL-safe encode/decode
-- =====================
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_'

local function base64_encode(data)
    local bytes = {data:byte(1,#data)}
    local bit_str = ""
    for i=1,#bytes do
        local byte = bytes[i]
        for j = 7, 0, -1 do
            bit_str = bit_str .. (math.floor(byte / 2^j) % 2)
        end
    end
    local output=""
    for i=1,#bit_str,6 do
        local chunk = bit_str:sub(i,i+5)
        if #chunk<6 then chunk = chunk .. string.rep("0",6-#chunk) end
        local val=0
        for j=1,6 do if chunk:sub(j,j)=="1" then val=val+2^(6-j) end end
        output=output..b:sub(val+1,val+1)
    end
    return output
end

local function base64_decode(data)
    local reverse={}
    for i=1,#b do reverse[b:sub(i,i)]=i-1 end
    local bit_str=""
    for i=1,#data do
        local val = reverse[data:sub(i,i)]
        for j = 5, 0, -1 do
            bit_str = bit_str .. ( (rshift(val, j) % 2) )
        end
    end
    local output=""
    for i=1,#bit_str,8 do
        local byte=0
        for j=0,7 do if bit_str:sub(i+j,i+j)=="1" then byte=byte+2^(7-j) end end
        output=output..string.char(byte)
    end
    return output
end

-- =====================
-- SHA256 (pure Lua)
-- =====================
local function str2bytes(str)
    local t={}
    for i=1,#str do t[i]=str:byte(i) end
    return t
end

local function bytes2str(t)
    return string.char(unpack(t))
end

-- SHA256 constants
local K={
0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,
0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,
0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,
0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,
0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,
0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,
0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,
0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2
}

local H={
0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,
0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19
}

-- SHA256 helpers
local function Ch(x,y,z) return bxor(band(x,y), band(bnot(x), z)) end
local function Maj(x,y,z) return bxor(band(x,y), band(x,z), band(y,z)) end
local function Sigma0(x) return bxor(rrotate(x,2), rrotate(x,13), rrotate(x,22)) end
local function Sigma1(x) return bxor(rrotate(x,6), rrotate(x,11), rrotate(x,25)) end
local function sigma0(x) return bxor(rrotate(x,7), rrotate(x,18), rshift(x,3)) end
local function sigma1(x) return bxor(rrotate(x,17), rrotate(x,19), rshift(x,10)) end

-- Convert 4 bytes to uint32
local function bytes2word(b, i)
    local a = b[i]     or 0
    local c = b[i+1]   or 0
    local d = b[i+2]   or 0
    local e = b[i+3]   or 0
    return a*2^24 + c*2^16 + d*2^8 + e
end

-- Convert uint32 to 4 bytes
local function word2bytes(w)
    local t = {}
    t[1] = band(rshift(w, 24), 0xFF)
    t[2] = band(rshift(w, 16), 0xFF)
    t[3] = band(rshift(w, 8), 0xFF)
    t[4] = band(w, 0xFF)
    return t
end

-- Preprocess message
local function preprocess(msg)
    local bytes = str2bytes(msg)
    local l = #bytes * 8
    table.insert(bytes, 0x80)
    while (#bytes * 8) % 512 ~= 448 do
        table.insert(bytes, 0x00)
    end
    -- Extend bytes array by 8 for length
    for i = #bytes + 1, #bytes + 8 do
        bytes[i] = 0
    end

    bytes[#bytes - 7] = band(rshift(l, 56), 0xFF)
    bytes[#bytes - 6] = band(rshift(l, 48), 0xFF)
    bytes[#bytes - 5] = band(rshift(l, 40), 0xFF)
    bytes[#bytes - 4] = band(rshift(l, 32), 0xFF)
    bytes[#bytes - 3] = band(rshift(l, 24), 0xFF)
    bytes[#bytes - 2] = band(rshift(l, 16), 0xFF)
    bytes[#bytes - 1] = band(rshift(l, 8), 0xFF)
    bytes[#bytes]     = band(l, 0xFF)

    return bytes
end


-- SHA256 main function
function jwt.sha256(msg)
    local bytes = preprocess(msg)
    local Hcopy = {unpack(H)}
    for i=1,#bytes,64 do
        local w={}
        for j=0,15 do w[j]=bytes2word(bytes,i+j*4+1) end
        for j=16,63 do w[j] = (sigma1(w[j-2]) + w[j-7] + sigma0(w[j-15]) + w[j-16]) % 2^32 end
        local a,b,c,d,e,f,g,h = unpack(Hcopy)
        for j=0,63 do
            local T1 = (h + Sigma1(e) + Ch(e,f,g) + K[j+1] + w[j]) % 2^32
            local T2 = (Sigma0(a) + Maj(a,b,c)) % 2^32
            h=g; g=f; f=e; e=(d+T1)%2^32; d=c; c=b; b=a; a=(T1+T2)%2^32
        end
        Hcopy[1]=(Hcopy[1]+a)%2^32
        Hcopy[2]=(Hcopy[2]+b)%2^32
        Hcopy[3]=(Hcopy[3]+c)%2^32
        Hcopy[4]=(Hcopy[4]+d)%2^32
        Hcopy[5]=(Hcopy[5]+e)%2^32
        Hcopy[6]=(Hcopy[6]+f)%2^32
        Hcopy[7]=(Hcopy[7]+g)%2^32
        Hcopy[8]=(Hcopy[8]+h)%2^32
    end
    local digest={}
    for i=1,8 do
        local b = word2bytes(Hcopy[i])
        for j=1,4 do table.insert(digest,b[j]) end
    end
    return bytes2str(digest)
end

-- =====================
-- HMAC-SHA256
-- =====================
local function hmac_sha256(key,msg)
    local blocksize=64
    if #key>blocksize then key=jwt.sha256(key) end
    key=key .. string.rep("\0", blocksize-#key)
    local o_key = ""
    local i_key = ""
    for i=1,#key do
        o_key=o_key..string.char(bxor(key:byte(i),0x5c))
        i_key=i_key..string.char(bxor(key:byte(i),0x36))
    end
    return jwt.sha256(o_key .. jwt.sha256(i_key..msg))
end

-- =====================
-- JWT encode/decode
-- =====================
local function jsonEncode(tbl)
    local function serialize(obj)
        local t = {}
        if type(obj) == "table" then
            local isArray = false
            for k,v in pairs(obj) do
                if type(k) == "number" then
                    isArray = true
                    break
                end
            end
            if isArray then
                local res = {}
                for i=1,#obj do table.insert(res, serialize(obj[i])) end
                return "[" .. table.concat(res,",") .. "]"
            else
                local res = {}
                for k,v in pairs(obj) do
                    table.insert(res, '"'..k..'":'..serialize(v))
                end
                return "{" .. table.concat(res,",") .. "}"
            end
        elseif type(obj) == "string" then
            return '"'..obj..'"'
        elseif type(obj) == "number" or type(obj) == "boolean" then
            return tostring(obj)
        else
            return 'null'
        end
    end
    return serialize(tbl)
end
local function jsonDecode(s) return fromJSON(s) end

function jwt.encode(payload,secret)
    local header={alg="HS256",typ="JWT"}
    local segments={base64_encode(jsonEncode(header)),base64_encode(jsonEncode(payload))}
    local signing_input = table.concat(segments,".")
    local signature = hmac_sha256(secret,signing_input)
    signature = base64_encode(signature)
    return signing_input.."."..signature
end

function jwt.decode(token,secret,verify)
    local parts={}
    for p in token:gmatch("[^%.]+") do table.insert(parts,p) end
    if #parts~=3 then return nil,"Invalid token" end
    local header=jsonDecode(base64_decode(parts[1]))
    local payload=jsonDecode(base64_decode(parts[2]))
    local signature = parts[3]
    if verify then
        local valid_sig = base64_encode(hmac_sha256(secret,parts[1].."."..parts[2]))
        if valid_sig ~= signature then return nil,"Invalid signature" end
        if payload.exp and os.time() > payload.exp then return nil,"Token expired" end
    end
    return payload
end