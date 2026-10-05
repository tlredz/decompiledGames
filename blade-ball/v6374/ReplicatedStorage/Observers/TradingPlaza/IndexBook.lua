local createVector = vector.create
local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("IndexBook", function(part)
	part:FindFirstAncestorWhichIsA("Folder")
	local position

	if part:IsA("BasePart") then
		position = part.Position
	else
		position = part.WorldPosition
	end

	local postSimulationConnection = RunService.PostSimulation:Connect(function(dt: number)
		local character = localPlayer.Character
		local pivot = character and character:GetPivot() or CFrame.identity
		local v = position
		local position2 = pivot.Position
		local v2 = position2 == v and createVector(0, 0, 0) or position2
		local orientation, v3, v4 = CFrame.lookAt(v, v2):ToOrientation()
		local cframe = CFrame.fromOrientation(-orientation, v3, v4)
		local v5 = CFrame.Angles(0, 1.5707963267948966, 0) * cframe.Rotation

		for _, instance in part:GetJoints() do
			if not ((instance:IsA("Weld") or instance:IsA("Motor6D")) and instance.Name ~= "IgnoreFloat") then
				continue
			end

			local defaultC0 = instance:GetAttribute("DefaultC0")

			if not defaultC0 then
				defaultC0 = instance.C0
				instance:SetAttribute("DefaultC0", defaultC0)
			end

			local v6 = defaultC0 * CFrame.new(0, math.sin((os.clock())) * 0.5 + 0.5, 0)
			instance.C0 = CFrame.new(v6.Position) * instance.C0.Rotation:Lerp(v5, dt * 0.1 * 60)
		end
	end)
	return function()
		postSimulationConnection:Disconnect()
	end
end, { workspace })