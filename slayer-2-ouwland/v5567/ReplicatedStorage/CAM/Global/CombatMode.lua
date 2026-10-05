local CombatMode = {
	Modes = {
		Arena = {
			PvP = true
		},
		Ranked = {
			PvP = true,
			Ranked = true
		},
		BalancerPvP = {
			PvP = true,
			Hits = true,
			Ranked = true
		}
	},
	Attribute = "CombatMode",
	SetMode = function(combatMode: string?, p)
		(p or workspace):SetAttribute("CombatMode", combatMode)
	end,
	Mode = function(instance)
		local combatMode

		if instance ~= nil then
			combatMode = instance:GetAttribute("CombatMode")
		end

		if combatMode == nil then
			combatMode = workspace:GetAttribute("CombatMode")
		end

		if typeof(combatMode) == "string" then
			return combatMode
		end

		return nil
	end
}

function CombatMode.InPvPMode(p)
	local mode = CombatMode.Mode(p)
	local v

	if mode ~= nil then
		v = CombatMode.Modes[mode]
	end

	return v ~= nil and v.PvP == true
end

function CombatMode.IsRanked(p)
	local mode = CombatMode.Mode(p)
	local v

	if mode ~= nil then
		v = CombatMode.Modes[mode]
	end

	return v ~= nil and v.Ranked == true
end

function CombatMode.PvPHits(p)
	local mode = CombatMode.Mode(p)
	local v

	if mode ~= nil then
		v = CombatMode.Modes[mode]
	end

	return v ~= nil and v.Hits == true
end

return CombatMode