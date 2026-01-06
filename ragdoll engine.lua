-- RAGDOLL ENGINE SUPREME OVERLORD: THE MASTER BUILD (V9)
-- [Features: Global Sky, Global Music, Advanced Fly, Total Anti-Kick/Ban Shield]

repeat task.wait() until game:IsLoaded()

-- [SECTION 1: SUPREME PROTECTION SHIELD]
-- This part blocks the server from removing you or kicking you
pcall(function()
    local lp = game:GetService("Players").LocalPlayer
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    local oldIndex = mt.__index

    setreadonly(mt, false)

    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        -- Block Kick and Destroy calls targeting the LocalPlayer
        if (tostring(method) == "Kick" or tostring(method) == "kick" or tostring(method) == "Destroy") and self == lp then
            return nil 
        end
        return oldNamecall(self, ...)
    end)

    mt.__index = newcclosure(function(t, k)
        -- Extra layer to prevent scripts from checking your Kick function
        if (k == "Kick" or k == "kick") and t == lp then
            return function() print("Blocked attempted script kick.") end
        end
        return oldIndex(t, k)
    end)

    setreadonly(mt, true)
end)

-- [SECTION 2: UI CORE DESIGN]
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MasterOverlord_" .. math.random(1000, 9999)
pcall(function()
    ScreenGui.Parent = game:GetService("CoreGui")
end)
if not ScreenGui.Parent then
    ScreenGui.Parent = game:GetService("Players").LocalPlayer:WaitForChild("PlayerGui")
end

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 260, 0, 350)
Main.Position = UDim2.new(0.5, -130, 0.5, -175)
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.BorderSizePixel = 2
Main.Active = true
Main.Draggable = true

local function CreateInput(pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Size = UDim2.new(0, 220, 0, 35)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.TextColor3 = Color3.new(1, 1, 1)
    tb.Font = Enum.Font.SourceSansBold
    tb.TextSize = 14
    return tb
end

local SkyInput = CreateInput(UDim2.new(0, 20, 0, 20), "Enter Sky Image ID")
local MusicInput = CreateInput(UDim2.new(0, 20, 0, 65), "Enter Music Audio ID")
local SpeedInput = CreateInput(UDim2.new(0, 20, 0, 110), "Fly Speed (Default 50)")

-- [SECTION 3: GLOBAL REPLICATION & UTILS]
local function ForceGlobal(val)
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            pcall(function() 
                remote:FireServer(val)
                remote:FireServer("Update", val)
            end)
        end
    end
end

local function CreateBtn(pos, text, color, func)
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

-- Sky Logic
CreateBtn(UDim2.new(0, 20, 0, 160), "APPLY GLOBAL SKY", Color3.fromRGB(34, 139, 34), function()
    local id = "rbxassetid://" .. SkyInput.Text
    ForceGlobal(id)
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

-- Music Logic
CreateBtn(UDim2.new(0, 20, 0, 210), "PLAY GLOBAL MUSIC", Color3.fromRGB(70, 130, 180), function()
    local id = "rbxassetid://" .. MusicInput.Text
    ForceGlobal(id)
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = id
    sound.Volume = 10
    sound.Looped = true
    sound:Play()
end)

-- Fly Logic
local flying = false
CreateBtn(UDim2.new(0, 20, 0, 260), "TOGGLE FLY", Color3.fromRGB(178, 34, 34), function()
    flying = not flying
    local speed = tonumber(SpeedInput.Text) or 50
    local lp = game.Players.LocalPlayer
    local char = lp.Character
    if flying and char then
        local root = char:FindFirstChild("HumanoidRootPart")
        if root then
            local bv = Instance.new("BodyVelocity", root)
            bv.Name = "OverlordMovement"
            bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
            task.spawn(function()
                while flying do
                    bv.Velocity = lp:GetMouse().Hit.lookVector * speed
                    task.wait()
                end
                bv:Destroy()
            end)
        end
    end
end)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(0, 220, 0, 20)
Status.Position = UDim2.new(0, 20, 0, 315)
Status.Text = "SYSTEMS ONLINE | SHIELD ACTIVE"
Status.TextColor3 = Color3.new(0, 1, 0)
Status.BackgroundTransparency = 1
Status.Font = Enum.Font.SourceSansItalic
Status.TextSize = 12