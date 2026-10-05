local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local Observers = require(ReplicatedStorage.Packages.Observers)
Observers.observeTag("StarburstRotate", function(instance)
	local layerCollector = instance:FindFirstAncestorWhichIsA("LayerCollector")
	local parent = instance.Parent
	local preRenderConnection = nil

	local function updateBind()
		local v = (not layerCollector or layerCollector.Enabled) and true or false

		if not parent.Visible then
			v = false
		end

		if v then
			if preRenderConnection then
				return
			end

			preRenderConnection = RunService.PreRender:Connect(function(dt: number)
				instance.Rotation += dt * 25
			end)
		elseif preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end
	end

	local enabledChangedConnection

	if layerCollector then
		enabledChangedConnection = layerCollector:GetPropertyChangedSignal("Enabled"):Connect(updateBind)
	else
		enabledChangedConnection = nil
	end

	local visibleChangedConnection = parent:GetPropertyChangedSignal("Visible"):Connect(updateBind)
	updateBind()
	return function()
		if preRenderConnection then
			preRenderConnection:Disconnect()
			preRenderConnection = nil
		end

		if visibleChangedConnection then
			visibleChangedConnection:Disconnect()
			visibleChangedConnection = nil
		end

		if enabledChangedConnection then
			enabledChangedConnection:Disconnect()
			enabledChangedConnection = nil
		end
	end
end, { workspace, Players.LocalPlayer })