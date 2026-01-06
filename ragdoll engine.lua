-- RAGDOLL ENGINE SUPREME OVERLORD (V6 - GOD-MODE SHIELD)
-- Интегрированная защита от Kick, Ban, Destroy и Script-Removal

-- [SECTION 1: DEEP SYSTEM HOOKING]
local lp = game:GetService("Players").LocalPlayer
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
local oldIndex = mt.__index

setreadonly(mt, false)

-- Перехват всех попыток вызова методов удаления
mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    -- Блокируем Kick, Destroy (если цель - игрок) и Remove
    if (tostring(method) == "Kick" or tostring(method) == "kick" or tostring(method) == "Destroy" or tostring(method) == "Remove") and self == lp then
        warn("ПОПЫТКА УДАЛЕНИЯ ЗАБЛОКИРОВАНА: " .. tostring(method))
        return nil 
    end
    return oldNamecall(self, unpack(args))
end)

-- Защита свойств игрока от изменения скриптами (Anti-Ban/Anti-Freeze)
mt.__newindex = newcclosure(function(t, k, v)
    if t == lp and (k == "Parent" or k == "Character") and v == nil then
        return nil -- Запрещаем скриптам отвязывать игрока от игры
    end
    return oldIndex(t, k, v)
end)

setreadonly(mt, true)

-- [SECTION 2: UI & MASTER FUNCTIONS]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0.5, -125, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.Active = true
Main.Draggable = true

local function CreateInput(pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Size = UDim2.new(0, 200, 0, 30)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.TextColor3 = Color3.new(1, 1, 1)
    return tb
end

local SkyInput = CreateInput(UDim2.new(0, 25, 0, 20), "Sky ID")
local MusicInput = CreateInput(UDim2.new(0, 25, 0, 60), "Music ID")
local SpeedInput = CreateInput(UDim2.new(0, 25, 0, 100), "Fly Speed")

local function Replicate(val, type)
    for _, r in pairs(game:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            pcall(function() r:FireServer(val) r:FireServer(type, val) end)
        end
    end
end

-- Кнопки управления
local function AddBtn(pos, text, func)
    local btn = Instance.new("TextButton", Main)
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.MouseButton1Click:Connect(func)
end

AddBtn(UDim2.new(0, 25, 0, 145), "FORCE SKY", function()
    local id = "rbxassetid://" .. SkyInput.Text
    Replicate(id, "Sky")
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

AddBtn(UDim2.new(0, 25, 0, 190), "FORCE MUSIC", function()
    local id = "rbxassetid://" .. MusicInput.Text
    Replicate(id, "Music")
    local snd = Instance.new("Sound", game.Workspace)
    snd.SoundId = id snd.Volume = 5 snd.Looped = true snd:Play()
end)

local flying = false
AddBtn(UDim2.new(0, 25, 0, 235), "TOGGLE FLY", function()
    flying = not flying
    local speed = tonumber(SpeedInput.Text) or 50
    if flying then
        local bv = Instance.new("BodyVelocity", lp.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            while flying do
                bv.Velocity = lp:GetMouse().Hit.lookVector * speed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(0, 200, 0, 20)
Status.Position = UDim2.new(0, 25, 0, 285)
Status.Text = "TOTAL IMMUNITY ACTIVE"
Status.TextColor3 = Color3.new(1, 0, 0)
Status.BackgroundTransparency = 1ы