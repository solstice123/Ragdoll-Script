-- RAGDOLL ENGINE SUPREME OVERLORD (V7 - EMERGENCY FIX)
-- Полная интеграция: Anti-Kick, Sky, Music, Fly + Исправленный GUI

repeat task.wait() until game:IsLoaded()

-- [SECTION 1: FAIL-SAFE HOOKING]
-- Оборачиваем в pcall, чтобы ошибки защиты не мешали запуску меню
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if (tostring(method) == "Kick" or tostring(method) == "kick") and self == game.Players.LocalPlayer then
            return nil 
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)

-- [SECTION 2: ROBUST UI CONSTRUCTION]
-- Используем альтернативный метод вставки GUI
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OverlordMenu_" .. math.random(100, 999)
-- Пытаемся вставить в CoreGui, если не выйдет - в PlayerGui
local success, err = pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not success then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 340)
Main.Position = UDim2.new(0.5, -130, 0.5, -170)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.BorderSizePixel = 2
Main.Active = true
Main.Draggable = true

local function CreateInput(pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Size = UDim2.new(0, 220, 0, 35)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.SourceSansBold
    tb.TextSize = 14
    return tb
end

local SkyInput = CreateInput(UDim2.new(0, 20, 0, 20), "Sky ID (Image)")
local MusicInput = CreateInput(UDim2.new(0, 20, 0, 65), "Music ID (Audio)")
local SpeedInput = CreateInput(UDim2.new(0, 20, 0, 110), "Fly Speed (50-500)")

local function Replicate(val, type)
    for _, r in pairs(game:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            pcall(function() r:FireServer(val) end)
        end
    end
end

local function AddBtn(pos, text, color, func)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 220, 0, 40)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 16
    btn.MouseButton1Click:Connect(func)
end

AddBtn(UDim2.new(0, 20, 0, 160), "ACTIVATE GLOBAL SKY", Color3.fromRGB(40, 80, 40), function()
    local id = "rbxassetid://" .. SkyInput.Text
    Replicate(id, "Sky")
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

AddBtn(UDim2.new(0, 20, 0, 210), "ACTIVATE GLOBAL MUSIC", Color3.fromRGB(40, 40, 80), function()
    local id = "rbxassetid://" .. MusicInput.Text
    Replicate(id, "Music")
    local snd = Instance.new("Sound", game.Workspace)
    snd.SoundId = id snd.Volume = 8 snd.Looped = true snd:Play()
end)

local flying = false
AddBtn(UDim2.new(0, 20, 0, 260), "TOGGLE FLY", Color3.fromRGB(80, 40, 40), function()
    flying = not flying
    local speed = tonumber(SpeedInput.Text) or 50
    local lp = game.Players.LocalPlayer
    if flying then
        local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        bv.Name = "OverlordFly"
        bv.MaxForce = Vector3.new(9e9, 9e9, 9e9)
        task.spawn(function()
            while flying do
                bv.Velocity = lp:GetMouse().Hit.lookVector * speed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

print("Menu Loaded Successfully.")