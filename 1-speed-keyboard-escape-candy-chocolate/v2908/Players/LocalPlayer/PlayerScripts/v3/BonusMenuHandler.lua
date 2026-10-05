local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer

if localPlayer.UserId ~= 3845375404 then
	return
end

local bonusMenuAction = ReplicatedStorage:WaitForChild("BonusMenuAction")
local playerGui = localPlayer:WaitForChild("PlayerGui")

local function wireMenu(bonusMenuGUI)
	local background = bonusMenuGUI:WaitForChild("Background")
	local panel = background:WaitForChild("Panel")
	local closeBtn = panel:WaitForChild("CloseBtn")
	local scopeFrame = panel:WaitForChild("ScopeFrame")
	local playerFrame = panel:WaitForChild("PlayerFrame")
	local playerInput = playerFrame:WaitForChild("PlayerInput")
	local typeFrame = panel:WaitForChild("TypeFrame")
	local multInput = panel:WaitForChild("MultInput")
	local durInput = panel:WaitForChild("DurInput")
	local activateBtn = panel:WaitForChild("ActivateBtn")
	local stopAllBtn = panel:WaitForChild("StopAllBtn")
	local scopeValue = "server"
	local typeValue = "Wins"
	local color = Color3.fromRGB(40, 40, 55)

	local function updateScopeVisual()
		for _, button in ipairs(scopeFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if button:GetAttribute("ScopeValue") == scopeValue then
				local activeColor = button:GetAttribute("ActiveColor")

				if activeColor then
					local v = string.split(activeColor, ",")
					button.BackgroundColor3 = Color3.fromRGB(
						tonumber(v[1]) or 40,
						tonumber(v[2]) or 40,
						tonumber(v[3]) or 55
					)
				end
			else
				button.BackgroundColor3 = color
			end
		end

		playerFrame.Visible = scopeValue == "player"
	end

	local function updateTypeVisual()
		for _, button in ipairs(typeFrame:GetChildren()) do
			if not button:IsA("TextButton") then
				continue
			end

			if button:GetAttribute("TypeValue") == typeValue then
				button.BackgroundColor3 = Color3.fromRGB(50, 100, 160)
			else
				button.BackgroundColor3 = color
			end
		end
	end

	for _, button in ipairs(scopeFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v = button
		button.MouseButton1Click:Connect(function()
			scopeValue = v:GetAttribute("ScopeValue") or "server"
			updateScopeVisual()
		end)
	end

	for _, button in ipairs(typeFrame:GetChildren()) do
		if not button:IsA("TextButton") then
			continue
		end

		local v = button
		button.MouseButton1Click:Connect(function()
			typeValue = v:GetAttribute("TypeValue") or "Wins"
			updateTypeVisual()
		end)
	end

	activateBtn.MouseButton1Click:Connect(function()
		bonusMenuAction:FireServer({
			action = "activate",
			scope = scopeValue,
			bonusType = typeValue,
			multiplier = multInput.Text,
			duration = durInput.Text,
			playerName = playerInput.Text
		})
	end)
	stopAllBtn.MouseButton1Click:Connect(function()
		bonusMenuAction:FireServer({
			action = "stopAll"
		})
	end)
	closeBtn.MouseButton1Click:Connect(function()
		bonusMenuGUI:Destroy()
	end)
	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local absolutePosition = panel.AbsolutePosition
			local absoluteSize = panel.AbsoluteSize
			local position = input.Position

			if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
				bonusMenuGUI:Destroy()
			end
		end
	end)
	updateScopeVisual()
	updateTypeVisual()
end

playerGui.ChildAdded:Connect(function(screenGui)
	if screenGui.Name == "BonusMenuGUI" and screenGui:IsA("ScreenGui") then
		task.defer(wireMenu, screenGui)
	end
end)
local bonusMenuGUI = playerGui:FindFirstChild("BonusMenuGUI")

if bonusMenuGUI then
	wireMenu(bonusMenuGUI)
end