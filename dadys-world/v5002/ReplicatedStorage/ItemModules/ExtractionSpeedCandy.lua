local ExtractionSpeedCandy = {
	Name = "Extraction Speed Candy",
	PointCost = 35,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Uncommon",
	Icon = "rbxassetid://108547367119591",
	Description = "Use this item to increase Extraction Speed by 50% for 5 seconds.",
	ItemDuration = 5
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function ExtractionSpeedCandy.UseItem(instance, p, p2)
	local itemDuration = ExtractionSpeedCandy.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Misc.UseSound", {
			Parent = humanoidRootPart
		})
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.DecodeSpeed.Glow:Clone()
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
		local v2 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 1.5, "ExtractionSpeedCandy", {
			category = "item"
		})
		BuffIndicator.raise(instance, "ItemExtractionSpeedCandy", itemDuration)
		task.wait(itemDuration)
		StatModifierManager.RemoveModifier(instance, "DecodeSpeedModifier", v2)
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 3
	end

	return {
		Outcome = true,
		Reason = "Can't use that item right now!"
	}
end

return ExtractionSpeedCandy