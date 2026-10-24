-- lang: Lua, file: fe_tool.lua, target: Xeno / Roblox executors
-- FE tool — executor GUI with normal + require script execution

local Players    = game:GetService("Players")
local lp         = Players.LocalPlayer
local CoreGui    = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")

-- ── FE utilities ──────────────────────────────────────────────────────────
local env = getfenv and getfenv() or {}

local function safeExec(src)
    local fn, err = loadstring(src)
    if not fn then return false, "Syntax: "..tostring(err) end
    local ok, res = pcall(fn)
    if not ok then return false, "Runtime: "..tostring(res) end
    return true, tostring(res or "ok")
end

local function safeRequire(id)
    id = tonumber(id)
    if not id then return false, "invalid id" end
    local ok, res = pcall(function()
        return require(id)
    end)
    if not ok then return false, tostring(res) end
    return true, "required: "..tostring(res)
end

-- ── GUI ───────────────────────────────────────────────────────────────────
local sg = Instance.new("ScreenGui")
sg.Name = "FETool"; sg.ResetOnSpawn = false
sg.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
sg.Parent = (gethui and gethui()) or CoreGui

-- main window
local win = Instance.new("Frame", sg)
win.Size = UDim2.new(0, 420, 0, 340)
win.Position = UDim2.new(0.5, -210, 0.5, -170)
win.BackgroundColor3 = Color3.fromRGB(14, 14, 20)
win.BorderSizePixel = 0; win.Active = true; win.Draggable = true
Instance.new("UICorner", win).CornerRadius = UDim.new(0, 12)

local stroke = Instance.new("UIStroke", win)
stroke.Color = Color3.fromRGB(40, 40, 60); stroke.Thickness = 1.2

-- title bar
local bar = Instance.new("Frame", win)
bar.Size = UDim2.new(1, 0, 0, 36)
bar.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
bar.BorderSizePixel = 0
Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 12)

local barFix = Instance.new("Frame", bar)
barFix.Size = UDim2.new(1, 0, 0.5, 0)
barFix.Position = UDim2.new(0, 0, 0.5, 0)
barFix.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
barFix.BorderSizePixel = 0

local title = Instance.new("TextLabel", bar)
title.Size = UDim2.new(1, -40, 1, 0)
title.Position = UDim2.new(0, 12, 0, 0)
title.BackgroundTransparency = 1
title.Text = "⚡ FE Tool"
title.Font = Enum.Font.GothamBold; title.TextSize = 14
title.TextColor3 = Color3.fromRGB(220, 220, 240)
title.TextXAlignment = Enum.TextXAlignment.Left

-- close button
local closeBtn = Instance.new("TextButton", bar)
closeBtn.Size = UDim2.new(0, 24, 0, 24)
closeBtn.Position = UDim2.new(1, -30, 0.5, -12)
closeBtn.BackgroundColor3 = Color3.fromRGB(180, 50, 50)
closeBtn.BorderSizePixel = 0; closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold; closeBtn.TextSize = 16
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(1, 0)
closeBtn.MouseButton1Click:Connect(function() sg:Destroy() end)

-- tabs
local tabFrame = Instance.new("Frame", win)
tabFrame.Size = UDim2.new(1, -20, 0, 28)
tabFrame.Position = UDim2.new(0, 10, 0, 44)
tabFrame.BackgroundTransparency = 1

local function makeTab(text, pos, active)
    local btn = Instance.new("TextButton", tabFrame)
    btn.Size = UDim2.new(0, 90, 1, 0)
    btn.Position = UDim2.new(0, pos, 0, 0)
    btn.BackgroundColor3 = active and Color3.fromRGB(40,40,120) or Color3.fromRGB(25,25,35)
    btn.BorderSizePixel = 0; btn.Text = text
    btn.Font = Enum.Font.GothamBold; btn.TextSize = 12
    btn.TextColor3 = Color3.fromRGB(200, 200, 220)
    Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
    return btn
end

local tabScript  = makeTab("Script", 0, true)
local tabRequire = makeTab("Require", 96, false)

-- script area
local scriptBox = Instance.new("TextBox", win)
scriptBox.Size = UDim2.new(1, -20, 0, 170)
scriptBox.Position = UDim2.new(0, 10, 0, 80)
scriptBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
scriptBox.BorderSizePixel = 0
scriptBox.Text = "-- paste script here"
scriptBox.Font = Enum.Font.Code; scriptBox.TextSize = 13
scriptBox.TextColor3 = Color3.fromRGB(200, 220, 255)
scriptBox.MultiLine = true; scriptBox.ClearTextOnFocus = false
scriptBox.TextXAlignment = Enum.TextXAlignment.Left
scriptBox.TextYAlignment = Enum.TextYAlignment.Top
Instance.new("UICorner", scriptBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", scriptBox).Color = Color3.fromRGB(40,40,70)

-- require area (hidden by default)
local reqBox = Instance.new("TextBox", win)
reqBox.Size = UDim2.new(1, -20, 0, 40)
reqBox.Position = UDim2.new(0, 10, 0, 80)
reqBox.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
reqBox.BorderSizePixel = 0
reqBox.Text = "module id / asset id"
reqBox.Font = Enum.Font.GothamBold; reqBox.TextSize = 13
reqBox.TextColor3 = Color3.fromRGB(200, 220, 255)
reqBox.ClearTextOnFocus = false
Instance.new("UICorner", reqBox).CornerRadius = UDim.new(0, 8)
Instance.new("UIStroke", reqBox).Color = Color3.fromRGB(40,40,70)
reqBox.Visible = false

-- output
local output = Instance.new("TextLabel", win)
output.Size = UDim2.new(1, -20, 0, 36)
output.Position = UDim2.new(0, 10, 0, 258)
output.BackgroundColor3 = Color3.fromRGB(18, 18, 26)
output.BorderSizePixel = 0
output.Text = "ready."
output.Font = Enum.Font.Code; output.TextSize = 12
output.TextColor3 = Color3.fromRGB(140, 220, 140)
output.TextXAlignment = Enum.TextXAlignment.Left
output.TextWrapped = true
Instance.new("UICorner", output).CornerRadius = UDim.new(0, 6)
Instance.new("UIPadding", output).PaddingLeft = UDim.new(0, 8)

local function setOutput(txt, ok)
    output.Text = txt
    output.TextColor3 = ok and Color3.fromRGB(80,220,100) or Color3.fromRGB(220,80,80)
end

-- buttons row
local function makeBtn(text, xpos, color)
    local b = Instance.new("TextButton", win)
    b.Size = UDim2.new(0, 118, 0, 28)
    b.Position = UDim2.new(0, xpos, 0, 302)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0; b.Text = text
    b.Font = Enum.Font.GothamBold; b.TextSize = 13
    b.TextColor3 = Color3.fromRGB(255,255,255)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 7)
    return b
end

local execBtn  = makeBtn("▶  Execute",  10, Color3.fromRGB(30,100,220))
local clearBtn = makeBtn("⌫  Clear",   134, Color3.fromRGB(40,40,60))
local copyBtn  = makeBtn("⎘  Copy",    258, Color3.fromRGB(40,60,40))

-- ── tab logic ─────────────────────────────────────────────────────────────
local mode = "script"

tabScript.MouseButton1Click:Connect(function()
    mode = "script"
    scriptBox.Visible = true; reqBox.Visible = false
    tabScript.BackgroundColor3 = Color3.fromRGB(40,40,120)
    tabRequire.BackgroundColor3 = Color3.fromRGB(25,25,35)
end)

tabRequire.MouseButton1Click:Connect(function()
    mode = "require"
    scriptBox.Visible = false; reqBox.Visible = true
    tabRequire.BackgroundColor3 = Color3.fromRGB(40,40,120)
    tabScript.BackgroundColor3 = Color3.fromRGB(25,25,35)
end)

-- ── button logic ──────────────────────────────────────────────────────────
execBtn.MouseButton1Click:Connect(function()
    if mode == "script" then
        local ok, res = safeExec(scriptBox.Text)
        setOutput((ok and "✓ " or "✗ ")..res, ok)
    else
        local ok, res = safeRequire(reqBox.Text)
        setOutput((ok and "✓ " or "✗ ")..res, ok)
    end
end)

clearBtn.MouseButton1Click:Connect(function()
    scriptBox.Text = ""; reqBox.Text = ""
    setOutput("cleared.", true)
end)

copyBtn.MouseButton1Click:Connect(function()
    local src = mode == "script" and scriptBox.Text or reqBox.Text
    if setclipboard then setclipboard(src)
    elseif toclipboard then toclipboard(src) end
    setOutput("copied.", true)
end)

print("[FE Tool] loaded")
