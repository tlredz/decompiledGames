local BonBon = {
	Name = "BonBon",
	SpecialItem = true,
	AbilityOnlyItem = true,
	Rarity = "Rare",
	PointCost = 0,
	Icon = "rbxassetid://130335597602610",
	Description = "Use this item to increase extraction speed +50% and movement speed +25% for 10 seconds.",
	ItemDuration = 10
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function BonBon.UseItem(instance, p, p2)
	local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Misc.UseSound", {
			Parent = humanoidRootPart
		})
	end

	local itemDuration = BonBon.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	local v2 = StatModifierManager.ApplySpeedModifiers(instance, 1.25, "BonBon", {
		category = "item",
		antiCheat = true
	})
	local v3 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.5, "BonBon", {
		category = "item"
	})
	BuffIndicator.raise(instance, "ItemBonBon", itemDuration)
	task.delay(itemDuration, function()
		if instance and instance.Parent ~= nil then
			StatModifierManager.RemoveSpeedModifiers(instance, v2)
			StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v3)
		end
	end)
	local attachment = Instance.new("Attachment")
	attachment.Name = "BuffParticle"
	attachment.Parent = humanoidRootPart
	local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
	clone.Parent = attachment
	clone.Enabled = true
	local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
	clone2.Parent = attachment
	clone2.Enabled = true
	local clone3 = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.BuffParticle:Clone()
	clone3.Parent = attachment
	clone3.Enabled = true
	local clone4 = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.Glow:Clone()
	clone4.Parent = attachment
	clone4.Enabled = true
	Debris:AddItem(clone, itemDuration + 1)
	Debris:AddItem(clone2, itemDuration + 1)
	Debris:AddItem(clone3, itemDuration + 1)
	Debris:AddItem(clone4, itemDuration + 1)
	Debris:AddItem(attachment, itemDuration + 1)
	task.delay(itemDuration, function()
		if instance and instance.Parent ~= nil and attachment then
			clone.Enabled = false
			clone2.Enabled = false
			clone3.Enabled = false
			clone4.Enabled = false
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Bon Bon consumed successfully!"
	}
end

return BonBon