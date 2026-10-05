local Instructions = {
	Name = "Instructions",
	PointCost = 40,
	DandyStoreItem = true,
	FloorItem = false,
	Rarity = "Uncommon",
	Icon = "rbxassetid://17602982694",
	Description = "Use this item to increase Extraction Speed by 100% for 10 seconds when on a Machine.",
	ItemDuration = 10
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Instructions.UseItem(instance, p)
	if instance:WaitForChild("Decoding").Value == nil then
		return {
			Outcome = false,
			Reason = "Item can only be used while extracting a Machine!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.Instructions.UseSound", {
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
			Debris:AddItem(clone, Instructions.ItemDuration + 1)
			Debris:AddItem(clone2, Instructions.ItemDuration + 1)
			Debris:AddItem(attachment, Instructions.ItemDuration + 1)
			task.delay(Instructions.ItemDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
					clone2.Enabled = false
				end
			end)
		end)
	end

	task.spawn(function()
		local v2 = StatModifierManager.ApplyModifier(instance, "DecodeSpeedModifier", 2, "Instructions", {
			category = "item"
		})
		BuffIndicator.raise(instance, "ItemInstructions", Instructions.ItemDuration)
		task.wait(Instructions.ItemDuration)
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
		Reason = "Can't use that item at full Stamina!"
	}
end

return Instructions