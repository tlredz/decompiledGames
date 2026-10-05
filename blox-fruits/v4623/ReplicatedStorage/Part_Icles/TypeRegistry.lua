local TypeData = require(script.TypeData)
local TypeRegistry = {
	CONFIG_NAME = "PartIcleProperties",
	Types = TypeData.Types
}

function TypeRegistry.getTypeFor(p)
	for k, type2 in pairs(TypeRegistry.Types) do
		if type2.classCheck(p) then
			return type2, k
		end
	end

	return nil, nil
end

function TypeRegistry.getTypeName(p)
	local _, v = TypeRegistry.getTypeFor(p)
	return v
end

function TypeRegistry.getConfig(instance)
	return instance:FindFirstChild(TypeRegistry.CONFIG_NAME)
end

function TypeRegistry.getAttrName(p, p2)
	local property = p.properties[p2]

	if property and property.attrName then
		return property.attrName
	end

	return p2
end

function TypeRegistry.read(instance, p)
	local typeFor = TypeRegistry.getTypeFor(instance)

	if not typeFor then
		return nil
	end

	local property = typeFor.properties[p]

	if not property then
		return nil
	end

	if typeFor.directAccess then
		if property.attribute then
			local attribute = instance:GetAttribute(property.attrName or p)

			if attribute == nil then
				return property.default
			end

			return attribute
		else
			local success, result = pcall(function()
				return instance[p]
			end)

			if success and result ~= nil then
				return result
			end

			return property.default
		end
	else
		local config = TypeRegistry.getConfig(instance)

		if not config then
			return nil
		end

		local attribute = config:GetAttribute((TypeRegistry.getAttrName(typeFor, p)))

		if attribute == nil then
			return property.default
		end

		if property.type ~= "enum" or type(attribute) ~= "string" then
			return attribute
		end

		local success, result = pcall(function()
			return Enum[property.enumType][attribute]
		end)

		if success and result then
			return result
		end

		return property.default
	end
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _bumpPoolGen(instance)
	local renderTemplate = instance:FindFirstChild("RenderTemplate")

	if not renderTemplate then
		return
	end

	local _PoolGen = renderTemplate:GetAttribute("_PoolGen") or 0
	pcall(function()
		renderTemplate:SetAttribute("_PoolGen", _PoolGen + 1)
	end)
end

function TypeRegistry.bumpPoolGen(instance)
	if not instance then
		return
	end

	_bumpPoolGen(instance) -- equivalent call inferred; original call site unknown
end

local function _clampNonNegativeSeq(numberSequence)
	if typeof(numberSequence) ~= "NumberSequence" then
		return numberSequence
	end

	local keypoints = numberSequence.Keypoints
	local v = false

	for _, keypoint in ipairs(keypoints) do
		if not (keypoint.Value < 0 or keypoint.Envelope > keypoint.Value) then
			continue
		end

		v = true
		break
	end

	if not v then
		return numberSequence
	end

	local numberSequenceKeypoints = {}

	for _, keypoint in ipairs(keypoints) do
		local v3 = math.max(0, keypoint.Value)
		local v4 = math.max(0, (math.min(keypoint.Envelope, v3)))
		table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v3, v4))
	end

	return NumberSequence.new(numberSequenceKeypoints)
end

-- equivalent calls inferred from this helper; original call sites unknown
local function _isInvalidNumber(value)
	return type(value) == "number" and (value ~= value or value == 1e999 or value == -1e999)
end

local function _isInvalidValue(numberSequence)
	if type(numberSequence) == "number" then
		return _isInvalidNumber(numberSequence)
	elseif typeof(numberSequence) == "NumberRange" then
		local min = numberSequence.Min
		local v

		if type(min) == "number" then
			v = min ~= min or min == 1e999 or min == -1e999
		else
			v = false
		end

		if v then
			return v
		end

		local max = numberSequence.Max
		return type(max) == "number" and (max ~= max or max == 1e999 or max == -1e999)
	else
		if typeof(numberSequence) ~= "NumberSequence" then
			return false
		end

		for _, keypoint in ipairs(numberSequence.Keypoints) do
			local time = keypoint.Time
			local v

			if type(time) == "number" then
				v = time ~= time or time == 1e999 or time == -1e999
			else
				v = false
			end

			if v then
				return true
			end

			local value = keypoint.Value
			local v2

			if type(value) == "number" then
				v2 = value ~= value or value == 1e999 or value == -1e999
			else
				v2 = false
			end

			if v2 then
				return true
			end

			local envelope = keypoint.Envelope
			local v3

			if type(envelope) == "number" then
				v3 = envelope ~= envelope or envelope == 1e999 or envelope == -1e999
			else
				v3 = false
			end

			if not v3 then
				if keypoint.Time < 0 or keypoint.Time > 1 then
					return true
				end

				continue
			end

			return true
		end

		return false
	end
end

function TypeRegistry:write(p, numberSequence)
	if _isInvalidValue(numberSequence) then
		warn("[Part-Icles] TypeRegistry.write rejected invalid value for " .. tostring(p))
		return
	end

	local typeFor = TypeRegistry.getTypeFor(self)

	if not typeFor then
		return
	end

	local property = typeFor.properties[p]

	if not property then
		return
	end

	if typeFor.directAccess then
		if property.nonNegative then
			numberSequence = _clampNonNegativeSeq(numberSequence)
		end

		if property.attribute then
			self:SetAttribute(property.attrName or p, numberSequence)
		else
			pcall(function()
				self[p] = numberSequence
			end)
		end

		_bumpPoolGen(self) -- equivalent call inferred; original call site unknown
	else
		local config = TypeRegistry.getConfig(self)

		if not config then
			return
		end

		local attrName = TypeRegistry.getAttrName(typeFor, p)

		if property.type == "enum" then
			if typeof(numberSequence) == "EnumItem" then
				config:SetAttribute(attrName, numberSequence.Name)
			else
				config:SetAttribute(attrName, (tostring(numberSequence)))
			end
		else
			if property.nonNegative and typeof(numberSequence) == "NumberSequence" then
				local keypoints = numberSequence.Keypoints
				local flag = false

				for _, keypoint in ipairs(keypoints) do
					if not (keypoint.Value < 0 or keypoint.Envelope > keypoint.Value) then
						continue
					end

					flag = true
					break
				end

				if flag then
					local numberSequenceKeypoints = {}

					for _, keypoint in ipairs(keypoints) do
						local v2 = math.max(0, keypoint.Value)
						local v3 = math.max(0, (math.min(keypoint.Envelope, v2)))
						table.insert(numberSequenceKeypoints, NumberSequenceKeypoint.new(keypoint.Time, v2, v3))
					end

					numberSequence = NumberSequence.new(numberSequenceKeypoints)
				end
			end

			config:SetAttribute(attrName, numberSequence)
		end

		_bumpPoolGen(self) -- equivalent call inferred; original call site unknown
	end
end

function TypeRegistry.readAll(p)
	local typeFor = TypeRegistry.getTypeFor(p)

	if not typeFor then
		return nil
	end

	local config = TypeRegistry.getConfig(p)

	if not config then
		return nil
	end

	local result = {}

	for k, property in pairs(typeFor.properties) do
		local attribute = config:GetAttribute((TypeRegistry.getAttrName(typeFor, k)))

		if attribute == nil then
			result[k] = property.default
		elseif property.type == "enum" and type(attribute) == "string" then
			result[k] = Enum[property.enumType][attribute]
		else
			result[k] = attribute
		end
	end

	return result
end

function TypeRegistry.writeDefaults(instance, p)
	for k, property in pairs(p.properties) do
		local attrName = property.attrName or k
		local default = property.default

		if property.type == "enum" then
			instance:SetAttribute(attrName, default.Name)
		else
			instance:SetAttribute(attrName, default)
		end
	end
end

function TypeRegistry.createConfig(parent, p)
	local configuration = Instance.new("Configuration")
	configuration.Name = TypeRegistry.CONFIG_NAME
	TypeRegistry.writeDefaults(configuration, p)
	configuration.Parent = parent
	return configuration
end

function TypeRegistry.isGraph(p)
	return p.type == "NumberSequence" or p.type == "ColorSequence"
end

function TypeRegistry.isNonNegative(p)
	return p.nonNegative == true
end

function TypeRegistry.getPropDef(p, p2)
	local type2 = TypeRegistry.Types[p]

	if type2 then
		return type2.properties[p2]
	end

	return nil
end

function TypeRegistry.getDefault(p, p2)
	local type2 = TypeRegistry.Types[p]

	if not type2 then
		return nil
	end

	local property = type2.properties[p2]

	if property then
		return property.default
	end

	return nil
end

return TypeRegistry