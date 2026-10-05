local Interface = {}
local localPlayer = game.Players.LocalPlayer
local playerGui = localPlayer.PlayerGui
local Client = require(localPlayer.PlayerScripts.Client)
local TweenService = game:GetService("TweenService")
Interface.CurrentWindow = "Game"
local v = {}
local v2 = {}

function MultiplyUDim(p, p2)
	return UDim2.new(p.X.Scale * p2, p.X.Offset * p2, p.Y.Scale * p2, p.Y.Offset * p2)
end

function Interface.BounceLabelSize(p, p2, value)
	task.spawn(function()
		value = value or 0.2

		if v[p] == nil then
			v[p] = {
				Size = p.Size
			}
		end

		local size = v[p].Size
		local size2 = MultiplyUDim(size, p2)
		local v4 = (v2[p] or 0) + 1
		v2[p] = v4
		local v5 = value / 2
		local tweenInfo = TweenInfo.new(v5)
		TweenService:Create(p, tweenInfo, {
			Size = size2
		}):Play()
		wait(v5)

		if v2[p] == v4 then
			TweenService:Create(p, tweenInfo, {
				Size = size
			}):Play()
		end
	end)
end

function LoadInterface()
	local replicatedInterface = game.ReplicatedStorage:WaitForChild("ReplicatedInterface")
	replicatedInterface.ChildAdded:Connect(function(guiBase2d)
		if guiBase2d:IsA("GuiBase2d") then
			guiBase2d.Parent = playerGui
		end
	end)

	for _, guiBase2d in pairs(replicatedInterface:GetChildren()) do
		if guiBase2d:IsA("GuiBase2d") then
			guiBase2d.Parent = playerGui
		end
	end
end

Client.Events.SetCurrentInterface:Connect(function(currentWindow)
	Interface.CurrentWindow = currentWindow
end)

function Interface.Init()
	LoadInterface()

	for _, child in pairs(localPlayer.PlayerGui:WaitForChild("Interface"):GetChildren()) do
		Interface[child.Name] = child
	end

	for _, moduleScript in pairs(script:GetDescendants()) do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v3 = Interface
		local name = moduleScript.Name
		local module = require(moduleScript)
		v3[name] = module
		local v4 = moduleScript
		task.spawn(function()
			if Interface[v4.Name] and Interface[v4.Name].Init then
				Interface[v4.Name].Init()
			end
		end)
	end
end

return Interface