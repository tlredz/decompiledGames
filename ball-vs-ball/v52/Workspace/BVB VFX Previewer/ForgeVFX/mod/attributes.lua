local RunService = game:GetService("RunService")
local module = require("./logger")
local isServer = RunService:IsServer()
local v = {}
local v2 = {}
local v3 = {}
local count = 0
local Attributes = {
	cache = function(instance)
		local U = instance:GetAttribute("U")

		if U then
			module.warn((`{instance} is already cached (id={U})`))
			return
		end

		local attributes = instance:GetAttributes()

		if next(attributes) == nil then
			return
		end

		count += 1
		local v4 = count
		local attributes2 = {}

		for k, attribute in attributes do
			if k == "U" then
				continue
			end

			attributes2[k] = attribute
			instance:SetAttribute(k, nil)
		end

		v[v4] = attributes2
		instance:SetAttribute("U", v4)
	end,
	restore = function(instance)
		local U = instance:GetAttribute("U")
		local v4 = v[U]

		if not v4 then
			module.warn((`{instance} with cache id '{U}' doesn't have any cached attributes`))
			return
		end

		for k, v5 in v4 do
			instance:SetAttribute(k, v5)
		end

		instance:SetAttribute("U", nil)
	end,
	get = function(instance, attributeName: string, p, flag: boolean?, callback)
		local v4 = v[instance:GetAttribute("U")]
		local selected = v4 and v4[attributeName]

		if selected == nil then
			local attribute = instance:GetAttribute(attributeName)

			if callback then
				p = callback(attribute)
			elseif attribute ~= nil then
				p = attribute
			end

			if not flag and isServer then
				instance:SetAttribute(attributeName, p)
			end

			return p
		else
			if callback then
				return (callback(selected))
			end

			if selected == nil then
				return p
			end

			return selected
		end
	end
}

function Attributes.getRange(p, p2: string, range: NumberRange, range2: NumberRange?, flag: boolean?)
	return Attributes.get(p, p2, range, flag, function(p3)
		if typeof(p3) ~= "NumberRange" then
			return range
		end

		if range2 then
			return NumberRange.new(
				math.clamp(p3.Min, range2.Min, range2.Max),
				(math.clamp(p3.Max, range2.Min, range2.Max))
			)
		end

		return p3
	end)
end

function Attributes.getEnum(p, p2: string, p3, list, flag: boolean?)
	return Attributes.get(p, p2, p3, flag, function(p4)
		if p4 == nil or not table.find(list, p4) then
			return p3
		end

		return p4
	end)
end

function Attributes.set(instance, p: string, p2)
	local v4 = v[instance:GetAttribute("U")]

	if v4 then
		v4[p] = p2
	else
		instance:SetAttribute(p, p2)
	end
end

function Attributes.isCached(instance)
	return instance:GetAttribute("U") ~= nil
end

function Attributes.getState(p, p2: string, p3)
	local v4 = v3[p]
	local selected = v4 and v4[p2]

	if selected == nil then
		return p3
	end

	return selected
end

function Attributes.setState(p, p2: string, p3)
	local v4 = v3[p]

	if not v4 then
		v4 = {}
		v3[p] = v4
	end

	v4[p2] = p3
end

function Attributes.clearState(p)
	v3[p] = nil
end

function Attributes.trigger(p, p2: string, p3)
	local v4 = v2[p]
	local v5 = v4 and v4[p2]

	if not v5 then
		return
	end

	for _, v6 in v5 do
		v6(p3)
	end
end

function Attributes.hook(instance, attributeName: string, callback)
	local v4 = v2[instance]

	if not v4 then
		v4 = {}
		v2[instance] = v4
	end

	local callbacks = v4[attributeName]

	if not callbacks then
		callbacks = {}
		v4[attributeName] = callbacks
	end

	table.insert(callbacks, callback)
	local connection

	if Attributes.isCached(instance) then
		connection = nil
	else
		connection = instance:GetAttributeChangedSignal(attributeName):Connect(function()
			callback((instance:GetAttribute(attributeName)))
		end)
	end

	return function()
		if connection then
			connection:Disconnect()
		end

		local index = table.find(callbacks, callback)

		if index then
			table.remove(callbacks, index)
		end

		if #callbacks == 0 then
			v4[attributeName] = nil
		end

		if next(v4) == nil then
			v2[instance] = nil
		end
	end
end

return Attributes