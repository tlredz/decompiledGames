local Chocolate = {
	Name = "Chocolate",
	PointCost = 22,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://17727840139",
	Description = "Use this item to increase Max Stamina by 25 and Walk Speed by 10% for 10 seconds.",
	ItemDuration = 10
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Chocolate.UseItem(instance, p, p2)
	local stats = instance:WaitForChild("Stats")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	local originalStamina = stats:WaitForChild("OriginalStamina")
	local itemDuration = Chocolate.ItemDuration

	if p2 and p2 > 0 then
		itemDuration += p2
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.Chocolate.UseSound", {
			Parent = humanoidRootPart
		})
		task.spawn(function()
			local attachment = Instance.new("Attachment")
			attachment.Name = "BuffParticle"
			attachment.Parent = humanoidRootPart
			local clone = game.ReplicatedStorage.Parts.BuffParticles.Stamina.BuffParticle:Clone()
			clone.Parent = attachment
			clone.Enabled = true
			local clone2 = game.ReplicatedStorage.Parts.BuffParticles.Stamina.Glow:Clone()
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
			local attachment2 = Instance.new("Attachment")
			attachment2.Name = "BuffParticle"
			attachment2.Parent = humanoidRootPart
			local clone3 = game.ReplicatedStorage.Parts.BuffParticles.Speed.BuffParticle:Clone()
			clone3.Parent = attachment2
			clone3.Enabled = true
			local clone4 = game.ReplicatedStorage.Parts.BuffParticles.Speed.Glow:Clone()
			clone4.Parent = attachment2
			clone4.Enabled = true
			Debris:AddItem(clone3, itemDuration + 1)
			Debris:AddItem(clone4, itemDuration + 1)
			Debris:AddItem(attachment2, itemDuration + 1)
			task.delay(itemDuration, function()
				if instance and instance.Parent ~= nil and attachment2 then
					clone3.Enabled = false
					clone4.Enabled = false
				end
			end)
		end)
	end

	task.spawn(function()
		originalStamina.Value += 25
		currentStamina.Value += 25
		local v4 = StatModifierManager.ApplyModifier(instance, "SpeedModifier", 1.1, "Chocolate", {
			category = "item"
		})
		BuffIndicator.raise(instance, "ItemChocolate", itemDuration)
		task.wait(itemDuration)

		if instance and instance.Parent ~= nil then
			originalStamina.Value -= 25
			StatModifierManager.RemoveModifier(instance, "SpeedModifier", v4)
		end
	end)
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 2
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Chocolate