local Players = game:GetService("Players")
local module = require("./console")
local module2 = require("./context")
require("./types")

local function noop(p)
	return p
end

-- equivalent calls inferred from this helper; original call sites unknown
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
		optional = false,
		name = "string",
		type = "string"
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
			local v2 = tostring(p2)

			if items[v2] == nil then
				error(`{v2} is not valid`, 0)
			end

			return items[v2]
		end,
		analysis = {
			kind = "argument",
			optional = false,
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

					if string.find(k, "[^%w_-]") or typeof((tonumber((string.sub(k, 1, 1))))) == "number" then
						k = string.format("%q", k)
					end

					table.insert(result, k)
				end

				return result
			end
		}
	}
end

local function convert_arg_to_player(player)
	local get_command_context = module2.get_command_context()

	if player == "@s" then
		return get_command_context and get_command_context.executor.player or error("not executed by a player")
	end

	if typeof(player) == "number" then
		return (assert(Players:GetPlayerByUserId(player), (`player with id {player} is not in this server`)))
	end

	if typeof(player) == "string" then
		return (assert(Players:FindFirstChild(player), (`player "{player}" is not valid`)))
	end

	if typeof(player) == "Instance" and player:IsA("Player") then
		return player
	end

	error((`unknown arg {player}`))
end

local function convert_arg_to_players(p)
	if p == "@a" then
		return Players:GetPlayers()
	end

	if typeof(p) ~= "table" then
		return { convert_arg_to_player(p) }
	end

	local clone = table.clone(p)

	for k, v2 in clone do
		clone[k] = convert_arg_to_player(v2)
	end

	return clone
end

local function convert_arg_to_userid(player)
	local get_command_context = module2.get_command_context()

	if player == "@s" then
		return get_command_context and get_command_context.executor.player and get_command_context.executor.player.UserId or error("not executed by a player")
	end

	if typeof(player) == "number" then
		local success, result = pcall(function()
			return Players:GetNameFromUserIdAsync(player)
		end)

		if not success and result:find("Unknown User") then
			error(`No user found with UserId {player}`, 0)
		end

		return player
	elseif typeof(player) == "string" then
		local player2 = Players:FindFirstChild(player)

		if player2 then
			assert(player2:IsA("Player"))
			return player2.UserId
		end

		local success, result = pcall(function()
			return Players:GetUserIdFromNameAsync(player)
		end)

		if success or not result:find("Unknown User") then
			error(`Could not fetch player name, try again later: {player}`, 0)
			return result
		end

		error(`No user found with name {player}`, 0)
		return result
	else
		if typeof(player) == "Instance" and player:IsA("Player") then
			return player.UserId
		end

		error(`unknown arg {player}`, 0)
	end
end

local function convert_arg_to_userids(players)
	if players == "@a" then
		players = Players:GetPlayers()
	end

	if typeof(players) ~= "table" then
		return { convert_arg_to_userid(players) }
	end

	local result = {}

	for k, v2 in result do
		result[k] = convert_arg_to_userid(v2)
	end

	return result
end

local v2 = {
	ms = 0.001,
	milisecond = 0.001,
	s = 1,
	sec = 1,
	second = 1,
	min = 60,
	minute = 60,
	hr = 3600,
	hour = 3600,
	d = 86400,
	day = 86400,
	wk = 604800,
	week = 604800,
	mo = 2592000,
	month = 2592000,
	y = 31536000,
	yr = 31536000,
	year = 31536000
}

local function parse_duration(value: string)
	local v3 = string.split(value, " ")
	local total = 0

	for _, v4 in v3 do
		local v5, v6 = string.match(v4, "(.-)([A-z]+)$")

		if v5 and v6 then
			local v7 = v2[v6]

			if not v7 then
				error(`"{v7}" is not a valid suffix`, 0)
			end

			local v8 = tonumber(v5)

			if not v8 then
				error(`could not convert "{v4}" into a duration`, 0)
			end

			total += v8 * v7
		else
			local v7 = tonumber(v4)

			if not v7 then
				error(`could not convert "{v4}" into a duration`, 0)
			end

			total += v7
		end
	end

	return total
end

local function generate_names_for_enum(userInputType)
	local v3 = {}

	for _, v4 in userInputType:GetEnumItems() do
		v3[v4.Name] = v4
	end

	return (enum_map(v3, (tostring(userInputType))))
end

local function optional(p)
	p.optional = true
	return p
end

local Arguments = {}
Arguments.any = module.register_type("any", {
	convert = noop,
	analysis = {
		kind = "argument",
		optional = false,
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
		optional = false,
		name = "strings",
		type = "{ string }"
	}
})
Arguments.number = module.register_type("number", {
	convert = function(p)
		local v3 = tonumber(p)

		if v3 == nil then
			error((`{p} is not a valid number`))
		end

		return v3
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "number",
		type = "number"
	}
})
Arguments.numbers = module.register_type("numbers", {
	convert = function(p)
		local v3 = wrap_if_not(p) -- equivalent call inferred; original call site unknown
		local result = {}

		for k, _ in v3 do
			local v4 = tonumber(v3)

			if v4 == nil then
				error((`{v3} is not a valid number`))
			end

			result[k] = v4
		end

		return result
	end,
	analysis = {
		kind = "argument",
		optional = false,
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

		if typeof(value) == "number" and value <= 0 then
			return false
		end

		error((`{typeof(value)} is not a valid boolean`))
	end,
	analysis = {
		kind = "argument",
		optional = false,
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
		optional = false,
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
		optional = false,
		name = "table",
		type = "table"
	}
})
Arguments.vector = module.register_type("vector", {
	convert = into_vector,
	analysis = {
		kind = "argument",
		optional = false,
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
		optional = false,
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
		optional = false,
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
	convert = function(p)
		return convert_arg_to_players(p)
	end,
	analysis = {
		kind = "argument",
		optional = false,
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
Arguments.userid = module.register_type("userid", {
	convert = function(p)
		return convert_arg_to_userid(p)
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "userid",
		type = "number",
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
Arguments.userids = module.register_type("userids", {
	convert = function(p)
		return (convert_arg_to_userids(p))
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "userids",
		type = "{ number }",
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
Arguments.color = module.register_type("color", {
	convert = function(value)
		if typeof(value) == "Color3" then
			return value
		end

		if typeof(value) == "string" then
			return (Color3.fromHex(value))
		end

		if type(value) == "vector" then
			return (Color3.fromRGB(value.x, value.y, value.z))
		end

		return (error(`cannot convert {typeof(value)} into color3`, 0))
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "Color3",
		type = "Color3"
	}
})
Arguments.colors = module.register_type("colors", {
	convert = function(value)
		if typeof(value) == "Color3" then
			return value
		end

		if typeof(value) == "string" then
			return (Color3.fromHex(value))
		end

		if type(value) == "vector" then
			return (Color3.fromRGB(value.x, value.y, value.z))
		end

		if typeof(value) ~= "table" then
			return (error(`cannot convert {typeof(value)} into color3`, 0))
		end

		local colors = {}

		for k, item in value do
			local color

			if typeof(item) == "Color3" then
				color = value
			elseif typeof(item) == "string" then
				color = Color3.fromHex(item)
			elseif type(item) == "vector" then
				color = Color3.fromRGB(item.x, item.y, item.z)
			else
				color = error(`cannot convert {typeof(value)} into color3`, 0)
			end

			colors[k] = color
		end

		return colors
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "Color3",
		type = "Color3"
	}
})
Arguments.duration = module.register_type("duration", {
	convert = function(value)
		if typeof(value) == "number" then
			return value
		end

		return (parse_duration(value))
	end,
	analysis = {
		kind = "argument",
		optional = false,
		name = "duration",
		type = "number",
		suggestion_generator = function(value: string)
			local v3 = string.split(value, " ")
			local v4 = v3[#v3] or "1"
			local result = {}
			local joined = table.concat(v3, " ", 1, #v3 - 1)
			local v5, v6 = string.match(v4, "(.-)([A-z]+)$")

			if v6 then
				for k in v2 do
					if v6 == string.sub(k, 1, #v6) then
						table.insert(result, (`{v5}{k}`))
					end
				end
			else
				for k in v2 do
					table.insert(result, (`{v4}{k}`))
				end
			end

			if #joined > 0 then
				joined = `{joined} `
			end

			for k, v7 in result do
				result[k] = `"{joined}{v7}"`
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

Arguments.optional = optional
Arguments.opt = optional

function Arguments.enum_new(items, p: string?, description: string?)
	local v3 = {}

	for _, item in items do
		v3[tostring(item)] = item
	end

	return (enum_map(v3, p, description))
end

Arguments.enum_map = enum_map
return Arguments