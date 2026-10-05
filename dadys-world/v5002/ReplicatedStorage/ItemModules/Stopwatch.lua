local Stopwatch = {
	Name = "Stopwatch",
	PointCost = 18,
	DandyStoreItem = true,
	FloorItem = false,
	Rarity = "Common",
	Icon = "rbxassetid://17728670202",
	Description = "Use this item to increase Skill Check window size by 50 for 15 seconds.",
	ItemDuration = 15
}
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StatModifierManager = require(ReplicatedStorage.Modules.Data.StatModifierManager)
local ReplicatedStorage2 = game:GetService("ReplicatedStorage")
local BuffIndicator = require(ReplicatedStorage2.Modules.Gameplay.BuffIndicator)
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Stopwatch.UseItem(instance, p)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	stats:WaitForChild("Sprinting")
	stats:WaitForChild("SpeedModifier")
	stats:WaitForChild("BoundarySize")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("WalkSpeed")

	if instance:WaitForChild("Decoding").Value == nil then
		return {
			Outcome = false,
			Reason = "Item can only be used while extracting a Machine!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local humanoidRootPart = instance:WaitForChild("HumanoidRootPart")
		Audio:Play("Sounds.Items.Stopwatch.UseSound", {
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
			Debris:AddItem(clone, Stopwatch.ItemDuration + 1)
			Debris:AddItem(clone2, Stopwatch.ItemDuration + 1)
			Debris:AddItem(attachment, Stopwatch.ItemDuration + 1)
			task.delay(Stopwatch.ItemDuration, function()
				if instance and instance.Parent ~= nil and attachment then
					clone.Enabled = false
					clone2.Enabled = false
				end
			end)
		end)
	end

	task.spawn(function()
		local v2 = StatModifierManager.ApplyAdditiveBoundarySize(instance, 50, "Stopwatch")
		BuffIndicator.raise(instance, "ItemStopwatch", Stopwatch.ItemDuration)
		task.wait(Stopwatch.ItemDuration)
		StatModifierManager.RemoveAdditiveBoundarySize(instance, v2)
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

return Stopwatch