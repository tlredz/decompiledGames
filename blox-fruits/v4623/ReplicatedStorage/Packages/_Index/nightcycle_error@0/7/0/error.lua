local option = require(script.Parent:WaitForChild("option"))

function getTraceInfo(p: number)
	local source, lineNumber, name, parameterCount, isVariadic, reference = debug.info(p, "slnaf")

	if source == nil then
		return option.none()
	end

	local v7 = {
		Source = source,
		LineNumber = lineNumber,
		Function = {
			Name = name,
			ParameterCount = parameterCount,
			IsVariadic = isVariadic,
			Reference = reference
		}
	}
	table.freeze(v7.Function)
	table.freeze(v7)
	return option.some(v7)
end

function dumpTrace(p: number, p2: number)
	local v = p + 1
	local traceInfo = getTraceInfo(v)
	local result = {}

	while traceInfo:isSome() do
		result[v - p] = traceInfo:unwrap()
		v += 1

		if p2 < v then
			break
		else
			traceInfo = getTraceInfo(v)
		end
	end

	return result
end

function newErrorStruct(p, title, description, body, trace)
	return {
		Title = title,
		Type = p,
		Description = description,
		Body = body,
		Trace = trace
	}
end

local class = {}
class.__index = class

function toJson(value, value2: number?, flag: boolean?, count: number?, options)
	local v = options or {}
	assert(v, "bad log")
	local v2 = count or 0
	assert(v2, "bad initialIndent")
	local v3 = value2 or 0
	assert(v3, "bad indent")

	if type(value) == "string" then
		return "\"" .. value:gsub("\"", "\\\"") .. "\""
	end

	if type(value) == "number" then
		if value ~= value then
			return "\"NaN\""
		end

		if math.abs(value) == 1e999 then
			return "\"Inf\""
		end

		return (tostring(value))
	else
		if type(value) == "boolean" then
			return (tostring(value))
		end

		if type(value) ~= "table" then
			return (`"{tostring(value)}"`)
		end

		if v[value] then
			return "\"<circular>\""
		end

		v[value] = true
		local metatable = nil
		pcall(function()
			metatable = getmetatable(value)
		end)

		if metatable and rawget(metatable, "__tostring") ~= nil and metatable ~= class then
			local v4 = nil
			local success, _ = pcall(function()
				v4 = tostring(value)
			end)

			if success then
				return (`"{v4}"`)
			end
		end

		local count2 = 0
		local v4 = {}
		local v5 = true

		for k, _ in pairs(value) do
			count2 += 1

			if type(k) == "number" then
				continue
			end

			v5 = false
			break
		end

		if #value == count2 and v5 then
			for _, item in ipairs(value) do
				table.insert(v4, toJson(item, v3, flag, v2 + v3, v))
			end

			if v3 == 0 then
				return "[" .. table.concat(v4, ",") .. "]"
			end

			if #v4 == 0 then
				return "[]"
			end

			local v7 = "["

			for i, v8 in ipairs(v4) do
				v7 ..= "\n" .. string.rep(" ", v2 + v3) .. v8

				if i ~= #v4 then
					v7 ..= ","
				end
			end

			return v7 .. "\n" .. string.rep(" ", v2) .. "]"
		else
			local v7 = {}

			for k, _ in pairs(value) do
				table.insert(v7, k)
			end

			if flag then
				table.sort(v7)
			end

			for _, v8 in ipairs(v7) do
				local item = value[v8]

				if option.isOption(item) then
					if item:isSome() then
						table.insert(
							v4,
							toJson(tostring(v8), v3, flag, v2 + v3, v) .. ": " .. toJson(
								item:unwrap(),
								v3,
								flag,
								v2 + v3,
								v
							)
						)
					else
						table.insert(v4, toJson(tostring(v8), v3, flag, v2 + v3, v) .. ": null")
					end
				else
					table.insert(
						v4,
						toJson(tostring(v8), v3, flag, v2 + v3, v) .. ": " .. toJson(item, v3, flag, v2 + v3, v)
					)
				end
			end

			if v3 == 0 then
				return "{" .. table.concat(v4, ",") .. "}"
			end

			if #v4 == 0 then
				return "{}"
			end

			local v8 = "{"

			for i, v9 in ipairs(v4) do
				v8 ..= "\n" .. string.rep(" ", v2 + v3) .. v9

				if i ~= #v4 then
					v8 ..= ","
				end
			end

			return v8 .. "\n" .. string.rep(" ", v2) .. "}"
		end
	end
end

function class:__tostring()
	return self:display("Full")
end

function class.is(p, p2)
	return p.Type == p2
end

function class:display(p: string)
	if p == "JSON" then
		return toJson(self)
	elseif p == "PrettyJSON" then
		return toJson(self, 4)
	elseif p == "Log" then
		return self.Trace:match(function(list)
			if not list[1] then
				return (`{self.Type}`)
			end

			local v = list[1]
			return (`{v.Source}({v.LineNumber}): {self.Type}`)
		end, function()
			return (`{self.Type}`)
		end)
	end

	local match = self.Title:match(function(p2)
		return self.Description:match(function(p3)
			return (`[{self.Type}]: {p2}\n\t{p3}`)
		end, function()
			return (`[{self.Type}]: {p2}`)
		end)
	end, function()
		return self.Description:match(function(p2)
			return (`[{self.Type}]\n\t{p2}`)
		end, function()
			return (`[{self.Type}]`)
		end)
	end)
	local none = option.none()

	if p == "Body" or p == "Full" then
		none = self.Body:match(function(p2)
			return option.some(toJson(p2))
		end, function()
			return option.none()
		end)
	end

	local none2 = option.none()

	if p == "Trace" or p == "Full" then
		none2 = self.Trace:match(function(list)
			local v = {}

			for _, v2 in ipairs(list) do
				table.insert(
					v,
					(`\t{v2.Source}{not (v2.Function.Name:len() > 0) and "" or "/" .. tostring(v2.Function.Name)}({v2.LineNumber})`)
				)
			end

			return option.some(table.concat(v, "\n"))
		end, function()
			return option.none()
		end)
	end

	return none:match(function(p2)
		return none2:match(function(p3)
			return (`{match}\n\t{p2}\n{p3}`)
		end, function()
			return (`{match}\n\t{p2}`)
		end)
	end, function()
		return none2:match(function(p2)
			return (`{match}\n{p2}`)
		end, function()
			return (`{match}`)
		end)
	end)
end

function newError(p, p2, p3, p4, p5)
	local self = setmetatable(newErrorStruct(p, p2, p3, p4, p5), class)
	table.freeze(self)
	return self
end

local class2 = {}
class2.__index = class2

function newErrorBuilder(p, p2, p3, p4, p5)
	local self = setmetatable(newErrorStruct(p, p2, p3, p4, p5), class2)
	table.freeze(self)
	return self
end

function class2.title(data, p: string)
	return newErrorBuilder(data.Type, option.some(p), data.Description, data.Body, data.Trace)
end

function class2.description(data, p: string)
	return newErrorBuilder(data.Type, data.Title, option.some(p), data.Body, data.Trace)
end

function class2.body(data, p)
	return newErrorBuilder(data.Type, data.Title, data.Description, option.some(p), data.Trace)
end

function class2.trace(data, clone)
	if not table.isfrozen(clone) then
		clone = table.clone(clone)
		table.freeze(clone)
	end

	return newErrorBuilder(data.Type, data.Title, data.Description, data.Body, option.some(clone))
end

function class2.build(data)
	return newError(data.Type, data.Title, data.Description, data.Body, data.Trace)
end

local Error = {}

function Error.new(p)
	return newErrorBuilder(p, option.none(), option.none(), option.none(), option.some(dumpTrace(3, 16)))
end

function Error.isErr(p)
	return typeof(p) == "table" and getmetatable(p) == class
end

function Error.trace(value: number?, value2: number)
	return dumpTrace(3 + (value or 0), value2 or 16)
end

Error.displayAsJson = toJson
return Error