local LungePursuit = {}
local v = {
	threshold = 2,
	speedMultiplier = 1.6,
	duration = 1.2,
	cooldown = 8,
	windup = 0.6
}
local v2 = nil

local function getMonsterAI()
	if v2 then
		return v2
	end

	local success, result = pcall(function()
		local ServerScriptService = game:GetService("ServerScriptService")
		return require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))
	end)

	if success and result then
		v2 = result
	end

	return v2
end

local ServerScriptService = game:GetService("ServerScriptService")
local SpeedControlModule = require(ServerScriptService:WaitForChild("MonsterAI"):WaitForChild("Modules"):WaitForChild("SpeedControlModule"))
local object = setmetatable({}, {
	__mode = "k"
})

local function resolveAI(p)
	if not v2 then
		local success, result = pcall(function()
			local ServerScriptService2 = game:GetService("ServerScriptService")
			return require(ServerScriptService2:WaitForChild("MonsterAI"):WaitForChild("MonsterAI"))
		end)

		if success and result then
			v2 = result
		end
	end

	local v3 = v2

	if not (v3 and v3.getActiveInstances) then
		return nil
	end

	for _, v4 in ipairs(v3.getActiveInstances()) do
		if v4.chaser == p then
			return v4
		end
	end

	return nil
end

local function mergeOver(items, items2)
	local result = {}

	for k, item in pairs(items) do
		result[k] = item
	end

	if type(items2) == "table" then
		for k, item in pairs(items2) do
			if item ~= nil then
				result[k] = item
			end
		end
	end

	return result
end

local function readAttributeConfig(instance)
	local lungePursuit = instance:GetAttribute("LungePursuit")

	if type(lungePursuit) ~= "string" or lungePursuit == "" then
		return nil
	end

	local success, result = pcall(function()
		local HttpService = game:GetService("HttpService")
		return HttpService:JSONDecode(lungePursuit)
	end)

	if success and type(result) == "table" then
		return result
	end

	return nil
end

local function resolveConfig(model, p, p2)
	local v4 = {}

	for k, v5 in pairs(v) do
		v4[k] = v5
	end

	if p2 and type(p2.monsterModule) == "table" and type(p2.monsterModule.LungePursuit) == "table" then
		v4 = mergeOver(v4, p2.monsterModule.LungePursuit)
	end

	return (mergeOver(mergeOver(v4, readAttributeConfig(model)), p))
end

local function shouldLunge(model, config, p, now, p2)
	if p.active or now < (p.onCooldownUntil or 0) or (model:GetAttribute("_KiteEscalation") or 0) < config.threshold or not model:GetAttribute("Chasing") then
		return false
	end

	return not model:GetAttribute("_MonsterAbilityFrozen") and not (p2 and p2.hitCooldown)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function restoreBurst(p, instance, p2)
	pcall(function()
		p.config.attackspeed.Value = p.config.attackspeed.Value / p2.speedMultiplier

		if instance.Parent then
			local v3 = instance:GetAttribute("Chasing") and "chase" or "patrol"
			SpeedControlModule.applySpeed(p, v3)
		end
	end)
end

local function runLunge(model, state)
	local config = state.config
	state.active = true
	state.generation = (state.generation or 0) + 1
	local generation = state.generation
	model:SetAttribute("_LungeWindup", true)
	task.delay(config.windup, function()
		local v3

		if object[model] == state then
			v3 = state.generation == generation
		else
			v3 = false
		end

		if v3 and model.Parent then
			if model:GetAttribute("Chasing") and not model:GetAttribute("_MonsterAbilityFrozen") then
				local v4 = resolveAI(model)

				if v4 and v4.config and v4.config.attackspeed and not v4.hitCooldown then
					model:SetAttribute("_LungeWindup", nil)
					local flag = false

					-- equivalent calls inferred from this helper; original call sites unknown
					local function restoreOnce()
						if flag then
							return
						end

						flag = true
						restoreBurst(v4, model, config) -- equivalent call inferred; original call site unknown
					end

					local flag2 = false
					pcall(function()
						v4.config.attackspeed.Value = v4.config.attackspeed.Value * config.speedMultiplier
						flag2 = true
						SpeedControlModule.applySpeed(v4, "chase")
					end)

					if flag2 then
						task.delay(config.duration, function()
							restoreOnce() -- equivalent call inferred; original call site unknown

							if object[model] == state and state.generation == generation then
								state.active = false
								state.onCooldownUntil = os.clock() + config.cooldown
							end
						end)
						return
					end

					state.active = false
					state.onCooldownUntil = os.clock() + config.cooldown
					return
				end

				model:SetAttribute("_LungeWindup", nil)
				state.active = false
			else
				model:SetAttribute("_LungeWindup", nil)
				state.active = false
			end
		else
			if model.Parent and model:GetAttribute("_LungeWindup") then
				model:SetAttribute("_LungeWindup", nil)
			end

			state.active = false
		end
	end)
end

function LungePursuit.unwatch(instance)
	local v3 = object[instance]

	if not v3 then
		return
	end

	object[instance] = nil

	if v3.connChanged then
		v3.connChanged:Disconnect()
	end

	if v3.connAncestry then
		v3.connAncestry:Disconnect()
	end

	v3.generation = (v3.generation or 0) + 1

	if instance.Parent and instance:GetAttribute("_LungeWindup") then
		instance:SetAttribute("_LungeWindup", nil)
	end
end

function LungePursuit.watch(model, p)
	if not (model and model:IsA("Model")) then
		warn("[LungePursuit] watch() needs a Model chaser")
		return
	end

	local v3 = object[model]

	if v3 then
		v3.config = resolveConfig(model, p, resolveAI(model))
		return
	end

	local v4 = {
		config = resolveConfig(model, p, resolveAI(model)),
		connChanged = nil,
		connAncestry = nil,
		generation = 0,
		onCooldownUntil = 0,
		active = false
	}
	object[model] = v4
	v4.connChanged = model:GetAttributeChangedSignal("_KiteEscalation"):Connect(function()
		local v5 = object[model]

		if v5 ~= v4 then
			return
		end

		local v6 = resolveAI(model)

		if not v5.config then
			v5.config = resolveConfig(model, p, v6)
		end

		if shouldLunge(model, v5.config, v5, os.clock(), v6) then
			runLunge(model, v5)
		end
	end)
	v4.connAncestry = model.AncestryChanged:Connect(function(_, parent)
		if not parent then
			LungePursuit.unwatch(model)
		end
	end)
end

function LungePursuit.isWatching(p)
	return object[p] ~= nil
end

return LungePursuit