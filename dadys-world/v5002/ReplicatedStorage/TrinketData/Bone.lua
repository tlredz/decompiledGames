local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local Bone = {
	Name = "Bone",
	Icon = "rbxassetid://17653810274",
	Rarity = "Common",
	Description = "Increases both Walk and Run Speed by 25% when picking up an Item for 4 seconds. Effect can stack but caps at 40 speed. (Does not include Capsules and Tapes).",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
Bone.Requirement1 = { "Coin", Bone.Cost }

function Bone.ApplyTrinket(instance)
	local inventory = instance:WaitForChild("Inventory")
	local stats = instance:WaitForChild("Stats")
	local runSpeed = stats:WaitForChild("RunSpeed")
	local runSpeedModifier = stats:WaitForChild("RunSpeedModifier")
	local slot1 = inventory:WaitForChild("Slot1")
	local slot2 = inventory:WaitForChild("Slot2")
	local slot3 = inventory:WaitForChild("Slot3")
	local slot4 = inventory:FindFirstChild("Slot4")

	local function applyBoneBoost()
		if runSpeed.Value * runSpeedModifier.Value >= 40 then
			return
		end

		local v = 40 / runSpeed.Value
		local value = runSpeedModifier.Value
		local v2 = math.min(value * 1.25, v) / value
		local v3 = StatModifierManager.ApplySpeedModifiers(instance, v2, "Bone", {
			category = "trinket"
		})
		task.wait(4)
		StatModifierManager.RemoveSpeedModifiers(instance, v3)
	end

	slot1.Changed:Connect(function()
		if slot1.Value ~= "None" then
			applyBoneBoost()
		end
	end)
	slot2.Changed:Connect(function()
		if slot2.Value ~= "None" then
			applyBoneBoost()
		end
	end)
	slot3.Changed:Connect(function()
		if slot3.Value ~= "None" then
			applyBoneBoost()
		end
	end)

	if slot4 then
		slot4.Changed:Connect(function()
			if slot4.Value ~= "None" then
				applyBoneBoost()
			end
		end)
	end
end

function Bone.RemoveTrinket(instance)
	local trinkets = instance:WaitForChild("Trinkets")
	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		return "Slot1"
	end

	if trinket2.Value ~= script.Name then
		return "CantRemove"
	end

	trinket2.Value = "None"
	return "Slot2"
end

return Bone