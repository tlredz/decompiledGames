local import = _G.import("event")
local import2 = _G.import("class")
local import3 = _G.import("dictUtil")
local import4 = _G.import("iterator")
local v = nil
local v2 = nil
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local v3 = {}
local Aura = {}
local v4 = import2.new()

function v4:add(p2)
	self.AuraInstances[p2.AuraInstanceId] = p2
end

function v4.has(p, p2)
	if p.AuraInstances[p2] then
		return true
	end

	return false
end

function v4:get(p2)
	return self.AuraInstances[p2]
end

function v4.remove(p, p2)
	local auraInstance = p.AuraInstances[p2]

	for k, _ in pairs(auraInstance.Attached) do
		Aura.removeAuraInstance(p.Object, k)
	end

	p.AuraInstances[p2] = nil
	import.fire("auraChanged", p.Object, auraInstance.AuraId, false)
	return auraInstance
end

function v4.getEffectInstances(p, p2)
	local effectInstances = {}

	for k, auraInstance in pairs(p.AuraInstances) do
		if p.DisabledMap[k] then
			continue
		end

		for k2, effectInstance in pairs(auraInstance.AuraSpecification.EffectInstances) do
			if k2 == p2 then
				effectInstances[#effectInstances + 1] = effectInstance
			end
		end
	end

	return effectInstances
end

function v4:hasEffect(p2)
	for _, auraInstance in pairs(self.AuraInstances) do
		for k, _ in pairs(auraInstance.AuraSpecification.EffectInstances) do
			if k == p2 then
				return true
			end
		end
	end

	return false
end

function v4:getAuraInstances(p2)
	local auraInstances = {}

	for k, auraInstance in pairs(self.AuraInstances) do
		if auraInstance.AuraId == p2 then
			auraInstances[k] = auraInstance
		end
	end

	return auraInstances
end

function v4:getAuras()
	local auraIdsByAuraId = {}

	for _, auraInstance in pairs(self.AuraInstances) do
		auraIdsByAuraId[auraInstance.AuraId] = auraInstance.AuraId
	end

	return auraIdsByAuraId
end

function v4:hasAura(p)
	if self:getAuras()[p] then
		return true
	end

	return false
end

function v4:new(object)
	local ancestryChangedConnection = nil
	ancestryChangedConnection = object.AncestryChanged:Connect(function(_, _)
		if object:IsDescendantOf(game) then
			return
		end

		ancestryChangedConnection:Disconnect()

		for k, auraInstance in pairs(self.AuraInstances) do
			if auraInstance.Cleanup then
				Aura.removeAuraInstance(object, k)
			end
		end

		task.wait(0)
		v3[object] = nil
	end)
	self.Object = object
	self.AuraInstances = {}
	self.EffectCache = {}
	self.Ticks = {}
	self.DisabledMap = {}
end

local v5 = import2.new()

function v5:new(auraId, callback, options, p)
	self.AuraId = auraId
	self.AuraSpecification = callback(options or {}, p)
	self.AuraInstanceId = HttpService:GenerateGUID()
	self.Cleanup = import3.remove(self.AuraSpecification, "Cleanup")
	self.Attached = {}
	local effectInstances = self.AuraSpecification.EffectInstances

	for k, v6 in pairs(self.AuraSpecification.Attached or {}) do
		local v7 = Aura.applyAura(p, k, v6)
		self.Attached[v7] = k
	end

	self.AuraSpecification.Attached = nil

	for k, v6 in pairs(self.AuraSpecification) do
		if k == "EffectInstances" then
			continue
		end

		for _, effectInstance in pairs(effectInstances) do
			effectInstance[k] = v6
		end
	end

	for _, effectInstance in pairs(effectInstances) do
		effectInstance.AuraId = auraId
		effectInstance.AuraInstanceId = self.AuraInstanceId
	end
end

local function runEffect(object, p)
	v2 = v2 or _G.import("effectCollection")
	local v6 = v2:get(p)
	local effectInstances = object:getEffectInstances(p)
	local copy = type(v6.Default) == "table" and import3.deepCopy(v6.Default) or v6.Default

	for _, effectInstance in pairs(effectInstances) do
		local v8
		copy, v8 = v6.reduce(copy, effectInstance)

		if v8 then
			break
		end
	end

	local v8 = object.EffectCache[p]
	object.EffectCache[p] = #effectInstances > 0 and copy or nil

	if type(copy) == "table" and type(v8) == "table" and import3.match(copy, v8) or copy == v8 then
		return
	end

	v6.apply(object.Object, copy, effectInstances)
	import.fire("effectApplied", object.Object, p, copy)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function runEffects(p, p2)
	for k, _ in pairs(p2.AuraSpecification.EffectInstances) do
		runEffect(p, k)
	end
end

local function runAuraMeta(p, p2, fn)
	for k, effectInstance in pairs(p.AuraSpecification.EffectInstances) do
		if effectInstance[p2] then
			fn(k, effectInstance)
		end
	end
end

local function removeEffectInstance(object, data, p)
	if not (data.Cleanup or object.Object.Parent) then
		return
	end

	local effectInstances = data.AuraSpecification.EffectInstances

	if not effectInstances[p] then
		return
	end

	effectInstances[p] = nil

	if import3.count(data.AuraSpecification.EffectInstances) == 0 then
		object:remove(data.AuraInstanceId)
	end

	local ticks = object.Ticks

	if ticks[p] and not object:hasEffect(p) then
		import.deschedule(ticks[p])
		ticks[p] = nil
	end

	runEffect(object, p)
end

if RunService:IsClient() then
	import.remoteConnect("ReplicateAura", function(p, p2, p3)
		Aura.applyAura(p, p2, p3)
	end)
	import.remoteConnect("ReplicateRemoveAura", function(p, p2)
		Aura.removeAura(p, p2)
	end)
else
	function Aura.replicateAura(p, p2, p3)
		local v6 = Aura.applyAura(p, p2, p3)
		import.fireAll("ReplicateAura", p, p2, p3)
		return v6
	end

	function Aura.replicateRemoveAura(p, p2)
		Aura.removeAura(p, p2)
		import.fireAll("ReplicateRemoveAura", p, p2)
	end

	function Aura.replicateAuraExclusive(p, p2, p3, p4)
		local v6 = Aura.applyAura(p2, p3, p4)
		import.replicate(p, "ReplicateAura", p2, p3, p4)
		return v6
	end

	function Aura.replicateRemoveAuraExclusive(p, p2, p3, _)
		Aura.removeAura(p2, p3)
		import.replicate(p, "ReplicateRemoveAura", p2, p3)
	end
end

function Aura.applyAura(p, p2, p3)
	v = v or _G.import("auraCollection")

	if not p then
		warn("attempt to apply aura to nil obj")
	end

	if not p.Parent then
		warn("object must be parented to apply aura")
		return
	end

	local v6 = v3[p] or v4(p)
	v3[p] = v6
	local v8 = v5(p2, v:get(p2), p3, p)
	local auraInstanceId = v8.AuraInstanceId
	v6:add(v8)
	runEffects(v6, v8) -- equivalent call inferred; original call site unknown
	local ticks = v6.Ticks
	runAuraMeta(v8, "Tick", function(p4, p5)
		if ticks[p4] then
			return
		end

		ticks[p4] = import.schedule(p5.Tick, function()
			runEffect(v6, p4)
		end, "tick " .. p4)
	end)
	runAuraMeta(v8, "Duration", function(p4, p5)
		task.delay(p5.Duration, function()
			removeEffectInstance(v6, v8, p4)
		end)
	end)
	import.fire("auraChanged", p, p2, true)
	return auraInstanceId
end

function Aura.getAuraInstance(p, p2)
	local v6 = v3[p]

	if v6 then
		return v6:get(p2)
	end
end

function Aura.removeAuraInstance(p, p2)
	local v6 = v3[p]

	if not v6 then
		return
	end

	local v7 = v6:get(p2)

	if not v7 then
		return
	end

	for k, _ in pairs(v7.AuraSpecification.EffectInstances) do
		removeEffectInstance(v6, v7, k)
	end
end

function Aura.removeAura(p, p2)
	v = v or _G.import("auraCollection")
	local v6 = v3[p]

	if not v6 then
		return
	end

	assert(v:get(p2), "Attempted to remove non-existant aura" .. p2)

	for k, _ in pairs(v6:getAuraInstances(p2)) do
		Aura.removeAuraInstance(p, k)
	end
end

function Aura:getAuraInstances(p2)
	local v6 = v3[self]

	if v6 then
		return v6:getAuraInstances(p2)
	end

	return {}
end

function Aura.getEffectInstances(p, p2)
	local v6 = v3[p]

	if v6 then
		return v6:getEffectInstances(p2)
	end

	return {}
end

function Aura.getEffectDuration(p, p2)
	return import4.values(Aura.getEffectInstances(p, p2)):map(function(p3)
		return p3.Duration
	end):max()
end

function Aura:getAuras()
	local v6 = v3[self]

	if v6 then
		return v6:getAuras()
	end

	return {}
end

function Aura:hasAura(p2)
	local v6 = v3[self]

	if v6 then
		return v6:hasAura(p2)
	end

	return false
end

function Aura.getAgent(p)
	return v3[p]
end

function Aura:hasEffect(p2)
	local v6 = v3[self]

	if not v6 then
		return false
	end

	if v6.EffectCache[p2] then
		return true
	end

	return false
end

function Aura.getEffectValue(p, p2)
	v2 = v2 or _G.import("effectCollection")
	local v6 = v3[p]
	return v6 and v6.EffectCache[p2] or v2:get(p2).Default
end

function Aura.enableAuraInstance(p, p2)
	local v6 = v3[p]
	v6.DisabledMap[p2] = nil
	runEffects(v6, v6:get(p2)) -- equivalent call inferred; original call site unknown
end

function Aura.disableAuraInstance(p, p2, duration)
	local v6 = v3[p]
	local v7 = v6.DisabledMap[p2] or {}
	local GUID = HttpService:GenerateGUID()
	v6.DisabledMap[p2] = v7
	v7[GUID] = true
	runEffects(v6, v6:get(p2)) -- equivalent call inferred; original call site unknown

	local function disconnector()
		v7[GUID] = nil

		if import3.count(v7) == 0 then
			v6.DisabledMap[p2] = nil
		end

		runEffects(v6, v6:get(p2)) -- equivalent call inferred; original call site unknown
	end

	if duration then
		task.delay(duration, disconnector)
	end

	return disconnector
end

return Aura