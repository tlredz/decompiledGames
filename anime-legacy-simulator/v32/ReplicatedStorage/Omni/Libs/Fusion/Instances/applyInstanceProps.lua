local parent = script.Parent.Parent
require(parent.Types)
local External = require(parent.External)
local parseError = require(parent.Logging.parseError)
local checkLifetime = require(parent.Memory.checkLifetime)
local Observer = require(parent.Graph.Observer)
local castToState = require(parent.State.castToState)
local peek = require(parent.State.peek)
local xtypeof = require(parent.Utility.xtypeof)

local function setProperty_unsafe(p, p2: string, p3)
	p[p2] = p3
end

local function testPropertyAssignable(p, p2: string)
	p[p2] = p[p2]
end

local function setProperty(instance, p: string, p2)
	local v, v2 = xpcall(setProperty_unsafe, parseError, instance, p, p2)

	if not v then
		if not pcall(testPropertyAssignable, instance, p) then
			External.logErrorNonFatal("cannotAssignProperty", nil, instance.ClassName, p)
			return
		end

		local typeName = typeof(p2)
		local typeName2 = typeof(instance[p])

		if typeName == typeName2 then
			External.logErrorNonFatal("propertySetError", v2)
		else
			External.logErrorNonFatal("invalidPropertyType", nil, instance.ClassName, p, typeName2, typeName)
		end
	end
end

local function bindProperty(p, p2, p3: string, p4)
	if not castToState(p4) then
		setProperty(p2, p3, p4)
		return
	end

	checkLifetime.bOutlivesA(p, p2, p4.scope, p4.oldestTask, checkLifetime.formatters.boundProperty, p3)
	Observer(p, p4):onBind(function()
		setProperty(p2, p3, peek(p4))
	end)
end

local function applyInstanceProps(p, p2, p3)
	local v = {
		self = {},
		descendants = {},
		ancestor = {},
		observer = {}
	}

	for k, v2 in pairs(p2) do
		local v3 = xtypeof(k)

		if v3 == "string" then
			if k ~= "Parent" then
				bindProperty(p, p3, k, v2)
			end
		elseif v3 == "SpecialKey" then
			local stage = k.stage
			local v4 = v[stage]

			if v4 == nil then
				External.logError("unrecognisedPropertyStage", nil, stage)
			else
				v4[k] = v2
			end
		else
			External.logError("unrecognisedPropertyKey", nil, v3)
		end
	end

	for k, v2 in pairs(v.self) do
		k:apply(p, v2, p3)
	end

	for k, descendant in pairs(v.descendants) do
		k:apply(p, descendant, p3)
	end

	if p2.Parent ~= nil then
		bindProperty(p, p3, "Parent", p2.Parent)
	end

	for k, v2 in pairs(v.ancestor) do
		k:apply(p, v2, p3)
	end

	for k, v2 in pairs(v.observer) do
		k:apply(p, v2, p3)
	end
end

return applyInstanceProps