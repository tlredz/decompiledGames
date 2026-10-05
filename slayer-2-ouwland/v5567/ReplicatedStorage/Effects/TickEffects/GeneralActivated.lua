local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Ouwmit = require(ReplicatedStorage.CAM.Client.Modules.Effects.Ouwmit)
local DebrisModule = require(ReplicatedStorage.CAM.DebrisModule)

-- equivalent calls inferred from this helper; original call sites unknown
local function getTemplate()
	local tickActivated = script.Parent:FindFirstChild("TickActivated")

	if tickActivated == nil then
		return nil
	end

	return tickActivated:FindFirstChild("StaminaActivated")
end

return function(instance, color: Color3?)
	if instance == nil then
		return
	end

	local humanoidRootPart = instance:FindFirstChild("HumanoidRootPart")

	if humanoidRootPart == nil then
		return
	end

	local template = getTemplate() -- equivalent call inferred; original call site unknown

	if template == nil then
		return
	end

	local clone = template:Clone()
	clone.Parent = humanoidRootPart
	Ouwmit.Emit(clone, Ouwmit.Owned(instance, {
		Color = color
	}))
	DebrisModule:AddItem(clone, 2.5)
end