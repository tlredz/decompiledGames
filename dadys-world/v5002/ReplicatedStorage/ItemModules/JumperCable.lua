local JumperCable = {
	Name = "Jumper Cable",
	PointCost = 65,
	DandyStoreItem = true,
	FloorItem = true,
	Rarity = "Rare",
	Icon = "rbxassetid://17715327284",
	Description = "Use this item while Extracting a Machine to add a large amount of completion to it.",
	ItemAmount = 15
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function JumperCable.UseItem(instance, p)
	local stats = instance:WaitForChild("Stats")
	stats:WaitForChild("CurrentStamina")
	stats:WaitForChild("Stamina")
	instance:WaitForChild("Humanoid")
	local decoding = instance:WaitForChild("Decoding")
	stats:WaitForChild("DecodeSpeedModifier")
	stats:WaitForChild("RunSpeed")
	stats:WaitForChild("WalkSpeed")

	if decoding.Value == nil then
		return {
			Outcome = false,
			Reason = "Item can only be used while extracting a Machine!"
		}
	end

	if instance:FindFirstChild("HumanoidRootPart") then
		local stats2 = decoding.Value:WaitForChild("Stats")
		local currentAmount = stats2:WaitForChild("CurrentAmount")
		local requiredAmount = stats2:WaitForChild("RequiredAmount")
		local playerCompletion = decoding.Value:WaitForChild("PlayerCompletion")
		local child = playerCompletion:FindFirstChild(instance.Name)
		local v2 = requiredAmount.Value / 3
		currentAmount.Value += v2

		if child then
			child.Value += v2
		else
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = instance.Name
			numberValue.Value = v2
			numberValue.Parent = playerCompletion
		end

		if currentAmount.Value >= requiredAmount.Value then
			currentAmount.Value = requiredAmount.Value
		end

		print(string.format(
			"[JumperCable] %s -> %s: +%.1f (1/3 of meter %d) => %.0f%%",
			instance.Name,
			decoding.Value.Name,
			v2,
			requiredAmount.Value,
			currentAmount.Value / requiredAmount.Value * 100
		))
		Audio:Play("Sounds.Items.JumperCable.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 5
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return JumperCable