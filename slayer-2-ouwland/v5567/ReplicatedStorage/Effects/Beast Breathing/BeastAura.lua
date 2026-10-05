local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CAM = ReplicatedStorage.CAM
local vfxUtility = require(CAM.Client.Modules.Effects.vfxUtility)
local DebrisModule = require(CAM.DebrisModule)

local function wearable(instance)
	if instance.Parent == nil or not instance.Parent:IsA("Attachment") then
		return instance:IsA("Attachment") or instance:IsA("ParticleEmitter") or instance:IsA("Beam") or instance:IsA("Trail") or instance:IsA("Light")
	end

	return false
end

return function(instance)
	if instance == nil then
		return
	end

	local upperTorso = instance:FindFirstChild("UpperTorso")

	if upperTorso == nil then
		return
	end

	local aura = script.Parent:FindFirstChild("Aura")

	if aura == nil then
		warn((`BeastAura: no "Aura" asset under {script.Parent:GetFullName()}`))
		return
	end

	local clone = aura:Clone()
	local v = {}

	if wearable(clone) then
		table.insert(v, clone)
	else
		for _, descendant in clone:GetDescendants() do
			if wearable(descendant) then
				table.insert(v, descendant)
			end
		end
	end

	local owned = vfxUtility.Owned(instance)

	for _, v2 in v do
		v2.Parent = upperTorso
		DebrisModule:AddItem(v2, 4)
		vfxUtility.EmitAll(v2, owned)
	end

	if clone.Parent == nil and #v > 0 and v[1] ~= clone then
		clone:Destroy()
	end
end