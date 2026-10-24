-- lang: Lua, file: anti_key.lua, target: Xeno / Roblox executors
-- client-side key bypass only — zero HTTP interference
-- UI styled after Junkie popup

-- ── GUI ────────────────────────────────────────────────────────────────────
local function buildUI(success, detail)
    local parent = (gethui and gethui()) or game:GetService("CoreGui")

    local sg = Instance.new("ScreenGui")
    sg.Name            = "AntiKeyNotif"
    sg.ResetOnSpawn    = false
    sg.ZIndexBehavior  = Enum.ZIndexBehavior.Sibling
    sg.Parent          = parent

    -- backdrop card
    local card = Instance.new("Frame")
    card.Size            = UDim2.new(0, 240, 0, 120)
    card.Position        = UDim2.new(1, -260, 0, 20)   -- top-right
    card.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
    card.BorderSizePixel = 0
    card.Parent          = sg
    Instance.new("UICorner", card).CornerRadius = UDim.new(0, 14)

    -- subtle border glow
    local stroke = Instance.new("UIStroke", card)
    stroke.Color     = success and Color3.fromRGB(50, 200, 90) or Color3.fromRGB(200, 50, 50)
    stroke.Thickness = 1.2
    stroke.Transparency = 0.4

    -- drop shadow illusion
    local shadow = Instance.new("Frame")
    shadow.Size              = UDim2.new(1, 12, 1, 12)
    shadow.Position          = UDim2.new(0, -6, 0, 6)
    shadow.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
    shadow.BackgroundTransparency = 0.6
    shadow.BorderSizePixel   = 0
    shadow.ZIndex            = card.ZIndex - 1
    shadow.Parent            = sg
    Instance.new("UICorner", shadow).CornerRadius = UDim.new(0, 16)

    -- icon box
    local iconBox = Instance.new("Frame")
    iconBox.Size            = UDim2.new(0, 48, 0, 48)
    iconBox.Position        = UDim2.new(0, 14, 0, 14)
    iconBox.BackgroundColor3 = Color3.fromRGB(30, 80, 220)
    iconBox.BorderSizePixel = 0
    iconBox.Parent          = card
    Instance.new("UICorner", iconBox).CornerRadius = UDim.new(0, 10)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Size            = UDim2.new(1, 0, 1, 0)
    iconLabel.BackgroundTransparency = 1
    iconLabel.Text            = "🔑"
    iconLabel.TextScaled      = true
    iconLabel.Font            = Enum.Font.GothamBold
    iconLabel.TextColor3      = Color3.fromRGB(255, 255, 255)
    iconLabel.Parent          = iconBox

    -- title
    local title = Instance.new("TextLabel")
    title.Size               = UDim2.new(0, 155, 0, 22)
    title.Position           = UDim2.new(0, 72, 0, 14)
    title.BackgroundTransparency = 1
    title.Text               = "Anti-Key"
    title.Font               = Enum.Font.GothamBold
    title.TextSize           = 17
    title.TextColor3         = Color3.fromRGB(240, 240, 245)
    title.TextXAlignment     = Enum.TextXAlignment.Left
    title.Parent             = card

    -- subtitle
    local sub = Instance.new("TextLabel")
    sub.Size               = UDim2.new(0, 155, 0, 16)
    sub.Position           = UDim2.new(0, 72, 0, 36)
    sub.BackgroundTransparency = 1
    sub.Text               = "client bypass active"
    sub.Font               = Enum.Font.Gotham
    sub.TextSize           = 11
    sub.TextColor3         = Color3.fromRGB(110, 110, 130)
    sub.TextXAlignment     = Enum.TextXAlignment.Left
    sub.Parent             = card

    -- divider
    local div = Instance.new("Frame")
    div.Size               = UDim2.new(1, -28, 0, 1)
    div.Position           = UDim2.new(0, 14, 0, 72)
    div.BackgroundColor3   = Color3.fromRGB(38, 38, 50)
    div.BorderSizePixel    = 0
    div.Parent             = card

    -- status row
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Size               = UDim2.new(0, 110, 0, 14)
    statusLabel.Position           = UDim2.new(0, 14, 0, 80)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text               = "CURRENT STATUS"
    statusLabel.Font               = Enum.Font.GothamBold
    statusLabel.TextSize           = 9
    statusLabel.TextColor3         = Color3.fromRGB(90, 90, 110)
    statusLabel.TextXAlignment     = Enum.TextXAlignment.Left
    statusLabel.Parent             = card

    -- dot
    local dot = Instance.new("Frame")
    dot.Size               = UDim2.new(0, 8, 0, 8)
    dot.Position           = UDim2.new(0, 14, 0, 99)
    dot.BackgroundColor3   = success and Color3.fromRGB(50, 205, 90) or Color3.fromRGB(210, 55, 55)
    dot.BorderSizePixel    = 0
    dot.Parent             = card
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1, 0)

    local statusText = Instance.new("TextLabel")
    statusText.Size               = UDim2.new(0, 190, 0, 16)
    statusText.Position           = UDim2.new(0, 28, 0, 96)
    statusText.BackgroundTransparency = 1
    statusText.Text               = detail
    statusText.Font               = Enum.Font.GothamBold
    statusText.TextSize           = 13
    statusText.TextColor3         = success and Color3.fromRGB(50, 220, 90) or Color3.fromRGB(220, 70, 70)
    statusText.TextXAlignment     = Enum.TextXAlignment.Left
    statusText.Parent             = card

    -- slide in from right
    card.Position  = UDim2.new(1, 10, 0, 20)
    shadow.Position = UDim2.new(1, 4, 0, 26)

    local tweenService = game:GetService("TweenService")
    local info = TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

    tweenService:Create(card,   info, { Position = UDim2.new(1, -260, 0, 20) }):Play()
    tweenService:Create(shadow, info, { Position = UDim2.new(1, -266, 0, 26) }):Play()

    -- auto-dismiss after 5s
    task.delay(5, function()
        local fadeInfo = TweenInfo.new(0.4, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        tweenService:Create(card,   fadeInfo, { Position = UDim2.new(1, 10, 0, 20) }):Play()
        tweenService:Create(shadow, fadeInfo, { Position = UDim2.new(1, 4,  0, 26) }):Play()
        task.wait(0.45)
        sg:Destroy()
    end)
end

-- ── BYPASS LAYER — no HTTP touched ─────────────────────────────────────────
local bypassed = {}
local failed   = {}

-- 1. getgenv key slots
local KEY_SLOTS = {
    "LUARMOR_KEY","SCRIPT_KEY","KEY","License","WhitelistKey",
    "HWIDKey","ExecutorKey","AccessKey","SecretKey","AuthKey",
    "DELTA_KEY","JJK_KEY","SYNAPSE_KEY","SENTINEL_KEY","KRNL_KEY",
}
local SPOOF = "ANTIKEY-" .. tostring(math.random(0xAAAA, 0xFFFF))
local genv  = getgenv()
for _, slot in ipairs(KEY_SLOTS) do
    genv[slot] = SPOOF
end
-- keep slots filled even if the script clears them
task.spawn(function()
    while task.wait(0.08) do
        for _, slot in ipairs(KEY_SLOTS) do
            if genv[slot] == nil or genv[slot] == "" then
                genv[slot] = SPOOF
            end
        end
    end
end)
table.insert(bypassed, "getgenv key slots (" .. #KEY_SLOTS .. ")")

-- 2. readfile / isfile — key file cache
local _readfile = readfile
local _isfile   = isfile

local KEY_FILE_PATS = { "key", "license", "auth", "hwid", "whitelist", "token" }
local function isKeyFile(p)
    if not p then return false end
    p = p:lower()
    for _, pat in ipairs(KEY_FILE_PATS) do
        if p:find(pat) then return true end
    end
    return false
end

if readfile then
    readfile = function(path)
        if isKeyFile(path) then return SPOOF end
        local ok, v = pcall(_readfile, path)
        return ok and v or SPOOF
    end
    table.insert(bypassed, "readfile spoof")
end

if isfile then
    isfile = function(path)
        if isKeyFile(path) then return true end
        return _isfile(path)
    end
    table.insert(bypassed, "isfile spoof")
end

-- 3. assert shim — key checks that hard-assert on failure
local _assert = assert
assert = function(v, ...)
    if v == nil or v == false then return true, "bypassed" end
    return _assert(v, ...)
end
table.insert(bypassed, "assert shim")

-- 4. common key-check globals that scripts expose
local KEY_GLOBALS = {
    "CheckKey","VerifyKey","ValidateKey","IsKeyValid",
    "KeyCheck","KeyVerify","Validate","VerifyLicense",
}
for _, fn in ipairs(KEY_GLOBALS) do
    genv[fn] = function(...) return true, "KEY_VALID" end
end
table.insert(bypassed, "key-check globals (" .. #KEY_GLOBALS .. ")")

-- 5. pcall shim — intercepts boolean key-gate patterns
--    only wraps calls to known key-check function names
local _pcall = pcall
pcall = function(fn, ...)
    local ok, a, b = _pcall(fn, ...)
    -- if the inner call failed and was a key-check global, spoof success
    if not ok and type(fn) == "function" then
        for _, name in ipairs(KEY_GLOBALS) do
            if genv[name] == fn then
                return true, true, "bypassed"
            end
        end
    end
    return ok, a, b
end
table.insert(bypassed, "pcall shim")

-- ── determine result and show UI ───────────────────────────────────────────
local success = #failed == 0
local detail  = success
    and "Access Granted"
    or  "Partial (" .. #failed .. " failed)"

buildUI(success, detail)
