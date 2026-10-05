local Players = game:GetService("Players")
local module = require("./console")
local module2 = require("./context")
require("./types")

local function noop(p)
	return p
end

local function wrap_if_not(p)
	if type(p) == "table" then
		return p
	end

	return { p }
end

local v = {
	convert = tostring,
	analysis = {
		kind = "argument",
		name = "string",
		type = "string"
	}
}
local v2 = {
	convert = tonumber,
	analysis = {
		kind = "argument",
		name = "number",
		type = "number"
	}
}

local function into_vector(value)
	if type(value) == "vector" then
		return value
	end

	if typeof(value) == "table" then
		return (vector.create(value[1] or 0, value[2] or 0, value[3] or 0))
	end

	error(`{value} is not valid`, 0)
end

local function enum_map(items, value: string?, description: string?)
	return {
		convert = function(p2)
			local v3 = tostring(p2)

			if items[v3] == nil then
				error(`{v3} is not valid`, 0)
			end

			return items[v3]
		end,
		analysis = {
			kind = "argument",
			name = value or "enum",
			description = description,
			type = value or "enum",
			suggestion_generator = function(value2: string)
				local lower = value2:lower()
				local result = {}

				for k in items do
					if string.sub(k:lower(), 1, #lower) ~= lower then
						continue
					end

					table.insert(result, k)
				end

				return result
			end
		}
	}
end

local function convert_arg_to_player(value)
	local get_command_context = module2.get_command_context()

	if value == "@s" or value == nil or value == "nil" then
		return get_command_context and get_command_context.executor.player or error("not executed by a player")
	end

	if typeof(value) == "number" then
		return (assert(Players:GetPlayerByUserId(value), (`player with id {value} is not in this server`)))
	end

	if typeof(value) == "string" then
		return (assert(Players:FindFirstChild(value), (`player "{value}" is not valid`)))
	end

	error((`unknown arg {value}`))
end

local function convert_arg_to_players(p)
	if p == "@a" then
		return Players:GetPlayers()
	end

	if typeof(p) ~= "table" then
		return { convert_arg_to_player(p) }
	end

	local clone = table.clone(p)

	for k, v3 in clone do
		clone[k] = convert_arg_to_player(v3)
	end

	return clone
end

local function generate_names_for_enum(userInputType)
	local v3 = {}

	for _, v4 in userInputType:GetEnumItems() do
		v3[v4.Name] = v4
	end

	return (enum_map(v3, (tostring(userInputType))))
end

local Arguments = {}
Arguments.any = module.register_type("any", {
	convert = noop,
	analysis = {
		kind = "argument",
		name = "any",
		type = "any"
	}
})
Arguments.string = module.register_type("string", v)
Arguments.strings = module.register_type("strings", {
	convert = function(p)
		if typeof(p) ~= "table" then
			return { (tostring(p)) }
		end

		local clone = table.clone(p)

		for k, v3 in clone do
			clone[k] = tostring(v3)
		end

		return clone
	end,
	analysis = {
		kind = "argument",
		name = "strings",
		type = "{ string }"
	}
})
Arguments.number = module.register_type("number", v2)
Arguments.numbers = module.register_type("numbers", {
	convert = wrap_if_not,
	analysis = {
		kind = "argument",
		name = "numbers",
		type = "{ number }"
	}
})
Arguments.boolean = module.register_type("boolean", {
	convert = function(value)
		if typeof(value) == "boolean" then
			return value
		end

		if typeof(value) == "number" and value > 0 then
			return true
		end

		if typeof(value) == "number" and value <= 0 or typeof(value) == "nil" then
			return false
		end

		error((`{typeof(value)} is not a valid boolean`))
	end,
	analysis = {
		kind = "argument",
		name = "boolean",
		type = "boolean",
		suggestion_generator = function(list: string)
			local v3 = {}

			if string.sub("true", 1, #list) == list then
				table.insert(v3, "true")
			end

			if string.sub("false", 1, #list) == list then
				table.insert(v3, "false")
			end

			return v3
		end
	}
})
Arguments.booleans = module.register_type("booleans", {
	convert = function(value)
		if typeof(value) == "table" then
			local clone = table.clone(value)

			for k, v3 in clone do
				if typeof(v3) == "boolean" then
					clone[k] = v3
				elseif typeof(v3) == "number" and v3 > 0 then
					clone[k] = true
				elseif typeof(v3) == "number" and v3 <= 0 then
					clone[k] = false
				else
					error((`type {typeof(v3)} of {k} is not a valid boolean`))
				end
			end

			return clone
		else
			if typeof(value) == "boolean" then
				return { value }
			end

			if typeof(value) == "number" and value > 0 then
				return { true }
			end

			if typeof(value) == "number" and value <= 0 then
				return { false }
			end

			error((`{typeof(value)} is not a valid boolean`))
		end
	end,
	analysis = {
		kind = "argument",
		name = "boolean",
		type = "boolean",
		suggestion_generator = function(list: string)
			local v3 = {}

			if string.sub("true", 1, #list) == list then
				table.insert(v3, "true")
			end

			if string.sub("false", 1, #list) == list then
				table.insert(v3, "false")
			end

			return v3
		end
	}
})
Arguments.table = module.register_type("table", {
	convert = noop,
	analysis = {
		kind = "argument",
		name = "table",
		type = "table"
	}
})
Arguments.vector = module.register_type("vector", {
	convert = into_vector,
	analysis = {
		kind = "argument",
		name = "vector",
		type = "vector"
	}
})
Arguments.vectors = module.register_type("vectors", {
	convert = function(value)
		if type(value) == "vector" then
			return { value }
		end

		if typeof(value) ~= "table" then
			error(`{value} is not valid`, 0)
			return
		end

		local vectors = {}

		for k, vector2 in value do
			if type(vector2) ~= "vector" then
				if typeof(vector2) == "table" then
					vector2 = vector.create(vector2[1] or 0, vector2[2] or 0, vector2[3] or 0)
				else
					error(`{vector2} is not valid`, 0)
					vector2 = nil
				end
			end

			vectors[k] = vector2
		end

		return vectors
	end,
	analysis = {
		kind = "argument",
		name = "vector",
		type = "vector"
	}
})
Arguments.player = module.register_type("player", {
	convert = function(p)
		return convert_arg_to_player(p)
	end,
	analysis = {
		kind = "argument",
		name = "player",
		type = "Player",
		suggestion_generator = function(value: string)
			local lower = value:lower()
			local result = {}

			if string.sub("@s", 1, #lower) == lower then
				table.insert(result, "@s")
			end

			for _, v3 in Players:GetPlayers() do
				if not (string.sub(v3.Name:lower(), 1, #lower) == lower or string.sub(v3.DisplayName:lower(), 1, #lower) == lower) then
					continue
				end

				table.insert(result, v3.Name)
			end

			return result
		end
	}
})
Arguments.players = module.register_type("players", {
	kind = "any",
	convert = function(p)
		return convert_arg_to_players(p)
	end,
	analysis = {
		kind = "argument",
		name = "players",
		type = "{ Player }",
		suggestion_generator = function(value: string)
			local lower = value:lower()
			local result = {}

			if string.sub("@s", 1, #lower) == lower then
				table.insert(result, "@s")
			end

			if string.sub("@a", 1, #lower) == lower then
				table.insert(result, "@a")
			end

			for _, v3 in Players:GetPlayers() do
				if not (string.sub(v3.Name:lower(), 1, #lower) == lower or string.sub(v3.DisplayName:lower(), 1, #lower) == lower) then
					continue
				end

				table.insert(result, v3.Name)
			end

			return result
		end
	}
})
Arguments.userinput = module.register_type("userinput", (generate_names_for_enum(Enum.UserInputType)))

function Arguments.variadic(p)
	p.kind = "varargs"
	return p
end

function Arguments.enum_new(items, p: string?, description: string?)
	local v3 = {}

	for _, item in items do
		v3[tostring(item)] = item
	end

	return (enum_map(v3, p, description))
end

Arguments.enum_map = enum_map
return Arguments