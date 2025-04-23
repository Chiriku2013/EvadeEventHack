-- Evade Hack Mobile | Full Toggle UI | By Chiriku
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local gui = Instance.new("ScreenGui", game.CoreGui)
gui.ResetOnSpawn = false

-- Toggle UI Button
local toggleButton = Instance.new("TextButton", gui)
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(0, 5, 0, 5)
toggleButton.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleButton.Text = "☰"
toggleButton.TextColor3 = Color3.new(1,1,1)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 24
toggleButton.ZIndex = 999

-- Main Frame
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 220, 0, 200)
frame.Position = UDim2.new(0, 10, 0.3, 0)
frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
frame.BorderSizePixel = 0
frame.Visible = true

toggleButton.MouseButton1Click:Connect(function()
    frame.Visible = not frame.Visible
end)

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "Evade Mobile Hack"
title.TextColor3 = Color3.new(1,1,1)
title.BackgroundColor3 = Color3.fromRGB(50,50,50)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 16

local y = 35
local function createToggle(name, callback)
    local btn = Instance.new("TextButton", frame)
    btn.Size = UDim2.new(1, -10, 0, 30)
    btn.Position = UDim2.new(0, 5, 0, y)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.Text = name
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 14

    local state = false
    btn.MouseButton1Click:Connect(function()
        state = not state
        btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
        callback(state)
    end)
    y += 35
end

-- Anti AFK
for _,v in pairs(getconnections(LocalPlayer.Idled)) do pcall(function() v:Disable() end) end

-- Auto Revive bản thân
createToggle("Auto Revive Self", function(on)
    task.spawn(function()
        while on do
            task.wait(1)
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Downed") then
                local prompt = char:FindFirstChildWhichIsA("ProximityPrompt", true)
                if prompt then
                    fireproximityprompt(prompt)
                end
            end
        end
    end)
end)

-- Avoid Bot (Teleport ra xa 100m)
createToggle("Avoid Bot", function(on)
    task.spawn(function()
        while on do
            task.wait(0.2)
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if not hrp then continue end
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("Model") and v.Name ~= LocalPlayer.Name and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                    local dist = (v.HumanoidRootPart.Position - hrp.Position).Magnitude
                    if dist < 20 then
                        local awayVec = (hrp.Position - v.HumanoidRootPart.Position).Unit * 100
                        hrp.CFrame = CFrame.new(hrp.Position + awayVec + Vector3.new(0, 3, 0))
                        break
                    end
                end
            end
        end
    end)
end)

-- Auto lụm Easter Eggs (teleport + chờ egg mới)
createToggle("Auto Grab Eggs", function(on)
    task.spawn(function()
        local lastEggPos = nil
        while on do
            task.wait(1)
            local found = false
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") and obj.Parent and (obj.Parent.Name:lower():find("egg") or obj.Parent.Name:lower():find("easter")) then
                    local eggPos = obj.Parent.Position
                    if not lastEggPos or (eggPos - lastEggPos).Magnitude > 5 then
                        lastEggPos = eggPos
                        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            hrp.CFrame = CFrame.new(eggPos + Vector3.new(0, 3, 0))
                            fireproximityprompt(obj)
                            found = true
                        end
                        break
                    end
                end
            end
            if found then
                repeat task.wait(1)
                    local stillExists = false
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj:IsA("ProximityPrompt") and obj.Parent and (obj.Parent.Name:lower():find("egg") or obj.Parent.Name:lower():find("easter")) then
                            stillExists = true break
                        end
                    end
                until not stillExists or not on
            end
        end
    end)
end)