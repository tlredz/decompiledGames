local require2 = require
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local require3 = require2(ReplicatedStorage:WaitForChild("RequireProxy")).CreateRequire(script, function(p)
	return require2(p)
end)
local Players = game:GetService("Players")
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local v = require3(ReplicatedStorage2.Shared.ReplicatedInstances.Swords)
local v2 = require3(ReplicatedStorage2.Packages.Trove)
local localPlayer = Players.LocalPlayer
return function(p: string, animation, _: number?)
	local v3 = v2.new()
	local clone = script.NPC:Clone()
	task.spawn(pcall, function()
		local character = localPlayer.Character
		local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
		local appliedDescription = humanoid and humanoid:GetAppliedDescription() or Players:GetHumanoidDescriptionFromUserId(localPlayer.UserId)
		clone.Humanoid:ApplyDescription(appliedDescription)
	end)
	clone.Name = ""

	if animation then
		clone.Humanoid:LoadAnimation(animation):Play(0)
	end

	v3:Add(clone)
	v:EquipSwordTo(clone, p)
	return clone, v3
end