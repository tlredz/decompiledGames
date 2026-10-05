local AbilityConfig = {
	Type = {
		Instant = "instant",
		HoldSelf = "hold_self",
		HoldTargeted = "hold_targeted"
	}
}

function AbilityConfig.getType(data)
	if not (data and (data.ActiveAbility or data.HoldProximityAbility)) then
		return nil
	end

	if not data.HoldProximityAbility then
		return AbilityConfig.Type.Instant
	end

	if data.SelfTargetedAbility then
		return AbilityConfig.Type.HoldSelf
	end

	return AbilityConfig.Type.HoldTargeted
end

AbilityConfig.Extended = {}

function AbilityConfig.getExtended(p)
	return AbilityConfig.Extended[p] or {}
end

return AbilityConfig