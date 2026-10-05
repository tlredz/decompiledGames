local Pop = {
	Name = "Pop",
	PointCost = 25,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Common",
	Icon = "rbxassetid://93271836826715",
	Description = "Use this item when low on Stamina to regain 45 Stamina."
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Pop.UseItem(instance, p)
	local stats = instance:WaitForChild("Stats")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	local stamina = stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")

	if currentStamina.Value >= stamina.Value then
		return {
			Outcome = false,
			Reason = "Can't use that item at full Stamina!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		Audio:Play("Sounds.Items.Pop.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	currentStamina.Value += 45
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

return Pop