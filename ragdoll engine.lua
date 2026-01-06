-- RAGDOLL ENGINE - BRUTE FORCE SERVER REPLICATION
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 250, 0, 300)
Main.Position = UDim2.new(0.5, -125, 0.5, -150)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
Main.Active = true
Main.Draggable = true

local function CreateInput(name, pos, placeholder)
    local tb = Instance.new("TextBox", Main)
    tb.Size = UDim2.new(0, 200, 0, 35)
    tb.Position = pos
    tb.PlaceholderText = placeholder
    tb.Text = ""
    tb.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tb.TextColor3 = Color3.new(1, 1, 1)
    return tb
end

local SkyInput = CreateInput("SkyInput", UDim2.new(0, 25, 0, 20), "Sky ID...")
local MusicInput = CreateInput("MusicInput", UDim2.new(0, 25, 0, 65), "Music ID...")
local SpeedInput = CreateInput("SpeedInput", UDim2.new(0, 25, 0, 110), "Fly Speed...")

-- THE BRUTE FORCE EXECUTION
local function RemoteBruteForce(dataType, value)
    for _, remote in pairs(game:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            -- We try to fire the value to every remote found
            -- In many games, one remote is used for multiple string/asset updates
            pcall(function()
                remote:FireServer(value)
                remote:FireServer(dataType, value)
                remote:FireServer("Update", value)
            end)
        end
    end
end

local SkyBtn = Instance.new("TextButton", Main)
SkyBtn.Size = UDim2.new(0, 200, 0, 40)
SkyBtn.Position = UDim2.new(0, 25, 0, 160)
SkyBtn.Text = "FORCE ALL REMOTES (SKY)"
SkyBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. SkyInput.Text
    RemoteBruteForce("Sky", id)
    -- Local Override
    local s = game.Lighting:FindFirstChildOfClass("Sky") or Instance.new("Sky", game.Lighting)
    s.SkyboxBk = id s.SkyboxDn = id s.SkyboxFt = id s.SkyboxLf = id s.SkyboxRt = id s.SkyboxUp = id
end)

local MusicBtn = Instance.new("TextButton", Main)
MusicBtn.Size = UDim2.new(0, 200, 0, 40)
MusicBtn.Position = UDim2.new(0, 25, 0, 210)
MusicBtn.Text = "FORCE ALL REMOTES (AUDIO)"
MusicBtn.MouseButton1Click:Connect(function()
    local id = "rbxassetid://" .. MusicInput.Text
    RemoteBruteForce("Audio", id)
    -- Local Override
    local sound = Instance.new("Sound", game.Workspace)
    sound.SoundId = id sound.Looped = true sound.Volume = 10 sound:Play()
end)

-- FLY REMAINS THE SAME AS IT WORKS
local FlyBtn = Instance.new("TextButton", Main)
FlyBtn.Size = UDim2.new(0, 200, 0, 30)
FlyBtn.Position = UDim2.new(0, 25, 0, 260)
FlyBtn.Text = "TOGGLE FLY"
local flying = false
FlyBtn.MouseButton1Click:Connect(function()
    flying = not flying
    local speed = tonumber(SpeedInput.Text) or 50
    local p = game.Players.LocalPlayer
    if flying then
        local bv = Instance.new("BodyVelocity", p.Character.HumanoidRootPart)
        bv.MaxForce = Vector3.new(9e9,9e9,9e9)
        task.spawn(function()
            while flying do
                bv.Velocity = p:GetMouse().Hit.lookVector * speed
                task.wait()
            end
            bv:Destroy()
        end)
    end
end)