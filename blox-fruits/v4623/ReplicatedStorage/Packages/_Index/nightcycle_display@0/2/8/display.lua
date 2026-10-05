local option = require(script.Parent:WaitForChild("option"))

function constructFrom(p, callback)
	local clone = table.clone(p)
	callback(clone)
	table.freeze(clone)
	return clone
end

local class = {}
class.__index = class
local class2 = {}
class2.__index = class2

function newDisplayBuilder(p)
	local clone = table.clone(p)
	setmetatable(clone, class2)
	table.freeze(clone)
	return clone
end

function newDisplay(p)
	local clone = table.clone(p)
	setmetatable(clone, class)
	table.freeze(clone)
	return clone
end

function class:display(p2, value: number?, options)
	local override = self.override(p2, value or 0, self, options or {})

	if override == nil then
		return self.callback(p2, value or 0, self, options or {})
	end

	return override
end

function class.builder(p)
	return newDisplayBuilder(p)
end

function class2:build()
	return newDisplay(self)
end

function class2.setSortKeys(p, sortKeys: boolean)
	return (newDisplayBuilder(constructFrom(p, function(p2)
		p2.sortKeys = sortKeys
	end)))
end

function class2.setUseMetatable(p, useMetatable)
	return (newDisplayBuilder(constructFrom(p, function(p2)
		p2.useMetatable = useMetatable
	end)))
end

function class2.setIndentWith(p, indentWith: string)
	return (newDisplayBuilder(constructFrom(p, function(p2)
		p2.indentWith = indentWith
	end)))
end

function class2.setCallback(p, callback)
	return (newDisplayBuilder(constructFrom(p, function(p2)
		p2.callback = callback
	end)))
end

function class2.setOverride(p, override)
	return (newDisplayBuilder(constructFrom(p, function(p2)
		p2.override = override
	end)))
end

function class2:display(p, p2, p3)
	return self:build():display(p, p2, p3)
end

function newJsonDisplayBuilder()
	return newDisplayBuilder({
		sortKeys = false,
		indentWith = "",
		useMetatable = false,
		override = function(_, _: number, _, _)
			return nil
		end,
		callback = function(value, p: number, object, p2)
			local override = object.override(value, p, object, p2)

			if override ~= nil then
				return override
			end

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

				if p2[value] then
					return "\"<circular>\""
				end

				p2[value] = true
				local metatable = nil
				pcall(function()
					metatable = getmetatable(value)
				end)

				if object.useMetatable and metatable and rawget(metatable, "__tostring") ~= nil then
					local v = nil
					local success, _ = pcall(function()
						v = tostring(value)
					end)

					if success then
						return (`"{v}"`)
					end
				end

				local count = 0
				local v = {}
				local v2 = true

				for k, _ in pairs(value) do
					count += 1

					if type(k) == "number" then
						continue
					end

					v2 = false
					break
				end

				if #value == count and v2 then
					for _, item in ipairs(value) do
						table.insert(v, object:display(item, p + 1, p2))
					end

					if object.indentWith:len() == 0 then
						return "[" .. table.concat(v, ",") .. "]"
					end

					if #v == 0 then
						return "[]"
					end

					local v4 = "["

					for i, v5 in ipairs(v) do
						v4 ..= "\n" .. string.rep(object.indentWith, p + 1) .. v5

						if i ~= #v then
							v4 ..= ","
						end
					end

					return v4 .. "\n" .. string.rep(object.indentWith, p) .. "]"
				else
					local v4 = {}

					for k, _ in pairs(value) do
						table.insert(v4, k)
					end

					if object.sortKeys then
						table.sort(v4)
					end

					for _, v5 in ipairs(v4) do
						local item = value[v5]

						if option.isOption(item) then
							if item:isSome() then
								table.insert(
									v,
									object:display(tostring(v5), p + 1, p2) .. ": " .. object:display(item, p + 1, p2)
								)
							else
								table.insert(v, object:display(tostring(v5), p + 1, p2) .. ": null")
							end
						else
							table.insert(
								v,
								object:display(tostring(v5), p + 1, p2) .. ": " .. object:display(item, p + 1, p2)
							)
						end
					end

					if object.indentWith:len() == 0 then
						return "{" .. table.concat(v, ",") .. "}"
					end

					if #v == 0 then
						return "{}"
					end

					local v5 = "{"

					for i, v6 in ipairs(v) do
						v5 ..= "\n" .. string.rep(object.indentWith, p + 1) .. v6

						if i ~= #v then
							v5 ..= ","
						end
					end

					return v5 .. "\n" .. string.rep(object.indentWith, p + 1) .. "}"
				end
			end
		end
	})
end

return {
	JSON = {
		new = newJsonDisplayBuilder
	}
}