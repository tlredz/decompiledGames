local PeppermintIcing = {
	Name = "Peppermint Icing",
	Icon = "rbxassetid://108493977706775",
	Rarity = "Common",
	Description = "Grants 30 stamina after using any active ability.",
	TrinketType = "Passive",
	MonsterTrinket = true,
	Cost = 250
}
PeppermintIcing.Requirement1 = { "Coin", PeppermintIcing.Cost }

function PeppermintIcing.ApplyTrinket(instance, _)
	instance:WaitForChild("Trinkets")
	local stats = instance:WaitForChild("Stats")
	local currentStamina = stats:WaitForChild("CurrentStamina")
	local stamina = stats:WaitForChild("Stamina")
	local ability1 = instance:WaitForChild("Abilities"):FindFirstChild("Ability1")

	if ability1 then
		local currentCooldown = ability1:WaitForChild("CurrentCooldown")
		local cooldown = ability1:WaitForChild("Cooldown")

		-- equivalent calls inferred from this helper; original call sites unknown
		local function grantStamina()
			if currentStamina.Value < stamina.Value then
				currentStamina.Value += 30
			end

			if currentStamina.Value >= stamina.Value then
				currentStamina.Value = stamina.Value
			end
		end

		if not instance:GetAttribute("HasToggleAbility") then
			local value = currentCooldown.Value
			currentCooldown.Changed:Connect(function()
				local value2 = currentCooldown.Value

				if value < value2 and currentCooldown.Value >= cooldown.Value * 0.95 then
					if instance:GetAttribute("AbilityCooldownProvisional") then
						local abilityCooldownProvisionalChangedConnection = nil
						abilityCooldownProvisionalChangedConnection = instance:GetAttributeChangedSignal("AbilityCooldownProvisional"):Connect(function()
							if instance:GetAttribute("AbilityCooldownProvisional") then
								return
							end

							abilityCooldownProvisionalChangedConnection:Disconnect()

							if currentCooldown.Value > 0 then
								grantStamina() -- equivalent call inferred; original call site unknown
							end
						end)
					else
						grantStamina() -- equivalent call inferred; original call site unknown
					end
				end

				value = currentCooldown.Value
			end)
		end
	end
end

function PeppermintIcing.RemoveTrinket(instance)
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

return PeppermintIcing