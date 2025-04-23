--[[
    Evade Mobile Script | By Chiriku
    - Auto Revive bản thân (ổn định)
    - Avoid Bot (teleport cách 100m, không nhầm vật phẩm)
    - Auto lụm vật phẩm như Easter Eggs
    - Auto Jump liên tục (hỗ trợ emote hop)
    - Toggle UI bằng icon
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

-- Toggle trạng thái
local settings = {
    AvoidBot = false,
    AutoRevive = false,
    AutoPickup = false,
    AutoJump = false
}

-- Tạo UI Toggle
local function createToggleUi()
    local ScreenGui = Instance.new("ScreenGui", CoreGui)
    ScreenGui.Name = "EvadeHackGui"
    ScreenGui.ResetOnSpawn = false

    local ToggleButton = Instance.new("ImageButton", ScreenGui)
    ToggleButton.Name = "MainToggle"
    ToggleButton.Size = UDim2.new(0, 50, 0, 50)
    ToggleButton.Position = UDim2.new(0, 10, 0, 200)
    ToggleButton.BackgroundTransparency = 1
    ToggleButton.Image = "rbxassetid://119198835819797"

    local Frame = Instance.new("Frame", ScreenGui)
    Frame.Size = UDim2.new(0, 180, 0, 160)
    Frame.Position = UDim2.new(0, 70, 0, 200)
    Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    Frame.Visible = false

    local function createButton(name, order)
        local Btn = Instance.new("TextButton", Frame)
        Btn.Size = UDim2.new(1, -20, 0, 30)
        Btn.Position = UDim2.new(0, 10, 0, 10 + (order - 1) * 35)
        Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        Btn.TextColor3 = Color3.new(1, 1, 1)
        Btn.Text = name .. ": OFF"
        Btn.Font = Enum.Font.SourceSans
        Btn.TextSize = 18

        Btn.MouseButton1Click:Connect(function()
            settings[name] = not settings[name]
            Btn.Text = name .. ": " .. (settings[name] and "ON" or "OFF")
        end)
    end

    createButton("AvoidBot", 1)
    createButton("AutoRevive", 2)
    createButton("AutoPickup", 3)
    createButton("AutoJump", 4)

    ToggleButton.MouseButton1Click:Connect(function()
        Frame.Visible = not Frame.Visible
    end)
end

createToggleUi()

-- Auto Revive
RunService.Stepped:Connect(function()
    if settings.AutoRevive then
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("Humanoid") and char:FindFirstChild("Humanoid").Health <= 0 then
            local remote = Workspace:FindFirstChildWhichIsA("RemoteEvent", true)
            if remote then pcall(function() remote:FireServer() end) end
        end
    end
end)

-- Avoid Bot
task.spawn(function()
    while task.wait(0.3) do
        if settings.AvoidBot then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, model in ipairs(Workspace:GetChildren()) do
                    if model:IsA("Model") and model ~= char and model:FindFirstChild("Humanoid") and model:FindFirstChild("HumanoidRootPart") then
                        local dist = (char.HumanoidRootPart.Position - model.HumanoidRootPart.Position).Magnitude
                        if dist < 50 then
                            local tpPos = model.HumanoidRootPart.Position + Vector3.new(100, 0, 0)
                            char:PivotTo(CFrame.new(tpPos))
                            break
                        end
                    end
                end
            end
        end
    end
end)

-- Auto Jump
task.spawn(function()
    while task.wait(0.25) do
        if settings.AutoJump then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") then
                char.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end
    end
end)

-- Auto Pickup vật phẩm
task.spawn(function()
    while task.wait(1) do
        if settings.AutoPickup then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, obj in ipairs(Workspace:GetDescendants()) do
                    if obj:IsA("TouchTransmitter") and obj.Parent and obj.Parent:IsA("BasePart") then
                        local part = obj.Parent
                        if (char.HumanoidRootPart.Position - part.Position).Magnitude > 5 then
                            char:PivotTo(CFrame.new(part.Position + Vector3.new(0, 2, 0)))
                            task.wait(0.4)
                        end
                    end
                end
            end
        end
    end
end)
