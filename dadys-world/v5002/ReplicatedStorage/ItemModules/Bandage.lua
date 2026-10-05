local Bandage = {
	Name = "Bandage",
	PointCost = 60,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Rare",
	Icon = "rbxassetid://17562647343",
	Description = "Use this item when injured to heal 1 Heart."
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Bandage.UseItem(instance, p)
	local humanoid = instance:WaitForChild("Humanoid")

	if humanoid.Health >= humanoid.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use that item at full Health!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Items.Bandage.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	humanoid.Health += 1
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Health!"
	}
end

return Bandage