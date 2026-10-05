local Valve = {
	Name = "Valve",
	PointCost = 150,
	DandyStoreItem = true,
	FloorItem = false,
	Rarity = "UltraRare",
	Icon = "rbxassetid://18583522993",
	Description = "Use this item while Extracting a Machine to instantly complete it.",
	ItemAmount = 999
}
game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
require(ReplicatedStorage.Modules.Audio.SoundUtils)
local Audio = require(ReplicatedStorage.SharedUtils.Audio)

function Valve.UseItem(instance, p)
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
		currentAmount.Value += Valve.ItemAmount

		if child then
			child.Value += Valve.ItemAmount
		else
			local numberValue = Instance.new("NumberValue")
			numberValue.Name = instance.Name
			numberValue.Value = Valve.ItemAmount
			numberValue.Parent = playerCompletion
		end

		if currentAmount.Value >= requiredAmount.Value then
			currentAmount.Value = requiredAmount.Value
		end

		pcall(function()
			local value = decoding.Value
			local stats3 = value:FindFirstChild("Stats")
			local completed = stats3 and stats3:FindFirstChild("Completed")
			local v2 = {}
			local v3 = false

			if stats3 then
				for _, objectValue in ipairs(stats3:GetChildren()) do
					if not (objectValue:IsA("ObjectValue") and objectValue.Name:match("^ActivePlayer%d*$")) then
						continue
					end

					local value2 = objectValue.Value
					table.insert(v2, objectValue.Name .. "=" .. (not value2 and "nil" or value2.Name or "nil"))

					if value2 == instance then
						v3 = true
					end
				end
			end

			print(string.format(
				"[Valve] %s used valve on %s (parent=%s) amount=%.1f/%.1f completed=%s registeredAsOccupant=%s slots=[%s]",
				instance.Name,
				value.Name,
				not value.Parent and "nil" or value.Parent.Name or "nil",
				currentAmount.Value,
				requiredAmount.Value,
				tostring(completed and completed.Value),
				tostring(v3),
				table.concat(v2, " ")
			))

			if not v3 then
				warn(string.format(
					"[Valve] %s is Decoding %s but is NOT registered on any of its slots — the completion bell will not ring for this bump",
					instance.Name,
					value.Name
				))
			end
		end)
		Audio:Play("Sounds.Items.Valve.UseSound", {
			Parent = instance:WaitForChild("HumanoidRootPart")
		})
	end

	p.Value = "None"
	local child = workspace.Info.PlayerStats:FindFirstChild(instance.Name)

	if child then
		local survivalPoints = child:WaitForChild("SurvivalPoints")
		survivalPoints.Value += 10
	end

	return {
		Outcome = true,
		Reason = "Can't use that item at full Stamina!"
	}
end

return Valve