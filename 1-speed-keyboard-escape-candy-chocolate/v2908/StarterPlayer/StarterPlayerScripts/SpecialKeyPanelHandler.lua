local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local specialKeyPanelAction = ReplicatedStorage:WaitForChild("SpecialKeyPanelAction")
local scope = "server"

local function wirePanel(specialKeyPanel)
	local background = specialKeyPanel:WaitForChild("Background")
	local panel = background:WaitForChild("Panel")
	local closeBtn = panel:WaitForChild("CloseBtn")
	local buttonScroll = panel:WaitForChild("ButtonScroll")
	local scopeFrame = panel:WaitForChild("ScopeFrame")
	local scopeServer = scopeFrame:WaitForChild("ScopeServer")
	local scopeGlobal = scopeFrame:WaitForChild("ScopeGlobal")

	local function updateScopeVisual()
		if scope == "server" then
			scopeServer.BackgroundColor3 = Color3.fromRGB(50, 130, 50)
			scopeServer.TextColor3 = Color3.fromRGB(255, 255, 255)
			scopeGlobal.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			scopeGlobal.TextColor3 = Color3.fromRGB(180, 180, 180)
		else
			scopeServer.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
			scopeServer.TextColor3 = Color3.fromRGB(180, 180, 180)
			scopeGlobal.BackgroundColor3 = Color3.fromRGB(170, 80, 30)
			scopeGlobal.TextColor3 = Color3.fromRGB(255, 255, 255)
		end
	end

	scopeServer.MouseButton1Click:Connect(function()
		scope = "server"
		updateScopeVisual()
	end)
	scopeGlobal.MouseButton1Click:Connect(function()
		scope = "global"
		updateScopeVisual()
	end)
	updateScopeVisual()
	closeBtn.MouseButton1Click:Connect(function()
		specialKeyPanel:Destroy()
	end)
	background.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			local absolutePosition = panel.AbsolutePosition
			local absoluteSize = panel.AbsoluteSize
			local position = input.Position

			if position.X < absolutePosition.X or position.X > absolutePosition.X + absoluteSize.X or position.Y < absolutePosition.Y or position.Y > absolutePosition.Y + absoluteSize.Y then
				specialKeyPanel:Destroy()
			end
		end
	end)
	local v2 = {
		NormalOn = function()
			return {
				Action = "normalOn",
				Scope = scope
			}
		end,
		NormalOff = function()
			return {
				Action = "normalOff",
				Scope = scope
			}
		end,
		EventOn = function()
			return {
				Action = "eventOn",
				Scope = scope
			}
		end,
		EventOff = function()
			return {
				Action = "eventOff",
				Scope = scope
			}
		end,
		ForceNormal = function()
			return {
				Action = "forceNormal",
				Scope = scope
			}
		end,
		ForceEvent = function()
			return {
				Action = "forceEvent",
				Scope = scope
			}
		end,
		ClearAll = function()
			return {
				Action = "clearAll",
				Scope = scope
			}
		end
	}

	for childName, v3 in pairs(v2) do
		local child = buttonScroll:WaitForChild(childName, 5)

		if not child then
			continue
		end

		local v4 = v3
		child.MouseButton1Click:Connect(function()
			specialKeyPanelAction:FireServer(v4())
		end)
	end

	local normalInterval_Row = buttonScroll:WaitForChild("NormalInterval_Row", 5)

	if normalInterval_Row then
		local normalInterval_Input = normalInterval_Row:WaitForChild("NormalInterval_Input", 5)
		local normalInterval_Set = normalInterval_Row:WaitForChild("NormalInterval_Set", 5)

		if normalInterval_Input and normalInterval_Set then
			normalInterval_Set.MouseButton1Click:Connect(function()
				specialKeyPanelAction:FireServer({
					Action = "setNormalInterval",
					Scope = scope,
					Interval = normalInterval_Input.Text
				})
			end)
		end
	end

	local eventInterval_Row = buttonScroll:WaitForChild("EventInterval_Row", 5)

	if eventInterval_Row then
		local eventInterval_Input = eventInterval_Row:WaitForChild("EventInterval_Input", 5)
		local eventInterval_Set = eventInterval_Row:WaitForChild("EventInterval_Set", 5)

		if eventInterval_Input and eventInterval_Set then
			eventInterval_Set.MouseButton1Click:Connect(function()
				specialKeyPanelAction:FireServer({
					Action = "setEventInterval",
					Scope = scope,
					Interval = eventInterval_Input.Text
				})
			end)
		end
	end
end

playerGui.ChildAdded:Connect(function(screenGui)
	if screenGui.Name == "SpecialKeyPanel" and screenGui:IsA("ScreenGui") then
		task.defer(wirePanel, screenGui)
	end
end)
local specialKeyPanel = playerGui:FindFirstChild("SpecialKeyPanel")

if specialKeyPanel then
	wirePanel(specialKeyPanel)
end