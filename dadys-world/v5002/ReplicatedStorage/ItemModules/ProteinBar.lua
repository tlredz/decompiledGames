local ProteinBar = {
	Name = "Protein Bar",
	PointCost = 45,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Uncommon",
	Icon = "rbxassetid://17725435324",
	Description = "Use this item to increase your Stamina Regeneration by 150% for 15 seconds.",
	ItemDuration = 15
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function ProteinBar.UseItem(instance, p)
	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.ProteinBar.UseSound", {
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
			Debris:AddItem(clone, ProteinBar.ItemDuration + 1)
			Debris:AddItem(clone2, ProteinBar.ItemDuration + 1)
			Debris:AddItem(attachment, ProteinBar.ItemDuration + 1)
			task.delay(ProteinBar.ItemDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
					clone2.Enabled = false
				end
			end)
		end)
	end

	task.spawn(function()
		local v2 = StatModifierManager.ApplyStaminaRegenModifier(instance, 2.5, "ProteinBar", {
			category = "item"
		})
		BuffIndicator.raise(instance, "ItemProteinBar", ProteinBar.ItemDuration)
		task.wait(ProteinBar.ItemDuration)

		if instance and instance.Parent ~= nil then
			StatModifierManager.RemoveStaminaRegenModifier(instance, v2)
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

return ProteinBar