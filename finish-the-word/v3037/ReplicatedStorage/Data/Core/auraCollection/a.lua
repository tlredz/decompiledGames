local A = {}

function A.FrostyAura(p)
	return {
		Duration = p.Duration,
		EffectInstances = {
			TimerRate = {
				Mult = 0
			}
		}
	}
end

function A.Celebration(p)
	return {
		Rotation = p.Rotation,
		EffectInstances = {
			Celebration = {}
		}
	}
end

function A.TimeModifier(data)
	return {
		Round = data.Round,
		EffectInstances = {
			TimeModifier = {
				Add = data.Add,
				Mult = data.Mult
			}
		}
	}
end

function A.CashReward(p)
	return {
		EffectInstances = {
			CashReward = {
				Add = p.Add,
				Mult = p.Mult
			}
		}
	}
end

function A.Shield(p)
	return {
		Round = p.Round,
		EffectInstances = {
			Shield = {}
		}
	}
end

function A.PetDisabled(p)
	return {
		Round = p.Round,
		EffectInstances = {
			PetDisabled = {
				Value = true
			}
		}
	}
end

return A