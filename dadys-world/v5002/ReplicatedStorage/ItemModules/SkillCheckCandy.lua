local SkillCheckCandy = {
	Name = "Skill Check Candy",
	PointCost = 42,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Uncommon",
	Icon = "rbxassetid://18702541120",
	Description = "Use this item to increase Skill Check Chance by 25% for 15 seconds.",
	ItemDuration = 15
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function SkillCheckCandy.UseItem(instance, p, p2)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Stealth")
	stats:WaitForChild("SkillCheckChance")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("WalkSpeed")
	local itemDuration = SkillCheckCandy.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.SkillCheckCandy.UseSound", {
			Parent = humanoidRootPart
		})
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = game.ReplicatedStorage.Parts.BuffParticles.SkillCheck.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.SkillCheck.Glow:Clone()
			clone2.Parent = attachment
			clone2.Enabled = true
			Debris:AddItem(clone, itemDuration + 1)
			Debris:AddItem(clone2, itemDuration + 1)
			Debris:AddItem(attachment, itemDuration + 1)
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
					clone2.Enabled = false
				end
			end)
		end)
	end

	task.spawn(function()
		local v2 = StatModifierManager.ApplyAdditiveSkillCheckChance(instance, 25, "SkillCheckCandy")
		BuffIndicator.raise(instance, "ItemSkillCheckCandy", itemDuration)
		task.wait(itemDuration)

		if instance and instance.Parent ~= nil then
			StatModifierManager.RemoveAdditiveSkillCheckChance(instance, v2)
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 3
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return SkillCheckCandy