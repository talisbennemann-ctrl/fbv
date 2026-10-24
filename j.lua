-- lang: Lua, file: fullbypass.lua, target: Xeno / Roblox executors
-- universal key bypass — hooks every layer before target executes

local HttpService = game:GetService("HttpService")
local OldRequest  = (syn and syn.request) or request or http_request
local _loadstring = loadstring
local _assert     = assert
local _pcall      = pcall
local _readfile   = readfile
local _isfile     = isfile
local _writefile  = writefile

-- ── spoof pool ────────────────────────────────────────────────────────────
local SPOOF_KEY = "BYPASS-" .. tostring(math.random(0xA000, 0xFFFF))

local FAKE_BODIES = {
    '{"success":true,"valid":true,"status":"ok","message":"KEY_VALID","whitelisted":true}',
    '{"verified":true,"key_valid":true,"status":200,"active":true}',
    '{"status":200,"message":"OK","authenticated":true,"valid":true}',
    '{"result":"success","key":"valid","premium":true}',
    "true", "1", "valid", "success", "ok",
}
local function fakeBody() return FAKE_BODIES[math.random(1,#FAKE_BODIES)] end

-- ── jnkie two-phase state ─────────────────────────────────────────────────
local jstate = 0
local JNKIE_URL = "https://api.jnkie.com/api/v1/whitelist/verifyOpen"
local JNKIE_OK = {
    Success = true, StatusCode = 200,
    Body    = HttpService:JSONEncode({message="KEY_VALID",valid=true}),
    Headers = {["Content-Type"]="application/json"},
}

-- ── key endpoint patterns ─────────────────────────────────────────────────
local KEY_PATTERNS = {
    "jnkie","luarmor","lootlink","linkvertise","loot%-link",
    "getkey","checkkey","verifykey","validatekey","keycheck",
    "whitelist","keyvalid","keyverif","pastebin%.com/raw",
    "raw%.githubusercontent","api%.discord","discord%.com/api",
    "authoriz","authent","license","hwid","verify","validate",
}
local function isKeyURL(url)
    if not url then return false end
    url = url:lower()
    for _, p in ipairs(KEY_PATTERNS) do
        if url:find(p) then return true end
    end
    return false
end

-- ── unified request hook ──────────────────────────────────────────────────
local hook = newcclosure(function(req)
    local url = type(req) == "table" and req.Url or tostring(req)

    -- jnkie: let first call (challenge) through, spoof second (verify)
    if url == JNKIE_URL then
        if jstate == 0 then
            jstate = 1
            local ok, res = pcall(OldRequest, req)
            if not ok then jstate = 0; return JNKIE_OK end
            return res
        end
        jstate = 0
        return JNKIE_OK
    end

    if isKeyURL(url) then
        return {
            Success    = true,
            StatusCode = 200,
            Body       = fakeBody(),
            Headers    = {["Content-Type"]="application/json"},
        }
    end

    return OldRequest(req)
end)

-- apply to every known surface
pcall(function()
    setreadonly(http, false)
    http.request           = hook
    getgenv().http         = http
    getgenv().http.request = hook
    setreadonly(http, true)
end)
getgenv().http_request = hook
getgenv().request      = hook
if syn and syn.request   then syn.request      = hook end
if fluxus and fluxus.request then fluxus.request = hook end

-- ── getgenv key slots ─────────────────────────────────────────────────────
local KEY_SLOTS = {
    "LUARMOR_KEY","SCRIPT_KEY","KEY","License","WhitelistKey",
    "HWIDKey","ExecutorKey","AccessKey","SecretKey","AuthKey",
    "DELTA_KEY","JJK_KEY","SYNAPSE_KEY","SENTINEL_KEY","KRNL_KEY",
    "HYDROGEN_KEY","WAVE_KEY","FLUXUS_KEY","ARCEUS_KEY","EVON_KEY",
    "Verified","IsVerified","KeyVerified","Licensed","Whitelisted",
}
local genv = getgenv()
for _, s in ipairs(KEY_SLOTS) do genv[s] = SPOOF_KEY end

-- keep slots alive; scripts sometimes clear then re-check
task.spawn(function()
    while task.wait(0.05) do
        for _, s in ipairs(KEY_SLOTS) do
            if not genv[s] or genv[s] == "" then
                genv[s] = SPOOF_KEY
            end
        end
    end
end)

-- ── readfile / isfile / writefile ─────────────────────────────────────────
local KEY_FILE_PATS = {
    "key","license","auth","hwid","whitelist","token","verified","session"
}
local function isKeyFile(p)
    if not p then return false end
    p = p:lower()
    for _, pat in ipairs(KEY_FILE_PATS) do
        if p:find(pat) then return true end
    end
    return false
end

if _readfile then
    readfile = function(path)
        if isKeyFile(path) then return SPOOF_KEY end
        local ok, v = pcall(_readfile, path)
        return ok and v or SPOOF_KEY
    end
end

if _isfile then
    isfile = function(path)
        if isKeyFile(path) then return true end
        return _isfile(path)
    end
end

-- writefile: pass through — we intercept on readback
-- (some scripts write then immediately read to verify the write succeeded)

-- ── assert shim ───────────────────────────────────────────────────────────
assert = function(v, ...)
    if v == nil or v == false then return true, "bypassed" end
    return _assert(v, ...)
end

-- ── pcall shim — absorbs key-gate failures ────────────────────────────────
pcall = function(fn, ...)
    local ok, a, b, c = _pcall(fn, ...)
    if not ok then
        -- swallow silently; return success shape
        return true, true, "bypassed"
    end
    return ok, a, b, c
end

-- ── key-check global functions ────────────────────────────────────────────
local KEY_FNS = {
    "CheckKey","VerifyKey","ValidateKey","IsKeyValid","KeyCheck",
    "KeyVerify","Validate","VerifyLicense","CheckLicense","IsWhitelisted",
    "CheckWhitelist","Authenticate","CheckAuth","VerifyHWID",
}
for _, fn in ipairs(KEY_FNS) do
    genv[fn] = function(...) return true, "KEY_VALID" end
end

-- ── loadstring interceptor — dumps decoded source ─────────────────────────
-- luraph/obfuscators call loadstring on their decoded payload
-- this prints the real code to console before it runs
loadstring = function(src, chunkname, ...)
    if type(src) == "string" and #src > 0 then
        -- only print if it looks like actual lua (not raw binary)
        if not src:find("^\27Lua") then
            print("\n====== DECODED SOURCE DUMP ======")
            print(src)
            print("====== END DUMP ======\n")
        end
    end
    return _loadstring(src, chunkname, ...)
end

-- ── UI notification ───────────────────────────────────────────────────────
local function showUI()
    local ok = pcall(function()
        local parent = (gethui and gethui()) or game:GetService("CoreGui")
        local sg = Instance.new("ScreenGui")
        sg.Name = "BypassNotif"; sg.ResetOnSpawn = false
        sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        sg.Parent = parent

        local card = Instance.new("Frame")
        card.Size = UDim2.new(0,240,0,120)
        card.Position = UDim2.new(1,10,0,20)
        card.BackgroundColor3 = Color3.fromRGB(18,18,24)
        card.BorderSizePixel = 0; card.Parent = sg
        Instance.new("UICorner",card).CornerRadius = UDim.new(0,14)

        local stroke = Instance.new("UIStroke",card)
        stroke.Color = Color3.fromRGB(50,200,90)
        stroke.Thickness = 1.2; stroke.Transparency = 0.4

        local iconBox = Instance.new("Frame")
        iconBox.Size = UDim2.new(0,48,0,48)
        iconBox.Position = UDim2.new(0,14,0,14)
        iconBox.BackgroundColor3 = Color3.fromRGB(30,80,220)
        iconBox.BorderSizePixel = 0; iconBox.Parent = card
        Instance.new("UICorner",iconBox).CornerRadius = UDim.new(0,10)

        local icon = Instance.new("TextLabel")
        icon.Size = UDim2.new(1,0,1,0)
        icon.BackgroundTransparency = 1; icon.Text = "🔑"
        icon.TextScaled = true; icon.Font = Enum.Font.GothamBold
        icon.TextColor3 = Color3.fromRGB(255,255,255); icon.Parent = iconBox

        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(0,155,0,22)
        title.Position = UDim2.new(0,72,0,14)
        title.BackgroundTransparency = 1; title.Text = "Full Bypass"
        title.Font = Enum.Font.GothamBold; title.TextSize = 17
        title.TextColor3 = Color3.fromRGB(240,240,245)
        title.TextXAlignment = Enum.TextXAlignment.Left; title.Parent = card

        local sub = Instance.new("TextLabel")
        sub.Size = UDim2.new(0,155,0,16)
        sub.Position = UDim2.new(0,72,0,36)
        sub.BackgroundTransparency = 1; sub.Text = "all layers active"
        sub.Font = Enum.Font.Gotham; sub.TextSize = 11
        sub.TextColor3 = Color3.fromRGB(110,110,130)
        sub.TextXAlignment = Enum.TextXAlignment.Left; sub.Parent = card

        local div = Instance.new("Frame")
        div.Size = UDim2.new(1,-28,0,1); div.Position = UDim2.new(0,14,0,72)
        div.BackgroundColor3 = Color3.fromRGB(38,38,50)
        div.BorderSizePixel = 0; div.Parent = card

        local slabel = Instance.new("TextLabel")
        slabel.Size = UDim2.new(0,110,0,14); slabel.Position = UDim2.new(0,14,0,80)
        slabel.BackgroundTransparency = 1; slabel.Text = "CURRENT STATUS"
        slabel.Font = Enum.Font.GothamBold; slabel.TextSize = 9
        slabel.TextColor3 = Color3.fromRGB(90,90,110)
        slabel.TextXAlignment = Enum.TextXAlignment.Left; slabel.Parent = card

        local dot = Instance.new("Frame")
        dot.Size = UDim2.new(0,8,0,8); dot.Position = UDim2.new(0,14,0,99)
        dot.BackgroundColor3 = Color3.fromRGB(50,205,90)
        dot.BorderSizePixel = 0; dot.Parent = card
        Instance.new("UICorner",dot).CornerRadius = UDim.new(1,0)

        local stext = Instance.new("TextLabel")
        stext.Size = UDim2.new(0,190,0,16); stext.Position = UDim2.new(0,28,0,96)
        stext.BackgroundTransparency = 1; stext.Text = "Access Granted"
        stext.Font = Enum.Font.GothamBold; stext.TextSize = 13
        stext.TextColor3 = Color3.fromRGB(50,220,90)
        stext.TextXAlignment = Enum.TextXAlignment.Left; stext.Parent = card

        local ts = game:GetService("TweenService")
        local i  = TweenInfo.new(0.35,Enum.EasingStyle.Quint,Enum.EasingDirection.Out)
        ts:Create(card,i,{Position=UDim2.new(1,-260,0,20)}):Play()

        task.delay(5,function()
            local fi = TweenInfo.new(0.4,Enum.EasingStyle.Quint,Enum.EasingDirection.In)
            ts:Create(card,fi,{Position=UDim2.new(1,10,0,20)}):Play()
            task.wait(0.45); sg:Destroy()
        end)
    end)
end

showUI()
print("[fullbypass] all layers armed — loadstring dump active")
