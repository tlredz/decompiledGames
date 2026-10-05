local GreenTea = require(script.Parent.GreenTea)
local InstanceClasses = require(script.Parent.InstanceClasses)
local v = {}

local function asPlainFn(callback)
	return function()
		return callback()
	end
end

local function asGreenTeaType(callback)
	if GreenTea.isGtType(callback) then
		return callback
	end

	if typeof(callback) == "function" then
		return GreenTea.custom(callback)
	end

	if callback == nil then
		return GreenTea.none()
	end

	return GreenTea.typeof(callback)
end

local v2 = {
	boolean = GreenTea.boolean,
	buffer = GreenTea.buffer,
	callback = GreenTea.anyfn,
	["function"] = GreenTea.anyfn,
	none = GreenTea.none,
	["nil"] = GreenTea.none
}
local string = GreenTea.string

function v2.string()
	return string()
end

local anyTable = GreenTea.anyTable

function v2.table()
	return anyTable()
end

local userdata = GreenTea.userdata

function v2.userdata()
	return userdata()
end

local vector = GreenTea.vector

function v2.vector()
	return vector()
end

local number = GreenTea.number

function v2.number()
	return number()
end

local coroutine = GreenTea.coroutine

function v2.thread()
	return coroutine()
end

function v2.any()
	return GreenTea.any()
end

function v2.nan()
	return (GreenTea.withCustom(GreenTea.number({
		nan = true
	}), function(p)
		return p ~= p
	end))
end

function v2.integer()
	return (GreenTea.number({
		integer = true
	}))
end

function v2.numberPositive()
	return (GreenTea.number({
		range = "(0, inf]"
	}))
end

function v2.numberNegative()
	return (GreenTea.number({
		range = "[-inf, 0)"
	}))
end

v2.Enum = GreenTea.Enum
v2.EnumItem = GreenTea.EnumItem

local function basicType(p: string)
	return GreenTea.__newBasicType(p)
end

v2.Axes = GreenTea.__newBasicType("Axes")
v2.BrickColor = GreenTea.__newBasicType("BrickColor")
v2.CatalogSearchParams = GreenTea.__newBasicType("CatalogSearchParams")
v2.CFrame = GreenTea.__newBasicType("CFrame")
v2.Color3 = GreenTea.__newBasicType("Color3")
v2.ColorSequence = GreenTea.__newBasicType("ColorSequence")
v2.ColorSequenceKeypoint = GreenTea.__newBasicType("ColorSequenceKeypoint")
v2.DateTime = GreenTea.__newBasicType("DateTime")
v2.DockWidgetPluginGuiInfo = GreenTea.__newBasicType("DockWidgetPluginGuiInfo")
v2.Enums = GreenTea.__newBasicType("Enums")
v2.Faces = GreenTea.__newBasicType("Faces")
v2.FloatCurveKey = GreenTea.__newBasicType("FloatCurveKey")
v2.Font = GreenTea.__newBasicType("Font")
v2.Instance = GreenTea.__newBasicType("Instance")
v2.NumberRange = GreenTea.__newBasicType("NumberRange")
v2.NumberSequence = GreenTea.__newBasicType("NumberSequence")
v2.NumberSequenceKeypoint = GreenTea.__newBasicType("NumberSequenceKeypoint")
v2.OverlapParams = GreenTea.__newBasicType("OverlapParams")
v2.PathWaypoint = GreenTea.__newBasicType("PathWaypoint")
v2.PhysicalProperties = GreenTea.__newBasicType("PhysicalProperties")
v2.Random = GreenTea.__newBasicType("Random")
v2.Ray = GreenTea.__newBasicType("Ray")
v2.RaycastParams = GreenTea.__newBasicType("RaycastParams")
v2.RaycastResult = GreenTea.__newBasicType("RaycastResult")
v2.RBXScriptConnection = GreenTea.__newBasicType("RBXScriptConnection")
v2.RBXScriptSignal = GreenTea.__newBasicType("RBXScriptSignal")
v2.Rect = GreenTea.__newBasicType("Rect")
v2.Region3 = GreenTea.__newBasicType("Region3")
v2.Region3int16 = GreenTea.__newBasicType("Region3int16")
v2.TweenInfo = GreenTea.__newBasicType("TweenInfo")
v2.UDim = GreenTea.__newBasicType("UDim")
v2.UDim2 = GreenTea.__newBasicType("UDim2")
v2.Vector2 = GreenTea.__newBasicType("Vector2")
v2.Vector2int16 = GreenTea.__newBasicType("Vector2int16")
v2.Vector3 = GreenTea.__newBasicType("Vector3")
v2.Vector3int16 = GreenTea.__newBasicType("Vector3int16")

function v.type(p: string)
	return GreenTea.isType(p)
end

function v.typeof(p: string)
	return GreenTea.isTypeof(p)
end

function v.literal(...)
	local v3 = select("#", ...)

	if v3 == 0 then
		return GreenTea.any()
	elseif v3 == 1 then
		return GreenTea.literal(...)
	end

	local v4 = {}

	for i = 1, v3 do
		table.insert(v4, GreenTea.literal(select(i, ...)))
	end

	return GreenTea.union(table.unpack(v4))
end

v.exactly = v.literal

function v.keyOf(items)
	local v3 = {}

	for k, _ in pairs(items) do
		table.insert(v3, GreenTea.literal(k))
	end

	return GreenTea.union(table.unpack(v3))
end

function v.valueOf(items)
	local v3 = {}

	for _, item in pairs(items) do
		table.insert(v3, GreenTea.typeof(item))
	end

	return GreenTea.union(table.unpack(v3))
end

function v.optional(p)
	return GreenTea.optional(asGreenTeaType(p))
end

function v.tuple(...)
	local v3 = table.pack(...)

	for i = 1, v3.n do
		local v4 = v3[i]

		if not GreenTea.isGtType(v4) then
			if typeof(v4) == "function" then
				v4 = GreenTea.custom(v4)
			elseif v4 == nil then
				v4 = GreenTea.none()
			else
				v4 = GreenTea.typeof(v4)
			end
		end

		v3[i] = v4
	end

	return GreenTea.tuple(table.unpack(v3))
end

function v.union(...)
	local v3 = table.pack(...)

	for i = 1, v3.n do
		local v4 = v3[i]

		if not GreenTea.isGtType(v4) then
			if typeof(v4) == "function" then
				v4 = GreenTea.custom(v4)
			elseif v4 == nil then
				v4 = GreenTea.none()
			else
				v4 = GreenTea.typeof(v4)
			end
		end

		v3[i] = v4
	end

	return GreenTea.union(table.unpack(v3))
end

v.some = v.union

function v.intersection(...)
	local v3 = table.pack(...)

	for i = 1, v3.n do
		local v4 = v3[i]

		if not GreenTea.isGtType(v4) then
			if typeof(v4) == "function" then
				v4 = GreenTea.custom(v4)
			elseif v4 == nil then
				v4 = GreenTea.none()
			else
				v4 = GreenTea.typeof(v4)
			end
		end

		v3[i] = v4
	end

	return GreenTea.intersection(table.unpack(v3))
end

v.every = v.intersection

function v.keys(callback)
	local dictionary = GreenTea.dictionary

	if GreenTea.isGtType(callback) then
		return dictionary(callback, GreenTea.any())
	end

	if typeof(callback) == "function" then
		callback = GreenTea.custom(callback)
	elseif callback == nil then
		callback = GreenTea.none()
	else
		callback = GreenTea.typeof(callback)
	end

	return dictionary(callback, GreenTea.any())
end

function v.values(p)
	return GreenTea.dictionary(GreenTea.any(), asGreenTeaType(p))
end

function v.map(callback, p)
	local dictionary = GreenTea.dictionary

	if GreenTea.isGtType(callback) then
		return dictionary(callback, asGreenTeaType(p))
	end

	if typeof(callback) == "function" then
		callback = GreenTea.custom(callback)
	elseif callback == nil then
		callback = GreenTea.none()
	else
		callback = GreenTea.typeof(callback)
	end

	return dictionary(callback, asGreenTeaType(p))
end

function v.set(callback)
	local dictionary = GreenTea.dictionary

	if GreenTea.isGtType(callback) then
		return dictionary(callback, GreenTea.literal(true))
	end

	if typeof(callback) == "function" then
		callback = GreenTea.custom(callback)
	elseif callback == nil then
		callback = GreenTea.none()
	else
		callback = GreenTea.typeof(callback)
	end

	return dictionary(callback, GreenTea.literal(true))
end

function v.numberMin(p: number)
	return GreenTea.number({
		range = `[{p}, inf]`
	})
end

function v.numberMax(p: number)
	return GreenTea.number({
		range = `[-inf, {p}]`
	})
end

function v.numberConstrained(p: number, p2: number)
	return GreenTea.number({
		range = `[{p}, {p2}]`
	})
end

function v.numberMinExclusive(p: number)
	return GreenTea.number({
		range = `({p}, inf]`
	})
end

function v.numberMaxExclusive(p: number)
	return GreenTea.number({
		range = `[-inf, {p})`
	})
end

function v.numberConstrainedExclusive(p: number, p2: number)
	return GreenTea.number({
		range = `({p}, {p2})`
	})
end

function v.match(pattern: string)
	return GreenTea.string({
		pattern = pattern
	})
end

function v.array(p)
	return GreenTea.array(asGreenTeaType(p))
end

function v.strictArray(...)
	local v3 = { ... }
	v3[GreenTea.any()] = GreenTea.never()
	local max = select("#", ...)

	for i = 1, max do
		local v5 = v3[i]

		if not GreenTea.isGtType(v5) then
			if typeof(v5) == "function" then
				v5 = GreenTea.custom(v5)
			elseif v5 == nil then
				v5 = GreenTea.none()
			else
				v5 = GreenTea.typeof(v5)
			end
		end

		v3[i] = v5
	end

	return GreenTea.table(v3, {
		raw = true,
		count = {
			min = 0,
			max = max
		}
	})
end

function v.interface(items)
	local v3 = {}

	for k, item in pairs(items) do
		if not GreenTea.isGtType(item) then
			if typeof(item) == "function" then
				item = GreenTea.custom(item)
			elseif item == nil then
				item = GreenTea.none()
			else
				item = GreenTea.typeof(item)
			end
		end

		v3[k] = item
	end

	return GreenTea.table(v3, {
		raw = true
	})
end

function v.strictInterface(items)
	local v3 = {}

	for k, item in pairs(items) do
		if not GreenTea.isGtType(item) then
			if typeof(item) == "function" then
				item = GreenTea.custom(item)
			elseif item == nil then
				item = GreenTea.none()
			else
				item = GreenTea.typeof(item)
			end
		end

		v3[k] = item
	end

	v3[GreenTea.any()] = GreenTea.never()
	return GreenTea.table(v3, {
		raw = true
	})
end

local function tChildren(items)
	local v3 = {}

	for k, item in pairs(items) do
		assert(typeof(k) == "string", "children keys must be strings")

		if not GreenTea.isGtType(item) then
			if typeof(item) == "function" then
				item = GreenTea.custom(item)
			elseif item == nil then
				item = GreenTea.none()
			else
				item = GreenTea.typeof(item)
			end
		end

		v3[k] = item
	end

	return function(instance)
		if not instance or typeof(instance) ~= "Instance" then
			return false, "expected an instance"
		end

		for childName, v4 in pairs(v3) do
			if not instance:FindFirstChild(childName) then
				return false, "missing child " .. childName
			end

			local v5, v6 = v4(instance:FindFirstChild(childName))

			if not v5 then
				return false, v6
			end
		end

		local v4 = {}

		for _, child in instance:GetChildren() do
			if v4[child.Name] then
				return false, "duplicate child " .. child.Name
			else
				v4[child.Name] = true
			end
		end

		return true, nil
	end
end

function v.instanceOf(p: string, p2)
	local v3 = p2 and tChildren(p2)
	return GreenTea.withCustom(InstanceClasses(p), function(instance)
		if instance.ClassName ~= p then
			return false, "expected an instance of " .. p
		end

		if v3 then
			return v3(instance)
		end

		return true
	end, "InstanceOf")
end

v.instance = v.instanceOf

function v.instanceIsA(p: string, p2)
	if p2 then
		return GreenTea.withCustom(InstanceClasses(p), tChildren(p2), "Children")
	end

	return InstanceClasses(p)
end

function v.children(p)
	return GreenTea.custom(tChildren(p), "Children")
end

function v.enum(p)
	return GreenTea.custom(function(p2)
		if typeof(p2) ~= "EnumItem" then
			return false, "expected an enum item"
		end

		if p2.EnumType == p then
			return true
		end

		return false, "expected an enum item of type " .. tostring(p)
	end, (`{p}`))
end

function v.wrap(callback, callback2)
	if not GreenTea.isGtType(callback2) then
		if typeof(callback2) == "function" then
			callback2 = GreenTea.custom(callback2)
		elseif callback2 == nil then
			callback2 = GreenTea.none()
		else
			callback2 = GreenTea.typeof(callback2)
		end
	end

	return function(...)
		callback2:assert(...)
		return callback(...)
	end
end

function v.strict(callback)
	if not GreenTea.isGtType(callback) then
		if typeof(callback) == "function" then
			callback = GreenTea.custom(callback)
		elseif callback == nil then
			callback = GreenTea.none()
		else
			callback = GreenTea.typeof(callback)
		end
	end

	return function(...)
		callback:assert(...)
	end
end

return (setmetatable(v, {
	__index = function(_, p)
		if v2[p] then
			return v2[p]()
		end

		return nil
	end
}))