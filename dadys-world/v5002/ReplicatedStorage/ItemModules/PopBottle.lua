local PopBottle = {
	Name = "Bottle o' Pop",
	PointCost = 85,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "VeryRare",
	Icon = "rbxassetid://86175986097521",
	Description = "Use this item when low on Stamina to refill your Stamina to full capacity."
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function PopBottle.UseItem(instance, p)
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
		Audio:Play("Sounds.Items.PopBottle.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	currentStamina.Value += stamina.Value
	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 8
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return PopBottle