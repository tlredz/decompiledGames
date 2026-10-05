local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Observers = require(ReplicatedStorage.Packages.Observers)
return Observers.observeTag("HiganbanaAccessory", function(instance)
	local model = instance:FindFirstAncestorWhichIsA("Model")

	if not model then
		return
	end

	local folder = instance:FindFirstAncestorWhichIsA("Folder")
	local v = (folder and folder:GetAttribute("Seed") or 0) + (instance:GetAttribute("Seed") or 0)
	local heightFrequency = instance:GetAttribute("HeightFrequency") or 3
	local heightTravel = instance:GetAttribute("HeightTravel") or 0.25
	local swayFrequency = instance:GetAttribute("SwayFrequency") or 3
	local swayAngle = instance:GetAttribute("SwayAngle") or 0.13962634015954636
	local yawFrequency = instance:GetAttribute("YawFrequency") or 3
	local yawAngle = instance:GetAttribute("YawAngle") or 0.20943951023931956
	local C0 = instance.C0
	local postSimulationConnection = RunService.PostSimulation:Connect(function()
		if model:GetAttribute("CurrentEmote") then
			if instance.C0 ~= C0 then
				instance.C0 = C0
			end
		else
			local now = os.clock()
			local v2 = math.sin(now * heightFrequency + v) * heightTravel
			local v3 = math.sin(now * swayFrequency + v) * swayAngle
			local v4 = math.cos(now * swayFrequency + v) * swayAngle
			local v5 = math.sin(now * yawFrequency + v) * yawAngle
			instance.C0 = C0 * CFrame.new(0, v2, 0) * CFrame.Angles(v3, v5, v4)
		end
	end)
	return function()
		postSimulationConnection:Disconnect()
	end
end, { workspace })