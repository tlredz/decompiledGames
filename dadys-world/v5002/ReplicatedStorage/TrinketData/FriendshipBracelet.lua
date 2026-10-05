local FriendshipBracelet = {
	Name = "Friendship Bracelet",
	Icon = "rbxassetid://17653809548",
	Rarity = "Common",
	Description = "Gain 5 Stamina for every alive Toon in the round. Maxes at 40 Stamina.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 350
}
FriendshipBracelet.Requirement1 = { "Coin", FriendshipBracelet.Cost }
local v = {}

function FriendshipBracelet.ApplyTrinket(instance)
	local stats = instance:FindFirstChild("Stats")

	if not stats then
		return
	end

	local originalStamina = stats:FindFirstChild("OriginalStamina")
	local currentStamina = stats:FindFirstChild("CurrentStamina")

	if not (originalStamina and currentStamina) then
		return
	end

	local inGamePlayers = workspace:FindFirstChild("InGamePlayers")

	if not inGamePlayers then
		return
	end

	local v2 = {
		connections = {},
		bonusApplied = 0
	}
	v[instance] = v2
	task.spawn(function()
		task.wait(5)

		if not instance.Parent then
			return
		end

		local bonusApplied = math.min(#inGamePlayers:GetChildren() * 5, 40)
		originalStamina.Value += bonusApplied
		currentStamina.Value += bonusApplied
		v2.bonusApplied = bonusApplied
		v2.connections[1] = inGamePlayers.ChildAdded:Connect(function()
			if not instance.Parent then
				return
			end

			local bonusApplied2 = math.min(v2.bonusApplied + 5, 40)
			local v7 = bonusApplied2 - v2.bonusApplied

			if v7 > 0 then
				originalStamina.Value += v7
				currentStamina.Value += v7
				v2.bonusApplied = bonusApplied2
			end
		end)
		v2.connections[2] = inGamePlayers.ChildRemoved:Connect(function()
			if not instance.Parent then
				return
			end

			local bonusApplied2 = math.max(v2.bonusApplied - 5, 0)
			local v7 = v2.bonusApplied - bonusApplied2

			if v7 > 0 then
				originalStamina.Value -= v7
				currentStamina.Value = math.min(currentStamina.Value, originalStamina.Value)
				v2.bonusApplied = bonusApplied2
			end
		end)
	end)
end

function FriendshipBracelet.RemoveTrinket(instance)
	local trinkets = instance:FindFirstChild("Trinkets")

	if not trinkets then
		return "CantRemove"
	end

	local trinket1 = trinkets:FindFirstChild("Trinket1")
	local trinket2 = trinkets:FindFirstChild("Trinket2")

	if not (trinket1 and trinket2) then
		return "CantRemove"
	end

	local function cleanup()
		local v2 = v[instance]

		if v2 then
			for _, connection in pairs(v2.connections) do
				connection:Disconnect()
			end

			local stats = v2.bonusApplied > 0 and instance:FindFirstChild("Stats")

			if stats then
				local originalStamina = stats:FindFirstChild("OriginalStamina")
				local currentStamina = stats:FindFirstChild("CurrentStamina")

				if originalStamina then
					originalStamina.Value -= v2.bonusApplied
				end

				if currentStamina then
					currentStamina.Value = math.min(
						currentStamina.Value,
						originalStamina and originalStamina.Value or currentStamina.Value
					)
				end
			end

			v[instance] = nil
		end
	end

	if trinket1.Value == script.Name then
		trinket1.Value = "None"
		cleanup()
		return "Slot1"
	else
		if trinket2.Value ~= script.Name then
			return "CantRemove"
		end

		trinket2.Value = "None"
		cleanup()
		return "Slot2"
	end
end

return FriendshipBracelet