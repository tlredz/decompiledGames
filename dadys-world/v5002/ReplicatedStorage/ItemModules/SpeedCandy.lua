local SpeedCandy = {
	Name = "Speed Candy",
	PointCost = 45,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Uncommon",
	Icon = "rbxassetid://17713663434",
	Description = "Use this item to increase Walk and Run Speed by 25% for 5 seconds.",
	ItemDuration = 5
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function SpeedCandy.UseItem(instance, p, p2)
	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.SpeedCandy.UseSound", {
			Parent = humanoidRootPart
		})
		local itemDuration = SpeedCandy.ItemDuration

		if p2 and p2 > 0 then
			itemDuration += p2
		end

		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
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
			local v2 = StatModifierManager.ApplySpeedModifiers(instance, 1.25, "SpeedCandy", {
				category = "item",
				antiCheat = true
			})
			BuffIndicator.raise(instance, "ItemSpeedCandy", itemDuration)
			task.wait(itemDuration)

			if instance and instance.Parent ~= nil then
				StatModifierManager.RemoveSpeedModifiers(instance, v2)
			end
		end)
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

return SpeedCandy