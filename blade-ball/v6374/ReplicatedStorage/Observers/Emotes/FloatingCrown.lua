local ReplicatedStorage = game:GetService("ReplicatedStorage")
game:GetService("TweenService")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("FloatingCrown", function(instance)
	local folder = instance:FindFirstAncestorWhichIsA("Folder")
	local v = (folder and folder:GetAttribute("Seed") or 0) + (instance:GetAttribute("Seed") or 0)
	local frequency = instance:GetAttribute("Frequency") or 3
	local travelDistance = instance:GetAttribute("TravelDistance") or 0.25
	local startDistance = instance:GetAttribute("StartDistance") or 0.25
	local isA = instance:IsA("BasePart")
	local isA2 = instance:IsA("Weld")
	local C0

	if isA2 then
		C0 = instance.C0
	else
		C0 = instance.CFrame
	end

	local postSimulationConnection = RunService.PostSimulation:Connect(function(_: number)
		if isA2 then
			instance.C0 = C0 * CFrame.new(0, startDistance + math.sin(v + os.clock() * frequency) * travelDistance, 0)
			return
		end

		if not isA then
			instance.CFrame = C0 * CFrame.new(
				0,
				startDistance + math.sin(v + os.clock() * frequency) * travelDistance,
				0
			)
			return
		end

		for _, instance2 in instance:GetJoints() do
			if not ((instance2:IsA("Weld") or instance2:IsA("Motor6D")) and instance2.Name ~= "IgnoreFloat") then
				continue
			end

			local defaultC0 = instance2:GetAttribute("DefaultC0")

			if not defaultC0 then
				defaultC0 = instance2.C0
				instance2:SetAttribute("DefaultC0", defaultC0)
			end

			instance2.C0 = defaultC0 * CFrame.new(
				0,
				startDistance + math.sin(v + os.clock() * frequency) * travelDistance,
				0
			)
		end
	end)
	return function()
		postSimulationConnection:Disconnect()
	end
end, { workspace })