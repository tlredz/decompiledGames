game:GetService("ReplicatedStorage")
game:GetService("Players")
require(script.Types)
local EffectController = {
	Effects = {},
	ActiveEffects = {}
}

function EffectController:Activate(p: string)
	local effect = EffectController.Effects[p]

	if not effect then
		return false
	end

	if type(effect.Activate) == "function" then
		effect:Activate()
	end

	return true
end

function EffectController.Run(_, p: string, p2: string)
	local effect = EffectController.Effects[p2]

	if not effect then
		return false, false
	end

	if not EffectController.ActiveEffects[p2] then
		EffectController.ActiveEffects[p2] = {}
	end

	local clone = table.clone(EffectController.ActiveEffects[p2])
	EffectController.ActiveEffects[p2][p] = true

	if next(clone) then
		if type(effect.OnUpdate) == "function" then
			effect:OnUpdate()
		end

		return false, true
	else
		if type(effect.OnStart) == "function" then
			effect:OnStart()
		end

		return true, true
	end
end

function EffectController.Stop(_, p: string, p2: string)
	local effect = EffectController.Effects[p2]

	if not (effect and EffectController.ActiveEffects[p2] and next(EffectController.ActiveEffects[p2])) then
		return false
	end

	EffectController.ActiveEffects[p2][p] = nil

	if type(effect.OnUpdate) == "function" then
		effect:OnUpdate()
	end

	if next(EffectController.ActiveEffects[p2]) then
		return false
	end

	EffectController.ActiveEffects[p2] = nil

	if type(effect.OnStop) == "function" then
		effect:OnStop()
	end

	return true
end

function EffectController.Load(_)
	for _, moduleScript in script.Effects:GetChildren() do
		if not moduleScript:IsA("ModuleScript") then
			continue
		end

		local v, v2 = coroutine.resume(coroutine.create(require), moduleScript)

		if v and type(v2) == "table" then
			if type(v2.OnLoad) == "function" then
				local v3, v4 = coroutine.resume(coroutine.create(v2.OnLoad), v2)

				if not v3 then
					warn((`Effect {moduleScript:GetFullName()} failed to call Load function:\n{v4 == nil and "yielded (possibly)" or v4}`))
					continue
				end
			end

			EffectController.Effects[moduleScript.Name] = v2
		else
			warn((`Effect {moduleScript:GetFullName()} failed to load:\n{v2 == nil and "yielded (possibly)" or v2}`))
		end
	end
end

function EffectController.Start(_) end

return EffectController