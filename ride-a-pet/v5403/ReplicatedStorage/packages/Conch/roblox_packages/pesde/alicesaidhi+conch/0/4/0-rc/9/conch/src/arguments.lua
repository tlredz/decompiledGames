local Players = game:GetService("Players")
local module = require("./context")
require("../roblox_packages/language")
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

local function normalize_type(p)
	if p.kind == "argument" then
		return p.type
	end

	return p
end

local obtain_type_name

obtain_type_name = function(data)
	if data.kind == "command" then
		return "Command"
	end

	if data.kind == "function" then
		return "Function"
	end

	if data.kind == "intersection" then
		local v = {}

		for _, field in data.fields do
			table.insert(v, obtain_type_name(field))
		end

		return table.concat(v, " & ")
	else
		if data.kind == "literal" then
			return (tostring(data.value))
		end

		if data.kind == "strange" then
			return data.type
		end

		if data.kind == "union" then
			local v = {}

			for _, field in data.fields do
				table.insert(v, obtain_type_name(field))
			end

			return table.concat(v, " | ")
		elseif data.kind == "table" then
			local v = {}

			if data.fields then
				for k, field in data.fields do
					table.insert(v, (`{obtain_type_name(k)} = {obtain_type_name(field)}`))
				end
			end

			if data.indexer and data.value then
				table.insert(v, (`[{obtain_type_name(data.indexer)}] = {obtain_type_name(data.value)}`))
			end

			return (`\{ {table.concat(v, ", ")} }`)
		elseif data.kind == "argument" then
			return data.name
		else
			return "error"
		end
	end
end

local v = {}

local function wrap_type(p, p2: string?, value: string?)
	local v2 = not p and "unknown" or obtain_type_name(p) or "unknown"
	local v3 = {
		kind = "argument",
		name = p2 or v2,
		description = value or "",
		type = p,
		varargs = false
	}
	return function(p3: string?, p4: string?)
		local clone = table.clone(v3)
		clone.name = p3 or clone.name
		clone.description = p4 or clone.description
		return clone
	end
end

local function generate_dynamic_options(p: string, fn, value: string?, p2: string?)
	local v2 = {
		type = value or "enum",
		id = `__enum_{p}`,
		convert = function(p3)
			local v3 = fn()[p3]

			if v3 == nil then
				return error((`could not convert "{tostring(p3)}" into a valid option, expected something like {next(fn())}`))
			end

			return v3
		end,
		match = function(p3)
			local v3 = next(fn())
			return v3 ~= nil and typeof(p3) == typeof(v3)
		end,
		suggestions = function(_)
			local result = {}

			for k, _ in fn() do
				table.insert(result, {
					text = tostring(k),
					display = tostring(k),
					kind = nil,
					metadata = nil
				})
			end

			return result
		end,
		exact_match = function(p3)
			return fn()[p3] ~= nil
		end
	}
	local v3 = {
		kind = "strange",
		type = v2.type,
		id = v2.id,
		convert = v2.convert,
		suggestions = v2.suggestions,
		match = v2.match,
		exact_match = v2.exact_match
	}
	v[v2.id] = v3
	return (wrap_type(v3, value, p2))
end

local v2 = {
	type = "any",
	id = "__any_base",
	convert = nil,
	match = nil,
	suggestions = nil,
	exact_match = nil
}
local any = {
	kind = "strange",
	type = v2.type,
	id = v2.id,
	convert = v2.convert,
	suggestions = v2.suggestions,
	match = v2.match,
	exact_match = v2.exact_match
}
v[v2.id] = any
local v4 = {
	type = "number",
	id = "__number_base",
	convert = function(p)
		local v5 = tonumber(p)

		if not v5 then
			error((`could not convert "{p}" to a number`))
		end

		return v5
	end,
	match = function(value)
		return type(value) == "number"
	end,
	exact_match = nil,
	suggestions = nil
}
local v5 = {
	kind = "strange",
	type = v4.type,
	id = v4.id,
	convert = v4.convert,
	suggestions = v4.suggestions,
	match = v4.match,
	exact_match = v4.exact_match
}
v[v4.id] = v5
local v6 = {
	type = "string",
	id = "__string_base",
	convert = function(p)
		local v7 = tostring(p)

		if not v7 then
			error((`could not convert "{p}" to a string`))
		end

		return v7
	end,
	match = function(value)
		return type(value) == "string"
	end,
	exact_match = nil,
	suggestions = nil
}
local string2 = {
	kind = "strange",
	type = v6.type,
	id = v6.id,
	convert = v6.convert,
	suggestions = v6.suggestions,
	match = v6.match,
	exact_match = v6.exact_match
}
v[v6.id] = string2
local v8 = {
	type = "boolean",
	id = "__boolean_base",
	convert = function(value)
		if typeof(value) == "number" then
			return value ~= 0
		end

		if typeof(value) == "boolean" then
			return value
		end

		return value and true or false
	end,
	match = function(p)
		return type(p) == "boolean"
	end,
	exact_match = nil,
	suggestions = function()
		return {
			{
				kind = "expression",
				text = "true",
				display = "true",
				metadata = nil
			},
			{
				kind = "expression",
				text = "false",
				display = "false",
				metadata = nil
			}
		}
	end
}
local boolean = {
	kind = "strange",
	type = v8.type,
	id = v8.id,
	convert = v8.convert,
	suggestions = v8.suggestions,
	match = v8.match,
	exact_match = v8.exact_match
}
v[v8.id] = boolean
local v10 = {
	type = "vector",
	id = "__vector_base",
	convert = function(value)
		if type(value) == "vector" then
			return value
		end

		if typeof(value) ~= "table" then
			error((`could not convert "{typeof(value)}" into vector`))
			return
		end

		local v11 = rawget(value, 1)
		local v12 = rawget(value, 2)
		local v13 = rawget(value, 3)

		if typeof(v11) == "number" and typeof(v12) == "number" and (typeof(v13) == "number" or v13 == nil) then
			return (vector.create(v11 or 0, v12 or 0, v13 or 0))
		end

		error((`could not convert "{typeof(value)}" into vector`))
	end,
	match = function(value)
		if type(value) == "vector" then
			return true
		end

		if typeof(value) ~= "table" then
			return false
		end

		local v11 = rawget(value, 1)
		local v12 = rawget(value, 2)
		local v13 = rawget(value, 3)

		if typeof(v11) == "number" and typeof(v12) == "number" and (typeof(v13) == "number" or v13 == nil) then
			return true
		end

		return false
	end,
	exact_match = nil,
	suggestions = function()
		return {
			{
				kind = "expression",
				text = "true",
				display = "true",
				metadata = nil
			},
			{
				kind = "expression",
				text = "false",
				display = "false",
				metadata = nil
			}
		}
	end
}
local vector2 = {
	kind = "strange",
	type = v10.type,
	id = v10.id,
	convert = v10.convert,
	suggestions = v10.suggestions,
	match = v10.match,
	exact_match = v10.exact_match
}
v[v10.id] = vector2
local v12 = {
	type = "player",
	id = "__player_base",
	convert = function(player)
		local get_command_context = module.get_command_context()

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
	end,
	match = function(player)
		if not (typeof(player) ~= "number" and typeof(player) ~= "string") then
			return true
		end

		if typeof(player) == "Instance" and player:IsA("Player") then
			return true
		end

		return false
	end,
	exact_match = function(player)
		if player == "@s" then
			return true
		end

		if typeof(player) == "number" then
			return Players:GetPlayerByUserId(player) ~= nil
		end

		if typeof(player) == "string" then
			return Players:FindFirstChild(player) ~= nil
		end

		if typeof(player) == "Instance" and player:IsA("Player") then
			return true
		end

		return false
	end,
	suggestions = function(_)
		local result = {}
		table.insert(result, {
			kind = nil,
			metadata = {
				name = "self",
				description = "Refers to yourself",
				type = "player"
			},
			text = "@s",
			display = "@s (self)"
		})

		for _, v13 in Players:GetPlayers() do
			table.insert(result, {
				kind = nil,
				metadata = nil,
				text = v13.Name,
				display = `{v13.DisplayName} (@{v13.Name})`
			})
		end

		return result
	end
}
local player2 = {
	kind = "strange",
	type = v12.type,
	id = v12.id,
	convert = v12.convert,
	suggestions = v12.suggestions,
	match = v12.match,
	exact_match = v12.exact_match
}
v[v12.id] = player2
local v14 = {
	type = "userid",
	id = "__userid_base",
	convert = function(player)
		local get_command_context = module.get_command_context()

		if player == "@s" then
			return get_command_context and get_command_context.executor.player and get_command_context.executor.player.UserId or error("not executed by a player")
		end

		if typeof(player) == "number" then
			return player
		end

		if typeof(player) == "string" then
			local child = Players:FindFirstChild(player)

			if child then
				return child.UserId
			end

			return (Players:GetUserIdFromNameAsync(player))
		else
			if typeof(player) == "Instance" and player:IsA("Player") then
				return player.UserId
			end

			error((`unknown arg {player}`))
		end
	end,
	match = function(player)
		return typeof(player) == "number" or (typeof(player) == "Instance" and player:IsA("Player") or typeof(player) == "string")
	end,
	exact_match = function(player)
		if not (player ~= "@s" and typeof(player) ~= "number" and typeof(player) ~= "string") then
			return true
		end

		if typeof(player) == "Instance" and player:IsA("Player") then
			return true
		end

		return false
	end,
	suggestions = function(_)
		local result = {}
		table.insert(result, {
			kind = nil,
			metadata = {
				name = "self",
				description = "Refers to yourself",
				type = "player"
			},
			text = "@s",
			display = "@s (self)"
		})

		for _, v15 in Players:GetPlayers() do
			table.insert(result, {
				kind = nil,
				metadata = nil,
				text = v15.Name,
				display = `{v15.DisplayName} (@{v15.Name})`
			})
		end

		return result
	end
}
local userid = {
	kind = "strange",
	type = v14.type,
	id = v14.id,
	convert = v14.convert,
	suggestions = v14.suggestions,
	match = v14.match,
	exact_match = v14.exact_match
}
v[v14.id] = userid
local v16 = {
	type = "Color3",
	id = "__color3_base",
	convert = function(value)
		if type(value) == "vector" then
			return (Color3.fromRGB(value.x, value.y, value.z))
		end

		if typeof(value) == "string" then
			return (Color3.fromHex(value))
		end

		if typeof(value) == "table" and typeof(value[1]) == "number" and typeof(value[2]) == "number" and typeof(value[3]) == "number" then
			return (Color3.fromRGB(value.x, value.y, value.z))
		end

		return (error((`could not convert "{typeof(value)}" into Color3`)))
	end,
	match = function(value)
		if not (type(value) ~= "vector" and typeof(value) ~= "string") then
			return true
		end

		return typeof(value) == "table" and typeof(value[1]) == "number" and typeof(value[2]) == "number" and typeof(value[3]) == "number"
	end,
	exact_match = nil,
	suggestions = nil
}
local color = {
	kind = "strange",
	type = v16.type,
	id = v16.id,
	convert = v16.convert,
	suggestions = v16.suggestions,
	match = v16.match,
	exact_match = v16.exact_match
}
v[v16.id] = color
local v18 = {
	ms = 0.001,
	milisecond = 0.001,
	miliseconds = 0.001,
	s = 1,
	sec = 1,
	second = 1,
	seconds = 1,
	min = 60,
	minute = 60,
	minutes = 60,
	hr = 3600,
	hour = 3600,
	hours = 3600,
	d = 86400,
	day = 86400,
	days = 86400,
	wk = 604800,
	week = 604800,
	weeks = 604800,
	mo = 2592000,
	month = 2592000,
	months = 2592000,
	y = 31536000,
	yr = 31536000,
	year = 31536000,
	years = 31536000
}

local function parse_duration(value)
	if typeof(value) ~= "string" then
		error("cannot parse non string")
	end

	local v19 = string.split(value, " ")
	local total = 0

	for _, v20 in v19 do
		local v21, v22 = string.match(v20, "(.-)[%s]?([A-z]+)$")

		if v21 and v22 then
			local v23 = v18[v22]

			if not v23 then
				error(`"{v23}" is not a valid suffix`, 0)
			end

			local v24 = tonumber(v21)

			if not v24 then
				error(`could not convert "{v20}" into a duration`, 0)
			end

			total += v24 * v23
		else
			local v23 = tonumber(v20)

			if not v23 then
				error(`could not convert "{v20}" into a duration`, 0)
			end

			total += v23
		end
	end

	return total
end

local v19 = {
	type = "number",
	id = "__duration_base",
	convert = function(value)
		if typeof(value) == "number" then
			return value
		end

		return (parse_duration(value))
	end,
	match = function(value)
		return typeof(value) == "string" or typeof(value) == "number"
	end,
	suggestions = function(value: string)
		local v20 = string.split(value:gsub("\"(.*)\"", "%1"), " ")
		local v21 = v20[#v20] or "1"
		local result = {}
		local joined = table.concat(v20, " ", 1, #v20 - 1)
		local v22, v23 = string.match(v21, "(.-)([A-z]+)$")

		if v23 then
			for k in v18 do
				table.insert(result, {
					text = `{v22}{k}`,
					display = `{v22}{k}`
				})
			end
		else
			for k in v18 do
				table.insert(result, {
					text = `{v21}{k}`,
					display = `{v21}{k}`
				})
			end
		end

		if #joined > 0 then
			joined = `{joined} `
		end

		for k, v24 in result do
			result[k] = {
				text = `{joined}{v24.text}`,
				display = `{joined}{v24.display}`
			}
		end

		return result
	end,
	exact_match = nil
}
local duration = {
	kind = "strange",
	type = v19.type,
	id = v19.id,
	convert = v19.convert,
	suggestions = v19.suggestions,
	match = v19.match,
	exact_match = v19.exact_match
}
v[v19.id] = duration

local function pluralize(data, data2)
	local v21 = {
		type = `{data.type}s`,
		id = `__pluralize_{data.id}_native`,
		convert = data.convert and function(list)
			if typeof(list) ~= "table" then
				return { data.convert(list) }
			end

			local result = {}

			for i, v22 in ipairs(list) do
				result[i] = data.convert(v22)
			end

			return result
		end or nil,
		match = {
			kind = "union",
			fields = {
				data,
				{
					kind = "table",
					indexer = v5,
					value = data
				}
			}
		},
		suggestions = {
			kind = "union",
			fields = {
				data,
				{
					kind = "table",
					indexer = v5,
					value = data
				}
			}
		},
		exact_match = nil
	}
	local v22 = {
		kind = "strange",
		type = v21.type,
		id = v21.id,
		convert = v21.convert,
		suggestions = v21.suggestions,
		match = v21.match,
		exact_match = v21.exact_match
	}
	v[v21.id] = v22
	local v23

	if data2 then
		local v24 = {
			type = `{data.type}s`,
			id = `__pluralize_{data.id}`,
			convert = data2.convert,
			match = data2.match,
			suggestions = data2.suggestions,
			exact_match = data2.exact_match
		}
		v23 = {
			kind = "strange",
			type = v24.type,
			id = v24.id,
			convert = v24.convert,
			suggestions = v24.suggestions,
			match = v24.match,
			exact_match = v24.exact_match
		}
		v[v24.id] = v23
	end

	if v23 then
		return {
			kind = "union",
			fields = { v23 or nil, v22 }
		}
	end

	return v22
end

local numbers = pluralize(v5)
local strings = pluralize(string2)
local booleans = pluralize(boolean)
local vectors = pluralize(vector2)
local players2 = pluralize(player2, {
	convert = function(p)
		if p == "@a" then
			return Players:GetPlayers()
		end

		if p ~= "@o" then
			error((`could not convert "{typeof(p)}" into players`))
			return
		end

		local get_command_context = module.get_command_context()

		if get_command_context and get_command_context.executor.player then
			local players = Players:GetPlayers()
			table.remove(players, table.find(players, get_command_context.executor.player))
			return players
		else
			return Players:GetPlayers()
		end
	end,
	suggestions = function(_)
		return {
			{
				kind = nil,
				metadata = {
					name = "all players",
					description = "Refers to all players in the server",
					type = "players"
				},
				text = "@a",
				display = "@a (all)"
			},
			{
				kind = nil,
				metadata = {
					name = "other players",
					description = "Refers to all players except you in the server",
					type = "players"
				},
				text = "@o",
				display = "@o (others)"
			}
		}
	end,
	match = function(value)
		return typeof(value) == "string"
	end,
	exact_match = function(p)
		return p == "@a" or p == "@o"
	end
})
local userids = pluralize(userid, {
	convert = function(p)
		if p ~= "@a" then
			error((`could not convert "{typeof(p)}" into players`))
			return
		end

		local players = Players:GetPlayers()
		local userIds = {}

		for _, player in players do
			table.insert(userIds, player.UserId)
		end

		return userIds
	end,
	suggestions = function(_)
		return {
			{
				kind = nil,
				metadata = {
					name = "all players",
					description = "Refers to all players in the server",
					type = "players"
				},
				text = "@a",
				display = "@a (all)"
			}
		}
	end,
	match = function(value)
		return typeof(value) == "string"
	end,
	exact_match = function(p)
		return p == "@a"
	end
})
local colors = pluralize(color)
local Arguments = {}
Arguments.wrap_type = wrap_type

function Arguments.register_strange_type(data)
	local v28 = {
		kind = "strange",
		type = data.type,
		id = data.id,
		convert = data.convert,
		suggestions = data.suggestions,
		match = data.match,
		exact_match = data.exact_match
	}
	v[data.id] = v28
	return v28
end

function Arguments.get_strange_type(p: string)
	return v[p]
end

Arguments.pluralize = pluralize
Arguments.obtain_type_name = obtain_type_name
Arguments.type = {
	any = any,
	number = v5,
	string = string2,
	boolean = boolean,
	vector = vector2,
	player = player2,
	color = color,
	colors = colors,
	userid = userid,
	userids = userids,
	duration = duration,
	numbers = numbers,
	strings = strings,
	booleans = booleans,
	vectors = vectors,
	players = players2
}
Arguments.args = {
	any = wrap_type(any, "any"),
	number = wrap_type(v5, "number"),
	string = wrap_type(string2, "string"),
	boolean = wrap_type(boolean, "boolean"),
	vector = wrap_type(vector2, "vector"),
	color = wrap_type(color, "Color3"),
	colors = wrap_type(colors, "Color3s"),
	userid = wrap_type(userid, "UserId"),
	userids = wrap_type(userids, "UserIds"),
	duration = wrap_type(duration, "duration"),
	player = wrap_type(player2, "player"),
	players = wrap_type(players2, "players"),
	numbers = wrap_type(numbers, "numbers"),
	strings = wrap_type(strings, "strings"),
	booleans = wrap_type(booleans, "booleans"),
	vectors = wrap_type(vectors, "vectors"),
	enum_from_array = function(p: string, items, p2: string?, p3: string?)
		return (generate_dynamic_options(p, function()
			local result = {}

			for _, item in items do
				result[item] = item
				result[tostring(item)] = item
			end

			return result
		end, p2, p3))
	end,
	enum_from_map = function(p: string, p2, p3: string?, p4: string?)
		return (generate_dynamic_options(p, function()
			return p2
		end, p3, p4))
	end,
	opt = function(data)
		return {
			kind = "argument",
			name = data.name or obtain_type_name(data),
			description = data.description or obtain_type_name(data),
			type = {
				kind = "union",
				fields = {
					{
						kind = "literal",
						value = nil
					},
					data.type or data
				}
			},
			varargs = data.varargs
		}
	end,
	variadic = function(data)
		return {
			kind = "argument",
			name = data.name or obtain_type_name(data),
			description = data.description or obtain_type_name(data),
			type = data.type or data,
			varargs = true
		}
	end,
	struct = function(items, type2, p)
		local types = {}

		for type3, type4 in pairs(items) do
			if type4.kind == "argument" then
				type4 = type4.type
			end

			if type3.kind == "argument" then
				type3 = type3.type
			end

			types[{
				kind = "literal",
				value = type3
			}] = type4
		end

		local indexer

		if type2 and type2.kind == "argument" then
			indexer = type2.type
		else
			indexer = type2
		end

		if p and p.kind == "argument" then
			type2 = p.type
		end

		return {
			kind = "table",
			fields = types,
			indexer = indexer,
			value = type2
		}
	end,
	literal = function(p)
		return {
			kind = "literal",
			value = p
		}
	end,
	union = function(...)
		local types = { ... }

		for k, type2 in types do
			if type2.kind == "argument" then
				type2 = type2.type
			end

			types[k] = type2
		end

		return {
			kind = "union",
			fields = types
		}
	end,
	intersect = function(...)
		local types = { ... }

		for k, type2 in types do
			if type2.kind == "argument" then
				type2 = type2.type
			end

			types[k] = type2
		end

		return {
			kind = "intersect",
			fields = types
		}
	end,
	overload = function(overloads)
		return {
			kind = "overload",
			overloads = overloads
		}
	end,
	dynamic = generate_dynamic_options
}
return Arguments