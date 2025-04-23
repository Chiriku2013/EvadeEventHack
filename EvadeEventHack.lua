-- Evade Hack Mobile | By Chiriku | FIXED VERSION
local plr = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local eggsCollected = {}
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "EvadeUI"
gui.ResetOnSpawn = false

-- Toggle UI button
local toggle = Instance.new("ImageButton", gui)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Image = "rbxassetid://119198835819797"
toggle.BackgroundTransparency = 1

-- Main UI
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 180)
main.Position = UDim2.new(0, 10, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Visible = true
main.BorderSizePixel = 0

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

-- Button function
local states = {}
local function createBtn(text, y, callback)
	local btn = Instance.new("TextButton", main)
	btn.Size = UDim2.new(1, -20, 0, 30)
	btn.Position = UDim2.new(0, 10, 0, y)
	btn.Text = text
	btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
	btn.TextColor3 = Color3.new(1, 1, 1)
	btn.Font = Enum.Font.SourceSansBold
	btn.TextSize = 14
	btn.BorderSizePixel = 0

	local state = false
	states[text] = false
	btn.MouseButton1Click:Connect(function()
		state = not state
		states[text] = state
		btn.BackgroundColor3 = state and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
		callback(state)
	end)
end

-- Auto Revive Self
createBtn("Auto Revive", 10, function(on)
	task.spawn(function()
		while states["Auto Revive"] do task.wait(1)
			if plr.Character and plr.Character:FindFirstChild("Downed") then
				plr:LoadCharacter()
			end
		end
	end)
end)

-- Avoid Bot (Safe TP)
createBtn("Avoid Bot", 50, function(on)
	task.spawn(function()
		while states["Avoid Bot"] do task.wait(0.3)
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			for _, bot in ipairs(workspace:GetDescendants()) do
				if not states["Avoid Bot"] then break end
				if bot:IsA("Model") and bot:FindFirstChild("HumanoidRootPart") and bot.Name ~= plr.Name then
					local bHRP = bot.HumanoidRootPart
					local dist = (bHRP.Position - hrp.Position).Magnitude
					if dist < 30 then
						local away = (hrp.Position - bHRP.Position).Unit * 100
						local targetPos = hrp.Position + away
						targetPos = Vector3.new(targetPos.X, math.max(targetPos.Y, 5), targetPos.Z)
						hrp.CFrame = CFrame.new(targetPos)
						break
					end
				end
			end
		end
	end)
end)

-- Auto Collect Easter Eggs
createBtn("Auto Egg", 90, function(on)
	task.spawn(function()
		while states["Auto Egg"] do
			local found = nil
			for _,v in pairs(workspace:GetDescendants()) do
				if not states["Auto Egg"] then break end
				if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") and v.Parent.Name:lower():find("egg") then
					if not eggsCollected[v.Parent] then
						found = v
						break
					end
				end
			end

			if found then
				local eggPart = found.Parent
				eggsCollected[eggPart] = true

				local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Teleport to Egg safely
					hrp.CFrame = eggPart.CFrame + Vector3.new(0, 3, 0)
					task.wait(0.3)
					pcall(function() fireproximityprompt(found) end)
				end

				-- Wait for next egg
				repeat
					task.wait(1)
					local more = false
					for _,v in pairs(workspace:GetDescendants()) do
						if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") and v.Parent.Name:lower():find("egg") then
							if not eggsCollected[v.Parent] then more = true break end
						end
					end
				until not states["Auto Egg"] or more
			else
				task.wait(1)
			end
		end
	end)
end)
