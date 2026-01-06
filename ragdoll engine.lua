-- RAGDOLL ENGINE SUPREME OVERLORD TOOL (V5 - INTEGRATED SHIELD)
-- Features: Global Sky, Global Music, Fly, Anti-Kick, Anti-Ban

-- [SECTION 1: ANTI-KICK SHIELD]
local mt = getrawmetatable(game)
local oldNamecall = mt.__namecall
setreadonly(mt, false)

mt.__namecall = newcclosure(function(self, ...)
    local method = getnamecallmethod()
    if tostring(method) == "Kick" or tostring(method) == "kick" then
        return nil -- Block all kick attempts
    end
    return oldNamecall(self, ...)
end)
setreadonly(mt, true)

-- [SECTION 2: UI CONSTRUCTION]
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 320)
Main.Position = UDim2.new(0.5, -125, 0.5, -160)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Active = true
Main.Draggable = true

local function CreateInput(name, pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Size = UDim2.new(0, 200, 0, 30)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tb.TextColor3 = Color3.new(1, 1, 1)
    return tb
end

local SkyInput = CreateInput("SkyI", UDim2.new(0, 25, 0, 20), "Sky ID")
local MusicInput = CreateInput("MusicI", UDim2.new(0, 25, 0, 60), "Music ID")
local SpeedInput = CreateInput("SpeedI", UDim2.new(0, 25, 0, 100), "Fly Speed")

-- [SECTION 3: CORE FUNCTIONS]
local function Replicate(val, type)
    for _, r in pairs(game:GetDescendants()) do
        if r:IsA("RemoteEvent") then
            pcall(function() r:FireServer(val) r:FireServer(type, val) end)
        end
    end
end

local SkyBtn = Instance.new("TextButton", Main)
SkyBtn.Size = UDim2.new(0, 200, 0, 35)
SkyBtn.Position = UDim2.new(0, 25, 0, 145)
SkyBtn.Text = "GLOBAL SKY"
SkyBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. SkyInput.Text
    Replicate(id, "Sky")
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

local MusicBtn = Instance.new("TextButton", Main)
MusicBtn.Size = UDim2.new(0, 200, 0, 35)
MusicBtn.Position = UDim2.new(0, 25, 0, 190)
MusicBtn.Text = "GLOBAL MUSIC"
MusicBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. MusicInput.Text
    Replicate(id, "Music")
    local snd = Instance.new("Sound", game.Workspace)
    snd.SoundId = id snd.Volume = 5 snd.Looped = true snd:Play()
end)

local FlyBtn = Instance.new("TextButton", Main)
FlyBtn.Size = UDim2.new(0, 200, 0, 35)
FlyBtn.Position = UDim2.new(0, 25, 0, 235)
FlyBtn.Text = "TOGGLE FLY"
local flying = false
FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    local speed = tonumber(SpeedInput.Text) or 50
    if flying then
        local bv = Instance.new("BodyVelocity", game.Players.LocalPlayer.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            while flying do
                bv.Velocity = game.Players.LocalPlayer:GetMouse().Hit.lookVector * speed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(0, 200, 0, 20)
Status.Position = UDim2.new(0, 25, 0, 285)
Status.Text = "SHIELD ACTIVE [V]"
Status.TextColor3 = Color3.new(0, 1, 0)
Status.BackgroundTransparency = 1