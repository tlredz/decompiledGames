local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart") or instance.PrimaryPart

	if humanoidRootPart == nil then
		return
	end

	vfxUtility.PlaySound(script, "PS2gauntletFLASHFISTinit", humanoidRootPart, true)
end