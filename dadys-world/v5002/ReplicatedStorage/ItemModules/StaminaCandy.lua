local StaminaCandy = {
	Name = "Stamina Candy",
	PointCost = 35,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://122723121767996",
	Description = "Use this item to increase your Stamina Regeneration by 50% for 20 seconds.",
	ItemDuration = 20
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function StaminaCandy.UseItem(instance, p, p2)
	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Misc.UseSound", {
			Parent = humanoidRootPart
		})
		local itemDuration = StaminaCandy.ItemDuration

		if p2 and p2 > 0 then
			itemDuration += p2
		end

		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = ReplicatedStorage.Parts.BuffParticles.Stamina.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = ReplicatedStorage.Parts.BuffParticles.Stamina.Glow:Clone()
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
		StatModifierManager.ApplyStaminaRegenModifier(instance, 1.5, "StaminaCandy", {
			duration = itemDuration,
			category = "item"
		})
		BuffIndicator.raise(instance, "ItemStaminaCandy", itemDuration)
	end

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

return StaminaCandy