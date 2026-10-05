local import = _G.import("aura")
local import2 = _G.import("class")
local import3 = _G.import("event")
local import4 = _G.import("global")
local import5 = _G.import("dictUtil")
local RunService = game:GetService("RunService")
local isServer = RunService:IsServer()
local v = import2.new()

function v:debounce(...)
	local playerByUserId = game.Players:GetPlayerByUserId(self.UserId)

	if not playerByUserId then
		return
	end

	local character = playerByUserId.Character
	local agent = import.getAgent(character)

	if not agent then
		return false
	end

	for _, v2 in pairs({ ... }) do
		if agent.EffectCache[v2] or agent.EffectCache[v2 .. "Silence"] then
			return true
		end
	end
end

function v:cooldown(p, inputDuration, ...)
	local playerByUserId = game.Players:GetPlayerByUserId(self.UserId)

	if not playerByUserId then
		return
	end

	local character = playerByUserId.Character
	local cooldownInstances = self.Character.CooldownInstances
	local duration = isServer and inputDuration or nil
	cooldownInstances[p] = cooldownInstances[p] or {}
	local cooldownInstance = cooldownInstances[p]

	for _, v3 in pairs({ ... }) do
		cooldownInstance[v3] = import.applyAura(character, "Cooldown", {
			Type = v3,
			InputDuration = inputDuration,
			Duration = duration
		})

		if not duration then
			continue
		end

		local v4 = v3
		task.delay(duration, function()
			cooldownInstance[v4] = nil

			if isServer then
				import3.remoteFire(playerByUserId, "removeCooldown", p, v4)
			end
		end)
	end
end

function v:removeCooldown(p, ...)
	local playerByUserId = game.Players:GetPlayerByUserId(self.UserId)

	if not playerByUserId then
		return
	end

	local character = playerByUserId.Character
	local cooldownInstance = self.Character.CooldownInstances[p]

	if not cooldownInstance then
		return
	end

	for _, v2 in pairs({ ... }) do
		import.removeAuraInstance(character, cooldownInstance[v2])
		cooldownInstance[v2] = nil
	end

	if import5.count(cooldownInstance) == 0 then
		self.Character.CooldownInstances[p] = nil
	end
end

function v:debounceCooldown(p, p2, ...)
	if self:debounce(...) then
		return true
	end

	self:cooldown(p, p2, ...)
end

if not isServer then
	import3.remoteConnect("removeCooldown", function(p, p2)
		import4.get("playerSession", game.Players.LocalPlayer):removeCooldown(p, p2)
	end)
end

return v