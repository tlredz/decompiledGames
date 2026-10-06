game:GetService("Players")
game:GetService("RunService")
game:GetService("ServerStorage")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Utils = {}
local InvisiblePart = require(ReplicatedStorage.Chest.Modules.InvisiblePart)

function SetObjectVisible(instance, enabled: boolean)
	local v = enabled and 1 or 0

	if instance:IsA("BasePart") and instance.Transparency ~= v and not InvisiblePart[instance.Name] then
		instance.Transparency = v
		return
	end

	if instance:IsA("Decal") then
		instance.Transparency = v
		return
	end

	if instance:IsA("Highlight") then
		instance.OutlineTransparency = v
		return
	end

	if not (instance:IsA("Beam") or instance:IsA("ObjecticleEmitter") or instance:IsA("Trail")) or instance.Enabled == enabled then
		return
	end

	instance.Enabled = enabled
end

function Utils.SetEntityVisible(_, folder, flag: boolean)
	for _, descendant in pairs(folder:GetDescendants()) do
		if not (descendant:IsA("BasePart") or descendant:IsA("Highlight") or descendant:IsA("Decal") or descendant:IsA("Beam") or descendant:IsA("ParticleEmitter") or descendant:IsA("Trail")) then
			continue
		end

		SetObjectVisible(descendant, flag)
	end
end

return Utils