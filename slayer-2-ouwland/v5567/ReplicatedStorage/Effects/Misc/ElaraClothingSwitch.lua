local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
local Cam_Shaker = require(ReplicatedStorage.CAM.Client.Modules.Effects.Cam_Shaker)
return function(instance)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local clone = script.lilfx.Attachment:Clone()
	clone.Parent = humanoidRootPart
	Ouwmit.Emit(clone, Ouwmit.Owned(instance))
	DebrisModule:AddItem(clone, 3)
	clone.PS2mannequinrestock:Play()
	Cam_Shaker(humanoidRootPart.Position, "tinyshake_preset")
end