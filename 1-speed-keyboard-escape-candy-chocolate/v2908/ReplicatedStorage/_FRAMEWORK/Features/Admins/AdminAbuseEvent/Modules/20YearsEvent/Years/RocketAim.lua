local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Config = require(script.Parent.Parent.Config)
return {
	start = function()
		local localPlayer = Players.LocalPlayer
		local mouse = localPlayer:GetMouse()
		local targetFilter = mouse.TargetFilter
		local v = {}

		local function aim()
			if localPlayer:GetAttribute(Config.participantAttribute) ~= true then
				return mouse.Hit.Position
			end

			local filterDescendantsInstances = {}

			if localPlayer.Character then
				table.insert(filterDescendantsInstances, localPlayer.Character)
			end

			if Workspace.CurrentCamera then
				table.insert(filterDescendantsInstances, Workspace.CurrentCamera)
			end

			local raycastParams = RaycastParams.new()
			raycastParams.FilterType = Enum.RaycastFilterType.Exclude
			local unitRay = mouse.UnitRay

			for _ = 1, 64 do
				raycastParams.FilterDescendantsInstances = filterDescendantsInstances
				local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 10000, raycastParams)

				if not raycastResult then
					return unitRay.Origin + unitRay.Direction * 10000
				end

				local instance = raycastResult.Instance
				local parent = instance

				while parent and parent.Name ~= "Zones" do
					parent = parent.Parent
				end

				if parent or instance:IsA("BasePart") and instance.Transparency >= 0.95 then
					table.insert(filterDescendantsInstances, parent or instance)
				else
					return raycastResult.Position
				end
			end

			return unitRay.Origin + unitRay.Direction * 10000
		end

		local renderSteppedConnection = RunService.RenderStepped:Connect(function()
			local character = localPlayer.Character
			local rocketLauncher

			if character then
				rocketLauncher = character:FindFirstChild("RocketLauncher")
			end

			if rocketLauncher and rocketLauncher:IsA("Tool") and localPlayer:GetAttribute(Config.participantAttribute) == true then
				mouse.TargetFilter = Workspace.CurrentCamera

				for _, remoteFunction in rocketLauncher:GetDescendants() do
					if not (remoteFunction:IsA("RemoteFunction") and remoteFunction.Name == "MouseLoc") then
						continue
					end

					v[remoteFunction] = true
					remoteFunction.OnClientInvoke = aim
				end
			elseif mouse.TargetFilter == Workspace.CurrentCamera then
				mouse.TargetFilter = targetFilter
			end
		end)
		return function()
			renderSteppedConnection:Disconnect()

			for k in v do
				if k.Parent then
					k.OnClientInvoke = function()
						return mouse.Hit.Position
					end
				end
			end

			if mouse.TargetFilter == Workspace.CurrentCamera then
				mouse.TargetFilter = targetFilter
			end
		end
	end
}