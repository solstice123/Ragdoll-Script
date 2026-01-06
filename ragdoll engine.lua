-- RAGDOLL ENGINE SUPREME CONTROL (DYNAMIC ID EDITION)
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 300)
Main.Position = UDim2.new(0.5, -125, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.BorderSizePixel = 2
Main.Active = true
Main.Draggable = true

local function CreateInput(name, pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Name = name
    tb.Size = UDim2.new(0, 200, 0, 35)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    tb.TextColor3 = Color3.new(1, 1, 1)
    return tb
end

local function CreateBtn(name, pos, text, color)
    local btn = Instance.new("TextButton", Main)
    btn.Name = name
    btn.Size = UDim2.new(0, 200, 0, 35)
    btn.Position = pos
    btn.Text = text
    btn.BackgroundColor3 = color
    btn.TextColor3 = Color3.new(1, 1, 1)
    return btn
end

-- UI Elements
local SkyInput = CreateInput("SkyInput", UDim2.new(0, 25, 0, 20), "Enter Sky ID here...")
local MusicInput = CreateInput("MusicInput", UDim2.new(0, 25, 0, 65), "Enter Music ID here...")
local SpeedInput = CreateInput("SpeedInput", UDim2.new(0, 25, 0, 110), "Fly Speed (e.g. 100)")

local SkyBtn = CreateBtn("SkyBtn", UDim2.new(0, 25, 0, 160), "SET GLOBAL SKY", Color3.fromRGB(50, 100, 50))
local MusicBtn = CreateBtn("MusicBtn", UDim2.new(0, 25, 0, 205), "SET GLOBAL MUSIC", Color3.fromRGB(50, 50, 100))
local FlyBtn = CreateBtn("FlyBtn", UDim2.new(0, 25, 0, 250), "TOGGLE FLY", Color3.fromRGB(100, 50, 50))

-- LOGIC
local ReplicatedStorage = game:GetService("ReplicatedStorage")

SkyBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. SkyInput.Text
    -- Replication Hunt
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("sky") or v.Name:lower():find("lighting")) then
            v:FireServer(id)
        end
    end
    -- Local Visual
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

MusicBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. MusicInput.Text
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("RemoteEvent") and (v.Name:lower():find("sound") or v.Name:lower():find("music")) then
            v:FireServer(id, true, 10)
        end
    end
    -- Local Playback
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = id sound.Looped = true sound.Volume = 5 sound:Play()
end)

local flying = false
local speed = 50
FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    speed = tonumber(SpeedInput.Text) or 50
    local p = game.Players.LocalPlayer
    local c = p.Character
    if flying then
        local bv = Instance.new("BodyVelocity", c.HumanoidRootPart)
        bv.Name = "FlyV" bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            while flying do
                bv.Velocity = p:GetMouse().Hit.lookVector * speed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)