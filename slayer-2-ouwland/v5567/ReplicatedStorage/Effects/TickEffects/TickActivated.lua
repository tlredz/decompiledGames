local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)
return function(instance, childName: string, color: Color3?)
	if instance == nil or childName == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local child = script:FindFirstChild(childName)

	if child ~= nil then
		local clone = child:Clone()
		clone.Parent = humanoidRootPart
		Ouwmit.Emit(clone, Ouwmit.Owned(instance, {
			Color = color
		}))
		DebrisModule:AddItem(clone, 2.5)
	end
end