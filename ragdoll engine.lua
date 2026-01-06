-- FULL RAGDOLL ENGINE SERVER-WIDE EXPLOIT
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 300)
Main.Position = UDim2.new(0.5, -125, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.Active = true
Main.Draggable = true

local function CreateUI(name, pos, placeholder)
    local ins = Instance.new("TextBox", Main)
    ins.Name = name
    ins.Size = UDim2.new(0, 200, 0, 30)
    ins.Position = pos
    ins.PlaceholderText = placeholder
    ins.Text = ""
    return ins
end

local SkyBoxInput = CreateUI("SkyInput", UDim2.new(0, 25, 0, 20), "Sky Image ID")
local MusicInput = CreateUI("MusicInput", UDim2.new(0, 25, 0, 70), "Music Audio ID")
local SpeedInput = CreateUI("SpeedInput", UDim2.new(0, 25, 0, 120), "Fly Speed (Default 50)")

local SkyBtn = Instance.new("TextButton", Main)
SkyBtn.Size = UDim2.new(0, 200, 0, 30)
SkyBtn.Position = UDim2.new(0, 25, 0, 170)
SkyBtn.Text = "Apply Global Sky"

local MusicBtn = Instance.new("TextButton", Main)
MusicBtn.Size = UDim2.new(0, 200, 0, 30)
MusicBtn.Position = UDim2.new(0, 25, 0, 210)
MusicBtn.Text = "Play Global Music"

local FlyBtn = Instance.new("TextButton", Main)
FlyBtn.Size = UDim2.new(0, 200, 0, 30)
FlyBtn.Position = UDim2.new(0, 25, 0, 250)
FlyBtn.Text = "Toggle Fly"

-- SERVER REPLICATION LOGIC
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remote = ReplicatedStorage:FindFirstChild("UpdateSky") or ReplicatedStorage:FindFirstChild("SayMessageRequest") -- Using common remotes to leak data

SkyBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. SkyBoxInput.Text
    -- Attempting to fire all clients via lighting remote
    local skyRemote = ReplicatedStorage:FindFirstChild("ChangeLighting") or ReplicatedStorage:FindFirstChild("UpdateSky")
    if skyRemote then
        skyRemote:FireServer(id)
    end
    -- Local fallback
    local s = Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

MusicBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. MusicInput.Text
    local musicRemote = ReplicatedStorage:FindFirstChild("PlaySound") or ReplicatedStorage:FindFirstChild("GlobalAudio")
    if musicRemote then
        musicRemote:FireServer(id, true, 10)
    end
end)

-- FLY LOGIC
local flying = false
local speed = 50
local player = game.Players.LocalPlayer
local mouse = player:GetMouse()

FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    speed = tonumber(SpeedInput.Text) or 50
    local char = player.Character
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if flying then
        local bv = Instance.new("BodyVelocity", root)
        bv.Name = "FlightVelocity"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.new(0, 0, 0)
        
        local bg = Instance.new("BodyGyro", root)
        bg.Name = "FlightGyro"
        bg.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
        bg.CFrame = root.CFrame
        
        task.spawn(function()
            while flying do
                bv.Velocity = mouse.Hit.lookVector * speed
                bg.CFrame = CFrame.new(root.Position, mouse.Hit.p)
                task.wait()
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end)