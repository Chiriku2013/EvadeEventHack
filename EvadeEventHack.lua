-- Evade Hack Mobile Stable | By Chiriku
local lp = game.Players.LocalPlayer
local char = lp.Character or lp.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local hrp = char:WaitForChild("HumanoidRootPart")
local rs = game:GetService("RunService")
local eggsCollected = {}
local avoiding = false

-- UI
local gui = Instance.new("ScreenGui", lp:WaitForChild("PlayerGui"))
gui.ResetOnSpawn = false
gui.Name = "EvadeUI"

local toggleBtn = Instance.new("TextButton", gui)
toggleBtn.Size = UDim2.new(0, 40, 0, 40)
toggleBtn.Position = UDim2.new(0, 10, 0, 10)
toggleBtn.Text = "☰"
toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
toggleBtn.TextColor3 = Color3.new(1,1,1)
toggleBtn.Font = Enum.Font.SourceSansBold
toggleBtn.TextSize = 20

local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 220, 0, 160)
main.Position = UDim2.new(0, 10, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Visible = true

toggleBtn.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

local function createBtn(text, yPos, callback)
	local b = Instance.new("TextButton", main)
	b.Size = UDim2.new(1, -10, 0, 30)
	b.Position = UDim2.new(0, 5, 0, yPos)
	b.Text = text
	b.TextColor3 = Color3.new(1,1,1)
	b.BackgroundColor3 = Color3.fromRGB(60,60,60)
	b.Font = Enum.Font.SourceSansBold
	b.TextSize = 14
	local on = false
	b.MouseButton1Click:Connect(function()
		on = not on
		b.BackgroundColor3 = on and Color3.fromRGB(0,170,0) or Color3.fromRGB(60,60,60)
		callback(on)
	end)
end

-- Anti AFK
for _,v in pairs(getconnections(lp.Idled)) do
	v:Disable()
end

-- Auto Revive (bằng cách gọi lại Character)
createBtn("Auto Revive Self", 10, function(on)
	task.spawn(function()
		while on do
			task.wait(1)
			local c = lp.Character
			if c and c:FindFirstChild("Downed") then
				lp:LoadCharacter() -- thay vì fire prompt
			end
		end
	end)
end)

-- Avoid Bot
createBtn("Avoid Bot", 45, function(on)
	task.spawn(function()
		while on do
			task.wait(0.25)
			local char = lp.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end
			for _, bot in ipairs(workspace:GetDescendants()) do
				if bot:IsA("Model") and bot:FindFirstChild("HumanoidRootPart") and bot.Name ~= lp.Name then
					local bHRP = bot.HumanoidRootPart
					if (bHRP.Position - hrp.Position).Magnitude < 25 then
						local away = (hrp.Position - bHRP.Position).Unit * 100
						hrp.CFrame = CFrame.new(hrp.Position + away + Vector3.new(0, 5, 0))
						break
					end
				end
			end
		end
	end)
end)

-- Auto nhặt Easter Egg
createBtn("Auto Grab Eggs", 80, function(on)
	task.spawn(function()
		while on do
			local foundEgg = nil
			for _,v in pairs(workspace:GetDescendants()) do
				if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
					local name = v.Parent.Name:lower()
					if name:find("egg") and not eggsCollected[v.Parent] then
						foundEgg = v
						break
					end
				end
			end
			if foundEgg then
				local part = foundEgg.Parent
				eggsCollected[part] = true
				if lp.Character and lp.Character:FindFirstChild("HumanoidRootPart") then
					lp.Character.HumanoidRootPart.CFrame = part.CFrame + Vector3.new(0, 5, 0)
					task.wait(0.5)
					pcall(function() fireproximityprompt(foundEgg) end)
				end
				-- Chờ đến khi trứng mới spawn
				repeat task.wait(1)
					local exists = false
					for _,v in pairs(workspace:GetDescendants()) do
						if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") and v.Parent.Name:lower():find("egg") then
							if not eggsCollected[v.Parent] then
								exists = true break
							end
						end
					end
				until exists or not on
			else
				task.wait(1)
			end
		end
	end)
end)
