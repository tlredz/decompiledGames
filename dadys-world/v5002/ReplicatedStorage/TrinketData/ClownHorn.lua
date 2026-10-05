local StatModifierManager = require(game.ReplicatedStorage.Modules.Data.StatModifierManager)
local v = {}
local ClownHorn = {
	Name = "Clown Horn",
	Icon = "rbxassetid://74598622618781",
	Rarity = "Uncommon",
	Description = "Increases your Walk and Run Speed by 10% on odd-numbered floors.",
	TrinketType = "Toggle",
	TrinketState = "Speed",
	MonsterTrinket = true,
	Cost = 450
}
ClownHorn.Requirement1 = { "Coin", ClownHorn.Cost }

function ClownHorn.ApplyTrinket(p, instance)
	local active = instance:WaitForChild("Active")
	active.Value = false

	local function updateSpeed()
		if workspace.Info.Floor.Value % 2 == 1 then
			if not v[p] then
				v[p] = StatModifierManager.ApplySpeedModifiers(p, 1.1, "ClownHorn", {
					category = "trinket"
				})

				if active and active.Parent then
					active.Value = true
				end
			end
		elseif active and active.Value then
			if v[p] then
				StatModifierManager.RemoveSpeedModifiers(p, v[p])
				v[p] = nil
			end

			active.Value = false
		end
	end

	updateSpeed()
	workspace.Info.Floor.Changed:Connect(updateSpeed)
end

function ClownHorn.RemoveTrinket(instance)
	local active = instance:FindFirstChild("Trinkets"):FindFirstChild("ClownHorn"):FindFirstChild("Active")

	if active and active.Value and v[instance] then
		StatModifierManager.RemoveSpeedModifiers(instance, v[instance])
		v[instance] = nil
	end
end

return ClownHorn