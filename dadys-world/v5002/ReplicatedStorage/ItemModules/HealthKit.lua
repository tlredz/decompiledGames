local HealthKit = {
	Name = "Health Kit",
	PointCost = 100,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "VeryRare",
	Icon = "rbxassetid://17564526592",
	Description = "Use this item when injured to fully restore all of your Hearts."
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function HealthKit.UseItem(instance, p)
	local humanoid = instance:WaitForChild("Humanoid")

	if humanoid.Health >= humanoid.MaxHealth then
		return {
			Outcome = false,
			Reason = "Can't use that item at full Health!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Items.HealthKit.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	humanoid.Health = humanoid.MaxHealth
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 8
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Health!"
	}
end

return HealthKit