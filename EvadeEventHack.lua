-- Evade Hack Mobile | By Chiriku | Final FIX + Auto Jump
local plr = game.Players.LocalPlayer
local rs = game:GetService("RunService")
local uis = game:GetService("UserInputService")
local gui = Instance.new("ScreenGui", plr:WaitForChild("PlayerGui"))
gui.Name = "EvadeUI"
gui.ResetOnSpawn = false

-- Toggle UI Button
local toggle = Instance.new("ImageButton", gui)
toggle.Size = UDim2.new(0, 40, 0, 40)
toggle.Position = UDim2.new(0, 10, 0, 10)
toggle.Image = "rbxassetid://119198835819797"
toggle.BackgroundTransparency = 1

-- Main UI
local main = Instance.new("Frame", gui)
main.Size = UDim2.new(0, 240, 0, 220)  -- tăng chiều cao để chứa Auto Jump
main.Position = UDim2.new(0, 10, 0, 60)
main.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
main.Visible = true
main.BorderSizePixel = 0

toggle.MouseButton1Click:Connect(function()
	main.Visible = not main.Visible
end)

-- Button Creator
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

	states[text] = false
	btn.MouseButton1Click:Connect(function()
		states[text] = not states[text]
		btn.BackgroundColor3 = states[text] and Color3.fromRGB(0, 170, 0) or Color3.fromRGB(60, 60, 60)
		callback(states[text])
	end)
end

-- Anti-AFK
for _, v in pairs(getconnections(plr.Idled)) do
	pcall(function() v:Disable() end)
end

-- Auto Revive Self
createBtn("Auto Revive", 10, function(on)
	task.spawn(function()
		while states["Auto Revive"] do
			task.wait(1)
			if plr.Character and plr.Character:FindFirstChild("Downed") then
				pcall(function() plr:LoadCharacter() end)
			end
		end
	end)
end)

-- Avoid Bot (safe sideways teleport)
createBtn("Avoid Bot", 50, function(on)
	task.spawn(function()
		while states["Avoid Bot"] do
			task.wait(0.5)
			local char = plr.Character
			local hrp = char and char:FindFirstChild("HumanoidRootPart")
			if not hrp then continue end

			for _, model in ipairs(workspace:GetDescendants()) do
				if not states["Avoid Bot"] then break end
				if model:IsA("Model") and model:FindFirstChild("HumanoidRootPart") then
					-- Kiểm tra model có phải là người chơi hay không
					local isPlayer = game.Players:GetPlayerFromCharacter(model)
					if not isPlayer and model.Name ~= plr.Name then
						local bHRP = model.HumanoidRootPart
						local dist = (bHRP.Position - hrp.Position).Magnitude
						if dist < 30 then
							local dir = (hrp.Position - bHRP.Position).Unit
							-- Chỉ dịch chuyển ngang (không thay đổi độ cao)
							local offset = Vector3.new(dir.X * 100, 0, dir.Z * 100)
							local safePos = hrp.Position + offset
							hrp.CFrame = CFrame.new(safePos)
							break
						end
					end
				end
			end
		end
	end)
end)

-- Auto Collect Items (mọi thứ có ProximityPrompt)
createBtn("Auto Collect", 90, function(on)
	local collected = {}
	task.spawn(function()
		while states["Auto Collect"] do
			local found = nil
			for _,v in pairs(workspace:GetDescendants()) do
				if not states["Auto Collect"] then break end
				if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") then
					local item = v.Parent
					if not collected[item] then
						found = v
						collected[item] = true
						break
					end
				end
			end

			if found then
				local hrp = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
				if hrp then
					-- Teleport ngay tới item
					hrp.CFrame = found.Parent.CFrame + Vector3.new(0, 3, 0)
					task.wait(0.3)
					pcall(function() fireproximityprompt(found) end)
				end

				-- Đợi cho đến khi có item mới
				repeat
					task.wait(1)
					local more = false
					for _,v in pairs(workspace:GetDescendants()) do
						if v:IsA("ProximityPrompt") and v.Parent:IsA("BasePart") and not collected[v.Parent] then
							more = true
							break
						end
					end
				until not states["Auto Collect"] or more
			else
				task.wait(1)
			end
		end
	end)
end)

-- Auto Jump (để emote hop)
createBtn("Auto Jump", 130, function(on)
	task.spawn(function()
		while states["Auto Jump"] do
			local char = plr.Character
			if char then
				local humanoid = char:FindFirstChildOfClass("Humanoid")
				if humanoid then
					humanoid.Jump = true
				end
			end
			task.wait(0.5)
		end
	end)
end)
