local StealthCandy = {
	Name = "Stealth Candy",
	PointCost = 35,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://18702541024",
	Description = "Use this item to increase Stealth by 25% for 8 seconds.",
	ItemDuration = 8
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function StealthCandy.UseItem(instance, p, p2)
	local itemDuration = StealthCandy.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.StealthCandy.UseSound", {
			Parent = humanoidRootPart
		})
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = ReplicatedStorage.Parts.BuffParticles.Stealth.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = ReplicatedStorage.Parts.BuffParticles.Stealth.Glow:Clone()
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

	StatModifierManager.ApplyModifier(instance, "StealthModifier", 1.25, "StealthCandy", {
		duration = itemDuration,
		category = "item"
	})
	BuffIndicator.raise(instance, "ItemStealthCandy", itemDuration)
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

return StealthCandy