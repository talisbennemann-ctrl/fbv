-- lang: Lua, file: luarmor_log.lua, target: Xeno / Roblox executors
local _old = (syn and syn.request) or request or http_request
local log = {}

local function flash(txt)
    pcall(function()
        local sg = Instance.new("ScreenGui", (gethui and gethui()) or game:GetService("CoreGui"))
        sg.ResetOnSpawn = false
        local f = Instance.new("Frame", sg)
        f.Size = UDim2.new(0,180,0,28); f.Position = UDim2.new(1,-200,0,16)
        f.BackgroundColor3 = Color3.fromRGB(18,18,24); f.BorderSizePixel = 0
        Instance.new("UICorner",f).CornerRadius = UDim.new(0,8)
        local t = Instance.new("TextLabel",f)
        t.Size = UDim2.new(1,0,1,0); t.BackgroundTransparency = 1
        t.Text = txt; t.Font = Enum.Font.GothamBold; t.TextSize = 12
        t.TextColor3 = Color3.fromRGB(50,220,90)
        task.delay(2, function() sg:Destroy() end)
    end)
end

getgenv().request = newcclosure(function(req)
    if type(req) == "table" and req.Url and req.Url:find("luarmor") then
        local res = _old(req)
        table.insert(log, "SENT: "..(req.Body or "nil").."\nRESP: "..(res and res.Body or "nil"))
        local out = table.concat(log, "\n---\n")
        if setclipboard then setclipboard(out) elseif toclipboard then toclipboard(out) end
        flash("✅ copied")
        return res
    end
    return _old(req)
end)
getgenv().http_request = getgenv().request
if syn then syn.request = getgenv().request end
pcall(function() setreadonly(http,false); http.request=getgenv().request; setreadonly(http,true) end)
