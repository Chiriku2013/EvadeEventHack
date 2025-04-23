--[[
    Evade Mobile Script | By Chiriku
    Tính năng:
    - Auto Revive bản thân
    - Avoid Bot (teleport cách bot 100m, không nhầm item)
    - Auto lụm tất cả vật phẩm (Easter Eggs...)
    - Auto Jump liên tục (hỗ trợ emote hop)
    - Toggle UI bằng icon
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

local toggles = {
    avoidBot = false,
    autoRevive = false,
    autoPickup = false,
    autoJump = false,
}

-- UI Toggle Button
local button = Instance.new("ImageButton")
button.Size = UDim2.new(0, 50, 0, 50)
button.Position = UDim2.new(0, 10, 0, 200)
button.BackgroundTransparency = 1
button.Image = "rbxassetid://"..119198835819797
button.Parent = game.CoreGui

local mainGui = Instance.new("ScreenGui", game.CoreGui)
mainGui.Name = "EvadeMobileGui"
mainGui.Enabled = false

local frame = Instance.new("Frame", mainGui)
frame.Size = UDim2.new(0, 200, 0, 180)
frame.Position = UDim2.new(0, 70, 0, 200)
frame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
frame.BorderSizePixel = 0

local function createToggle(name, posY)
    local toggle = Instance.new("TextButton", frame)
    toggle.Size = UDim2.new(1, -20, 0, 30)
    toggle.Position = UDim2.new(0, 10, 0, posY)
    toggle.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggle.TextColor3 = Color3.new(1, 1, 1)
    toggle.Text = name .. ": OFF"
    toggle.MouseButton1Click:Connect(function()
        toggles[name] = not toggles[name]
        toggle.Text = name .. ": " .. (toggles[name] and "ON" or "OFF")
    end)
end

createToggle("avoidBot", 10)
createToggle("autoRevive", 50)
createToggle("autoPickup", 90)
createToggle("autoJump", 130)

button.MouseButton1Click:Connect(function()
    mainGui.Enabled = not mainGui.Enabled
end)

-- Auto Revive
RunService.RenderStepped:Connect(function()
    if toggles.autoRevive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health <= 0 then
            local reviveEvent = Workspace:FindFirstChild("ReviveRemote", true)
            if reviveEvent and reviveEvent:IsA("RemoteEvent") then
                reviveEvent:FireServer()
            end
        end
    end
end)

-- Avoid Bot
RunService.Heartbeat:Connect(function()
    if toggles.avoidBot then
        for _, v in pairs(Workspace:GetChildren()) do
            if v:IsA("Model") and v ~= LocalPlayer.Character and v:FindFirstChild("Humanoid") and v:FindFirstChild("HumanoidRootPart") then
                local botPos = v.HumanoidRootPart.Position
                local myChar = LocalPlayer.Character
                if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                    local dist = (myChar.HumanoidRootPart.Position - botPos).Magnitude
                    if dist < 60 then
                        local awayPos = botPos + Vector3.new(100, 0, 100)
                        myChar:PivotTo(CFrame.new(awayPos))
                    end
                end
            end
        end
    end
end)

-- Auto Jump
spawn(function()
    while true do
        task.wait(0.3)
        if toggles.autoJump then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid:GetState() ~= Enum.HumanoidStateType.Jumping then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Auto Pickup
spawn(function()
    while true do
        task.wait(1)
        if toggles.autoPickup then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                    local part = obj.Parent
                    local myChar = LocalPlayer.Character
                    if myChar and myChar:FindFirstChild("HumanoidRootPart") then
                        if (myChar.HumanoidRootPart.Position - part.Position).Magnitude > 5 then
                            myChar:PivotTo(CFrame.new(part.Position + Vector3.new(0, 3, 0)))
                            task.wait(0.2)
                        end
                    end
                end
            end
        end
    end
end)
