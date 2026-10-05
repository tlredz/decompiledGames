local Util = require(script.Parent.Util)

local function unescapeOperators(value)
	for _, v in ipairs({
		"%.",
		"%?",
		"%*",
		"%*%*"
	}) do
		value = value:gsub("\\" .. v, v:gsub("%%", ""))
	end

	return value
end

local Argument = {}
Argument.__index = Argument

function Argument.new(command, data2, rawValue)
	local v = {
		Command = command,
		Type = nil,
		Name = data2.Name,
		Object = data2,
		Required = data2.Default == nil and data2.Optional ~= true,
		Executor = command.Executor,
		RawValue = rawValue,
		RawSegments = {},
		TransformedValues = {},
		Prefix = "",
		TextSegmentInProgress = "",
		RawSegmentsAreAutocomplete = false
	}

	if type(data2.Type) == "table" then
		v.Type = data2.Type
	else
		local prefixedUnionType, rawValue2, prefix = Util.ParsePrefixedUnionType(
			command.Cmdr.Registry:GetTypeName(data2.Type),
			rawValue
		)
		v.Type = command.Dispatcher.Registry:GetType(prefixedUnionType)
		v.RawValue = rawValue2
		v.Prefix = prefix

		if v.Type == nil then
			error(string.format("%s has an unregistered type %q", v.Name or "<none>", prefixedUnionType or "<none>"))
		end
	end

	setmetatable(v, Argument)
	v:Transform()
	return v
end

function Argument:GetDefaultAutocomplete()
	if not self.Type.Autocomplete then
		return {}
	end

	local autocomplete, v = self.Type.Autocomplete(self:TransformSegment(""))
	return autocomplete, v or {}
end

function Argument:Transform()
	if #self.TransformedValues ~= 0 then
		return
	end

	local rawValue = self.RawValue

	if self.Type.ArgumentOperatorAliases then
		rawValue = self.Type.ArgumentOperatorAliases[rawValue] or rawValue
	end

	if rawValue == "." and self.Type.Default then
		rawValue = self.Type.Default(self.Executor) or ""
		self.RawSegmentsAreAutocomplete = true
	end

	if rawValue == "?" and self.Type.Autocomplete then
		local defaultAutocomplete, v = self:GetDefaultAutocomplete()

		if not v.IsPartial and #defaultAutocomplete > 0 then
			rawValue = defaultAutocomplete[math.random(1, #defaultAutocomplete)]
			self.RawSegmentsAreAutocomplete = true
		end
	end

	if self.Type.Listable and #self.RawValue > 0 then
		local match = rawValue:match("^%?(%d+)$")

		if match then
			local v = tonumber(match)

			if v and v > 0 then
				local v2 = {}
				local defaultAutocomplete, v3 = self:GetDefaultAutocomplete()

				if not v3.IsPartial and #defaultAutocomplete > 0 then
					for _ = 1, math.min(v, #defaultAutocomplete) do
						table.insert(v2, table.remove(defaultAutocomplete, math.random(1, #defaultAutocomplete)))
					end

					rawValue = table.concat(v2, ",")
					self.RawSegmentsAreAutocomplete = true
				end
			end
		elseif rawValue == "*" or rawValue == "**" then
			local defaultAutocomplete, v = self:GetDefaultAutocomplete()

			if not v.IsPartial and #defaultAutocomplete > 0 then
				if rawValue == "**" and self.Type.Default then
					local v2 = self.Type.Default(self.Executor) or ""

					for i, v3 in ipairs(defaultAutocomplete) do
						if v3 == v2 then
							table.remove(defaultAutocomplete, i)
						end
					end
				end

				rawValue = table.concat(defaultAutocomplete, ",")
				self.RawSegmentsAreAutocomplete = true
			end
		end

		local v = unescapeOperators(rawValue)
		local splitStringSimple = Util.SplitStringSimple(v, ",")
		local v2 = #splitStringSimple == 0 and { "" } or splitStringSimple

		if v:sub(#v, #v) == "," then
			v2[#v2 + 1] = ""
		end

		for i, v3 in ipairs(v2) do
			self.RawSegments[i] = v3
			self.TransformedValues[i] = { self:TransformSegment(v3) }
		end

		self.TextSegmentInProgress = v2[#v2]
	else
		local v = unescapeOperators(rawValue)
		self.RawSegments[1] = unescapeOperators(v)
		self.TransformedValues[1] = { self:TransformSegment(v) }
		self.TextSegmentInProgress = self.RawValue
	end
end

function Argument:TransformSegment(p2)
	if self.Type.Transform then
		return self.Type.Transform(p2, self.Executor)
	end

	return p2
end

function Argument:GetTransformedValue(p2)
	return unpack(self.TransformedValues[p2])
end

function Argument:Validate(p)
	if self.RawValue == nil or #self.RawValue == 0 and self.Required == false then
		return true
	end

	if self.Required and (self.RawSegments[1] == nil or #self.RawSegments[1] == 0) then
		return false, "This argument is required."
	end

	if not (self.Type.Validate or self.Type.ValidateOnce) then
		return true
	end

	for i = 1, #self.TransformedValues do
		if self.Type.Validate then
			local v, v2 = self.Type.Validate(self:GetTransformedValue(i))

			if not v then
				return v, v2 or "Invalid value"
			end
		end

		if not (p and self.Type.ValidateOnce) then
			continue
		end

		local v, v2 = self.Type.ValidateOnce(self:GetTransformedValue(i))

		if not v then
			return v, v2
		end
	end

	return true
end

function Argument:GetAutocomplete()
	if self.Type.Autocomplete then
		return self.Type.Autocomplete(self:GetTransformedValue(#self.TransformedValues))
	end

	return {}
end

function Argument:ParseValue(p)
	if self.Type.Parse then
		return self.Type.Parse(self:GetTransformedValue(p))
	end

	return self:GetTransformedValue(p)
end

function Argument:GetValue()
	if #self.RawValue == 0 and not self.Required and self.Object.Default ~= nil then
		return self.Object.Default
	end

	if not self.Type.Listable then
		return self:ParseValue(1)
	end

	local v = {}

	for i = 1, #self.TransformedValues do
		local value = self:ParseValue(i)

		if type(value) ~= "table" then
			error(("Listable types must return a table from Parse (%s)"):format(self.Type.Name))
		end

		for _, v2 in pairs(value) do
			v[v2] = true
		end
	end

	local result = {}

	for k in pairs(v) do
		result[#result + 1] = k
	end

	return result
end

return Argument